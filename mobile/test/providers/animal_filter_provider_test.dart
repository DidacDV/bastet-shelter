import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:bastetshelter/providers/animals/animal_filter_provider.dart';
import 'package:bastetshelter/providers/animals/animal_filter_state.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

class _FakeAnimals extends Animals {
  _FakeAnimals(this.data);

  final List<AnimalSummary> data;

  @override
  Future<List<AnimalSummary>> build() async => data;
}

void main() {
  group('AnimalFilter provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          animalsProvider.overrideWith(() => _FakeAnimals(sampleAnimals)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('updateQuery updates filter state', () {
      container.read(animalFilterProvider.notifier).updateQuery('luna');

      expect(container.read(animalFilterProvider).query, 'luna');
    });

    test('setInAdoption and setHasPendingTasks update filters', () {
      final notifier = container.read(animalFilterProvider.notifier);

      notifier.setInAdoption(true);
      notifier.setHasPendingTasks(true);

      final filter = container.read(animalFilterProvider);
      expect(filter.inAdoption, isTrue);
      expect(filter.hasPendingTasks, isTrue);
      expect(filter.activeFilterCount, 2);
    });

    test('removeFilter clears specific filter', () {
      final notifier = container.read(animalFilterProvider.notifier);
      notifier.setHasPendingTasks(true);
      notifier.removeFilter('hasPendingTasks');

      expect(container.read(animalFilterProvider).hasPendingTasks, isFalse);
    });

    test('reset restores default filter state', () {
      final notifier = container.read(animalFilterProvider.notifier);
      notifier.updateQuery('test');
      notifier.setInAdoption(false);
      notifier.reset();

      expect(container.read(animalFilterProvider), const AnimalFilterState());
    });

    test('filteredAnimals applies active filters to animals list', () async {
      container.read(animalFilterProvider.notifier).updateQuery('main');
      container.read(animalFilterProvider.notifier).setHasPendingTasks(true);

      await container.read(animalsProvider.future);
      final filtered = container.read(filteredAnimalsProvider).requireValue;

      expect(filtered.map((animal) => animal.name), ['Luna', 'Bella']);
    });
  });
}
