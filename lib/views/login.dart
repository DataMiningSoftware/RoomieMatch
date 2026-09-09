import 'package:RoomieMatch/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/settings.dart';

import '../config.dart';
import '../app_theme.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/main_init_service.dart';
import '../services/cryptography_service.dart';

import 'home.dart';
import 'registation/rule_page.dart';
import 'registation/email_verification_page.dart';
import 'registation/first_name_page.dart';
import 'registation/last_name_page.dart';
import 'registation/birthday_page.dart';
import 'registation/gender_selection_page.dart';
import 'registation/location_page.dart';
import 'registation/distance_preference_page.dart';
import 'registation/budget_preference_page.dart';
import 'registation/about_you_page.dart';
import 'registation/more_about_you.dart';
import 'registation/your_interests_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simple login logic
  void _logIn() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in both fields.');
    } else {
      Map<String, String> response = await AuthService.login(username, password);

      if (response["status"] == "OK") {
        await Future.delayed(Duration(milliseconds: 300));
        if (await _getRegistrationStat()) {
          if (!AppConfig.offlineMode) {
            await MainInitService.requestPermissions();
            MainInitService.initService();
            await MainInitService.startService();
          }

          await CryptographyService.initRSA();

          await _getAllSettings();
          await _getAllProfile();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else if (response["status"] == "ERROR") {
        _showErrorDialog(response["error"] ?? "An unknown error occurred.");
      } else if (response["status"] == "UNKNOWN") {
        _showErrorDialog("An unknown error occurred.");
      }
    }
  }

  Future<bool> _getRegistrationStat() async {
    Map<String, dynamic> response = await DBService.getStat("self", "registration");

    if (response["status"] == "ERROR") {
      if (response["error"] != "No record found!") {
        _showErrorDialog(response["error"] ?? "An unknown error occurred.");
      }
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    } else if (response["status"] == "OK") {
      final List<dynamic> pageList = [VerificationCodePage(), FirstNamePage(), LastNamePage(), BirthdayPage(), GenderSelectionPage(), LocationPage(), DistancePreferencePage(), BudgetPreferencePage(), AboutYouPage(), MoreAboutYouPage(), YourInterestPage()];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pageList[int.parse(response["value"])]),
      );
      return false;
    }
    return true;
  }

  Future<void> _getAllSettings() async {
    Map<String, dynamic> response = await DBService.getAllSettings();

    if (response["status"] == "ERROR") {
      _showErrorDialog(response["error"] ?? "An unknown error occurred.");
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    } else if (response["status"] == "OK") {
      HiveService.deleteSettings();

      Settings settings = Settings();
      settings.notifPauseAll = response["notifPauseAll"] == "T" ? true : false;
      settings.notifMessages = response["notifMessages"] == "T" ? true : false;
      settings.notifNewMatch = response["notifNewMatch"] == "T" ? true : false;
      settings.sleepMode = response["sleepMode"] == "T" ? true : false;
      settings.sleepStartTime = response["sleepStartTime"];
      settings.sleepEndTime = response["sleepEndTime"];
      for (int i = 0; i < 7; i++) {
        settings.sleepChooseDays[i] = response["sleepChooseDays"][i] == "T" ? true : false;
      }
      settings.accountPrivacy = response["accountPrivacy"] == "T" ? true : false;

      HiveService.setSettings(settings);
    }
  }

  Future<void> _getAllProfile() async {
    Map<String, dynamic> response = await DBService.getAllProfile();

    if (response["status"] == "ERROR") {
      _showErrorDialog(response["error"] ?? "An unknown error occurred.");
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.");
    } else if (response["status"] == "OK") {
      HiveService.deleteProfile();

      Profile profile = Profile();
      profile.firstName = response["firstName"] ?? "";
      profile.lastName = response["lastName"] ?? "";
      profile.age = response["age"] ?? 0;
      profile.birthday = response["birthday"];
      profile.gender = response["gender"] ?? "M";
      profile.latitude = response["latitude"] ?? 0;
      profile.longitude = response["longitude"] ?? 0;
      profile.distance = response["distance"] ?? 0;
      profile.budget = response["budget"];
      profile.description = response["description"];
      profile.schoolJob = response["schoolJob"];
      profile.allergies = response["allergies"];

      HiveService.setProfile(profile);
    }
  }

  // Navigate to the Register Page
  void _goToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RulePage()), // Update with your actual RegisterPage
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/RoomieMatch_logo.png', height: 110, width: 110),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Log in to find your perfect roommate',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Log In button
                  ElevatedButton(
                    onPressed: _logIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C8585),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register text link
                  TextButton(
                    onPressed: _goToRegisterPage,
                    child: const Text(
                      "Don't have an account? Register here.",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
