import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/Api.dart';
import '../Api/chatApi.dart';
import '../helper_functions.dart';

class ChatPage extends StatefulWidget {
  final String sender;
  final String projectName;

  const ChatPage({required this.sender, required this.projectName, Key? key})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Chat _chatApi = Chat();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _messages = [];
  String? imageBase64 = '';
  String? Email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Email = prefs.getString('email');
    if (Email != null) {
      _loadChatMessages();
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      await Chat.getChatMessages(Email!);
      List<dynamic>? savedMessages = await Chat.getSavedMessages();

      if (savedMessages != null && savedMessages.isNotEmpty) {
        // Add a combined timestamp field for sorting
        for (var message in savedMessages) {
          // Parse the ISO 8601 date format
          DateTime dateTime = DateTime.parse(
              message['date']); // For example, "2024-08-12T18:30:00.000Z"

          // Parse the time string
          String timeString =
              message['time']; // Ensure this is in "HH:mm:ss" format
          // Combine date and time
          DateTime combinedDateTime = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            int.parse(timeString.split(':')[0]), // hour
            int.parse(timeString.split(':')[1]), // minute
            int.parse(timeString.split(':')[2]), // second
          );

          message['timestamp'] =
              combinedDateTime.millisecondsSinceEpoch; // Store as milliseconds
        }

        // Sort messages by timestamp
        savedMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        setState(() {
          _messages = savedMessages;
        });
      } else {
        print('No saved messages found.');
      }

      _scrollToBottom();
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    try {
      await _chatApi.addChatMessage(
          widget.projectName, widget.sender, _messageController.text);
      _messageController.clear();
      _loadChatMessages();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _sendImage() async {
    if (imageBase64 == '') return;
    try {
      await _chatApi.addChatImage(
          widget.projectName, widget.sender, imageBase64!);
      _messageController.clear();
      _loadChatMessages();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      imageBase64 = base64Encode(await imageFile.readAsBytes());

      _showImagePreviewDialog(imageFile); // Show preview dialog
    }
  }

  void _showImagePreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(imageFile), // Show the image preview
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _sendImage(); // Send the image
                },
                child: Text('Send Image'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary),
          onPressed: () => context.pop('/'),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/personImg.png'),
              radius: 18,
            ),
            SizedBox(width: 10),
            SizedBox(
              width: EHelperFunctions.screenWidth(context) * .5,
              child: Text(
                widget.projectName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rubik(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
          SizedBox(height: EHelperFunctions.screenHeight(context) * .01),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    Map<String, List<dynamic>> groupedMessages =
        _groupMessagesByDate(_messages);

    return ListView(
      controller: _scrollController,
      children: groupedMessages.entries.map((entry) {
        String dateLabel = _getDateLabel(entry.key);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    dateLabel,
                    style: GoogleFonts.rubik(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
            ...entry.value.map((message) {
              bool isSender = message['sender'] == widget.sender;
              bool isProjectMatch =
                  message['projectName'] == widget.projectName;
              if (!isProjectMatch) {
                return SizedBox.shrink();
              }

              bool isImageMessage = message['message'].startsWith('image:');
              Widget messageContent;

              if (isImageMessage) {
                String base64Image = message['message'].substring(6);
                final decodedBytes = base64Decode(base64Image);
                messageContent = InstaImageViewer(
                  backgroundIsTransparent: true,
                  child: Image.memory(
                    decodedBytes,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                messageContent = Text(
                  message['message'],
                  style: GoogleFonts.rubik(color: Colors.black),
                );
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(isSender ? 16 : 0),
                        bottomRight: Radius.circular(isSender ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSender) ...[
                          Text(
                            message['sender'],
                            style: GoogleFonts.rubik(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                        messageContent,
                        SizedBox(height: 5),
                        Text(
                          _formatTime(message['time']),
                          style: GoogleFonts.rubik(
                              color: Colors.black54, fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  Map<String, List<dynamic>> _groupMessagesByDate(List<dynamic> messages) {
    Map<String, List<dynamic>> groupedMessages = {};
    for (var message in messages) {
      DateTime dateTime = DateTime.parse(message['date']);
      String localDate = DateFormat('yyyy-MM-dd').format(dateTime.toLocal());

      if (!groupedMessages.containsKey(localDate)) {
        groupedMessages[localDate] = [];
      }
      groupedMessages[localDate]!.add(message);
    }
    return groupedMessages;
  }

  String _getDateLabel(String date) {
    DateTime messageDate = DateFormat('yyyy-MM-dd').parse(date);
    DateTime now = DateTime.now();

    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime yesterdayStart = todayStart.subtract(Duration(days: 1));
    DateTime yesterdayEnd = todayStart.subtract(Duration(milliseconds: 1));

    if (_isSameDay(messageDate, todayStart)) {
      return 'Today';
    } else if (messageDate.isAfter(yesterdayStart) &&
        messageDate.isBefore(todayStart)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(messageDate);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatTime(String timeString) {
    try {
      // Parse the time string assuming it is in the format "HH:mm:ss"
      DateTime dateTime = DateFormat('HH:mm:ss').parse(timeString);
      // Format the parsed time to a more readable format like "8:28 PM"
      return DateFormat.jm().format(dateTime);
    } catch (e) {
      // If parsing fails, return the original time string
      print('Error parsing time: $e');
      return timeString;
    }
  }

  Widget _buildMessageInput() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
          onPressed: _pickImage,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: _scrollToBottom,
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary),
                  hintText: "Type your message...",
                  hintStyle: GoogleFonts.rubik(
                      color: Colors.grey, fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
          onPressed: _sendMessage,
        ),
      ],
    );
  }
}
