import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/animals/data/animal_model.dart';
import 'package:bastetshelter/features/animals/data/animal_repository.dart';
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
}
