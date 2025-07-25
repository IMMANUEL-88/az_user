import 'dart:convert';
import 'dart:typed_data';
import 'package:attendzone_new/auth/FDF.dart';
import 'package:attendzone_new/auth/person.dart';
import 'package:attendzone_new/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/Api.dart';
import '../Api/chatApi.dart';
import '../auth/facedetectionview.dart';
import '../popups/fullscreen_loaders.dart';
import 'Projects.dart';
import 'attendance_page.dart';
import 'dashboard.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  String? Email;
  String? usrName;
  List<int> profileBytes = [];

  @override
  void initState() {
    super.initState();
    _check();
    _loadProfileData();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Email = prefs.getString('email');
      usrName = prefs.getString('username');
      String? base64Profile = prefs.getString('profile');
      profileBytes = base64Profile != null ? base64Decode(base64Profile) : [];
    });

    if (Email != null) {
      _fetchChatMessages();
    }
  }

  Future<void> _check() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userid = prefs.getString('userid');
      final String? dbIP = prefs.getString('dip');
      final String ip = await Api().userIpAddress();

      if (userid != null) {
        await Api().fetchIP(userid);
        final bool isExist = await Atten().checkUserIdExists(userid);

        EFullScreenLoader.openLoadingDialog('Loading...', context);

        if (isExist) {
          await Future.delayed(const Duration(seconds: 2));
          EFullScreenLoader.stopLoading(context);
        } else {
          await Future.delayed(const Duration(seconds: 4));
          EFullScreenLoader.stopLoading(context);

          if (dbIP == ip) {
            // EHelperFunctions.showSnackBar(context, 'Initializing face detection');
            // FaceDect().initFDF();
            // final List<Person> personList = await FaceDect().enrollPerson();
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
            EHelperFunctions.showSnackBar(context, 'IP invalid');
          }
        }
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _fetchChatMessages() async {
    if (Email != null) {
      try {
        await Chat.getChatMessages(Email!);
      } catch (e) {
        print('Error fetching chat messages: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const <Widget>[
          MyHomePage(title: ''),
          Projects(),
          AttendancePage(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.briefcase, size: 26),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar_1, size: 26),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange),
                  ),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: profileBytes.isNotEmpty
                        ? MemoryImage(Uint8List.fromList(profileBytes))
                        : const AssetImage('assets/images/personImg.png') as ImageProvider, // Handle default profile image or fallback
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

