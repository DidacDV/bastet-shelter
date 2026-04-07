import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';

class MedicineRepository {
  final ApiClient _client;
  MedicineRepository(this._client);

  Future<List<Medicine>> getAllMedicines() async {
    final data = await _client.get('/medical/medicines');
    return Medicine.listFromJson(data['medicines'] as List<dynamic>);
  }
}
