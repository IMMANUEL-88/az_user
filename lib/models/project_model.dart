class Project_model {
  final String projectName;
  final String statusName;
  final double completionPercentage;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tasks;
  final String? icon;
  final String assignees;
  final String link;

  Project_model({
    required this.projectName,
    required this.statusName,
    required this.completionPercentage,
    this.priority,
    this.startDate,
    this.endDate,
    required this.assignees,
    required this.tasks,
    this.icon,
    required this.link,
  });

  factory Project_model.fromJson(Map<String, dynamic> json) {
    String extractProjectName() {
      return json['properties']['Project name']['title'][0]['plain_text'] ?? '';
    }

    String extractStatusName() {
      return json['properties']['Status']['status']['name'] ?? '';
    }

    String extractGitLink() {
      var richTextList = json['properties']['link']['rich_text'] as List<dynamic>;
      if (richTextList.isNotEmpty) {
        return richTextList[0]['text']['content'] ?? '';
      }
      return '';
    }

    double extractCompletionPercentage() {
      var completionValue = json['properties']['Completion']['rollup']['number'];
      if (completionValue is int) {
        return completionValue.toDouble();
      } else if (completionValue is double) {
        return completionValue;
      }
      return 0.0;
    }

    String? extractPriority() {
      return json['properties']['Priority']['select']?['name'];
    }

    DateTime? extractStartDate() {
      var startDateString = json['properties']['Dates']['date']?['start'];
      if (startDateString != null) {
        return DateTime.parse(startDateString);
      }
      return null;
    }

    DateTime? extractEndDate() {
      var endDateString = json['properties']['Dates']['date']?['end'];
      if (endDateString != null) {
        return DateTime.parse(endDateString);
      }
      return null;
    }

    String extractAssigneeEmail() {
      var assigneeList = json['properties']['Assignee']['people'];
      if (assigneeList != null && assigneeList.isNotEmpty) {
        List<dynamic> emails = assigneeList.map((assignee) {
          return assignee['person']['email'] ?? '';
        }).toList();
        print(emails);
        return emails.join(', ');
      }
      return '';
    }

    String? extractIconEmoji() {
      return json['icon']?['emoji'];
    }

    List<String> extractTasks() {
      var tasksList = json['properties']['Tasks']['relation'] as List<dynamic>?;
      if (tasksList != null) {
        return tasksList.map((task) => task['id'] as String).toList();
      }
      return [];
    }

    return Project_model(
      projectName: extractProjectName(),
      statusName: extractStatusName(),
      completionPercentage: extractCompletionPercentage(),
      priority: extractPriority(),
      startDate: extractStartDate(),
      endDate: extractEndDate(),
      link: extractGitLink(),
      tasks: extractTasks(),
      assignees: extractAssigneeEmail(),
      icon: extractIconEmoji(),
    );
  }
}
