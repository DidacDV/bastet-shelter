import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/features/animals/data/animal_repository.dart';
import 'package:bastetshelter/features/geo/data/geo_repository.dart';
import 'package:bastetshelter/features/medicine/data/medicine_repository.dart';
import 'package:bastetshelter/features/medicine/data/vet_visit_repository.dart';
import 'package:bastetshelter/features/medical_treatments/data/medical_treatment_repository.dart';
import 'package:bastetshelter/features/traits/data/trait_repository.dart';
import 'package:get_it/get_it.dart';

import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:bastetshelter/core/auth/auth_service.dart';
import 'package:bastetshelter/features/home/data/dashboard_repository.dart';
import 'network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthRepository>(AuthRepository(getIt<ApiClient>()));
  getIt.registerSingleton<ShelterRepository>(
    ShelterRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<GeoRepository>(
    () => GeoRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<AnimalRepository>(
    AnimalRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<TraitRepository>(TraitRepository(getIt<ApiClient>()));
  getIt.registerSingleton<MedicineRepository>(
    MedicineRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<VetVisitRepository>(
    VetVisitRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<MedicalTreatmentRepository>(
    MedicalTreatmentRepository(getIt<ApiClient>()),
  );
}
