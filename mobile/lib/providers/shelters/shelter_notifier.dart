import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';

part 'shelter_notifier.g.dart';

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
    await genericApiCall(() async {
      final newCode = await ref
          .read(shelterRepositoryProvider)
          .changeVolunteerCode();
      state = AsyncData(state.value!.copyWith(volunteerCode: newCode));
    });
  }

  Future<void> resetManagerCode() async {
    await genericApiCall(() async {
      final newCode = await ref
          .read(shelterRepositoryProvider)
          .changeManagerCode();
      state = AsyncData(state.value!.copyWith(managerCode: newCode));
    });
  }

  Future<void> addRefuge(String name, String locationId) async {
    await genericApiCall(() async {
      final refuge = await ref
          .read(shelterRepositoryProvider)
          .addNewRefuge(name, locationId);
      state = AsyncData(
        state.value!.copyWith(refuges: [...state.value!.refuges, refuge]),
      );
      return refuge;
    });
  }

  Future<void> deleteRefuge(int refugeId) async {
    await genericApiCall(() async {
      await ref.read(shelterRepositoryProvider).deleteRefuge(refugeId);
      final currentRefuges = state.value!.refuges;
      final updatedRefuges = currentRefuges
          .where((r) => r.id != refugeId)
          .toList();

      state = AsyncData(state.value!.copyWith(refuges: updatedRefuges));
    });
  }

  Future<void> updateRefuge(
    int refugeId,
    String name,
    String locationId,
  ) async {
    await genericApiCall(() async {
      final updatedRefuge = await ref
          .read(shelterRepositoryProvider)
          .updateRefuge(refugeId, name, locationId);

      //replace previous refuge with updated refuge
      final updatedList = state.value!.refuges.map((refuge) {
        return refuge.id == refugeId ? updatedRefuge : refuge;
      }).toList();

      state = AsyncData(state.value!.copyWith(refuges: updatedList));
    });
  }

  Future<void> updateShelter({
    required String name,
    required String provinceId,
    required String email,
  }) async {
    await genericApiCall(() async {
      final updated = await ref
          .read(shelterRepositoryProvider)
          .updateShelter(name, provinceId, email);
      final newName = updated.name;
      final newProvince = updated.province;
      state = AsyncData(
        state.value!.copyWith(
          name: newName,
          province: newProvince,
          email: email,
        ),
      );
    });
  }
}
