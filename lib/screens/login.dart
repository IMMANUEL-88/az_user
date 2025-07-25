import 'package:attendzone_new/auth/facedetectionview.dart';
import 'package:attendzone_new/constants/image_strings.dart';
import 'package:attendzone_new/constants/sizes.dart';
import 'package:attendzone_new/helper_functions.dart';
import 'package:attendzone_new/popups/fullscreen_loaders.dart';
import 'package:attendzone_new/screens/home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typewritertext/typewritertext.dart';
import '../Api/Api.dart';
import '../auth/FDF.dart';
import '../auth/person.dart';
import '../models/attendance_model.dart';

TextEditingController usr = TextEditingController();
TextEditingController pass = TextEditingController();
TextEditingController usrid = TextEditingController();
double attendancePercentage = 0;
int attendancePercent = 0;

Future<void> requestCameraPermission() async {
  // Check if camera permission is granted
  PermissionStatus status = await Permission.camera.status;

  if (status.isDenied) {
    // If permission is denied, request it
    status = await Permission.camera.request();
  }

  if (status.isDenied) {
    // If permission is still denied, show a message or handle accordingly
  } else if (status.isGranted) {
    // Permission is granted, you can proceed with using the camera
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List<AttendanceEntry> _attendanceData = [];
  bool _isLoading = true;
  late final DateTime _selectedDate = DateTime.now();
  bool isObscure = true;
  double totalHours = 0;

  Future<void> _fetchDataForUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _attendanceData = await ApiService().fetchAttendanceData(usrid.text);
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
  Widget build(BuildContext context) {
    final dark = EHelperFunctions.isDarkMode(context);
    final width = MediaQuery.of(context).size.width;
    var usridEM = "Enter UserID";
    var passEM = "Enter Password";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: SingleChildScrollView(
        child: Container(
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.onSurface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * .10,
              ),
              SizedBox(
                  height: EHelperFunctions.screenHeight(context) * .20,
                  width: EHelperFunctions.screenWidth(context) * .45,
                  child: Column(
                    children: [
                      dark
                          ? Image.asset(EImages.darkAppLogo)
                          : Image.asset(EImages.lightAppLogo),
                      Text(
                        'A T T E N D Z O N E',
                        style: GoogleFonts.rubik(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )),
              Row(
                children: [
                  SizedBox(
                    width: EHelperFunctions.screenWidth(context) * .05,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: GoogleFonts.rubik(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: EHelperFunctions.screenHeight(context) * .025,
                        width: EHelperFunctions.screenWidth(context) * .785,
                        child: TypeWriter.text(
                          "Keep track of your attendance effortlessly",
                          maintainSize: true,
                          maxLines: 1,
                          // Ensure text is constrained to one line
                          overflow: TextOverflow.ellipsis,
                          // Use ellipsis for overflow
                          textAlign: TextAlign.left,
                          // Align text to the left
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          duration: const Duration(milliseconds: 50),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(ESizes.spaceBtwSections),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Login",
                      style: GoogleFonts.rubik(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: ESizes.spaceBtwInputFields,
                    ),
                    TextField(
                      controller: usrid,
                      style: GoogleFonts.poppins(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: 'Userid',
                        hintStyle: GoogleFonts.rubik(color: Colors.grey),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(
                      height: ESizes.spaceBtwInputFields,
                    ),
                    TextField(
                      controller: pass,
                      style: GoogleFonts.poppins(color: Colors.black),
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,  // Toggle visibility
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            // Add logic to toggle the visibility of the password
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        prefixIcon: Icon(MdiIcons.lock, color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: EHelperFunctions.screenWidth(context) * .45,
                        ),
                        TextButton(
                            onPressed: () async {},
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.rubik(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: EHelperFunctions.screenHeight(context) * .03,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await requestCameraPermission();
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: Image.asset(EImages.gearLoadingLogo),
                              );
                            },
                          );

                          // Validate user inputs
                          if (usrid.text.isEmpty) {
                            context.pop();
                            EHelperFunctions.showSnackBar(context, usridEM);
                            return;
                          }

                          if (pass.text.isEmpty) {
                            context.pop(); // Dismiss the dialog
                            EHelperFunctions.showSnackBar(context, passEM);
                            return;
                          }

                          // Check internet connectivity
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
                            context.pop(); // Dismiss the dialog
                            EHelperFunctions.showSnackBar(
                                context, 'No internet connection');
                            return;
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));

                          // Perform login
                          // bool login = await Api().login(usrid.text, pass.text);
                          // if (login) {
                          //   print('successful');
                          //   await _fetchDataForUser();
                          //   await _calculateTotalHoursandattendance();

                          //   // Ensure keyboard is dismissed only after a successful login
                          //   // FocusScope.of(context).unfocus();

                          //   // Check user existence and handle accordingly
                          //   bool isExist = await Atten()
                          //       .checkUserIdExists(usrid.text.toString());
                          //   context.pop(); // Dismiss the dialog

                          //     if (isExist ) {
                          //       FocusScope.of(context).unfocus();
                          //       EFullScreenLoader.openLoadingDialog(
                          //           'Loading...', context);
                          //       // Wait before stopping the loader and navigating
                          //       Future.delayed(const Duration(seconds: 5), () {
                          //         FocusScope.of(context).unfocus();
                          //         EFullScreenLoader.stopLoading(context);
                          //         setState(() {
                          //           pass.clear(); // Clear the password field
                          //         });
                          //         // FocusScope.of(context).unfocus(); // Ensure keyboard is dismissed
                          //         context.pushReplacement('/home');
                          //       });
                          //     } else {
                          //       FocusScope.of(context).unfocus();
                          //       EFullScreenLoader.openLoadingDialog(
                          //           'Loading...', context);
                          //       // Wait before stopping the loader and proceeding
                          //       Future.delayed(const Duration(seconds: 4),
                          //           () async {
                          //         FocusScope.of(context).unfocus();
                          //         EFullScreenLoader.stopLoading(context);
                          //         // Initialize face detection
                          //        // FaceDect().initFDF();
                          //        // List<Person> personList =
                          //          //   await FaceDect().enrollPerson();

                          //         // if (personList.isNotEmpty) {
                          //         //   Navigator.push(
                          //         //     context,
                          //         //     MaterialPageRoute(
                          //         //       builder: (context) =>
                          //         //           FaceRecognitionView(
                          //         //         personList: personList,
                          //         //       ),
                          //         //     ),
                          //         //   );
                          //         // }
                          //             Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
                          //       });
                          //     }

                          // } else if (globalMessage =='Invalid IP'){
                          //   context.pop(); // Dismiss the dialog
                          //   showDialog(
                          //     context: context,
                          //     builder: (context) {
                          //       return Theme(
                          //         data: Theme.of(context).copyWith(
                          //           dialogBackgroundColor: Theme.of(context)
                          //               .colorScheme
                          //               .surfaceContainer,
                          //         ),
                          //         child: AlertDialog(
                          //           icon: SizedBox(
                          //             height:
                          //             EHelperFunctions.screenHeight(context) *
                          //                 .1,
                          //             child: Image.asset(EImages.ipAppLogo),
                          //           ),
                          //           title: Text(
                          //             '$globalMessage',
                          //             style: GoogleFonts.rubik(
                          //               color:
                          //               Theme.of(context).colorScheme.primary,
                          //             ),
                          //           ),
                          //           content: Text(
                          //             'Please connect to a valid network',
                          //             style: GoogleFonts.rubik(
                          //               color:
                          //               Theme.of(context).colorScheme.primary,
                          //             ),
                          //           ),
                          //           actions: [
                          //             SizedBox(
                          //               width: double.infinity,
                          //               child: ElevatedButton(
                          //                 onPressed: () {
                          //                   Navigator.of(context).pop();
                          //                 },
                          //                 child: const Text('Retry'),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       );
                          //     },
                          //   );
                          //   throw Exception('Login failed');
                          // }
                          // else{
                          //   context.pop();
                          //   EHelperFunctions.showSnackBar(context, globalMessage);
                          // }
                        } catch (e) {
                          context.pop(); // Dismiss the dialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                ),
                                child: AlertDialog(
                                  icon: SizedBox(
                                    height:
                                        EHelperFunctions.screenHeight(context) *
                                            .1,
                                    child: Image.asset(EImages.ipAppLogo),
                                  ),
                                  title: Text(
                                    e.toString(),
                                    style: GoogleFonts.rubik(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  content: Text(
                                    'Please connect to internet',
                                    style: GoogleFonts.rubik(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  actions: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: Center(
                        child: Text(
                          "Login",
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .11,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.faceAgent,
                    color: Colors.grey,
                  ),
                  Text(
                    'for support contact @it.attendzone@gmail.com',
                    style: GoogleFonts.rubik(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
