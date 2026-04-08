import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';

class MedicineRepository {
  final ApiClient _client;
  MedicineRepository(this._client);

  Future<List<Medicine>> getAllMedicines() async {
    final data = await _client.get('/medical/medicines');
    return Medicine.listFromJson(data['medicines'] as List<dynamic>);
  }

  Future<Medicine> createMedicine(String name, int stock) async {
    final data = await _client.post(
      '/medical/medicines',
      body: {'name': name, 'current_stock': stock},
    );
    return Medicine.fromJson(data);
  }

  Future<void> deleteMedicine(int id) async {
    await _client.delete('/medical/medicines/$id');
  }

  Future<Medicine> updateMedicine(int id, String name, int stock) async {
    final data = await _client.patch(
      '/medical/medicines/${id}',
      body: {'name': name, 'current_stock': stock},
    );
    return Medicine.fromJson(data);
  }
}
