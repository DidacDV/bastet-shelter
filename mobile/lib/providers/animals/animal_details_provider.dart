import 'package:bastetshelter/features/animals/data/models/animal_details_model.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_details_provider.g.dart';

@riverpod
Future<AnimalDetails> animalDetail(Ref ref, int animalId) async {
  return ref.read(animalRepositoryProvider).getAnimalDetails(animalId);
}
