import 'package:get_it/get_it.dart';

import '../features/auth/data/auth_repository.dart';
import 'network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthRepository>(AuthRepository(getIt<ApiClient>()));
}