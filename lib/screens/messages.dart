import 'dart:convert';
import 'package:attendzone_new/helper_functions.dart';
import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/Api.dart';
import '../Api/notionApi.dart';
import '../models/project_model.dart';
import 'chat.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late Future<List<Project_model>> _fetchProjectsFuture;
  late List<Map<String, dynamic>> _announcements;
  String? Email;

  @override
  void initState() {
    super.initState();
    _fetchProjectsFuture = fetchProjects(); // Initialize the future
    _loadEmail();
    _announcements = []; // Initialize announcements
    _fetchAnnouncements();
  }

  Future<void> _loadEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Email = prefs.getString('email');
    });
  }

  Future<void> _fetchAnnouncements() async {
    Future<List<Map<String, dynamic>>> getPreviousAnnouncements() async {
      try {
        String? authToken = await Get().getToken();
        const String apiUrl =
            'https://attendzone-backend.onrender.com/api/v1/announcements';
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': authToken!,
          },
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data
              .map((item) => {
                    'message': item['message'],
                    'date': item['date'],
                    'time': item['time']
                  })
              .toList();
        } else {
          throw Exception('Failed to load previous announcements');
        }
      } catch (e) {
        throw Exception('Error fetching previous announcements: $e');
      }
    }

    try {
      List<Map<String, dynamic>> messages = await getPreviousAnnouncements();
      setState(() {
        _announcements = messages;
      });
    } catch (e) {
      print('Failed to fetch announcements: $e');
    }
  }

  Future<List<Project_model>> fetchProjects() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return fetchNotionPages(); // Fetch actual data using the API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.rubik(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: EHelperFunctions.screenHeight(context) * .03),
          Center(
            child: _announcements.isEmpty
                ? Container(
                    height: EHelperFunctions.screenHeight(context) * .15,
                    width: EHelperFunctions.screenWidth(context) * .9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: EHelperFunctions.screenHeight(context) * .025,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  EHelperFunctions.screenWidth(context) * .025,
                            ),
                            SizedBox(
                              height:
                                  EHelperFunctions.screenHeight(context) * .1,
                              width:
                                  EHelperFunctions.screenWidth(context) * .18,
                              child: Image.asset(
                                  'assets/images/anouncementImage.png'),
                            ),
                            SizedBox(
                              width:
                                  EHelperFunctions.screenWidth(context) * .025,
                            ),
                            Text(
                              'No Announcements',
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: EHelperFunctions.screenHeight(context) * .15,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _announcements.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = _announcements.length - 1 - index;
                        final announcement = _announcements[reversedIndex];
                        final time = formatTimeOfDay(announcement['time']);
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  content: Text(
                                    announcement['message'],
                                    style: GoogleFonts.rubik(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: EHelperFunctions.screenWidth(context) * .9,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height:
                                      EHelperFunctions.screenHeight(context) *
                                          .025,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: EHelperFunctions.screenWidth(
                                              context) *
                                          .025,
                                    ),
                                    SizedBox(
                                      height: EHelperFunctions.screenHeight(
                                              context) *
                                          .1,
                                      width: EHelperFunctions.screenWidth(
                                              context) *
                                          .18,
                                      child: Image.asset(
                                          'assets/images/anouncementImage.png'),
                                    ),
                                    SizedBox(
                                      width: EHelperFunctions.screenWidth(
                                              context) *
                                          .025,
                                    ),
                                    Expanded(
                                      child: Text(
                                        announcement['message'],
                                        style: GoogleFonts.rubik(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      children: [
                                        Text(
                                          time,
                                          style: GoogleFonts.rubik(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          SizedBox(height: EHelperFunctions.screenHeight(context) * .05),
          Row(
            children: [
              SizedBox(width: EHelperFunctions.screenWidth(context) * .03),
              Text(
                'Messages',
                style: GoogleFonts.rubik(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: EHelperFunctions.screenHeight(context) * .02),
          Expanded(
            child: FutureBuilder<List<Project_model>>(
              future: _fetchProjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Loading indicator
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  List<Project_model> projects = snapshot.data!;
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      Project_model project = projects[index];
                      return Visibility(
                        visible: project.assignees.contains(Email!),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push('/Chat',
                                    extra: ChatPage(
                                        sender: Email!,
                                        projectName: project.projectName));
                              },
                              child: Container(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: EHelperFunctions.screenWidth(
                                                context) *
                                            .025,
                                      ),
                                      SizedBox(
                                        height: EHelperFunctions.screenHeight(
                                                context) *
                                            .085,
                                        width: EHelperFunctions.screenWidth(
                                                context) *
                                            .16,
                                        child: Image.asset(
                                            'assets/images/personImg.png'),
                                      ),
                                      SizedBox(
                                        width: EHelperFunctions.screenWidth(
                                                context) *
                                            .025,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: EHelperFunctions.screenWidth(
                                                    context) *
                                                .5,
                                            child: Text(
                                              project.projectName,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.rubik(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'New message',
                                            style: GoogleFonts.rubik(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.camera_alt_outlined,
                                          size: 30),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No projects found'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatTimeOfDay(String time) {
    // Assuming the time is in the format "HH:mm:ss" (24-hour format)
    try {
      final timeParts = time.split(':');
      final int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      // Convert hour to 12-hour format
      final period = hour >= 12 ? 'PM' : 'AM';
      final adjustedHour = hour % 12 == 0 ? 12 : hour % 12;

      return '$adjustedHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Failed to format time: $e');
      return time; // Return the original time if formatting fails
    }
  }
}
