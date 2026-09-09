import 'package:supertokens_flutter/supertokens.dart';

import '../config.dart';
import '../helpers/auth_box_helper.dart';
import '../models/user.dart';
import './hive_service.dart';
import './api_service.dart';

class AuthService {
  static final ApiService apiService = ApiService();

  AuthService();

  // Handles user login by sending email and password to the backend
  static Future<Map<String, String>> login(String email, String password) async {
    if (AppConfig.offlineMode) {
      AuthBoxHelper.setIsAuthenticated(true);
      HiveService.deleteUser();
      HiveService.setUser(User(userId: "mock-user-id", username: email, email: email));
      return {"status": "OK"};
    }

    Map<String, dynamic> signinMap = {
      "formFields": [
        {"id": "email", "value": ""},
        {"id": "password", "value": ""}
      ] // Leave this as an empty string initially
    };

    signinMap['formFields'][0]['value'] = email;
    signinMap['formFields'][1]['value'] = password;

    Map<String, dynamic> apiResponse = await apiService.post('auth/signin', signinMap);

    if (apiResponse['status'] == "FIELD_ERROR") {
      return {"status": "ERROR", "error": apiResponse["formFields"][0]["error"]};
    } else if (apiResponse['status'] == 'WRONG_CREDENTIALS_ERROR') {
      return {"status": "ERROR", "error": "The input email and password combination is incorrect."};
    } else if (apiResponse['status'] == "OK") {
      AuthBoxHelper.setIsAuthenticated(true);
      HiveService.deleteUser();
      HiveService.setUser(User(userId: apiResponse["user"]["id"], username: apiResponse["user"]["emails"][1], email: apiResponse["user"]["emails"][0]));

      return {"status": "OK"};
    } else if (apiResponse['status'] == "ERROR") {
      return {"status": apiResponse['status'], "error": apiResponse['error']};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  // Handles user signup by sending email, password, and username to the backend
  static Future<Map<String, String>> signup(String email, String password, String username) async {
    if (AppConfig.offlineMode) {
      AuthBoxHelper.setIsAuthenticated(true);
      HiveService.deleteUser();
      HiveService.setUser(User(userId: "mock-user-id", username: username, email: email));
      return {"status": "OK"};
    }

    Map<String, dynamic> signupMap = {
      "formFields": [
        {"id": "email", "value": "na"},
        {"id": "actualEmail", "value": ""},
        {"id": "username", "value": ""},
        {"id": "password", "value": ""}
      ] // Leave this as an empty string initially
    };

    signupMap['formFields'][1]['value'] = email;
    signupMap['formFields'][2]['value'] = username;
    signupMap['formFields'][3]['value'] = password;

    Map<String, dynamic> apiResponse = await apiService.post('auth/signup', signupMap);

    if (apiResponse['status'] == "FIELD_ERROR") {
      return {"status": "ERROR", "error": apiResponse["formFields"][0]["error"]};
    } else if (apiResponse['status'] == "OK") {
      AuthBoxHelper.setIsAuthenticated(true);
      HiveService.deleteUser();
      HiveService.setUser(User(userId: apiResponse["user"]["id"], username: username, email: email));

      return {"status": "OK"};
    } else if (apiResponse['status'] == "ERROR") {
      return {"status": apiResponse['status'], "error": apiResponse['error']};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  // Checks if a user is already authenticated when the app loads
  static Future<void> checkAuth() async {
    if (AppConfig.offlineMode) {
      return;
    }

    if (await SuperTokens.doesSessionExist()) {
      AuthBoxHelper.setIsAuthenticated(true);
    } else {
      AuthBoxHelper.setIsAuthenticated(false);
    }
  }

  // Logs out the current user and clears local data
  static Future<void> signOut() async {
    if (!AppConfig.offlineMode) {
      await SuperTokens.signOut();
    }

    HiveService.deleteUser();
    HiveService.deleteSettings();
    AuthBoxHelper.setIsAuthenticated(false);
  }
}