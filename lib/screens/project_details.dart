import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Add intl package for date formatting
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class Project_Details extends StatelessWidget {
  final String projectName;
  final String statusName;
  final double completionPercentage;
  final String Link;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tasks;

  const Project_Details({super.key, 
    required this.projectName,
    required this.statusName,
    required this.completionPercentage,
    required this.Link,
    this.priority,
    this.startDate,
    this.endDate,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text('Project Details', style: GoogleFonts.rubik(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'Name:',
                style: GoogleFonts.rubik(
            color: Theme.of(context).colorScheme.primary
          ),
                ),
                Text(projectName, style: GoogleFonts.rubik(
                    color: Theme.of(context).colorScheme.primary
                ),),
                const SizedBox(height: 10),

                _buildDetailRow('Status:', statusName, context),
                _buildDetailRow('Completion:',
                    '${(completionPercentage * 100).toStringAsFixed(2)}%', context),
                _buildDetailRow('Priority:', priority ?? 'N/A', context),
                _buildDetailRow('Start Date:', _formatDate(startDate),context),
                _buildDetailRow('End Date:', _formatDate(endDate),context),
                IconButton(onPressed: () async{
                  print(Link);
                  final Uri url = Uri.parse(Link);
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                }, icon: FaIcon(FontAwesomeIcons.github, color: Colors.white,)),
                const SizedBox(height: 10),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: tasks.length,
                //     itemBuilder: (context, index) {
                //       return ListTile(
                //         title: Text(tasks[index]),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.rubik(
              color: Theme.of(context).colorScheme.primary
          ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: GoogleFonts.rubik(
                color: Theme.of(context).colorScheme.primary
            ),),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
