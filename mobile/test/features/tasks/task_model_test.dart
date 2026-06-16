import 'package:bastetshelter/features/tasks/data/task_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task', () {
    test('fromJson parses task template fields', () {
      final task = Task.fromJson({
        'id': 9,
        'title': 'Feed cats',
        'description': 'Morning feeding',
        'num_people': 2,
      });

      expect(task.id, 9);
      expect(task.title, 'Feed cats');
      expect(task.description, 'Morning feeding');
      expect(task.numPeople, 2);
    });

    test('listFromJson parses list of templates', () {
      final tasks = Task.listFromJson([
        {'id': 1, 'title': 'A', 'description': 'Desc A', 'num_people': 1},
        {'id': 2, 'title': 'B', 'description': 'Desc B', 'num_people': 3},
      ]);

      expect(tasks, hasLength(2));
      expect(tasks.last.numPeople, 3);
    });
  });
}
