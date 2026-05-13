import 'package:bastetshelter/core/auth/auth_service.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isManagerProvider = Provider<bool>((ref) {
  final authService = getIt<AuthService>();
  return authService.isManager;
});
