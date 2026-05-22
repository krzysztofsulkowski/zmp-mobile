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

  Future<dynamic> getData(String endpoint) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final headers = {'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error connecting to API: $e');
    }
  }

  Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final headers = {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
      final response = await http.post(Uri.parse('$baseUrl/$endpoint'), headers: headers, body: json.encode(data));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error connecting to API: $e');
    }
  }

  Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final headers = {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
      final response = await http.put(Uri.parse('$baseUrl/$endpoint'), headers: headers, body: json.encode(data));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error connecting to API: $e');
    }
  }

  Future<dynamic> deleteData(String endpoint) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final headers = {'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Error connecting to API: $e');
    }
  }

  // Generalized Multipart Request
  Future<dynamic> sendMultipart({
    required String endpoint,
    required String method,
    required Map<String, String> fields,
    File? imageFile,
    String fileKey = 'Image',
  }) async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      var request = http.MultipartRequest(method, Uri.parse('$baseUrl/$endpoint'));
      
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(fields);

      if (imageFile != null && imageFile.path.isNotEmpty && await imageFile.exists()) {
        var multipartFile = await http.MultipartFile.fromPath(fileKey, imageFile.path);
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error uploading: $e');
    }
  }

  // For backward compatibility with AddGameView
  Future<dynamic> postMultipartData(String endpoint, Map<String, String> fields, File imageFile) async {
    return sendMultipart(endpoint: endpoint, method: 'POST', fields: fields, imageFile: imageFile, fileKey: 'Image');
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String errorMessage = 'Request failed (${response.statusCode})';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData['detail'] != null) errorMessage = errorData['detail'];
        else if (errorData is Map && errorData['message'] != null) errorMessage = errorData['message'];
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
