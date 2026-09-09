import 'dart:convert';
import 'package:supertokens_flutter/http.dart' as http;

import '../config.dart';
import 'mock_backend.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api/v1'; // Development
  // final String baseUrl = 'http://127.0.0.1:8000/api/v1'; // Development
  // final String baseUrl = 'http://192.168.2.168:8000/api/v1'; // Deployment

  /// Makes a GET request to the specified endpoint and returns the parsed JSON response.
  Future<Map<String, dynamic>> get(String endpoint) async {
    if (AppConfig.offlineMode) {
      return MockBackend.get(endpoint);
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"status": "ERROR", "message": "Failed to get. Server Error."};
      }
    } catch (e) {
      return {"status": "ERROR", "message": "Connection to Backend Failed. Please ensure you have Internet Connection."};
    }
  }

  /// Makes a POST request to the specified endpoint with the provided data and returns the parsed JSON response.
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    if (AppConfig.offlineMode) {
      return MockBackend.post(endpoint, data);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"status": "ERROR", "message": "Failed to post. Server Error."};
      }
    } catch (e) {
      return {"status": "ERROR", "message": "Connection to Backend Failed. Please ensure you have Internet Connection."};
    }
  }
}