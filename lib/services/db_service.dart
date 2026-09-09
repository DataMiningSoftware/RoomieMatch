import 'package:RoomieMatch/services/cryptography_service.dart';
import 'package:RoomieMatch/services/message_key_db_service.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import './api_service.dart';
import './chat_db_service.dart';
import './message_db_service.dart';
import './mock_backend.dart';

import '../helpers/auth_box_helper.dart';

class DBService {
  static final ApiService apiService = ApiService();

  DBService();

  /// Fetches all user settings from the backend API.
  static Future<Map<String, dynamic>> getAllSettings() async {
    Map<String, dynamic> apiResponse = await apiService.get('db/get-all-settings/');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Updates a specific setting field in the backend with a new value.
  static Future<Map<String, String>> updateSettingsField(String field, String value) async {
    Map<String, dynamic> settingsMap = {"field": "", "value": ""};

    settingsMap['field'] = field;
    settingsMap['value'] = value;

    Map<String, dynamic> apiResponse = await apiService.post('db/update-settings/', settingsMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Retrieves all profile information for the current user from the backend.
  static Future<Map<String, dynamic>> getAllProfile() async {
    Map<String, dynamic> apiResponse = await apiService.get('db/get-all-profile/');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Updates a specific profile field with a new value via the backend.
  static Future<Map<String, String>> updateProfileField(String field, String value) async {
    Map<String, dynamic> profileMap = {"field": "", "value": ""};

    profileMap['field'] = field;
    profileMap['value'] = value;

    Map<String, dynamic> apiResponse = await apiService.post('db/update-profile/', profileMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Updates a specific preference field with a new value via the backend.
  static Future<Map<String, String>> updatePreferenceField(String field, String value) async {
    Map<String, dynamic> preferenceMap = {"field": "", "value": ""};

    preferenceMap['field'] = field;
    preferenceMap['value'] = value;

    Map<String, dynamic> apiResponse = await apiService.post('db/update-preference/', preferenceMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Retrieves all match data for the current user.
  static Future<Map<String, dynamic>> getAllMatches() async {
    Map<String, dynamic> apiResponse = await apiService.get('db/get-all-matches/');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Updates the match status between the current user and another user.
  static Future<Map<String, String>> updateMatch(String compareUserId, int currMatchType) async {
    Map<String, dynamic> matchMap = {"compareUserId": "", "currMatchType": 2};

    matchMap['compareUserId'] = compareUserId;
    matchMap['currMatchType'] = currMatchType;

    Map<String, dynamic> apiResponse = await apiService.post('db/update-match/', matchMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Retrieves a specific stat value for a given user and key.
  static Future<Map<String, dynamic>> getStat(String userId, String key) async {
    Map<String, dynamic> apiResponse = await apiService.get('db/get-stat/?user_id=$userId&key=$key');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Updates a specific stat value for a given user and key.
  static Future<Map<String, String>> updateStat(String userId, String key, String value) async {
    Map<String, dynamic> statMap = {"userId": "", "key": "", "value": ""};

    statMap['userId'] = userId;
    statMap['key'] = key;
    statMap['value'] = value;

    Map<String, dynamic> apiResponse = await apiService.post('db/update-stat/', statMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Deletes a specific stat entry for a given user and key.
  static Future<Map<String, String>> deleteStat(String userId, String key) async {
    Map<String, dynamic> apiResponse = await apiService.get('db/delete-stat/?user_id=$userId&key=$key');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Triggers the backend process to calculate or update matches.
  static Future<Map<String, String>> triggerProcessMatch() async {
    Map<String, dynamic> apiResponse = await apiService.get('logic/process-match/');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  /// Fetches all chat relationships and inserts them into the local database.
  static Future<void> getAllChats() async {
    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-all-chats/');

    if (apiResponse['status'] == "OK") {
      for (int i = 0; i < apiResponse['matched'].length; i++) {
        await ChatDBService().insertChat(apiResponse['matched'][i]["userId"], apiResponse['matched'][i]["chatUserId"], apiResponse['matched'][i]['firstName'], apiResponse['matched'][i]["latestTime"].toInt());
      }
    }
  }

  /// Fetches all messages for the current user, decrypts them, and stores them locally.
  static Future<List<Map<String, dynamic>>> getAllMessages() async {
    await getAllChats();

    if (AppConfig.offlineMode) {
      await MockBackend.seedMessages();
      return [];
    }

    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-messages/');
    String currUserId = AuthBoxHelper.getUserId();
    List<Map<String, dynamic>> result = [];
    String plainText = "";

    if (apiResponse['status'] == "OK") {
      for (int i = 0; i < apiResponse['messages'].length; i++) {
        final List<Map<String, dynamic>> keyResponse = await MessageKeyDBService().getMessagesPrivateKeyById(apiResponse['messages'][i]['keyId']);

        if (keyResponse.isNotEmpty) {
          plainText = await CryptographyService.decryptMessage(keyResponse[0]['private_key'], apiResponse['messages'][i]['cipherText']);
        } else {
          plainText = "An Error Occured";
        }

        await MessageDBService().insertMessage(apiResponse['messages'][i]["senderUserId"], currUserId, plainText, apiResponse['messages'][i]["timestamp"]);
        result.add({
          "senderUserId": apiResponse['messages'][i]["senderUserId"],
          "plainText": plainText,
          "timestamp": apiResponse['messages'][i]["timestamp"],
        });
      }
    }

    return result;
  }

  /// Sends an encrypted message to a recipient user via the backend.
  static Future<void> sendMessage(String recipientUserId, String plainText) async {
    String currUserId = AuthBoxHelper.getUserId();
    String timestamp = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    if (AppConfig.offlineMode) {
      await MessageDBService().insertMessage(currUserId, recipientUserId, plainText, timestamp);
      return;
    }

    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-messaging-public-key/?user_id=$recipientUserId');

    timestamp = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    if (apiResponse['status'] == "OK") {
      String cipherText = await CryptographyService.encryptMessage(apiResponse['publicKey'], plainText);

      Map<String, dynamic> messageMap = {"recipientUserId": "", "cipherText": "", "keyId": -1, "timestamp": ""};

      messageMap['recipientUserId'] = recipientUserId;
      messageMap['cipherText'] = cipherText;
      messageMap['keyId'] = apiResponse['keyId'];
      messageMap['timestamp'] = timestamp;

      String apiResponseStatus;
      bool isIteration = false;

      do {
        Map<String, dynamic> apiResponse = await apiService.post('messaging/send-messages/', messageMap);

        apiResponseStatus = apiResponse['status'];

        if (isIteration) {
          await Future.delayed(Duration(seconds: 30));
        }

        isIteration = true;
      } while (apiResponseStatus == 'ERROR' || apiResponseStatus == 'UNKNOWN');
    } else {
      plainText = "An Error Occured";
    }

    await MessageDBService().insertMessage(currUserId, recipientUserId, plainText, timestamp);
  }
}