import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Api/notionApi.dart';
import '../models/task_model.dart';

class TaskCard extends StatefulWidget {
  final Task_model task;

  TaskCard({required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Future<List<Task_model>> _fetchTasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasksFuture = fetchTasks();
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

  Color getCompletionColor(String priority) {
    // Define colors based on priority here
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String statusName, BuildContext context) {
    // Define colors based on status here
    switch (statusName) {
      case 'Done':
        return Colors.green;
      case 'In progress':
        return Colors.blue;
      case 'Not started':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final task = widget.task;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenWidth * .02),
            Row(
              children: [
                SizedBox(width: screenWidth * .02),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Task: ${task.taskName}',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              width: 360,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 2, 0),
                child: SingleChildScrollView(
                  child: Text(task.Description),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(190, 5, 0, 0),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    color: getCompletionColor('${task.priority}'),
                  ),
                  SizedBox(width: screenWidth * .01),
                  Text(
                    '${task.priority}',
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: screenWidth * .025),
                  Container(
                    height: 25,
                    width: 90,
                    decoration: BoxDecoration(
                      color: getStatusColor(task.statusName, context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                        value: task.statusName,
                        onChanged: (String? newValue) async {
                          if (newValue != null) {
                            await updateStatus(task.task_id, newValue);
                            setState(() {
                              // Refresh the task card state
                            });
                          }
                        },
                        items: <String>[
                          'Done',
                          'In progress',
                          'Not started',
                        ].map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.rubik(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        underline: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
