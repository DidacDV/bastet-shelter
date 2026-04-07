import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:bastetshelter/features/animals/data/animal_repository.dart';
import 'package:bastetshelter/features/animals/data/animal_type_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_provider.g.dart';

@riverpod
AnimalRepository animalRepository(Ref ref) {
  return getIt<AnimalRepository>();
}

@riverpod
class Animals extends _$Animals {
  @override
  Future<List<AnimalSummary>> build() async {
    ref.keepAlive();
    return ref.read(animalRepositoryProvider).getAllAnimals();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> registerAnimal({
    required String name,
    required DateTime birthDate,
    DateTime? arrivalDate,
    required String description,
    required String breed,
    required AnimalTypeEnum animalType,
    required int refugeId,
    bool inAdoption = false,
    List<int> traitIds = const [],
  }) async {
    await genericApiCall(() async {
      await ref
          .read(animalRepositoryProvider)
          .registerAnimal(
            name: name,
            birthDate: birthDate,
            arrivalDate: arrivalDate,
            description: description,
            breed: breed,
            animalType: animalType,
            refugeId: refugeId,
            inAdoption: inAdoption,
            traitIds: traitIds,
          );

      ref.invalidateSelf();
      await future;
    });
  }

  Future<void> updateAnimal({
    required int animalId,
    String? name,
    String? breed,
    String? description,
    bool? inAdoption,
  }) async {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (breed != null) updates['breed'] = breed;
    if (description != null) updates['description'] = description;
    if (inAdoption != null) updates['in_adoption'] = inAdoption;

    if (updates.isEmpty) return;

    await genericApiCall(() async {
      await ref.read(animalRepositoryProvider).updateAnimal(animalId, updates);
      ref.invalidateSelf();
      await future;
    });
  }
}
