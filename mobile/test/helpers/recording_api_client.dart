import 'package:bastetshelter/core/network/api_client.dart';

class RecordingApiClient extends ApiClient {
  final List<String> getCalls = [];
  final List<String> postCalls = [];
  final List<String> patchCalls = [];
  final List<String> deleteCalls = [];

  final Map<String, Map<String, dynamic>> getResponses = {};
  Map<String, dynamic>? defaultGetResponse;

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    getCalls.add(endpoint);
    return getResponses[endpoint] ?? defaultGetResponse ?? {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    postCalls.add(endpoint);
    return {};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    patchCalls.add(endpoint);
    return {};
  }

  @override
  Future<void> delete(String endpoint) async {
    deleteCalls.add(endpoint);
  }
}
