import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:basic_utils/basic_utils.dart';

import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/message_key_db_service.dart';
import '../services/cryptography_service.dart';
import '../services/hive_service.dart';
import '../services/mock_backend.dart';

import 'settings/settings.dart';
import 'settings/faq.dart';
import 'settings/profile_settings_page.dart';

import 'chat.dart';
import 'swipe.dart';
import 'notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    initMessagesKey();
  }

  void initMessagesKey() async {
    final response = await MessageKeyDBService().getLatestMessagesKey();

    int keyId = -1;
    int secondsElapsed = -1;

    if (response.isNotEmpty) {
      DateFormat format = DateFormat('yyyy-MM-dd HH:mm:SS');
      DateTime initTimestamp = format.parse(response[0]['init_timestamp']);
      DateTime now = DateTime.now();

      secondsElapsed = now.difference(initTimestamp).inSeconds;
    }

    if (response.isEmpty) {
      keyId = 0;
    }
    // Refreshes every 7 days in seconds
    else if (secondsElapsed > 604800) {
      keyId = response[0]['key_id'] + 1;
    }

    if (keyId != -1) {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = CryptographyService.generateRSAKeyPair();

      String privateKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey);
      await MessageKeyDBService().insertMessageKey(keyId, privateKeyPEM);

      String publicKeyPEM = CryptoUtils.encodeRSAPublicKeyToPem(keyPair.publicKey);
      await CryptographyService.sendPublicMessageKey(publicKeyPEM, keyId);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChatPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SwipePage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: _buildHeader(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 16),
                  _buildFeatureBanner(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Image.asset('assets/RoomieMatch_logo.png', height: 42),
              const SizedBox(width: 8),
              const Text(
                'RoomieMatch',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final profile = HiveService.getProfile();
    final String name = profile.firstName.isNotEmpty ? profile.firstName : 'there';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, $name!',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 2),
        const Text(
          'Ready to find your new roommate?',
          style: TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildFeatureBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SwipePage()));
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/homepage3.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover your match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Swipe through profiles near you',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SwipePage()));
                        },
                        icon: const Icon(Icons.swipe_rounded, size: 18),
                        label: const Text('Start swiping'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final profiles = MockBackend.profiles;

    int topScore = 0;
    int nearest = 999;
    for (final p in profiles) {
      final score = (p['match_score'] as num).toInt();
      final dist = (p['distance'] as num).toInt();
      if (score > topScore) topScore = score;
      if (dist < nearest) nearest = dist;
    }

    return Row(
      children: [
        _StatCard(icon: Icons.group_rounded, value: '${profiles.length}', label: 'Profiles nearby', color: AppColors.primary),
        const SizedBox(width: 10),
        _StatCard(icon: Icons.bolt_rounded, value: '$topScore%', label: 'Top match', color: AppColors.superLike),
        const SizedBox(width: 10),
        _StatCard(icon: Icons.location_on_rounded, value: '$nearest km', label: 'Nearest', color: AppColors.like),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(Icons.manage_accounts_rounded, 'Edit Profile', const Color(0xFF1C8585), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettingsPage()));
      }),
      _QuickAction(Icons.chat_bubble_rounded, 'Messages', const Color(0xFF3A9BE8), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
      }),
      _QuickAction(Icons.notifications_rounded, 'Notifications', const Color(0xFFF5B93E), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
      }),
      _QuickAction(Icons.help_rounded, 'FAQs', const Color(0xFF35B37E), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FAQPage()));
      }),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: actions.map((a) => _QuickActionTile(a)).toList(),
    );
  }

  Widget _QuickActionTile(_QuickAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}
