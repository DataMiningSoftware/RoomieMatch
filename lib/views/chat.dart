import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/chat_db_service.dart';
import '../services/db_service.dart';
import '../services/mock_backend.dart';

import '../helpers/auth_box_helper.dart';

import '../chat_detail_page.dart';
import 'settings/settings.dart';
import 'swipe.dart';
import 'home.dart';
import 'notifications.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 1; // Default to "Chats" tab
  List<Map<String, dynamic>> chats = [];

  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();

    getChats();
  }

  Future<void> getChats() async {
    await DBService.getAllChats();

    chats = await ChatDBService().getChatsByUserId(AuthBoxHelper.getUserId());


    setState(() => _isLoadingChats = false);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget page = const HomePage();
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 2:
        page = const SwipePage();
        break;
      case 3:
        page = const SettingsPage();
        break;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingChats
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : chats.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 72, color: AppColors.accentStrong),
                      SizedBox(height: 16),
                      Text('No chats yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Match with someone to start chatting!', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final String avatar = MockBackend.profileImageFor(chat['chat_user_id']);
                    DateTime localTime = DateTime.fromMillisecondsSinceEpoch(chat['latest_time'] * 1000, isUtc: false);
                    String formattedTime = DateFormat('dd-MM-yyyy HH:mm').format(localTime);

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage(avatar), // Per-user profile image
                      ),
                      title: Text(
                        chat['first_name'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Text(
                        formattedTime,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              userId: chat['chat_user_id'],
                              firstName: chat['first_name'],
                              profileImageAsset: avatar,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
