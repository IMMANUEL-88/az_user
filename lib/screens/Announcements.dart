import 'package:attendzone_new/helper_functions.dart';
import 'package:attendzone_new/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  _AnnouncementState createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcements> {
  final TextEditingController _announcementController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      List<Map<String, dynamic>> messages = await getPreviousAnnouncements();
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: EAppBar(
        title: Text(
          'Announcements',
          style: GoogleFonts.rubik(color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 30),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                final message = _messages[reversedIndex];
                final date = _formatDate(message['date']);
                final time = message['time'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (index == 0 ||
                        _formatDate(_messages[_messages.length - 1 - (index - 1)]['date']) != date)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            date,
                            style: GoogleFonts.rubik(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      width: EHelperFunctions.screenWidth(context) * .9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                message['message'],
                                style: GoogleFonts.rubik(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0, bottom: 5.0),
                              child: Text(
                                time,
                                style: GoogleFonts.rubik(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<List<Map<String, dynamic>>> getPreviousAnnouncements() async {
    try {
      const String apiUrl = 'https://attendzone-backend.onrender.com/api/v1/announcements';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'message': item['message'],
          'date': item['date'],
          'time': item['time']
        }).toList();
      } else {
        throw Exception('Failed to load previous announcements');
      }
    } catch (e) {
      throw Exception('Error fetching previous announcements: $e');
    }
  }
}
