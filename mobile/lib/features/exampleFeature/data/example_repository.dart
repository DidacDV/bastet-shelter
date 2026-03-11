import 'package:bastetshelter/core/network/api_client.dart';

class ExampleRepository {
  final ApiClient _apiClient;
  ExampleRepository(this._apiClient);

  Future<String> fetchStatus() async {
    try {
      final response = await _apiClient.get('/');
      return response['status'];
    } catch (e) {
      rethrow;
    }
  }
}