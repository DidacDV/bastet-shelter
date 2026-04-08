import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';

class VetVisitRepository {
  final ApiClient _client;
  VetVisitRepository(this._client);

  Future<List<VetVisit>> getVetVisitsByAnimal(int animalId) async {
    final data = await _client.get('/medical/vet-visits/$animalId');

    final vetVisitsList = (data['traits'] ?? []) as List<dynamic>;
    return VetVisit.listFromJson(vetVisitsList);
  }

  Future<VetVisit> createVetVisit(VetVisit visit) async {
    final data = await _client.post(
      '/medical/vet-visits',
      body: visit.toJson(),
    );
    return VetVisit.fromJson(data);
  }

  Future<VetVisit> updateVetVisit(int id, VetVisit visit) async {
    final data = await _client.patch(
      '/medical/vet-visits/$id',
      body: visit.toJson(),
    );
    return VetVisit.fromJson(data);
  }

  Future<void> deleteVetVisit(int id) async {
    await _client.delete('/medical/vet-visits/$id');
  }
}
