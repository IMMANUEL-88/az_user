import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import '../auth/facedetectionview.dart';
import '../models/attendance_model.dart';

final client = http.Client();
String globalMessage = '';

class Get {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class Api {
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<String> userIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return json.decode(response.body)["ip"];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      throw Exception('Failed to get IP address: $e');
    }
  }

  Future<bool> login(String userid, String password) async {
    try {
      String ip = await userIpAddress();
      // String? authToken = await Get().getToken();

      // if (authToken == null) {
      //   throw Exception('Authorization token not found');
      // }

      var url = Uri.parse('https://attendzone-backend.onrender.com/api/v1/auth/login');
      var body = jsonEncode({
        'userid': userid,
        'password': password,
        'ip': ip,
      });

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('userId')) {
          final prefs = await _getPrefs();
          final String token = data['token']?.toString() ?? '';
          final String userid = data['userId']?.toString() ?? '';
          final String username = data['username']?.toString() ?? '';
          final String email = data['email']?.toString() ?? '';
          final String? profileBase64 = data['profile'] as String?;

          await prefs.setString('userid', userid);
          await prefs.setString('username', username);
          await prefs.setString('email', email);
          await prefs.setString('token', token);

          if (profileBase64 != null) {
            try {
              await prefs.setString('profile', profileBase64);
              var profileBytes = base64.decode(profileBase64);
              data['profile'] = profileBytes;
            } catch (e) {
              print('Error decoding base64 profile: $e');
            }
          }

          globalMessage = '';
          return true;
        } else {
          globalMessage = 'No user data found in response';
          return false;
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        globalMessage = errorData['message'] ?? 'Unknown error occurred';
        print(globalMessage);
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String userId) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.get(
        Uri.parse('https://attendzone-backend.onrender.com/api/v1/users?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        for (var user in data) {
          String base64EncodedProfile = user['profile'];
          var profileBytes = base64.decode(base64EncodedProfile);
          user['profile'] = profileBytes;
        }
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIP(String userId) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.get(
        Uri.parse('https://attendzone-backend.onrender.com/api/v1/users?id=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final List<dynamic> data = json.decode(response.body);
        for (var user in data) {
          String dbip = user['ip'];
          prefs.setString('dip', dbip);
        }
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}

class Atten {
  Future<void> updateData(String userId, String date, String timeIn) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      var url = Uri.parse(
          'https://attendzone-backend.onrender.com/api/v1/attendance/mark');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: jsonEncode({'id': userId, 'Date': date, 'TimeIn': timeIn}),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully');
      } else {
        print('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  Future<void> getAttendance(String userId, String date) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      var url = Uri.parse(
          'https://attendzone-backend.onrender.com/api/v1/attendance/show?id=$userId&date=$date');
      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        for (var entry in data) {
          prefs.setString('time_in', entry['time_in'] ?? '');
          prefs.setString('time_out', entry['time_out'] ?? '');
          print("Time in: ${entry['time_in'] ?? 'N/A'}");
          print("Time out: ${entry['time_out'] ?? 'N/A'}");
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    }
  }

  Future<void> updateTimeOut(String userId, String date, String timeout) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      var url = Uri.parse(
          'https://attendzone-backend.onrender.com/api/v1/attendance/update?id=$userId&date=$date');
      var body = jsonEncode({"time_out": timeout});

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Attendance updated successfully!');
      } else {
        print('Error updating attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating time out: $e');
    }
  }

  Future<bool> checkUserIdExists(String userId) async {
    try {
      String? authToken = await Get().getToken();
      if (authToken == null) {
        throw Exception('Authorization token not found');
      }

      DateTime now = DateTime.now();
      var date = '${now.year}-${now.month}-${now.day}';

      var response = await http.post(
        Uri.parse(
            'https://attendzone-backend.onrender.com/api/v1/user/checkAttendance'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: jsonEncode({'id': userId, 'date': date}),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          var data = json.decode(response.body);
          return data["exists"] ?? false;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error during checking user ID existence: $e');
      return false;
    }
  }
}
class ApiService {
  Future<List<AttendanceEntry>> fetchAttendanceData(String userId) async {
    String? authToken = await Get().getToken();
    var url = Uri.parse(
        'https://attendzone-backend.onrender.com/api/v1/attendance/attendance?id=$userId');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authToken!,
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((entry) => AttendanceEntry.fromJson(entry)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
