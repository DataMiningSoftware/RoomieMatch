import 'package:flutter/material.dart';

import 'budget_preference_page.dart';

import '../../services/db_service.dart';

class DistancePreferencePage extends StatefulWidget {
  @override
  State<DistancePreferencePage> createState() => _DistancePreferencePageState();
}

class _DistancePreferencePageState extends State<DistancePreferencePage> {
  double _currentDistance = 10.0; // Default distance value

  void _validateAndNavigate() {
  
      _updateStat("self", "registration", "7");
      
      _updateProfile("distance", (_currentDistance.toInt()).toString());

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BudgetPreferencePage()),
      );
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Your distance\npreference?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Adjust the slider to set the maximum distance for your potential matches.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              "Distance Preference",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_currentDistance.toInt()} km",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  "Min: 1 km   Max: 100 km",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Slider(
              value: _currentDistance,
              min: 1,
              max: 100,
              divisions: 99,
              label: "${_currentDistance.toInt()} km",
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() {
                  _currentDistance = value;
                });
              },
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
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
                    fontWeight: FontWeight.bold,
                  ),
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
