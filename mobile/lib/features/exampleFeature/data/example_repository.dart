import 'package:bastetshelter/core/network/api_client.dart';

class ExampleRepository {
  final ApiClient _apiClient;
  ExampleRepository(this._apiClient);

  Future<String> fetchStatus() async {
    final response = await _apiClient.get('/');
    if (response.statusCode == 200) return response.body;
    throw Exception('Failed to reach backend');
  }
}