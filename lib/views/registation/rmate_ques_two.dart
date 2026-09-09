import 'package:flutter/material.dart';

import 'rmate_ques_three.dart';

import '../../services/db_service.dart';

class RMateQuesTwo extends StatefulWidget {
  @override
  _RMateQuesTwoState createState() => _RMateQuesTwoState();
}

class _RMateQuesTwoState extends State<RMateQuesTwo> {
  String? selectedTemp;
  String? selectedDrinking;
  String? selectedCook;
  String? selectedGroceries;
  String? selectedSmoke;

  void _validateAndNavigate() async {
    if (selectedTemp == null || selectedDrinking == null || selectedCook == null || selectedGroceries == null || selectedSmoke == null) {
      _showErrorDialog('Please answer all questions before proceeding.');
    } else {
      _updateStat("self", "registration", "11");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RMateQuesThree()),
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

                  // Temperature Question
                  Text('What’s your ideal room temp?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Winter cold', selectedTemp, (value) => selectedTemp = value),
                    SizedBox(width: 8),
                    _optionButton('Moderate AC', selectedTemp, (value) => selectedTemp = value),
                    SizedBox(width: 8),
                    _optionButton('Warm fan', selectedTemp, (value) => selectedTemp = value),
                  ]),

                  SizedBox(height: 30),

                  // Drinking Question
                  Text('What’s your stance on drinking alcohol?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Never', selectedDrinking, (value) => selectedDrinking = value),
                    SizedBox(width: 8),
                    _optionButton('Socially', selectedDrinking, (value) => selectedDrinking = value),
                    SizedBox(width: 8),
                    _optionButton('Regularly', selectedDrinking, (value) => selectedDrinking = value),
                  ]),

                  SizedBox(height: 30),

                  // Cook Preference
                  Text('How often do you cook at home?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Every day', selectedCook, (value) => selectedCook = value),
                    SizedBox(width: 8),
                    _optionButton('Ocassionally', selectedCook, (value) => selectedCook = value),
                    SizedBox(width: 8),
                    _optionButton('Never', selectedCook, (value) => selectedCook = value),
                  ]),

                  SizedBox(height: 30),

                  // Groceries Preference
                  Text('Do you prefer shared groceries?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Shared basics', selectedGroceries, (value) => selectedGroceries = value),
                    SizedBox(width: 8),
                    _optionButton('Sperate', selectedGroceries, (value) => selectedGroceries = value),
                    SizedBox(width: 8),
                    _optionButton('Depends', selectedGroceries, (value) => selectedGroceries = value),
                  ]),

                  SizedBox(height: 30),

                  // Dishwashing Preference
                  Text('How soon do you wash dishes?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(children: [
                    _optionButton('Immediately', selectedSmoke, (value) => selectedSmoke = value),
                    SizedBox(width: 8),
                    _optionButton('Same day', selectedSmoke, (value) => selectedSmoke = value),
                    SizedBox(width: 8),
                    _optionButton('Next day', selectedSmoke, (value) => selectedSmoke = value),
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
