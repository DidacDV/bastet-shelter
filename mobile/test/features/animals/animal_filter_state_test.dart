import 'package:bastetshelter/providers/animals/animal_filter_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('AnimalFilterState', () {
    const filter = AnimalFilterState();

    test('isEmpty is true for default state', () {
      expect(filter.isEmpty, isTrue);
      expect(filter.activeFilterCount, 0);
    });

    test('copyWith updates selected fields', () {
      final updated = filter.copyWith(
        query: 'luna',
        inAdoption: true,
        hasPendingTasks: true,
      );

      expect(updated.query, 'luna');
      expect(updated.inAdoption, isTrue);
      expect(updated.hasPendingTasks, isTrue);
      expect(updated.activeFilterCount, 2);
    });

    test('apply filters by name case-insensitively', () {
      final result = filter.copyWith(query: 'luna').apply(sampleAnimals);

      expect(result.map((animal) => animal.name), ['Luna']);
    });

    test('apply filters by refuge name', () {
      final result = filter.copyWith(query: 'north').apply(sampleAnimals);

      expect(result.single.name, 'Max');
    });

    test('apply filters by adoption status', () {
      final result = filter.copyWith(inAdoption: true).apply(sampleAnimals);

      expect(result.map((animal) => animal.name), ['Luna', 'Bella']);
    });

    test('apply filters animals with pending tasks', () {
      final result = filter
          .copyWith(hasPendingTasks: true)
          .apply(sampleAnimals);

      expect(result.map((animal) => animal.name), ['Luna', 'Bella']);
    });

    test('apply combines multiple filters', () {
      final result = filter
          .copyWith(query: 'main', inAdoption: true, hasPendingTasks: true)
          .apply(sampleAnimals);

      expect(result.map((animal) => animal.name), ['Luna', 'Bella']);
    });
  });
}
