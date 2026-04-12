import 'package:bastetshelter/core/network/api_client.dart';

import 'dashboard_model.dart';

class DashboardRepository {
  final ApiClient _client;
  DashboardRepository(this._client);

  Future<DashboardData> getDashboard() async {
    final data = await _client.get('/dashboard/');
    return DashboardData.fromJson(data);
  }
}
