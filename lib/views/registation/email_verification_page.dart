import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../services/db_service.dart';

import 'first_name_page.dart'; // Replace with the actual next page

class VerificationCodePage extends StatefulWidget {
  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController _pinController = TextEditingController();

  void _validateAndNavigate() {
    if (_pinController.text.length < 6) {
      _showErrorDialog('Please enter a valid verification code.');
    } else {
      _updateStat("self", "registration", "1");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FirstNamePage()),
      );
    }
  }

  void _updateStat(String userId, String key, String value) async {
    Map<String, String> response = await DBService.updateStat(userId, key, value);

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
            SizedBox(height: 20),
            Text(
              "Enter your verification code",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Pinput(
                length: 6,
                controller: _pinController,
                defaultPinTheme: PinTheme(
                  width: 40,
                  height: 50,
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 2, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    "Didn't get anything? Fret not, let's try again.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Implement resend functionality here
                    },
                    child: Text(
                      "Resend",
                      style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
