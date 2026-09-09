import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'services/main_init_service.dart';
import 'services/hive_service.dart';

import 'config.dart';
import 'app_theme.dart';

import 'views/welcome.dart';

void main() async {
  // Ensure Flutter widgets are initialized before running async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services required at app start
  MainInitService.initSupertoken();
  await MainInitService.initHive();
  await MainInitService.initAuth();

  // If user is authenticated, initialize background/service-related features
  if ((HiveService.getAuth()?.isAuthenticated ?? false) && !AppConfig.offlineMode) {
    await MainInitService.requestPermissions();
    MainInitService.initService();
    await MainInitService.startService();
  }

  // Run the application
  runApp(const MyApp());
}

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  // Set the task handler for foreground task
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomieMatch',
      theme: AppTheme.light(),
      home: const WelcomePage(title: 'RoomieMatch'),
    );
  }
}