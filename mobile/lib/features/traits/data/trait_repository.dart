import 'package:bastetshelter/core/network/api_client.dart';
import 'trait_model.dart';

class TraitRepository {
  final ApiClient _apiClient;

  TraitRepository(this._apiClient);

  Future<List<Trait>> getAllTraits() async {
    final response = await _apiClient.get('/traits/');

    final traitsList = (response['traits'] ?? []) as List<dynamic>;
    return Trait.listFromJson(traitsList);
  }

  Future<Trait> createTrait(String name) async {
    final response = await _apiClient.post('/traits/', body: {'name': name});
    return Trait.fromJson(response);
  }

  Future<Trait> updateTrait(int id, String newName) async {
    final response = await _apiClient.put(
      '/traits/$id',
      body: {'name': newName},
    );
    return Trait.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteTrait(int id) async {
    await _apiClient.delete('/traits/$id');
  }
}
