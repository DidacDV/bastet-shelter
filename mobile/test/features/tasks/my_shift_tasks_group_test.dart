import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('MyShiftTasksGroup', () {
    test('fromJson parses shift and tasks', () {
      final group = MyShiftTasksGroup.fromJson({
        'shift': sampleShiftJson,
        'tasks': [
          shiftTaskJson(id: 1),
          shiftTaskJson(id: 2, status: 'COMPLETED'),
        ],
      });

      expect(group.shift.id, 1);
      expect(group.tasks, hasLength(2));
      expect(group.tasks.first.status, ShiftTaskStatus.notCompleted);
      expect(group.tasks.last.status, ShiftTaskStatus.completed);
    });

    test('listFromJson reads my_shift_tasks key', () {
      final groups = MyShiftTasksGroup.listFromJson({
        'my_shift_tasks': [
          {
            'shift': sampleShiftJson,
            'tasks': [shiftTaskJson()],
          },
        ],
      });

      expect(groups, hasLength(1));
    });

    test('pendingTasksListFromJson reads pending_tasks key', () {
      final groups = MyShiftTasksGroup.pendingTasksListFromJson(
        pendingTasksResponse(tasks: [shiftTaskJson(id: 1)]),
      );

      expect(groups, hasLength(1));
      expect(groups.first.tasks.single.id, 1);
    });

    test('sortTasksPendingFirst puts completed tasks last', () {
      final groups = MyShiftTasksGroup.sortTasksPendingFirst([
        buildShiftTasksGroup(
          tasks: [
            buildShiftTask(id: 3, status: ShiftTaskStatus.completed),
            buildShiftTask(id: 1, status: ShiftTaskStatus.notCompleted),
            buildShiftTask(id: 2, status: ShiftTaskStatus.completed),
            buildShiftTask(id: 4, status: ShiftTaskStatus.notCompleted),
          ],
        ),
      ]);

      expect(groups.first.tasks.map((task) => task.id).toList(), [1, 4, 2, 3]);
    });

    test('sortTasksPendingFirst keeps pending tasks ordered by id', () {
      final groups = MyShiftTasksGroup.sortTasksPendingFirst([
        buildShiftTasksGroup(
          tasks: [
            buildShiftTask(id: 5),
            buildShiftTask(id: 2),
            buildShiftTask(id: 8),
          ],
        ),
      ]);

      expect(groups.first.tasks.map((task) => task.id).toList(), [2, 5, 8]);
    });

    test('pendingTasksListFromJson applies pending-first sorting', () {
      final groups = MyShiftTasksGroup.pendingTasksListFromJson(
        pendingTasksResponse(
          tasks: [
            shiftTaskJson(id: 10, status: 'COMPLETED'),
            shiftTaskJson(id: 5, status: 'NOT_COMPLETED'),
          ],
        ),
      );

      expect(groups.first.tasks.map((task) => task.id).toList(), [5, 10]);
    });
  });
}
