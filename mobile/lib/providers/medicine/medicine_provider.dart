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
}
