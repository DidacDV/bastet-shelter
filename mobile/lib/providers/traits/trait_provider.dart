import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/traits/data/trait_model.dart';
import 'package:bastetshelter/features/traits/data/trait_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trait_provider.g.dart';

@riverpod
TraitRepository traitRepository(Ref ref) {
  return getIt<TraitRepository>();
}

@riverpod
class Traits extends _$Traits {
  @override
  Future<List<Trait>> build() async {
    ref.keepAlive();
    return ref.read(traitRepositoryProvider).getAllTraits();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addTrait(String name) async {
    final previousState = await future;

    final newTrait = await ref.read(traitRepositoryProvider).createTrait(name);
    state = AsyncValue.data([...previousState, newTrait]);
  }

  Future<void> updateTrait(int id, String newName) async {
    final previousState = await future;

    final updatedTrait = await ref
        .read(traitRepositoryProvider)
        .updateTrait(id, newName);

    state = AsyncValue.data([
      for (final trait in previousState)
        if (trait.id == id) updatedTrait else trait,
    ]);
  }

  Future<void> deleteTrait(int id) async {
    final previousState = await future;

    await ref.read(traitRepositoryProvider).deleteTrait(id);
    state = AsyncValue.data(
      previousState.where((trait) => trait.id != id).toList(),
    );
  }
}
