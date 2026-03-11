import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bastetshelter/core/config.dart';

class ApiClient {
  final http.Client _client = http.Client();
  String? _accessToken;

  void setToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final response = await _client.get(
      url,
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postForm(String endpoint, {Map<String, String>? body}) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final response = await _client.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
