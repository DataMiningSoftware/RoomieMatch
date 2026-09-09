import 'package:flutter/material.dart';

import 'your_interests_page.dart';

import '../../helpers/enum_helper.dart';

import '../../services/db_service.dart';

class MoreAboutYouPage extends StatefulWidget {
  @override
  _MoreAboutYouPageState createState() => _MoreAboutYouPageState();
}

class _MoreAboutYouPageState extends State<MoreAboutYouPage> {
  String? selectedPersonality;
  String? selectedGuests;
  String? selectedNoise;
  String? selectedCleanliness;
  String? selectedSmoke;

  // Convert string to enum
  String stringToEnum<T extends Enum>(List<T> enumValues, String name) {
    return enumValues
        .firstWhere(
          (enumInstance) => enumInstance.name == name,
        )
        .index
        .toString();
  }

  void _validateAndNavigate() async {
    if (selectedPersonality == null || selectedGuests == null || selectedNoise == null || selectedCleanliness == null || selectedSmoke == null) {
      _showErrorDialog('Please answer all questions before proceeding.');
    } else {
      _updateStat("self", "registration", "13");

      await _updatePreference("personality", stringToEnum(Personality.values, selectedPersonality ?? "Introverted"));
      await _updatePreference("guestsOver", stringToEnum(GuestsOver.values, selectedGuests ?? "Often"));
      await _updatePreference("loudNoise", stringToEnum(LoudNoise.values, selectedNoise ?? "Yes"));
      await _updatePreference("cleanliness", stringToEnum(Cleanliness.values, selectedCleanliness?.replaceAll(" ", "") ?? "VeryTidy"));
      await _updatePreference("smoke", stringToEnum(Smoke.values, selectedSmoke ?? "Yes"));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => YourInterestPage()),
      );
    }
  }

  Future<void> _updatePreference(String field, String value) async {
    Map<String, String> response = await DBService.updatePreferenceField(field, value);

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

  /// **Reusable Option Button (Matching "About You" Page)**
  Widget _optionButton(String label, String? groupValue, Function(String) onSelect) {
    bool isSelected = groupValue == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => onSelect(label)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12), // Thinner option box
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF1C8585).withOpacity(0.15) : Colors.grey[200], // Light green highlight when selected
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.black), // Normal black text
            ),
          ),
        ),
      ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What else is there about you?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sell yourself to us. You know you want to.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 16),

                  // Personality Question
                  Text('Which describes you best?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Introverted', selectedPersonality, (value) => selectedPersonality = value),
                    SizedBox(width: 8),
                    _optionButton('Extroverted', selectedPersonality, (value) => selectedPersonality = value),
                    SizedBox(width: 8),
                    _optionButton('Ambivert', selectedPersonality, (value) => selectedPersonality = value),
                  ]),

                  SizedBox(height: 16),

                  // Guests Question
                  Text('How often do you have guests over?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Often', selectedGuests, (value) => selectedGuests = value),
                    SizedBox(width: 8),
                    _optionButton('Sometimes', selectedGuests, (value) => selectedGuests = value),
                    SizedBox(width: 8),
                    _optionButton('Never', selectedGuests, (value) => selectedGuests = value),
                  ]),

                  SizedBox(height: 16),

                  // Noise Preference
                  Text('Are you comfortable with loud noises?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Yes', selectedNoise, (value) => selectedNoise = value),
                    SizedBox(width: 8),
                    _optionButton('No', selectedNoise, (value) => selectedNoise = value),
                  ]),

                  SizedBox(height: 16),

                  // Cleanliness Preference
                  Text('How would you describe your approach to keeping shared spaces clean?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Very tidy', selectedCleanliness, (value) => selectedCleanliness = value),
                    SizedBox(width: 8),
                    _optionButton('Moderate', selectedCleanliness, (value) => selectedCleanliness = value),
                    SizedBox(width: 8),
                    _optionButton('Casual', selectedCleanliness, (value) => selectedCleanliness = value),
                  ]),

                  SizedBox(height: 16),

                  // Smoking Preference
                  Text('Do you smoke?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Yes', selectedSmoke, (value) => selectedSmoke = value),
                    SizedBox(width: 8),
                    _optionButton('No', selectedSmoke, (value) => selectedSmoke = value),
                  ]),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // "Next" button fixed at bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Ensures spacing
            child: SizedBox(
              height: 50, // Ensures consistent height across pages
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
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
