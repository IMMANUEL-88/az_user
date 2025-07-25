import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
class Chat {

  final String baseUrl = 'https://attendzone-backend.onrender.com/api/v1/chat';

  // Method to get chat messages for a given email (static)
  static Future<List<dynamic>> getChatMessages(String email) async {
    String? authToken = await Get().getToken();
    final url = Uri.parse('https://attendzone-backend.onrender.com/api/v1/chat/messages');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken!,
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      List<dynamic> messages = jsonDecode(response.body);
      await _saveMessagesToSharedPrefs(messages);

      return messages;
    } else if (response.statusCode == 404) {
      print('No chat messages found for this email');
      return [];
    } else {
      throw Exception('Failed to fetch chat messages: ${response.statusCode}');
    }
  }

  // Method to add a new chat message
  Future<void> addChatMessage(String projectName, String sender, String message) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    final url = Uri.parse('$baseUrl/add');
    String? authToken = await Get().getToken();
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken!,
      },
      body: jsonEncode({
        'project_name': projectName,
        'sender': sender,
        'message': message,
        'date': formattedDate,
        'time': formattedTime,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('Response: ${responseBody['message']}');
    } else {
      throw Exception('Failed to add chat message: ${response.statusCode}');
    }
  }

  // Method to add a new chat image
  Future<void> addChatImage(String projectName, String sender, String imageBase64) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String? authToken = await Get().getToken();
    final url = Uri.parse('$baseUrl/add');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken!,
      },
      body: jsonEncode({
        'project_name': projectName,
        'sender': sender,
        'message': 'image:$imageBase64',
        'date': formattedDate,
        'time': formattedTime,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('Response: ${responseBody['message']}');
    } else {
      throw Exception('Failed to add chat message: ${response.statusCode}');
    }
  }
  // Private method to save messages to SharedPreferences (static)
  static Future<void> _saveMessagesToSharedPrefs(List<dynamic> messages) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chatMessages', jsonEncode(messages));
  }

  // Method to get saved messages from SharedPreferences
  static Future<List<dynamic>?> getSavedMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMessagesJson = prefs.getString('chatMessages');

    if (savedMessagesJson != null) {
      return jsonDecode(savedMessagesJson);
    }
    return null;
  }
}
