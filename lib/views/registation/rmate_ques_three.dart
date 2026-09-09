import 'package:flutter/material.dart';

import 'more_about_you.dart';

import '../../services/db_service.dart';

class RMateQuesThree extends StatefulWidget {
  @override
  _RMateQuesThreeState createState() => _RMateQuesThreeState();
}

class _RMateQuesThreeState extends State<RMateQuesThree> {
  String? selectedLaundry;
  String? selectedFurniture;
  String? selectedAppliance;
  String? selectedBathroom;
  String? selectedEnergy;

  void _validateAndNavigate() async {
    if (selectedLaundry == null || selectedFurniture == null || selectedAppliance == null || selectedBathroom == null || selectedEnergy == null) {
      _showErrorDialog('Please answer all questions before proceeding.');
    } else {
      _updateStat("self", "registration", "12");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MoreAboutYouPage()),
      );
    }
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
                  SizedBox(height: 30),

                  // Laundry Question
                  Text('How often do you do your laundry?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Weekly', selectedLaundry, (value) => selectedLaundry = value),
                    SizedBox(width: 8),
                    _optionButton('Bi-weekly', selectedLaundry, (value) => selectedLaundry = value),
                    SizedBox(width: 8),
                    _optionButton('As needed', selectedLaundry, (value) => selectedLaundry = value),
                  ]),

                  SizedBox(height: 30),

                  // Furniture Question
                  Text('Are you comfortable with sharing furniture?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Shared basics', selectedFurniture, (value) => selectedFurniture = value),
                    SizedBox(width: 8),
                    _optionButton('No sharing', selectedFurniture, (value) => selectedFurniture = value),
                    SizedBox(width: 8),
                    _optionButton('Discuss further', selectedFurniture, (value) => selectedFurniture = value),
                  ]),

                  SizedBox(height: 30),

                  // Appliance Preference
                  Text('Are you comforable with sharing appliances?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('All sharing', selectedAppliance, (value) => selectedAppliance = value),
                    SizedBox(width: 8),
                    _optionButton('Ask first', selectedAppliance, (value) => selectedAppliance = value),
                    SizedBox(width: 8),
                    _optionButton('No sharing', selectedAppliance, (value) => selectedAppliance = value),
                  ]),

                  SizedBox(height: 30),

                  // Bathroom Preference
                  Text('How long do you spend in the bathroom?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Quick', selectedBathroom, (value) => selectedBathroom = value),
                    SizedBox(width: 8),
                    _optionButton('Moderate', selectedBathroom, (value) => selectedBathroom = value),
                    SizedBox(width: 8),
                    _optionButton('Long', selectedBathroom, (value) => selectedBathroom = value),
                  ]),

                  SizedBox(height: 30),

                  // Energy  Preference
                  Text('How mindful are you of energy usage?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Eco-friendly', selectedEnergy, (value) => selectedEnergy = value),
                    SizedBox(width: 8),
                    _optionButton('Moderate', selectedEnergy, (value) => selectedEnergy = value),
                    SizedBox(width: 8),
                    _optionButton("Don't care", selectedEnergy, (value) => selectedEnergy = value),
                  ]),

                  SizedBox(height: 30),
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
