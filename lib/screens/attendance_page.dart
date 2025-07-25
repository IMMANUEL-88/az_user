import 'package:attendzone_new/helper_functions.dart';
import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/Api.dart';
import '../models/attendance_model.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<AttendanceEntry> _attendanceData = [];
  bool _isLoading = true;
  late DateTime _selectedDate;
  double totalHours = 0;
  double attendancePercentage = 0;
  int _notificationCount = 3;
  String? userId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadId();
  }

  Future<void> _loadId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userid');
    });
    _fetchDataForUser();
  }

  Future<void> _fetchDataForUser() async {
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _attendanceData = await ApiService().fetchAttendanceData(userId!);
      _calculateTotalHoursAndAttendance();
    } catch (e) {
      print('Failed to load data: $e');
      setState(() {
        _attendanceData = [];
        totalHours = 0;
        attendancePercentage = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotalHoursAndAttendance() {
    int selectedMonth = _selectedDate.month;
    int selectedYear = _selectedDate.year;

    List<AttendanceEntry> attendanceForMonth = _attendanceData
        .where((entry) =>
    entry.date.month == selectedMonth && entry.date.year == selectedYear)
        .toList();

    int totalMinutes = attendanceForMonth.fold(0, (sum, entry) {
      if (entry.timeOut.hour >= entry.timeIn.hour) {
        return sum +
            (entry.timeOut.hour - entry.timeIn.hour) * 60 +
            (entry.timeOut.minute - entry.timeIn.minute);
      } else {
        return sum +
            ((24 - entry.timeIn.hour) + entry.timeOut.hour) * 60 +
            (entry.timeOut.minute - entry.timeIn.minute);
      }
    });

    int expectedWorkingMinutes = 8 * 60 * _getTotalWorkingDays(selectedMonth, selectedYear);

    setState(() {
      totalHours = totalMinutes / 60;
      attendancePercentage = (totalMinutes / expectedWorkingMinutes) * 100;
    });
  }

  int _getTotalWorkingDays(int month, int year) {
    int totalDaysInMonth = DateTime(year, month + 1, 0).day;
    int totalWorkingDays = 0;

    for (int i = 1; i <= totalDaysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        totalWorkingDays++;
      }
    }

    return totalWorkingDays;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchDataForUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Attendance History',
          style: GoogleFonts.rubik(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/announcements');
            },
            icon: badges.Badge(
              badgeContent: Text(
                '$_notificationCount',
                style: const TextStyle(color: Colors.white),
              ),
              child: Icon(Iconsax.message, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    onSurface: Theme.of(context).colorScheme.primary,
                  ),
                  textTheme: GoogleFonts.rubikTextTheme(
                    Theme.of(context).textTheme.apply(
                      bodyColor: Theme.of(context).colorScheme.primary,
                      displayColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  onDateChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                    _fetchDataForUser();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceData.isEmpty
                ? _buildAbsentWidget(screenHeight, screenWidth)
                : _buildAttendanceList(screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(double screenWidth, double screenHeight) {
    List<AttendanceEntry> filteredData = _attendanceData
        .where((entry) =>
    entry.date.year == _selectedDate.year &&
        entry.date.month == _selectedDate.month &&
        entry.date.day == _selectedDate.day)
        .toList();

    return filteredData.isNotEmpty
        ? ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final attendanceEntry = filteredData[index];
        String formattedDate = DateFormat('dd/MM/yyyy').format(attendanceEntry.date);

        return Column(
          children: [
            SizedBox(height: screenHeight * .01),
            Container(
              height: screenHeight * 0.21,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * .01),
                  Center(
                    child: Text(
                      'Date: $formattedDate',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * .03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time In: ${attendanceEntry.timeIn.format(context)}',
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * .01),
                        Text(
                          'Time Out: ${attendanceEntry.timeOut.format(context)}',
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * .03),
                        Text(
                          'Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%',
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    )
        : _buildAbsentWidget(screenHeight, screenWidth);
  }

  Widget _buildAbsentWidget(double screenHeight, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: screenHeight * 0.19,
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'No attendance data found for this date',
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }
}
