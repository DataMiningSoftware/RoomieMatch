import 'package:flutter/material.dart';

import 'settings.dart';
import '../swipe.dart';
import '../chat.dart';
import '../home.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int _selectedIndex = 3; // Default index for the "Settings" tab
  final Map<String, bool> _isExpanded = {}; // Initialize the map for tracking expanded states

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigate to different pages
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SwipePage()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
          break;
      }
    }
  }

  Widget _buildIcon(String assetPath, bool isSelected) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: const Text('Welcome to FAQs'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black, // Black arrow for visibility
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white, // Header background color
            child: Column(
              children: [
                Image.asset(
                  'assets/faq_header.png', // Replace with your actual asset
                  width: double.infinity,
                  height: 250, // Increased height for larger image
                  fit: BoxFit.contain, // Keep proportions intact
                ),
              ],
            ),
          ),
          // Blue Background Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE3EFEF), // Blue background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    '\nGeneral Questions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    title: 'About us',
                    preview: 'Our app makes finding the right roommate simple and stress-free. With swipe-to-ma...',
                    content: 'Our app makes finding the right roommate simple and stress-free. With swipe-to-match functionality and customizable filters, you can connect with people who truly fit your lifestyle.',
                  ),
                  const SizedBox(height: 16), // Space between FAQ items
                  _buildFAQItem(
                    title: 'Terms of use',
                    preview: 'Swipe to Match\nOn the main swipe page, you can swipe ri...',
                    content:
                        'Swipe to Match:\nOn the main swipe page, you can swipe right on profiles you’re interested in and left on profiles you’re not. When both you and another user swipe right on each other’s profiles, a match is created, and you’ll receive a notification to start chatting!\n\n'
                        'Customize Your Preferences and Filters:\nTailor your roommate matches by adjusting your preferences and filters directly on the swipe page. This allows you to see profiles that best fit your needs.\n\n'
                        'Manage Notifications:\nControl your notifications to suit your schedule. In the settings, you can mute notifications altogether or set specific days and times for notifications to be paused using the Sleep mode.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFC7FBD2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
        ),
        child: SizedBox(
          height: 80, // Change this value to make it thinner or thicker
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: const Color(0xFFC7FBD2),
              elevation: 0,
              selectedItemColor: Colors.grey,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: _buildIcon('assets/icons/homebutton.png', _selectedIndex==0),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon('assets/icons/chatbutton.png', _selectedIndex==1),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon('assets/icons/swipepage.png', _selectedIndex==2),
                  label: 'Swipe',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon('assets/icons/settingsbutton.png', _selectedIndex==3),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build a collapsible FAQ item with preview content
  Widget _buildFAQItem({
    required String title,
    required String preview,
    required String content,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: _isExpanded[title] == true
          ? null
          : Text(
              preview,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
      trailing: Icon(
        _isExpanded[title] == true ? Icons.remove : Icons.add,
        color: Colors.black,
      ),
      onExpansionChanged: (isExpanded) {
        setState(() {
          _isExpanded[title] = isExpanded;
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
