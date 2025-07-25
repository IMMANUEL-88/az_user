import 'package:attendzone_new/Api/Api.dart';
import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;
import '../Api/notionApi.dart';
import '../helper_functions.dart';
import '../models/project_model.dart';
import 'project_details.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  late Future<List<Project_model>> _fetchProjectsFuture;
  int _notificationCount = 3;
  String? Email;


  Future<List<Project_model>> fetchProjects() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return fetchNotionPages(); // Fetch actual data using the API
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectsFuture = fetchProjects(); // Initialize the future for fetching projects
    _loadEmail(); // Load email asynchronously
  }

  Future<void> _loadEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Email = prefs.getString('email');
    });
  }

  Widget buildShimmerEffect(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        // Separator height
        itemCount: 6,
        // Number of shimmer items to show
        itemBuilder: (_, __) => Column(
          children: [
            SizedBox(height: EHelperFunctions.screenHeight(context)*.01,),
            Container(
              width: screenWidth * .95,
              height: screenWidth * .35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surfaceContainer),
            ),
            SizedBox(height: EHelperFunctions.screenHeight(context)*.01,),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final dark = EHelperFunctions.isDarkMode(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Projects',
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
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Iconsax.message, color: Theme.of(context).colorScheme.primary,),
            ),),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: LiquidPullToRefresh(
          animSpeedFactor: 1,
          color: Colors.orange,
          onRefresh: () async {
            setState(() {
              _fetchProjectsFuture = fetchProjects(); // Refresh the data
            });
          },
          child: FutureBuilder<List<Project_model>>(
            future: _fetchProjectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildShimmerEffect(context);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<Project_model> projects = snapshot.data ?? [];
                return ListView.builder(

                  // padding: const EdgeInsets.symmetric(vertical: 8.0),
                  // // Add padding for equal spacing
                  // separatorBuilder: (_,__) => const SizedBox(height: 8),
                  // // Separator height
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    Project_model project = projects[index];
                    return Visibility(
                      visible: project.assignees.contains(Email!),
                      // Filter projects by assignee email
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Project_Details(
                                projectName: project.projectName,
                                statusName: project.statusName,
                                Link: project.link,
                                completionPercentage:
                                    project.completionPercentage,
                                priority: project.priority,
                                startDate: project.startDate,
                                endDate: project.endDate,
                                tasks: project.tasks,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            SizedBox(height: EHelperFunctions.screenHeight(context)*.01,),
                            Container(
                              height: screenWidth * .35,
                              width: screenWidth * .95,
                              // padding: const EdgeInsets.symmetric(vertical: 8.0),
                              // Add padding for equal spacing
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF000000),
                                    offset: Offset.fromDirection(20, 2),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:
                                        EHelperFunctions.screenWidth(context) * .03,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircularPercentIndicator(
                                          radius: 30.0,
                                          animation: true,
                                          animationDuration: 1200,
                                          lineWidth: 8.0,
                                          percent: project.completionPercentage,
                                          circularStrokeCap: CircularStrokeCap.butt,
                                          fillColor: Theme.of(context).colorScheme.surfaceContainer,
                                          progressColor: Colors.orange,
                                        ),
                                        SizedBox(
                                          width: EHelperFunctions.screenWidth(
                                                  context) *
                                              .03,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            // Center vertically within the row
                                            child: Text(
                                              project.projectName,
                                              style: GoogleFonts.rubik(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: EHelperFunctions.screenHeight(context)*.13,),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color:
                                              getCompletionColor(project.priority),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            project.priority ?? 'Not Set',
                                            style: GoogleFonts.rubik(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(width: 13),

                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: EHelperFunctions.screenHeight(context)*.01,),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// Color functions and Project_model class remain the same as in the original code

Color getCompletionColor(String? category) {
  switch (category) {
    case 'High':
      return Colors.red.shade400;
    case 'Low':
      return Colors.green.shade400;
    case 'Medium':
      return Colors.orange.shade400;
    case 'General':
      return Colors.blue.shade400;
    default:
      return Colors.black;
  }
}

Color getStatusColor(String? category, BuildContext context) {
  switch (category) {
    case 'Dropped':
      return Colors.red.shade400;
    case 'Done':
      return Colors.green.shade400;
    case 'Requested':
      return Colors.orange.shade400;
    case 'In progress':
      return Colors.blue.shade400;
    default:
      return Theme.of(context).colorScheme.primary;
  }
}
