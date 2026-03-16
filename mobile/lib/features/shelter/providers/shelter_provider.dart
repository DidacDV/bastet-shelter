// features/shelter/providers/shelter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';

part 'shelter_provider.g.dart';

@riverpod
ShelterRepository shelterRepository(Ref ref) {
  return getIt<ShelterRepository>();
}

@riverpod
class ShelterNotifier extends _$ShelterNotifier {
  @override
  Future<Shelter> build() async {
    return ref.read(shelterRepositoryProvider).getShelterInfo();
  }

  Future<void> resetVolunteerCode() async {
    final newCode = await ref.read(shelterRepositoryProvider).changeVolunteerCode();
    state = AsyncData(state.value!.copyWith(volunteerCode: newCode));
  }

  Future<void> resetManagerCode() async {
    final newCode = await ref.read(shelterRepositoryProvider).changeManagerCode();
    state = AsyncData(state.value!.copyWith(managerCode: newCode));
  }
}