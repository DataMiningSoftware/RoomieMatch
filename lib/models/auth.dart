import 'package:hive/hive.dart';

part 'auth.g.dart'; // Generated file

@HiveType(typeId: 1)
class Auth {
  @HiveField(0)
  bool isAuthenticated = false;

  Auth();
}
