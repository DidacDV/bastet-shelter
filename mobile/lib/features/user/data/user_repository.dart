import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/user/data/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<UserProfile> getMyProfile() async {
    final response = await _apiClient.get('/users/me');
    return UserProfile.fromJson(response);
  }

  Future<void> deleteUser() async {
    await _apiClient.delete('/users/me');
  }
}
