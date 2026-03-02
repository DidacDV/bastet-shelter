import 'package:http/http.dart' as http;
import 'package:bastetshelter/core/config.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await _client.get(url);
  }
}