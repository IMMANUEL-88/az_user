import 'dart:convert';
import 'dart:typed_data';
import 'package:attendzone_new/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/Api.dart';
import '../utils/appbar.dart';
import '../helper_functions.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  String? email;
  String? userName;
  List<int> profileBytes = [];

  @override
  void initState() {
    _loadProfileData();
    super.initState();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Loading profile data...');
    setState(() {
      email = prefs.getString('email');
      userName = prefs.getString('username');
      String? base64Profile = prefs.getString('profile');
      print('Email: $email');
      print('Username: $userName');
      if (base64Profile != null) {
        try {
          profileBytes = base64Decode(base64Profile);
          print('Profile loaded successfully');
        } catch (e) {
          print('Error decoding base64 profile: $e');
          profileBytes = [];
        }
      } else {
        print('No profile data found');
        profileBytes = [];
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Profile',
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
            icon: Icon(
              Iconsax.setting,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: EHelperFunctions.screenHeight(context) * .25,
                  width: EHelperFunctions.screenWidth(context) * .35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.0, // Outer border width
                    ),
                  ),
                ),
                Container(
                  height: EHelperFunctions.screenHeight(context) * .30,
                  width: EHelperFunctions.screenWidth(context) * .30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0, // Inner border width
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileBytes.isNotEmpty
                      ? MemoryImage(Uint8List.fromList(profileBytes))
                      : null,
                  backgroundColor:
                  profileBytes.isEmpty ? Colors.grey[200] : Colors.transparent, // Provide default color if profile is empty
                ),
              ],
            ),
          ),
          Container(
            width: EHelperFunctions.screenWidth(context) * .8,
            child: Column(
              children: [
                TF(
                  hintText: userName ?? 'Username not available',
                  icon: Icon(Icons.person),
                ),
                SizedBox(height: 20),
                TF(
                  hintText: email ?? 'Email not available',
                  icon: Icon(MdiIcons.email),
                ),
                SizedBox(height: 20),
                TF(
                  hintText: 'Developer',
                  icon: Icon(Icons.military_tech_sharp),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: EHelperFunctions.screenHeight(context) * .15,
            width: EHelperFunctions.screenWidth(context) * .8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Column(),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: EHelperFunctions.screenWidth(context) * .8,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                      icon: Icon(
                        MdiIcons.exitToApp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        'Do you want to exit?',
                        style: GoogleFonts.rubik(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .25,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child:
                                Text('Cancel', style: GoogleFonts.rubik()),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .25,
                              child: ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  Navigator.of(context).pop();
                                  context.go('/');
                                },
                                child: Text('Yes', style: GoogleFonts.rubik()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                elevation: 0,
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: const BorderSide(color: Colors.orangeAccent),
                textStyle: GoogleFonts.rubik(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class TF extends StatelessWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const TF({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: false,
      style: GoogleFonts.rubik(color: Theme.of(context).colorScheme.primary),
      decoration: InputDecoration(
        prefixIcon: icon,
        prefixIconColor: Theme.of(context).colorScheme.primary,
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        filled: true,
        hintStyle: GoogleFonts.rubik(
          color: Theme.of(context).colorScheme.primary,
        ),
        labelText: hintText,
        labelStyle: GoogleFonts.rubik(
          color: Theme.of(context).colorScheme.primary,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
