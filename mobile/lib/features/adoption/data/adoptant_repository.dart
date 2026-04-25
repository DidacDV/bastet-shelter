import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_adoptant/adoptant_model.dart';

class AdoptantRepository {
  final ApiClient _apiClient;

  AdoptantRepository(this._apiClient);

  Future<AdoptantResponse> getAdoptant(int adoptantId) async {
    final response = await _apiClient.get('/adoptant/$adoptantId');
    return AdoptantResponse.fromJson(response);
  }
}
