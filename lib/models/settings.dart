import 'package:hive/hive.dart';

part 'settings.g.dart'; // Generated file

@HiveType(typeId: 3)
class Settings {
  @HiveField(0)
  bool notifPauseAll = false;

  @HiveField(1)
  bool notifMessages = false;

  @HiveField(2)
  bool notifNewMatch = false;

  @HiveField(3)
  bool sleepMode = false;

  @HiveField(4)
  String sleepStartTime = "0000";

  @HiveField(5)
  String sleepEndTime = "0000";

  @HiveField(6)
  List<bool> sleepChooseDays = [false, false, false, false, false, false, false];

  @HiveField(7)
  bool accountPrivacy = false;

  Settings();
}
