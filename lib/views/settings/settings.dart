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
  int _selectedIndex = 3;

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
    final profile = HiveService.getProfile();

    String name = [profile.firstName, profile.lastName].where((s) => s.isNotEmpty).join(' ');
    if (name.isEmpty) name = 'Your Profile';
    final String subtitle = profile.schoolJob.isNotEmpty ? profile.schoolJob : 'RoomieMatch member';
    final String avatar = profile.gender == 'F' ? 'assets/profile/1.jpg' : 'assets/profile/2.jpg';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildProfileHeader(name, subtitle, avatar),
          const SizedBox(height: 20),
          const _SectionTitle('Account'),
          _SettingsTile(
            icon: Icons.person_rounded,
            color: AppColors.primary,
            title: 'Profile',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettingsPage()));
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.lock_rounded,
            color: AppColors.superLike,
            title: 'Account Privacy',
            trailing: Switch(
              value: settings.accountPrivacy,
              onChanged: (value) {
                setState(() {
                  settings.accountPrivacy = value;
                });
                HiveService.setSettings(settings);
                _updateSettings('accountPrivacy', value ? 'T' : 'F');
              },
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Preferences'),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            color: AppColors.rewind,
            title: 'Notifications',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
            },
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Support'),
          _SettingsTile(
            icon: Icons.help_rounded,
            color: AppColors.like,
            title: 'FAQs',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FAQPage()));
            },
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  Widget _buildProfileHeader(String name, String subtitle, String avatar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage: AssetImage(avatar),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettingsPage()));
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2D6D4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFE4574C), size: 20),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE4574C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
