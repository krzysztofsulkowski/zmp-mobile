import 'dart:convert';
import 'dart:io';
import 'package:game_shelf/core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(data);
      
      print('API Request: POST $baseUrl/$endpoint');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: body,
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error connecting to API: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String errorMessage = 'Request failed (${response.statusCode})';
      try {
        final errorData = json.decode(response.body);
        
        // 1. Handle .NET Identity Errors (List of {code, description})
        if (errorData is List) {
          errorMessage = errorData.map((e) => e['description'] ?? e.toString()).join('\n');
        } 
        // 2. Handle ValidationProblemDetails (ModelState errors)
        else if (errorData is Map) {
          if (errorData['errors'] != null) {
            var errors = errorData['errors'];
            if (errors is Map) {
              errorMessage = errors.values.expand((v) => v is List ? v : [v]).join('\n');
            } else if (errors is List) {
              errorMessage = errors.map((e) => e['description'] ?? e.toString()).join('\n');
            }
          } else {
            errorMessage = errorData['message'] ?? errorData['title'] ?? errorMessage;
          }
        }
      } catch (_) {}
      
      throw Exception(errorMessage);
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
}
