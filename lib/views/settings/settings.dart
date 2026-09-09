import 'package:flutter/material.dart';

import '../../models/settings.dart';

import '../../app_theme.dart';
import '../../config.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../services/db_service.dart';
import '../../services/hive_service.dart';
import '../../services/auth_service.dart';
import '../../services/main_init_service.dart';

import '../swipe.dart';
import '../chat.dart';
import 'faq.dart';
import 'notifications_settings.dart';
import '../login.dart';
import '../home.dart';
import '../notifications.dart';
import 'profile_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3; // Default to "Settings" tab
  bool isAccountPrivate = false; // State for Account Privacy toggle

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
      case 1:
        page = const ChatPage();
        break;
      case 2:
        page = const SwipePage();
        break;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _updateSettings(String field, String value) async {
    Map<String, String> response = await DBService.updateSettingsField(field, value);

    if (response["status"] == "ERROR") {
      _showErrorDialog(response["error"] ?? "An unknown error occurred.");
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = HiveService.getSettings() ?? Settings();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFE3EFEF),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF1C8585)), // Match homepage icon color
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFE3EFEF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: const AssetImage(
                    'assets/profile/11.jpeg',
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Erika',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kuala Lumpur, Malaysia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                children: [
                  ListTile(
                    leading: _buildCustomIcon(
                      'assets/icons/profile.png',
                      const Color(0xFF1C8585),
                    ),
                    title: const Text('Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: _buildCustomIcon(
                      'assets/icons/notifications.png',
                      const Color(0xFF1C8585),
                    ),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: _buildCustomIcon(
                      'assets/icons/privacy.png',
                      const Color(0xFF1C8585),
                    ),
                    title: const Text('Account Privacy'),
                    trailing: Switch(
                      value: settings.accountPrivacy,
                      onChanged: (value) {
                        setState(() {
                          settings.accountPrivacy = value;
                        });

                        HiveService.setSettings(settings);

                        if (value) {
                          _updateSettings('accountPrivacy', 'T');
                        } else {
                          _updateSettings('accountPrivacy', 'F');
                        }
                      },
                      activeColor: const Color(0xFF1C8585),
                      activeTrackColor: const Color(0xFF1C8585).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: _buildCustomIcon(
                      'assets/icons/faq.png',
                      const Color(0xFF1C8585),
                    ),
                    title: const Text('FAQs'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FAQPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: _buildCustomIcon(
                      'assets/icons/logout.png',
                      Colors.grey,
                    ),
                    title: const Text('Logout'),
                    onTap: () async {
                      await AuthService.signOut();
                      if (!AppConfig.offlineMode) {
                        await MainInitService.stopService();
                      }
                      HiveService.deleteUser();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LogInPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  Widget _buildCustomIcon(String assetPath, Color backgroundColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
