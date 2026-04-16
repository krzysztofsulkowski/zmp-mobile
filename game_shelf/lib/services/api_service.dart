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

  // GET request
  Future<dynamic> getData(String endpoint) async {
    try {
      final headers = await _getHeaders();
      print('API Request: GET $baseUrl/$endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      print('API Response Status: ${response.statusCode}');
      return _processResponse(response);
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error connecting to API: $e');
    }
  }

  // POST request
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

  // Multipart POST request for Image Upload
  Future<dynamic> postMultipartData(String endpoint, Map<String, String> fields, File imageFile) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'Image', // Match your API's field name
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);

      print('API Request: Multipart POST $baseUrl/$endpoint');
      print('Fields: $fields');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error uploading image: $e');
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
        if (errorData is List) {
          errorMessage = errorData.map((e) => e['description'] ?? e.toString()).join('\n');
        } else if (errorData is Map) {
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

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
