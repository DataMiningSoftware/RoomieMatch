import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';
import '../services/main_init_service.dart';
import '../services/db_service.dart';

import 'home.dart';
import 'login.dart';
import 'registation/email_verification_page.dart';
import 'registation/first_name_page.dart';
import 'registation/last_name_page.dart';
import 'registation/birthday_page.dart';
import 'registation/gender_selection_page.dart';
import 'registation/location_page.dart';
import 'registation/distance_preference_page.dart';
import 'registation/budget_preference_page.dart';
import 'registation/about_you_page.dart';
import 'registation/rmate_ques_one.dart';
import 'registation/rmate_ques_two.dart';
import 'registation/rmate_ques_three.dart';
import 'registation/more_about_you.dart';
import 'registation/your_interests_page.dart';

class WelcomePage extends StatefulWidget {
  final String title;

  const WelcomePage({super.key, required this.title});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Start a 1-second delay before navigating to the Login Page
    Future.delayed(const Duration(seconds: 1), () async {
      await initBackendConnection();

      if (HiveService.getAuth()?.isAuthenticated ?? false) {
        if (await _getRegistrationStat()) {
          _goToHomePage(context);
        }
      } else {
        _goToLoginPage(context);
      }
    });
  }

  Future<void> initBackendConnection() async {
    String apiResponseStatus;
    bool isIteration = false;
    List<bool> hasErrorDialog = [false];

    do {
      ApiService apiService = ApiService();

      Map<String, dynamic> apiResponse = await apiService.get('utils/frontend-connection-check/');
      apiResponseStatus = apiResponse['status'];

      if (isIteration) {
        if (!hasErrorDialog[0]) {
          _showErrorDialog("Connection to Backend Failed. Please ensure you have Internet Connection.", hasErrorDialog);
          hasErrorDialog[0] = true;
        }
        await Future.delayed(Duration(seconds: 30));
      }

      isIteration = true;
    } while (apiResponseStatus != "OK");

    if (hasErrorDialog[0]) {
      Navigator.of(context).pop();
    }

    await MainInitService.initAuth();
  }

  Future<bool> _getRegistrationStat() async {
    Map<String, dynamic> response = await DBService.getStat("self", "registration");

    if (response["status"] == "ERROR") {
      if (response["message"] != "No record found!") {
        _showErrorDialog(response["error"] ?? "An unknown error occurred.", [false]);
      }
    } else if (response["status"] == "UNKNOWN") {
      _showErrorDialog("An unknown error occurred.", [false]);
    } else if (response["status"] == "OK") {
      final List<dynamic> pageList = [VerificationCodePage(), FirstNamePage(), LastNamePage(), BirthdayPage(), GenderSelectionPage(), LocationPage(), DistancePreferencePage(), BudgetPreferencePage(), AboutYouPage(), RMateQuesOne(), RMateQuesTwo(), RMateQuesThree(), MoreAboutYouPage(), YourInterestPage()];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pageList[int.parse(response["value"])]),
      );
      return false;
    }
    return true;
  }

  void _goToLoginPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInPage()),
    );
  }

  void _goToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message, List<bool> hasErrorDialog) {
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
                hasErrorDialog[0] = false;
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/RoomieMatch_logo.png', width: 160, height: 160),
              const SizedBox(height: 16),
              const Text(
                'RoomieMatch',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'A LOCATION BASED\nROOMMATE MATCHING APP',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
