import 'package:bastetshelter/core/network/api_client.dart';

class ShelterRepository {
  final ApiClient _client;
  ShelterRepository(this._client);

  /// returns true if an user is member of a shelter, volunteer or manager doesn't matter
  Future<bool> hasMembership() async {
    try {
      await _client.get('/shelters/me');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<void> joinAsVolunteer(String code) async {
    final data = await _client.post('/shelters/join/volunteer/$code', body: {});
    _client.setToken(data['access_token']);
  }

  Future<void> joinAsManager(String code) async {
    final data = await _client.post('/shelters/join/manager/$code', body: {});
    _client.setToken(data['access_token']);
  }

  Future<void> createShelter(String name, String location) async {
    final data = await _client.post('/shelters/', body: {
      'name': name,
      'location': location,
    });
    final token = data['access_token'];
    _client.setToken(token);
  }

  Future<Map<String, dynamic>> getShelterInfo() async {
    final shelterId = _client.getTokenClaim<int>('shelter_id');
    if (shelterId == null) throw ApiException(401, 'No shelter in token');
    return await _client.get('/shelters/?shelter_id=$shelterId');
  }

}