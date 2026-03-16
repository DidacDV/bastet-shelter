import 'dart:convert';

import 'package:bastetshelter/core/navigation_service.dart';
import 'package:http/http.dart' as http;
import 'package:bastetshelter/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException: $statusCode $body';
}

class ApiClient {
  final http.Client _client = http.Client();
  String? _accessToken;
  static const String _tokenKey = 'access_token';

  Future<void> loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
  }

  bool get hasValidToken {
    if (_accessToken == null) return false;
    final exp = getTokenClaim<int>('exp');
    if (exp == null) return false;
    return DateTime.now().isBefore(
        DateTime.fromMillisecondsSinceEpoch(exp * 1000)
    );
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
    }
    if (response.statusCode == 401) {
      NavigationService.instance.redirectToLogin();
      clearToken();
      NavigationService.instance.showSnackBar("api expired", isError: true);
    }
     throw ApiException(response.statusCode, response.body);
  }

  // generic function that returns a value stored in the JWT token
  T? getTokenClaim<T>(String key) {
    if (_accessToken == null) return null;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload)[key] as T?;
    } catch (_) {
      return null;
    }
  }

}
