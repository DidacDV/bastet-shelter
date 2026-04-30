//needed provider to avoid fetching 3 other providers when loading the adoption process screen
import 'package:bastetshelter/features/adoption/data/models/adoption_adoptant/adoptant_model.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_details.dart';
import 'package:bastetshelter/features/animals/data/models/animal_details_model.dart';
import 'package:bastetshelter/providers/adoption/adoptant_provider.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'adoption_detail_provider.dart';

part 'adoption_screen_data_provider.g.dart';

class AdoptionScreenState {
  final AdoptionProcessDetails process;
  final AnimalDetails animal;
  final AdoptantResponse adoptant;

  AdoptionScreenState({
    required this.process,
    required this.animal,
    required this.adoptant,
  });
}

@riverpod
Future<AdoptionScreenState> adoptionScreenData(Ref ref, int processId) async {
  final process = await ref.watch(adoptionDetailProvider(processId).future);

  final results = await Future.wait([
    ref.watch(animalDetailProvider(process.animalId).future),
    ref.watch(adoptantDetailProvider(process.adoptantId).future),
  ]);

  return AdoptionScreenState(
    process: process,
    animal: results[0] as AnimalDetails,
    adoptant: results[1] as AdoptantResponse,
  );
}
