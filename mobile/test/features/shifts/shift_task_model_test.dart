import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('ShiftTask', () {
    test('fromJson parses pending task', () {
      final task = ShiftTask.fromJson(
        shiftTaskJson(
          id: 7,
          participant: {
            'id': 20,
            'shift_id': 1,
            'name': 'Anna',
            'last_name_1': 'Smith',
          },
          animal: {
            'id': 3,
            'name': 'Luna',
            'age': 2,
            'in_adoption': true,
            'pending_shift_tasks': 1,
            'refuge_name': 'Main refuge',
          },
        ),
      );

      expect(task.id, 7);
      expect(task.status, ShiftTaskStatus.notCompleted);
      expect(task.shiftId, 1);
      expect(task.task.title, 'Morning walk');
      expect(task.participant?.displayName, 'Anna Smith');
      expect(task.animal?.name, 'Luna');
    });

    test('fromJson maps COMPLETED status', () {
      final task = ShiftTask.fromJson(
        shiftTaskJson(id: 2, status: 'COMPLETED'),
      );

      expect(task.status, ShiftTaskStatus.completed);
    });

    test('fromJson treats unknown status as not completed', () {
      final task = ShiftTask.fromJson(
        shiftTaskJson(id: 2, status: 'CANCELLED'),
      );

      expect(task.status, ShiftTaskStatus.notCompleted);
    });

    test('listFromJson parses multiple tasks', () {
      final tasks = ShiftTask.listFromJson([
        shiftTaskJson(id: 1),
        shiftTaskJson(id: 2),
      ]);

      expect(tasks, hasLength(2));
      expect(tasks.map((task) => task.id), [1, 2]);
    });
  });
}
