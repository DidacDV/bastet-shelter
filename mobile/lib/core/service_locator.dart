import 'package:get_it/get_it.dart';

import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthRepository>(AuthRepository(getIt<ApiClient>()));
  getIt.registerSingleton<ShelterRepository>(ShelterRepository(getIt<ApiClient>()));
}