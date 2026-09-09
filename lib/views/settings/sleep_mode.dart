import 'package:flutter/material.dart';

import '../../models/settings.dart';
import '../../services/hive_service.dart';
import '../../services/db_service.dart';

class SleepModePage extends StatefulWidget {
  const SleepModePage({super.key});

  @override
  _SleepModePageState createState() => _SleepModePageState();
}

class _SleepModePageState extends State<SleepModePage> {
  // State variables
  Settings settings = HiveService.getSettings() ?? Settings();
  TimeOfDay startTime = _formatTime((HiveService.getSettings() ?? Settings()).sleepStartTime);
  TimeOfDay endTime = _formatTime((HiveService.getSettings() ?? Settings()).sleepEndTime);
  List<bool> selectedDays = (HiveService.getSettings() ?? Settings()).sleepChooseDays;
  bool isSaved = false; // Track if the settings are saved

  // Function to pick time
  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1C8585), // Clock circle and selected text color
              onPrimary: Colors.white, // Text color on primary color
              onSurface: Colors.black, // Default text color
            ),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.white, // Background color of the clock
              hourMinuteColor: const Color(0xFF1C8585), // Background color for hours and minutes
              hourMinuteTextColor: Colors.white, // Text color for hours and minutes
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });

      String tempTime = picked.hour.toString().padLeft(2, '0') + picked.minute.toString().padLeft(2, '0');

      if (isStartTime) {
        settings.sleepStartTime = tempTime;
        _updateSettings('sleepStartTime', tempTime);
      } else {
        settings.sleepEndTime = tempTime;
        _updateSettings('sleepEndTime', tempTime);
      }

      HiveService.setSettings(settings);
    }
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
    return Scaffold(
      backgroundColor: Colors.white, // Ensure white background
      appBar: AppBar(
        title: const Text('Sleep Mode'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context); // Navigate back to Notification Settings
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Mode Toggle
            SwitchListTile(
              value: settings.sleepMode,
              onChanged: (value) {
                setState(() {
                  settings.sleepMode = value;
                });

                HiveService.setSettings(settings);

                if (value)
                  _updateSettings('sleepMode', 'T');
                else
                  _updateSettings('sleepMode', 'F');
              },
              title: const Text(
                'Sleep mode',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Your notifications will be muted during the times you choose.',
                style: TextStyle(color: Colors.grey),
              ),
              activeColor: const Color(0xFF1C8585), // Thumb color
              activeTrackColor: const Color(0xFF1C8585).withOpacity(0.5), // Track color
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Start Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start time'),
              trailing: TextButton(
                onPressed: () => _pickTime(context, true),
                child: Text(
                  startTime.format(context),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),

            // End Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End time'),
              trailing: TextButton(
                onPressed: () => _pickTime(context, false),
                child: Text(
                  endTime.format(context),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Choose Days
            const Text(
              'Choose days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDays[index] = !selectedDays[index];
                    });

                    HiveService.setSettings(settings);

                    String temp = selectedDays.map((b) => b ? 'T' : 'F').join();

                    _updateSettings('sleepChooseDays', temp);

                    // if (value)
                    //   _updateSettings('sleepMode', 'T');
                    // else
                    //   _updateSettings('sleepMode', 'F');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedDays[index] ? const Color(0xFF1C8585) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                        style: TextStyle(
                          color: selectedDays[index] ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

TimeOfDay _formatTime(String time) {
  int hour = int.tryParse(time.substring(0, 2)) ?? 0;
  int minute = int.tryParse(time.substring(2, 4)) ?? 0;

  return TimeOfDay(hour: hour, minute: minute);
}
