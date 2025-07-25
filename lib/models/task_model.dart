class Task_model {
  final String taskName;
  final String statusName;
  final String email;
  final String? priority;
  final String Description;
  final String task_id;

  Task_model({
    required this.taskName,
    required this.statusName,
    required this.email,
    required this.Description,
    required this.priority,
    required this.task_id,
  });

  factory Task_model.fromJson(Map<String, dynamic> json) {
    String extractTaskName() {
      var title = json['properties']['Task name']['title'];
      if (title != null && title.isNotEmpty) {
        return title[0]['plain_text'] ?? '';
      }
      return '';
    }

    String extractStatusName() {
      var status = json['properties']['Status'];
      if (status != null && status['status'] != null) {
        return status['status']['name'] ?? '';
      }
      return '';
    }

    String extractTaskId() {
      return json['id'] ?? '';
    }

    String extractDescription() {
      var descriptionList = json['properties']['Summary']['rich_text'];
      if (descriptionList != null && descriptionList.isNotEmpty) {
        var description = descriptionList[0]['plain_text'];
        if (description != null && description.isNotEmpty) {
          return description;
        }
      }
      return '';
    }

    String extractAssigneeEmail() {
      var assigneeList = json['properties']['Assignee`'];
      if (assigneeList != null && assigneeList['people'] != null) {
        List<dynamic> emails = assigneeList['people'].map((assignee) {
          return assignee['person']['email'] ?? '';
        }).toList();
        return emails.join(', ');
      }
      return '';
    }

    String extractPriority() {
      var priority = json['properties']['Priority'];
      if (priority != null && priority['select'] != null) {
        return priority['select']['name'] ?? 'Not set';
      }
      return 'Not set';
    }

    return Task_model(
      taskName: extractTaskName(),
      statusName: extractStatusName(),
      email: extractAssigneeEmail(),
      priority: extractPriority(),
      Description: extractDescription(),
      task_id: extractTaskId(),
    );
  }
}
