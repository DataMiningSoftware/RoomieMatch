import 'package:flutter/foundation.dart';
import 'package:supertokens_flutter/supertokens.dart';
import '../models/user2.dart';

class AuthStore with ChangeNotifier {
  User? _user;
  bool isAuthenticated = false;

  String? get getUsername => _user?.getUsername;
  String? get getUserEmail => _user?.getEmail;
  User? get getUser => _user;
  bool get getIsAuthenticated => isAuthenticated;

  set setIsAuthenticated(bool isAuthenticated) {
    this.isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  set setUser(User? user) {
    _user = user;
  }

  void init() async {
    bool sess = await SuperTokens.doesSessionExist();

    if (sess) {
      isAuthenticated = true;
    } else {
      isAuthenticated = false;
    }
  }

  AuthStore();
}