import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/medical/data/medicine_repository.dart';
import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medicine_provider.g.dart';

@riverpod
MedicineRepository medicineRepository(Ref ref) {
  return getIt<MedicineRepository>();
}

@riverpod
class Medicines extends _$Medicines {
  @override
  Future<List<Medicine>> build() async {
    ref.keepAlive();
    return ref.read(medicineRepositoryProvider).getAllMedicines();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addMedicine(String name, int stock) async {
    final previousState = await future;

    final newMedicine = await ref
        .read(medicineRepositoryProvider)
        .createMedicine(name, stock);
    state = AsyncValue.data([...previousState, newMedicine]);
  }

  Future<void> updateMedicine(int id, String newName, int newStock) async {
    final previousState = await future;

    final updatedMedicine = await ref
        .read(medicineRepositoryProvider)
        .updateMedicine(id, newName, newStock);

    state = AsyncValue.data([
      for (final med in previousState)
        if (med.id == id) updatedMedicine else med,
    ]);
  }

  Future<void> deleteMedicine(int id) async {
    final previousState = await future;

    await ref.read(medicineRepositoryProvider).deleteMedicine(id);
    state = AsyncValue.data(
      previousState.where((med) => med.id != id).toList(),
    );
  }
}
