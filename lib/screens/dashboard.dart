
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:attendzone_new/helper_functions.dart';
import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badges;
import '../Api/Api.dart';
import '../Api/notionApi.dart';
import '../auth/FDF.dart';
import '../auth/FDforout.dart';
import '../auth/person.dart';
import '../models/attendance_model.dart';
import '../models/task_model.dart';
import '../utils/taskCard.dart';
import 'Projects.dart';
import 'login.dart';

List<Task_model> tasks = [];


String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

DateTime now = DateTime.now();
String date_now = formatDate(now);

class MyHomePage extends StatefulWidget {
  final String title;


  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Task_model>> _fetchTasksFuture;
  late Future<void> _getAttenFuture;
  int _notificationCount = 3;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? usrName;
  String? email;
  String? timeIn;
  String? userId;
  String? dbIp;
  String? firstName;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _fetchTasksFuture = fetchTasks(); // Ensure fetchTasks is defined
    _getAttenFuture = _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userid');

    if (userId != null) {
      print('Loading profile data...');
      setState(() {
        email = prefs.getString('email');
        usrName = prefs.getString('username');
        dbIp = prefs.getString('dip');
        _getAttenFuture = Atten().getAttendance('$userId', DateFormat('yyyy-MM-dd').format(DateTime.now()));
        timeIn = prefs.getString('time_in');
      });
      await _fetchDataForUser();
      await _calculateTotalHoursandattendance();
      if (usrName != null && usrName!.isNotEmpty) {
        List<String> nameParts = usrName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
      }
    }
  }
  List<AttendanceEntry> _attendanceData = [];
  bool _isLoading = true;
  late final DateTime _selectedDate = DateTime.now();
  double totalHours = 0;

  Future<void> _fetchDataForUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _attendanceData = await ApiService().fetchAttendanceData(userId!);
      await _calculateTotalHoursandattendance(); // Await the calculation
    } catch (e) {
      print('Failed to load data: $e');
      _attendanceData = [];
      totalHours = 0;
      attendancePercentage = 0;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _calculateTotalHoursandattendance() async {
    // Extract the month and year from the selected date
    int selectedMonth = _selectedDate.month;
    int selectedYear = _selectedDate.year;

    // Filter the attendance entries for the selected month and year
    List<AttendanceEntry> attendanceForMonth = _attendanceData
        .where((entry) =>
    entry.date.month == selectedMonth &&
        entry.date.year == selectedYear)
        .toList();

    // Calculate the total working minutes for the month
    int totalMinutes = attendanceForMonth.fold(0, (sum, entry) {
      if (entry.timeOut.hour >= entry.timeIn.hour) {
        return sum +
            (entry.timeOut.hour - entry.timeIn.hour) * 60 +
            (entry.timeOut.minute - entry.timeIn.minute);
      } else {
        // Handle cases where timeOut is on the next day
        return sum +
            ((24 - entry.timeIn.hour) + entry.timeOut.hour) * 60 +
            (entry.timeOut.minute - entry.timeIn.minute);
      }
    });

    // Calculate the expected working minutes for the month
    int expectedWorkingMinutes = 8 *
        60 *
        _getTotalWorkingDays(
            selectedMonth, selectedYear); // Assuming 8 hours per day

    // Calculate the attendance percentage
    setState(() {
      totalHours = totalMinutes / 60;
      attendancePercentage = (totalMinutes / expectedWorkingMinutes);
      attendancePercent = attendancePercentage.toInt();
    });
  }

  int _getTotalWorkingDays(int month, int year) {
    int totalDaysInMonth = DateTime(year, month + 1, 0).day;
    int totalWorkingDays = 0;
    for (int i = 1; i <= totalDaysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        totalWorkingDays++;
      }
    }
    return totalWorkingDays;
  }


  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }

  Future<List<Task_model>> fetchTasks() async {
    try {
      List<Task_model> fetchedTasks = await fetchNotionTasks();
      if (fetchedTasks.isEmpty) {
        await fetchNotionTasks();
      }
      return fetchedTasks;
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.rubik(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.push('/announcements');
              },
              icon: badges.Badge(
                badgeContent: Text(
                  '$_notificationCount',
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Iconsax.message, color: Theme.of(context).colorScheme.primary,),
              ),),
        ],
      ),
      body: LiquidPullToRefresh(
        animSpeedFactor: 1,
        color: Colors.orange,
        onRefresh: () async {
          // Load profile data asynchronously
          await _loadProfileData();

          // Update the tasks and ensure it's fetched before proceeding
          setState(() {
            _fetchTasksFuture = fetchTasks();
          });

          // Wait for task fetching to complete before refreshing
          await _fetchTasksFuture;

          // Optionally navigate to '/home' after the refresh is complete
          context.go('/home');

          // Return a completed future to indicate the refresh is done
          return Future.value();
        },
        child: ListView(
          children: [
            SizedBox(height: EHelperFunctions.screenHeight(context) * .07),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: EHelperFunctions.screenWidth(context) * .1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName',
                      style: GoogleFonts.rubik(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 26
                      ),
                    ),
                    Text(
                      '$email',
                      style: GoogleFonts.rubik(
                          color: Theme.of(context).colorScheme.primary),
                    )
                  ],
                ),
                SizedBox(width: EHelperFunctions.screenWidth(context) * .25),
                CircularPercentIndicator(
                  radius: 31.0,
                  animation: true,
                  animationDuration: 1200,
                  lineWidth: 6.0,
                  percent: attendancePercentage,
                  center: Text(
                    '${(attendancePercentage * 100).round()}%',
                    style: GoogleFonts.rubik(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  fillColor: Colors.transparent,
                  progressColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: EHelperFunctions.screenHeight(context) * .1),
            SizedBox(
              height: screenHeight * 0.2957,
              child: FutureBuilder<List<Task_model>>(
                future: _fetchTasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildShimmerEffect(context);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No tasks found.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _fetchTasksFuture = fetchTasks();
                              });
                            },
                            child: Text(
                              'Refresh',
                              style: GoogleFonts.rubik(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  tasks = snapshot.data!
                      .where((task) =>
                  task.statusName == 'In progress' &&
                      task.email == (email))
                      .toList();

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                         tasks =tasks;
                        _fetchTasksFuture = fetchTasks();
                      });
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: tasks.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(task: task,);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 5,
              // child: PageIndicator(
              //   currentPage: _currentPage,
              //   pageCount: tasks.length,
              // ),
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: tasks.length,
                  effect: const WormEffect(
                    activeDotColor: Colors.orange,
                    dotHeight: 5,
                    dotWidth: 10,
                    type: WormType.thinUnderground,
                  ),
                ),
              ),
            ),
            SizedBox(height: EHelperFunctions.screenHeight(context)*.1,),
            Container(
              child: Row(
                children: [
                  SizedBox(width: EHelperFunctions.screenWidth(context)*.10,),
                  Column(
                    children: [
                      Text(
                        'IN TIME:',
                        style: GoogleFonts.rubik(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder<void>(
                        future: _getAttenFuture, // The future that retrieves attendance or relevant data
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // return const CircularProgressIndicator(); // Show a loading indicator
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.rubik(color: Theme.of(context).colorScheme.error),
                            );
                          } else {
                            // Assuming 'timeIn' is fetched and you're showing the 'IN TIME' label
                            return Text(
                              timeIn ?? 'N/A', // Show 'N/A' if timeIn is null
                              style: GoogleFonts.rubik(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: EHelperFunctions.screenWidth(context)*.4,),
                  SizedBox(
                    width: EHelperFunctions.screenWidth(context)*.25,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.orange,
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        print('DB IP: $dbIp');
                        await requestCameraPermission();
                        await Api().fetchIP('$userId');
                        String uip = await Api().userIpAddress();
                        String dip = dbIp!;
                        if (uip == dip) {
                          // FaceDect().initFDF();
                          // List<Person> personList = await FaceDect().enrollPerson();
                          // if (personList.isNotEmpty) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => FaceRecognitionView(
                          //         personList: personList,
                          //       ),
                          //     ),
                          //   );
                          // }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("IP invalid"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Check-Out",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEffect(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 17,
                ),
                Container(
                  width: screenWidth * .913,
                  height: screenHeight * 0.2685,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
  Widget buildShimmerForInTime(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Container(
              height: 30,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


