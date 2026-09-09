import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supertokens_flutter/supertokens.dart';

import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ntfy_dart/ntfy_dart.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth_service.dart';
import 'cryptography_service.dart';
import 'hive_service.dart';
import 'db_service.dart';

import '../models/auth.dart';
import '../models/profile.dart';
import '../models/settings.dart';
import '../models/user.dart';
import '../models/preference.dart';

import '../helpers/auth_box_helper.dart';

import '../config.dart';

import '../main.dart';

class MainInitService {
  MainInitService();

  // Initializes Supertokens for authentication
  static void initSupertoken() {
    if (AppConfig.offlineMode) {
      return;
    }

    SuperTokens.init(
      apiDomain: "http://localhost:8000",
      // apiDomain: "http://192.168.2.168:8000",
      apiBasePath: "/api/v1/auth",
    );
  }

  // Initializes Hive database and registers adapters
  static Future<void> initHive() async {
    // Initialize Hive in the app's documents directory
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);

    // Register Hive adapters for models
    Hive.registerAdapter(AuthAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProfileAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(PreferenceAdapter());

    // Open required Hive boxes
    await Hive.openBox('authBox');
    await Hive.openBox('appBox');
  }

  // Sets up default Auth model and checks user authentication status
  static Future<void> initAuth() async {
    if (AppConfig.offlineMode) {
      await AuthService.checkAuth();
      return;
    }

    HiveService.setAuth(Auth());
    await AuthService.checkAuth();
  }

  // Requests required permissions for foreground task (notifications, battery optimization)
  static Future<void> requestPermissions() async {
    // Check notification permission
    final NotificationPermission notificationPermission = await FlutterForegroundTask.checkNotificationPermission();

    if (Platform.isAndroid) {
      // Request battery optimization permission for Android 12+
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Request notification permission if not already granted
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
  }

  // Initializes the foreground service configuration
  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // Starts or restarts the foreground service
  static Future<ServiceRequestResult> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'RoomieMatch Notification is Running',
        notificationText: '',
        callback: startCallback,
      );
    }
  }

  // Stops the foreground service
  static Future<ServiceRequestResult> stopService() {
    return FlutterForegroundTask.stopService();
  }

  // Initializes ntfy client and listens for incoming notifications
  static Future<void> initNtfy(FlutterLocalNotificationsPlugin notificationsPlugin, NotificationDetails notificationDetails, NotificationDetails summaryNotificationDetails) async {
    bool connectionEstablished = false;
    bool isIteration = false;

    do {
      try {
        final String topic = 'notifications';
        final NtfyClient ntfyClient = NtfyClient(basePath: Uri.parse("http://localhost:9980"));
        // final NtfyClient ntfyClient = NtfyClient(basePath: Uri.parse("http://192.168.2.168:9980"));

        // Subscribe to the topic stream
        final Stream<MessageResponse> ntfyStream = (await ntfyClient.getMessageStream([topic]));

        int counter = 0;

        // Listen for messages on the topic
        final StreamSubscription<MessageResponse> ntfyListen = ntfyStream.listen((event) async {
          if (event.event == EventTypes.message) {
            Map<String, dynamic> notification = jsonDecode(event.message ?? '{"userId": "", "title":"", "message":""}');

            // Handle message if it's addressed to the current user
            if (notification['userId'].compareTo(AuthBoxHelper.getUserId()) == 0) {
              String title = await CryptographyService.decryptRSA(notification['title']);
              String message = await CryptographyService.decryptRSA(notification['message']);

              if (title.compareTo("New Match!") == 0) {
                await notificationsPlugin.show(counter, title, message, notificationDetails);
                counter++;

                if ((await notificationsPlugin.getActiveNotifications()).length == 2) {
                  await notificationsPlugin.show(counter, "", "", summaryNotificationDetails);
                }
                counter++;
              }

              if (title.compareTo("New Message!") == 0) {
                await DBService.getAllMessages();

                await notificationsPlugin.show(counter, title, message, notificationDetails);
                counter++;

                if ((await notificationsPlugin.getActiveNotifications()).length == 2) {
                  await notificationsPlugin.show(counter, "", "", summaryNotificationDetails);
                }
                counter++;
              }
            }
          }
        }, onError: (e) {
          initNtfy(notificationsPlugin, notificationDetails, summaryNotificationDetails);
        });

        connectionEstablished = true;
      } catch (c) {
        connectionEstablished = false;
      }

      if (isIteration) {
        await Future.delayed(Duration(seconds: 30));
      }

      isIteration = true;
    } while (!connectionEstablished);
  }

  // Initializes local notifications and starts listening for remote notifications
  static Future<void> initNotification() async {
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);

    FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.initialize(initSettings);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'RoomieMatch',
      'RoomieMatch',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: "RoomieMatch",
    );

    const AndroidNotificationDetails summaryAndroidNotificationDetails = AndroidNotificationDetails(
      'RoomieMatch',
      'RoomieMatch',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: "RoomieMatch",
      setAsGroupSummary: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    const NotificationDetails summaryNotificationDetails = NotificationDetails(android: summaryAndroidNotificationDetails);

    await initNtfy(notificationsPlugin, notificationDetails, summaryNotificationDetails);
  }
}

// Handles events for the foreground service
class MyTaskHandler extends TaskHandler {
  // Called when the foreground task is started
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    MainInitService.initSupertoken();
    await MainInitService.initHive();
    await MainInitService.initNotification();
  }

  // Called when the task repeats (not used here)
  @override
  void onRepeatEvent(DateTime timestamp) {}

  // Called when the task is destroyed
  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  // Called when data is received by the foreground task
  @override
  void onReceiveData(Object data) {}

  // Called when a notification button is pressed
  @override
  void onNotificationButtonPressed(String id) {}

  // Called when the notification is pressed
  @override
  void onNotificationPressed() {}

  // Called when the notification is dismissed
  @override
  void onNotificationDismissed() {}
}