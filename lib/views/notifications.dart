import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'avatarPath': 'assets/profile/4.png',
        'title': 'Message',
        'description': 'You have a message from Emily!',
        'timestamp': '9:00 AM',
      },
      {
        'avatarPath': 'assets/profile/4.png',
        'title': 'Message',
        'description': 'You have a message from Zack!',
        'timestamp': '3:00 PM',
      },
      {
        'avatarPath': 'assets/profile/4.png',
        'title': 'Message',
        'description': 'You have a message from Bruno!',
        'timestamp': '5 Days Ago',
      },
      {
        'avatarPath': 'assets/profile/3.png',
        'title': 'Message',
        'description': 'You have a message from Jasnie!',
        'timestamp': '5 Days Ago',
      },
      {
        'avatarPath': 'assets/profile/6.png',
        'title': 'Message',
        'description': 'You have a message from Mimi!',
        'timestamp': '6 Days Ago',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Background set to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black), // Keep title text black
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, // Keep background white
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(notification['avatarPath']),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      notification['timestamp'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
