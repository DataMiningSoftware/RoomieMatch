import 'package:flutter/material.dart';

import 'gender_selection_page.dart'; // Next page after this

import '../../services/db_service.dart';

class BirthdayPage extends StatefulWidget {
  @override
  State<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  final TextEditingController birthdateController = TextEditingController();

  void _validateAndNavigate() {
    String input = birthdateController.text.trim();

    if (input.isEmpty) {
      _showErrorDialog('Please select your birth date.');
      return;
    }

    try {
      DateTime birthDate = _parseDate(input);

      if (birthDate.isAfter(DateTime.now())) {
        _showErrorDialog('Birth date cannot be in the future.');
      } else {
        _updateStat("self", "registration", "4");

        _updateProfile("birthday", input);
        print(input);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenderSelectionPage()),
        );
      }
    } catch (e) {
      _showErrorDialog('Invalid date format. Please use MM/DD/YYYY.');
    }
  }

  DateTime _parseDate(String input) {
    final parts = input.split('/');
    if (parts.length != 3) throw FormatException('Incorrect format');

    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      throw FormatException('Invalid numbers');
    }

    if (month < 1 || month > 12 || day < 1 || day > 31) {
      throw FormatException('Month or day out of range');
    }

    final date = DateTime.tryParse(
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );

    if (date == null || date.month != month || date.day != day || date.year != year) {
      throw FormatException('Invalid date');
    }

    return date;
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthdateController.text = "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.day.toString().padLeft(2, '0')}/"
            "${pickedDate.year}";
      });
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
            SizedBox(height: 20),
            Text(
              "What's your B-Day?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: birthdateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                hintText: 'MM / DD / YYYY',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your profile shows your age, not your birth date.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
