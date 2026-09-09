import 'package:RoomieMatch/views/home.dart';
import 'package:flutter/material.dart';

import '../../models/settings.dart';
import '../../services/hive_service.dart';
import '../../services/db_service.dart';

import 'settings.dart';
import 'sleep_mode.dart';
import '../chat.dart';
import '../swipe.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // State variables for toggle switches
  bool pauseAll = true;
  bool messages = true;
  bool matchRequests = true;

  int _selectedIndex = 3; // Default to Settings tab

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
        case 2: // Navigate to Notifications Page
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
 

  void _updateSettings(String field, String value) async {
    Map<String, String> response = await DBService.updateSettingsField(field, value);

    if (response["status"] == "ERROR") {
      _showErrorDialog(response["error"] ?? "An unknown error occurred.");
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    Settings settings = HiveService.getSettings() ?? Settings();

    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white, // Match the app bar background to white
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black, // Ensure the back arrow is visible
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Text(
              'Push notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Pause All Notifications
            SwitchListTile(
              value: settings.notifPauseAll,
              onChanged: (value) {
                setState(() {
                  settings.notifPauseAll = value;
                });

                HiveService.setSettings(settings);
                
                if (value){
                  _updateSettings('notifPauseAll', 'T');
                }
                else{
                  _updateSettings('notifPauseAll', 'F');
                }
              },
              title: const Text('Pause all'),
              subtitle: const Text(
                'Temporarily pause notifications',
                style: TextStyle(color: Colors.grey),
              ),
              activeColor: const Color(0xFF1C8585), // Thumb color
              activeTrackColor: const Color(0xFF1C8585).withOpacity(0.5), // Track color
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),

            // Messages Notifications
            SwitchListTile(
              value: settings.notifMessages,
              onChanged: (value) {
                setState(() {
                  settings.notifMessages = value;
                });

                HiveService.setSettings(settings);
                
                if (value){
                  _updateSettings('notifMessages', 'T');
                }
                else{
                  _updateSettings('notifMessages', 'F');
                }
              },
              title: const Text('Messages'),
              subtitle: const Text(
                'Enable or disable message notifications',
                style: TextStyle(color: Colors.grey),
              ),
              activeColor: const Color(0xFF1C8585), // Thumb color
              activeTrackColor: const Color(0xFF1C8585).withOpacity(0.5), // Track color
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),

            // New Match Requests Notifications
            SwitchListTile(
              value: settings.notifNewMatch,
              onChanged: (value) {
                setState(() {
                  settings.notifNewMatch = value;
                });

                HiveService.setSettings(settings);

                if (value){
                  _updateSettings('notifNewMatch', 'T');
                }
                else{
                  _updateSettings('notifNewMatch', 'F');
                }
              },
              title: const Text('New match requests'),
              subtitle: const Text(
                'Enable or disable match request notifications',
                style: TextStyle(color: Colors.grey),
              ),
              activeColor: const Color(0xFF1C8585), // Thumb color
              activeTrackColor: const Color(0xFF1C8585).withOpacity(0.5), // Track color
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),

            // Sleep Mode
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              title: const Text('Sleep mode'),
              subtitle: const Text(
                'Automatically mute notifications at night or whenever you need to focus.',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // Navigate to Sleep Mode settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepModePage(),
                  ),
                );
              },
            ),
          ],
        ),
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
              spreadRadius: 2,
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
}
