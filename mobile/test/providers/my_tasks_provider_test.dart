import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:bastetshelter/providers/tasks/my_tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_shift_repository.dart';
import '../helpers/fixtures.dart';

void main() {
  group('MyTasks provider', () {
    late FakeShiftRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeShiftRepository();
      fakeRepository.myTasks = [
        buildShiftTasksGroup(
          tasks: [buildShiftTask(id: 1), buildShiftTask(id: 2)],
        ),
      ];

      container = ProviderContainer(
        overrides: [shiftRepositoryProvider.overrideWithValue(fakeRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build loads tasks from repository', () async {
      final tasks = await container.read(myTasksProvider.future);

      expect(tasks.single.tasks, hasLength(2));
    });

    test(
      'unassignTask removes task optimistically and calls repository',
      () async {
        await container.read(myTasksProvider.future);

        await container
            .read(myTasksProvider.notifier)
            .unassignTask(1, 10, animalId: 5);

        final tasks = container.read(myTasksProvider).value!;
        expect(tasks.single.tasks.map((task) => task.id), [2]);
        expect(fakeRepository.unassignedTaskIds, [1]);
      },
    );

    test('toggleCompletion completes task through repository', () async {
      await container.read(myTasksProvider.future);
      final task = buildShiftTask(id: 4);

      await container.read(myTasksProvider.notifier).toggleCompletion(task);

      expect(fakeRepository.completedTaskIds, [4]);
    });

    test('toggleCompletion uncompletes completed task', () async {
      await container.read(myTasksProvider.future);
      final task = buildShiftTask(id: 4, status: ShiftTaskStatus.completed);

      await container.read(myTasksProvider.notifier).toggleCompletion(task);

      expect(fakeRepository.uncompletedTaskIds, [4]);
    });
  });
}
