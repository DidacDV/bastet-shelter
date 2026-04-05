import 'package:bastetshelter/core/network/api_client.dart';
import 'animal_model.dart';

class AnimalRepository {
  final ApiClient _apiClient;
  AnimalRepository(this._apiClient);

  Future<List<AnimalSummary>> getAllAnimals() async {
    final data = await _apiClient.get('/animals/short_info');
    return AnimalSummary.listFromJson(data['animals'] as List<dynamic>);
  }
}
