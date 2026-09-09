import 'package:hive/hive.dart';

import '../models/auth.dart';
import '../models/user.dart';
import '../models/profile.dart';
import '../models/settings.dart';
import '../models/preference.dart';

class HiveService {
  static final authBox = Hive.box('authBox');
  static final appBox = Hive.box('appBox');

  // Retrieves the stored Auth object from 'authBox'
  static Auth? getAuth() {
    return authBox.get('auth');
  }

  // Stores the provided Auth object in 'authBox'
  static void setAuth(Auth auth) {
    authBox.put('auth', auth);
  }

  // Retrieves the stored User object from 'authBox' or returns a new User if not found
  static User getUser() {
    return authBox.get('user') ?? User();
  }

  // Stores the provided User object in 'authBox'
  static void setUser(User user) {
    authBox.put('user', user);
  }

  // Deletes the User object from 'authBox'
  static void deleteUser() {
    authBox.delete('user');
  }

  // Clears all data from 'authBox'
  static void clearAuthBox() {
    authBox.clear();
  }

  // Retrieves the stored Profile object from 'appBox' or returns a new Profile if not found
  static Profile getProfile() {
    return appBox.get('profile') ?? Profile();
  }

  // Stores the provided Profile object in 'appBox'
  static void setProfile(Profile profile) {
    appBox.put('profile', profile);
  }

  // Deletes the Profile object from 'appBox'
  static void deleteProfile() {
    appBox.delete('profile');
  }

  // Retrieves the stored Settings object from 'appBox' or returns a new Settings if not found
  static Settings getSettings() {
    return appBox.get('settings') ?? Settings();
  }

  // Stores the provided Settings object in 'appBox'
  static void setSettings(Settings settings) {
    appBox.put('settings', settings);
  }

  // Deletes the Settings object from 'appBox'
  static void deleteSettings() {
    appBox.delete('settings');
  }

  // Retrieves the stored Preference object from 'appBox' or returns a new Preference if not found
  static Preference getPreference() {
    return appBox.get('preference') ?? Preference();
  }

  // Stores the provided Preference object in 'appBox'
  static void setPreference(Preference preference) {
    appBox.put('preference', preference);
  }

  // Deletes the Preference object from 'appBox'
  static void deletePreference() {
    appBox.delete('preference');
  }
}