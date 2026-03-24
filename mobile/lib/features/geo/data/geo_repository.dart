import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/geo/data/province_model.dart';

class GeoRepository {
  final ApiClient _apiClient;
  GeoRepository(this._apiClient);

  Future<List<Province>> getAllProvinces() async {
   final data = await _apiClient.get("/geo/provinces");
   return Province.listFromJson(data["provinces"] as List<dynamic>);
  }
}