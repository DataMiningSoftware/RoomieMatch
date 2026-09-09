import 'package:flutter/material.dart';

import 'rmate_ques_one.dart';

import '../../services/db_service.dart';

class AboutYouPage extends StatefulWidget {
  @override
  State<AboutYouPage> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends State<AboutYouPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();

  bool? _isStudent;
  bool? _hasAllergies;

  void _validateAndNavigate() {
    if (_descriptionController.text.trim().isEmpty || _isStudent == null || (_isStudent == true && _schoolController.text.trim().isEmpty) || (_isStudent == false && _jobController.text.trim().isEmpty) || _hasAllergies == null || (_hasAllergies == true && _allergyController.text.trim().isEmpty)) {
      _showErrorDialog('Please fill in all required fields.');
    } else {
      _updateStat("self", "registration", "9");
      
      _updateProfile("description", _descriptionController.text.trim());
      _updateProfile("schoolJob", _isStudent ?? false ? _schoolController.text.trim() : _jobController.text.trim());
      _updateProfile("allergies", _hasAllergies ?? false ? _allergyController.text.trim() : "");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RMateQuesOne()),
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

  /// **Reusable Option Button (Thinner)**
  Widget _optionButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12), // Reduced padding for thinner button
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1C8585).withOpacity(0.15) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12), // Slightly rounded corners
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.black), // Adjusted font size
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Help us to get to know about you",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enter a short description about yourself. It will be shown in your info page.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter description',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Student Selection
                    Text("Are you a student?"),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _optionButton("Yes", _isStudent == true, () {
                            setState(() {
                              _isStudent = true;
                            });
                          }),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _optionButton("No", _isStudent == false, () {
                            setState(() {
                              _isStudent = false;
                            });
                          }),
                        ),
                      ],
                    ),
                    if (_isStudent == true) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _schoolController,
                        decoration: InputDecoration(
                          hintText: 'Enter school name',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                    if (_isStudent == false) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _jobController,
                        decoration: InputDecoration(
                          hintText: 'Enter your job',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                    SizedBox(height: 24),

                    // Allergy Selection
                    Text("Do you have any allergies?"),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _optionButton("Yes", _hasAllergies == true, () {
                            setState(() {
                              _hasAllergies = true;
                            });
                          }),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _optionButton("No", _hasAllergies == false, () {
                            setState(() {
                              _hasAllergies = false;
                            });
                          }),
                        ),
                      ],
                    ),
                    if (_hasAllergies == true) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _allergyController,
                        decoration: InputDecoration(
                          hintText: 'Specify your allergies',
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // "Next" Button
            SizedBox(
              width: double.infinity,
              height: 50,
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
