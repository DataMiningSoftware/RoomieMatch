import './api_service.dart';

class MessagingService {
  static final ApiService apiService = ApiService();

  MessagingService();
  
  // Fetches the messaging public key for a given user ID from the API
  static Future<Map<String, dynamic>> getMessagingPublicKey(String userId) async {
    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-messaging-public-key/?user_id=$userId');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  // Updates the user's messaging public key using the provided key and ID
  static Future<Map<String, String>> updateMessagingPublicKey(String publicKey, int keyId) async {
    Map<String, dynamic> publicKeyMap = {"publicKey": "", "keyId": 0};

    publicKeyMap['publicKey'] = publicKey;
    publicKeyMap['keyId'] = keyId;

    Map<String, dynamic> apiResponse = await apiService.post('messaging/update-messaging-public-key/', publicKeyMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  // Retrieves messages for the current user from the API
  static Future<Map<String, dynamic>> getMessages() async {
    Map<String, dynamic> apiResponse = await apiService.get('messaging/get-messages/');

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return apiResponse;
    } else {
      return {"status": "UNKNOWN"};
    }
  }

  // Sends an encrypted message to a specified recipient with the provided key ID
  static Future<Map<String, String>> sendMessages(String recipientUserId, String cipherText, int keyId) async {
    Map<String, dynamic> messagesMap = {"recipientUserId": "", "cipherText": "", "keyId": 0};

    messagesMap['recipientUserId'] = recipientUserId;
    messagesMap['cipherText'] = cipherText;
    messagesMap['keyId'] = keyId;

    Map<String, dynamic> apiResponse = await apiService.post('messaging/send-messages/', messagesMap);

    if (apiResponse['status'] == 'ERROR') {
      return {"status": "ERROR", "error": apiResponse["message"]};
    } else if (apiResponse['status'] == "OK") {
      return {"status": "OK"};
    } else {
      return {"status": "UNKNOWN"};
    }
  }
}