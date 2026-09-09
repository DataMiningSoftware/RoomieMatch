import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:basic_utils/basic_utils.dart';

import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/message_key_db_service.dart';
import '../services/cryptography_service.dart';

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

    // CryptographyService.test();

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
    // Refereshes every 7 days in seconds
    else if (secondsElapsed > 604800) {
      keyId = response[0]['key_id'] + 1;
    }

    if (keyId != -1) {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = CryptographyService.generateRSAKeyPair();

      // Convert RSAPrivateKey to PEM format and store to secureStorage
      String privateKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey);
      await MessageKeyDBService().insertMessageKey(keyId, privateKeyPEM);

      // Send public key to backend to encrypt
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
      backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureImage(),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome to RoomieMatch!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C8585),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Explore your profile, find useful info, and get ready to meet your future roommate.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImageGrid(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures space between logo and icon
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
        // Notification Icon
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary), // Icon color
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

  Widget _buildFeatureImage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SwipePage()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/homepage3.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final List<Map<String, String>> items = [
      {
        'image': 'assets/homepage1.jpg',
        'title': 'Modify your account here!',
        'subtitle': '',
        'route': 'account' // Placeholder action for account settings
      },
      {'image': 'assets/homepage2.jpg', 'title': 'Having some questions?', 'subtitle': 'Click here', 'route': 'faq'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Lower value = taller cards
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return GestureDetector(
          onTap: () {
            if (item['route'] == 'account') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
              );
            } else if (item['route'] == 'faq') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQPage()),
              );
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(item['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C8585),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (item['subtitle']!.isNotEmpty)
                        Text(
                          item['subtitle']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
