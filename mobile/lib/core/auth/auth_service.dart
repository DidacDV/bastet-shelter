import 'package:bastetshelter/core/network/api_client.dart';

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  String? get role => _client.getTokenClaim<String>('role');
  int? get shelterId => _client.getTokenClaim<int>('shelter_id');

  bool get isManager => role == 'MANAGER' || role == 'ADMIN';
  bool get isVolunteer => role == 'VOLUNTEER' || role == 'MANAGER';
  bool get hasNoRole => role == null;
}
