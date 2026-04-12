import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/medical_treatments/data/medical_treatment_repository.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medical_treatment_provider.g.dart';

@riverpod
MedicalTreatmentRepository medicalTreatmentRepository(Ref ref) {
  return getIt<MedicalTreatmentRepository>();
}

@riverpod
class MedicalTreatments extends _$MedicalTreatments {
  @override
  Future<List<MedicalTreatment>> build(int animalId) async {
    ref.keepAlive();
    return ref
        .read(medicalTreatmentRepositoryProvider)
        .getTreatmentsByAnimal(animalId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addTreatment(MedicalTreatment treatment) async {
    final previousState = await future;

    final newTreatment = await ref
        .read(medicalTreatmentRepositoryProvider)
        .createTreatment(treatment);

    state = AsyncValue.data([...previousState, newTreatment]);
  }

  Future<void> updateTreatment(int id, MedicalTreatment treatment) async {
    final previousState = await future;

    final updatedTreatment = await ref
        .read(medicalTreatmentRepositoryProvider)
        .updateTreatment(id, treatment);

    state = AsyncValue.data([
      for (final t in previousState)
        if (t.id == id) updatedTreatment else t,
    ]);
  }

  Future<void> deleteTreatment(int id) async {
    final previousState = await future;

    await ref.read(medicalTreatmentRepositoryProvider).deleteTreatment(id);

    state = AsyncValue.data(previousState.where((t) => t.id != id).toList());
  }

  Future<void> toggleStatus(int id, MedicineStatus newStatus) async {
    final previousState = await future;
    final treatmentToUpdate = previousState.firstWhere((t) => t.id == id);

    final updatedTreatment = treatmentToUpdate.copyWith(status: newStatus);

    await updateTreatment(id, updatedTreatment);
  }
}
