import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/shelter/data/refuge_model.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';

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

  Future<void> createShelter(
    String name,
    String location,
    String refugeName,
    String email,
  ) async {
    final data = await _client.post(
      '/shelters/',
      body: {
        'name': name,
        'province_id': location,
        'refuge_name': refugeName,
        'shelter_email': email,
      },
    );
    final token = data['access_token'];
    _client.setToken(token);
  }

  Future<Shelter> getShelterInfo() async {
    final shelterId = _client.getTokenClaim<int>('shelter_id');
    if (shelterId == null) throw ApiException(401, 'No shelter in token');
    final response = await _client.get('/shelters/info');
    return Shelter.fromJson(response);
  }

  Future<String> changeVolunteerCode() async {
    final shelterId = _client.getTokenClaim<int>('shelter_id');
    if (shelterId == null) throw ApiException(401, 'No shelter in token');
    final response = await _client.post('/shelters/reset/volunteer');
    return response['code'];
  }

  Future<String> changeManagerCode() async {
    final shelterId = _client.getTokenClaim<int>('shelter_id');
    if (shelterId == null) throw ApiException(401, 'No shelter in token');
    final response = await _client.post('/shelters/reset/manager');
    return response['code'];
  }

  Future addNewRefuge(String name, String locationId) async {
    final response = await _client.post(
      '/refuges/',
      body: {'name': name, 'province_id': locationId},
    );
    return Refuge.fromJson(response);
  }

  Future<void> deleteRefuge(int refugeId) async {
    await _client.delete('/refuges/$refugeId');
  }

  Future<Refuge> updateRefuge(
    int refugeId,
    String name,
    String locationId,
  ) async {
    final response = await _client.put(
      '/refuges/$refugeId',
      body: {'name': name, 'province_id': locationId},
    );
    return Refuge.fromJson(response);
  }

  Future<Shelter> updateShelter(
    String shelterName,
    String locationId,
    String email,
  ) async {
    final response = await _client.put(
      '/shelters/',
      body: {'name': shelterName, 'province_id': locationId, 'email': email},
    );
    return Shelter.fromJson(response);
  }
}
