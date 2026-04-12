import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:bastetshelter/features/medicine/data/vet_visit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vet_visit_provider.g.dart';

@riverpod
VetVisitRepository vetVisitRepository(Ref ref) {
  return getIt<VetVisitRepository>();
}

@riverpod
class VetVisits extends _$VetVisits {
  @override
  Future<List<VetVisit>> build(int animalId) async {
    ref.keepAlive();
    return ref.read(vetVisitRepositoryProvider).getVetVisitsByAnimal(animalId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addVisit(VetVisit visit) async {
    final previousState = await future;

    final newVisit = await ref
        .read(vetVisitRepositoryProvider)
        .createVetVisit(visit);

    state = AsyncValue.data([...previousState, newVisit]);
  }

  Future<void> updateVisit(int id, VetVisit visit) async {
    final previousState = await future;

    final updatedVisit = await ref
        .read(vetVisitRepositoryProvider)
        .updateVetVisit(id, visit);

    state = AsyncValue.data([
      for (final v in previousState)
        if (v.id == id) updatedVisit else v,
    ]);
  }

  Future<void> deleteVisit(int id) async {
    final previousState = await future;

    await ref.read(vetVisitRepositoryProvider).deleteVetVisit(id);

    state = AsyncValue.data(previousState.where((v) => v.id != id).toList());
  }
}
