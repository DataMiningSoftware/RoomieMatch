import 'package:hive/hive.dart';

part 'user.g.dart'; // Generated file

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String userId = "";

  @HiveField(1)
  String email = " ";

  @HiveField(2)
  String username = "";

  User({this.userId = "", this.email = "", this.username = ""});
}