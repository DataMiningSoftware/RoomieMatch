import 'package:flutter/material.dart';

import 'rmate_ques_two.dart';

import '../../services/db_service.dart';

class RMateQuesOne extends StatefulWidget {
  @override
  _RMateQuesOneState createState() => _RMateQuesOneState();
}

class _RMateQuesOneState extends State<RMateQuesOne> {
  String? selectedSleep;
  String? selectedShared;
  String? selectedFood;
  String? selectedPets;
  String? selectedWork;

  void _validateAndNavigate() async {
    if (selectedSleep == null || selectedShared == null || selectedFood == null || selectedPets == null || selectedWork == null) {
      _showErrorDialog('Please answer all questions before proceeding.');
    } else {
      _updateStat("self", "registration", "10");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RMateQuesTwo()),
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

                  // Sleep schedule Question
                  Text('What’s your sleep schedule?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Early Sleeper', selectedSleep, (value) => selectedSleep = value),
                    SizedBox(width: 8),
                    _optionButton('Night Owl', selectedSleep, (value) => selectedSleep = value),
                    SizedBox(width: 8),
                    _optionButton('Flexible', selectedSleep, (value) => selectedSleep = value),
                  ]),

                  SizedBox(height: 30),

                  // Shared space Question
                  Text('How important is shared space etiquette?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Extremely strict', selectedShared, (value) => selectedShared = value),
                    SizedBox(width: 8),
                    _optionButton('Relaxed', selectedShared, (value) => selectedShared = value),
                  ]),

                  SizedBox(height: 30),

                  // Sharing food Preference
                  Text('Are you open to sharing food?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Sure thing!', selectedFood, (value) => selectedFood = value),
                    SizedBox(width: 8),
                    _optionButton('Only snacks', selectedFood, (value) => selectedFood = value),
                    SizedBox(width: 8),
                    _optionButton('No', selectedFood, (value) => selectedFood = value),
                  ]),

                  SizedBox(height: 30),

                  // Pets Preference
                  Text('How do you feel about pets?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('All pets', selectedPets, (value) => selectedPets = value),
                    SizedBox(width: 8),
                    _optionButton('Small pets', selectedPets, (value) => selectedPets = value),
                    SizedBox(width: 8),
                    _optionButton('No pets', selectedPets, (value) => selectedPets = value),
                  ]),

                  SizedBox(height: 30),

                  // Work From Home Preference
                  Text('Do you work from home often?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Full remote', selectedWork, (value) => selectedWork = value),
                    SizedBox(width: 8),
                    _optionButton('Part remote', selectedWork, (value) => selectedWork = value),
                    SizedBox(width: 8),
                    _optionButton('Never remote', selectedWork, (value) => selectedWork = value),
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
