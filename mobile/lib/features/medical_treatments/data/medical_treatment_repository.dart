import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';

class MedicalTreatmentRepository {
  final ApiClient _client;
  MedicalTreatmentRepository(this._client);

  Future<List<MedicalTreatment>> getTreatmentsByAnimal(int animalId) async {
    final data = await _client.get('/medical/treatments/$animalId');

    final treatmentsList =
        (data['medical_treatments'] ?? data['items'] ?? []) as List<dynamic>;
    return MedicalTreatment.listFromJson(treatmentsList);
  }

  Future<MedicalTreatment> createTreatment(MedicalTreatment treatment) async {
    final data = await _client.post(
      '/medical/treatments',
      body: treatment.toJson(),
    );
    return MedicalTreatment.fromJson(data);
  }

  Future<MedicalTreatment> updateTreatment(
    int id,
    MedicalTreatment treatment,
  ) async {
    final data = await _client.patch(
      '/medical/treatments/$id',
      body: treatment.toJson(),
    );
    return MedicalTreatment.fromJson(data);
  }

  Future<void> deleteTreatment(int id) async {
    await _client.delete('/medical/treatments/$id');
  }
}
