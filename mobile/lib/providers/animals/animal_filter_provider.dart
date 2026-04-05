import 'package:bastetshelter/features/animals/data/animal_model.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'animal_filter_state.dart';

part 'animal_filter_provider.g.dart';

/// holds the current filters state (so widgets don't directly access to filter state)
@riverpod
class AnimalFilter extends _$AnimalFilter {
  @override
  AnimalFilterState build() {
    ref.keepAlive();
    return const AnimalFilterState();
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setInAdoption(bool? value) {
    state = state.copyWith(inAdoption: value);
  }

  void setHasPendingTasks(bool value) {
    state = state.copyWith(hasPendingTasks: value);
  }

  void removeFilter(String key) {
    switch (key) {
      case 'inAdoption':
        state = state.copyWith(inAdoption: null);
      case 'hasPendingTasks':
        state = state.copyWith(hasPendingTasks: false);
    }
  }

  void reset() {
    state = const AnimalFilterState();
  }
}

//re fetched if list changed or if filters change
@riverpod
AsyncValue<List<AnimalSummary>> filteredAnimals(Ref ref) {
  final animalsAsync = ref.watch(animalsProvider);
  final filter = ref.watch(animalFilterProvider);

  return animalsAsync.whenData((all) => filter.apply(all));
}
