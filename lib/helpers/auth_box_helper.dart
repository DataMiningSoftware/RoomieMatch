import '../services/hive_service.dart';

import '../models/auth.dart';
import '../models/user.dart';

class AuthBoxHelper {
  static void setIsAuthenticated(bool isAuthenticated) {
    Auth temp = HiveService.getAuth() ?? Auth();

    temp.isAuthenticated = isAuthenticated;

    HiveService.setAuth(temp);
  }

  static String getUserId() {
    User temp = HiveService.getUser();

    return temp.userId;
  }
}
