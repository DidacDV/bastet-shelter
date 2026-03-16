import 'package:bastetshelter/core/network/api_client.dart';

class AuthRepository {
  final ApiClient _client;
  AuthRepository(this._client);

  Future<String> login(String email, String password) async {
    final data = await _client.postForm('/auth/login', body: {
      'username': email,
      'password': password,
    });
    final token = data['access_token'];
    await _client.setToken(token);
    return token;
  }

  Future<String> register(String name, String lastName1, String? lastName2, String email, String password) async {
    final data = await _client.post('/auth/register', body: {
      'name': name,
      'last_name_1': lastName1,
      'last_name_2': ?lastName2,
      'email': email,
      'password': password,
    });
    final token = data['access_token'];
    await _client.setToken(token);
    return token;
  }

  Future<void> logout() async {
    await _client.clearToken();
  }
}
