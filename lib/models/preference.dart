import 'package:hive/hive.dart';

part 'preference.g.dart'; // Generated file

@HiveType(typeId: 4)
class Preference {
  @HiveField(0)
  int personality = 0;

  @HiveField(1)
  int guestsOver = 0;

  @HiveField(2)
  int loudNoise = 0;

  @HiveField(3)
  int cleanliness = 0;

  @HiveField(4)
  int smoke = 0;

  @HiveField(5)
  int guestsFeeling = 0;

  @HiveField(6)
  int sociality = 0;

  @HiveField(7)
  int loudTv = 0;

  @HiveField(8)
  int contributeCleaning = 0;

  @HiveField(9)
  int roommateSmoke = 0;

  Preference();
}
