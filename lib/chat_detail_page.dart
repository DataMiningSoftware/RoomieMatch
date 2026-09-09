import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntfy_dart/ntfy_dart.dart';

import 'dart:async';
import 'dart:convert';

import 'info_page.dart';

import './services/cryptography_service.dart';
import './services/message_db_service.dart';
import './services/db_service.dart';

import './helpers/auth_box_helper.dart';
import './config.dart';
import './app_theme.dart';

class ChatDetailPage extends StatefulWidget {
  final String userId;
  final String firstName; // Name of the person you are chatting with
  final String profileImageAsset; // Local asset image for the profile
  List<Map<String, dynamic>> messages = []; // List of messages (content and sender info)

  ChatDetailPage({super.key, required this.userId, required this.firstName, required this.profileImageAsset // Required local asset image
      // required this.messages, // Messages specific to the user
      });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();

    getMessages();
    if (!AppConfig.offlineMode) {
      createConnection();
    }
  }

  Future<void> createConnection() async {
    final String topic = 'notifications';
    final NtfyClient ntfyClient = NtfyClient(basePath: Uri.parse("http://localhost:9980"));
    // final NtfyClient ntfyClient = NtfyClient(basePath: Uri.parse("http://192.168.2.168:9980"));

    // Subscribe to the topic(s), receiving the MessageResponses right as they are published
    final Stream<MessageResponse> ntfyStream = (await ntfyClient.getMessageStream([topic]));

    // listen to our stream for messages sent to the topic, instantaneous update
    final StreamSubscription<MessageResponse> ntfyListen = ntfyStream.listen((event) async {
      if (event.event == EventTypes.message) {
        Map<String, dynamic> notification = jsonDecode(event.message ?? '{"userId": "", "title":"", "message":""}');

        // check for message incoming here
        if (notification['userId'].compareTo(AuthBoxHelper.getUserId()) == 0) {
          String title = await CryptographyService.decryptRSA(notification['title']);

          if (title.compareTo("New Message!") == 0) {
            _onMessageChanged(await DBService.getAllMessages());
          }
        }
      }
    });
  }

  Future<void> getMessages() async {
    await DBService.getAllMessages();

    final List<Map<String, dynamic>> temp = await MessageDBService().getMessagesByUserId(AuthBoxHelper.getUserId(), widget.userId);

    DateFormat format = DateFormat('yyyy-MM-ddTHH:mm:ss');

    for (int i = 0; i < temp.length; i++) {
      Map<String, dynamic> mes = {'content': "", "timestamp": "", "isSender": true};
      mes["content"] = temp[i]["plain_text"];

      DateTime? dateTime = DateTime.tryParse(temp[i]["timestamp"]);
      if (dateTime == null) dateTime = format.parse(temp[i]["timestamp"]);
      mes["timestamp"] = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);

      if (temp[i]["sender_user_id"] == AuthBoxHelper.getUserId()) {
        mes["isSender"] = true;
      } else {
        mes["isSender"] = false;
      }

      widget.messages.add(mes);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), // Smooth animation
          curve: Curves.easeOut,
        );
      }
    });

    setState(() => _isLoadingMessages = false);
  }

  void _onMessageChanged(List<Map<String, dynamic>> messages) {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i]['senderUserId'] == widget.userId) {
        Map<String, dynamic> mes = {'content': "", "timestamp": "", "isSender": false};

        mes["content"] = messages[i]['plainText'];

        DateFormat format = DateFormat('yyyy-MM-ddTHH:mm:ss');
        DateTime? dateTime = DateTime.tryParse(messages[i]["timestamp"]);
        if (dateTime == null) dateTime = format.parse(messages[i]["timestamp"]);
        mes["timestamp"] = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);

        widget.messages.add(mes);

        setState(() => _isLoadingMessages = false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300), // Smooth animation
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the InfoPage when the profile picture is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoPage(
                      name: widget.firstName,
                      age: '25', // Provide the age dynamically if available
                      imagePath: widget.profileImageAsset,
                      distance: '5km', // Provide the distance dynamically if available
                      location: 'Sample Location',
                      about: 'Sample About Information',
                      preferences: ['Preference 1', 'Preference 2'],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(widget.profileImageAsset), // Use local asset image
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.firstName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController, // Attach the controller

                    padding: const EdgeInsets.all(16),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.messages[index];
                      final isSender = message['isSender']; // Check if the message is sent by the user

                      return Column(
                        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSender ? AppColors.primary : const Color(0xFFECF1F1),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isSender ? 16 : 4),
                                bottomRight: Radius.circular(isSender ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              message['content'],
                              style: TextStyle(
                                fontSize: 15,
                                color: isSender ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                          Padding(
                            padding: isSender ? const EdgeInsets.only(right: 8, bottom: 10) : const EdgeInsets.only(left: 8, bottom: 10),
                            child: Text(
                              message['timestamp'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Input field for new messages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Correct placement for borderRadius
                        borderSide: BorderSide.none, // Correct placement for borderSide
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: AppColors.primary,
                  iconSize: 28,
                  onPressed: () {
                    // Handle sending message logic
                    if (messageController.text.trim() != "") {
                      DBService.sendMessage(widget.userId, messageController.text);

                      Map<String, dynamic> mes = {'content': "", "timestamp": "", "isSender": true};
                      mes["content"] = messageController.text;
                      mes["timestamp"] = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

                      widget.messages.add(mes);

                      messageController.clear();
                      FocusScope.of(context).unfocus(); // Dismiss the keyboard
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300), // Smooth animation
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
