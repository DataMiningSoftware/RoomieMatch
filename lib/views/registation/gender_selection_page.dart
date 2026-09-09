import 'package:flutter/material.dart';

import 'location_page.dart';

import '../../services/db_service.dart';

class GenderSelectionPage extends StatefulWidget {
  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? selectedGender;

  Widget _genderOption(String label, IconData icon) {
    bool isSelected = selectedGender == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = label;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24), // Increased padding for thicker button
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1C8585).withOpacity(0.15) : Colors.grey[200], // Light green highlight when selected
          borderRadius: BorderRadius.circular(16), // More rounded corners
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Icon(icon, color: Color(0xFF1C8585), size: 28), // Green icon
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500), // Bigger text
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndNavigate() {
    if (selectedGender == null) {
      _showErrorDialog('Please select your gender.');
    } else {
      _updateStat("self", "registration", "5");

      if (selectedGender == "Man") {
        _updateProfile("gender", "M");
      } else if (selectedGender == "Woman") {
        _updateProfile("gender", "F");
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationPage()),
      );
    }
  }

  void _updateProfile(String field, String value) async {
    Map<String, String> response = await DBService.updateProfileField(field, value);

    _checkError(response);
  }

  void _updateStat(String userId, String key, String value) async {
    Map<String, String> response = await DBService.updateStat(userId, key, value);

    _checkError(response);
  }

  void _checkError(Map<String, String> response) {
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question at the top
            SizedBox(height: 16),
            Text(
              "What's your gender?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Gender selection options (immediately below the question)
            _genderOption("Woman", Icons.female),
            SizedBox(height: 16),
            _genderOption("Man", Icons.male),

            Spacer(), // Pushes the Next button to the bottom

            // "Next" button at the bottom
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _validateAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C8585),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
