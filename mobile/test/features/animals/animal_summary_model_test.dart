import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimalSummary', () {
    test('fromJson parses summary fields', () {
      final animal = AnimalSummary.fromJson({
        'id': 12,
        'name': 'Rocky',
        'age': 4,
        'in_adoption': false,
        'pending_shift_tasks': 3,
        'refuge_name': 'East wing',
        'image_url': 'https://example.com/rocky.jpg',
      });

      expect(animal.id, 12);
      expect(animal.name, 'Rocky');
      expect(animal.pendingShiftTasks, 3);
      expect(animal.imageUrl, 'https://example.com/rocky.jpg');
    });

    test('fromJson defaults age to zero when missing', () {
      final animal = AnimalSummary.fromJson({
        'id': 1,
        'name': 'Unknown age',
        'in_adoption': true,
        'pending_shift_tasks': 0,
        'refuge_name': 'Main',
      });

      expect(animal.age, 0);
    });

    test('listFromJson parses animal list', () {
      final animals = AnimalSummary.listFromJson([
        {
          'id': 1,
          'name': 'A',
          'age': 1,
          'in_adoption': true,
          'pending_shift_tasks': 0,
          'refuge_name': 'R1',
        },
        {
          'id': 2,
          'name': 'B',
          'age': 2,
          'in_adoption': false,
          'pending_shift_tasks': 1,
          'refuge_name': 'R2',
        },
      ]);

      expect(animals, hasLength(2));
    });
  });
}
