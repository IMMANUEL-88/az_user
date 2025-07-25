import 'dart:convert';

import 'package:attendzone_new/models/project_model.dart';
import 'package:http/http.dart' as http;

import '../models/task_model.dart';

Future<List<Project_model>> fetchNotionPages() async {
  try {
    final response = await http.post(
      Uri.parse(
          'https://api.notion.com/v1/databases/c4e5666358bc4f95bf94d725de51a7c8/query'),
      headers: {
        'Authorization':
        'Bearer secret_8dCi3ETaCE5QZoFV7zBi6ftP35Lk6lujTHw1ztmNK12',
        'Notion-Version': '2022-06-28',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Project_model> projects = [];
      for (var json in results) {
        try {
          var project = Project_model.fromJson(json);
          projects.add(project);
        } catch (e) {
          rethrow;
        }
      }
      return projects;
    } else {
      throw Exception('Failed to load Notion pages: ${response.statusCode}');
    }
  } catch (error) {
    rethrow;
  }
}

Future<List<Task_model>> fetchNotionTasks() async {
  try {
    final response = await http.post(
      Uri.parse('https://api.notion.com/v1/databases/c9f1428a38934f78b673fd6f72eaa77f/query'),
      headers: {
        'Authorization': 'Bearer secret_8dCi3ETaCE5QZoFV7zBi6ftP35Lk6lujTHw1ztmNK12',
        'Notion-Version': '2022-06-28',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Task_model> tasks = [];
      for (var json in results) {
        try {
          var task = Task_model.fromJson(json);
          tasks.add(task);
        } catch (e) {
          print('Error parsing task JSON: $e');
        }
      }
      return tasks;
    } else if (response.statusCode == 404) {
      throw Exception('Notion database not found');
    } else {
      throw Exception('Failed to load Notion pages: ${response.statusCode}');
    }
  } catch (error) {
    // Handle errors gracefully
    print('Error fetching tasks: $error');
    return []; // or rethrow error
  }
}



Future<void> updateStatus(String? id, String? name) async {
  try {
    final response = await http.patch(
      Uri.parse('https://api.notion.com/v1/pages/$id'),
      headers: {
        'Authorization':
        'Bearer secret_8dCi3ETaCE5QZoFV7zBi6ftP35Lk6lujTHw1ztmNK12',
        'Notion-Version': '2022-06-28',
        'Content-Type':
        'application/json', // Add this line to specify JSON content type
      },
      body: jsonEncode({
        "properties": {
          "Status": {
            "status": {"name": name}
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      print('Data updated Successfully');
    } else {
      throw Exception('Failed to update Notion page: ${response.statusCode}');
    }
  } catch (error) {
    rethrow;
  }
}
