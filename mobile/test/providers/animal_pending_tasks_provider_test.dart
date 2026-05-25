import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/animals/data/animal_repository.dart';
import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';
import 'package:bastetshelter/providers/animals/animal_pending_tasks_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_shift_repository.dart';
import '../helpers/fixtures.dart';

class FakeAnimalRepository extends AnimalRepository {
  FakeAnimalRepository() : super(ApiClient());

  final List<int> getPendingTasksCalls = [];
  List<MyShiftTasksGroup> pendingTasks = [];

  @override
  Future<List<MyShiftTasksGroup>> getPendingTasks(int animalId) async {
    getPendingTasksCalls.add(animalId);
    return pendingTasks;
  }
}

void main() {
  group('AnimalPendingTasks provider', () {
    late FakeAnimalRepository fakeAnimalRepository;
    late FakeShiftRepository fakeShiftRepository;
    late ProviderContainer container;

    setUp(() {
      fakeAnimalRepository = FakeAnimalRepository();
      fakeAnimalRepository.pendingTasks = [
        buildShiftTasksGroup(
          tasks: [buildShiftTask(id: 1), buildShiftTask(id: 2)],
        ),
      ];
      fakeShiftRepository = FakeShiftRepository();

      container = ProviderContainer(
        overrides: [
          animalRepositoryProvider.overrideWithValue(fakeAnimalRepository),
          shiftRepositoryProvider.overrideWithValue(fakeShiftRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build loads daily tasks for animal', () async {
      final groups = await container.read(animalPendingTasksProvider(7).future);

      expect(fakeAnimalRepository.getPendingTasksCalls, [7]);
      expect(groups.single.tasks, hasLength(2));
    });

    test('unassignTask calls repository', () async {
      await container.read(animalPendingTasksProvider(7).future);

      await container
          .read(animalPendingTasksProvider(7).notifier)
          .unassignTask(1, 10);

      expect(fakeShiftRepository.unassignedTaskIds, [1]);
    });

    test('toggleCompletion completes task through shift repository', () async {
      await container.read(animalPendingTasksProvider(7).future);
      final task = buildShiftTask(id: 9);

      await container
          .read(animalPendingTasksProvider(7).notifier)
          .toggleCompletion(task);

      expect(fakeShiftRepository.completedTaskIds, [9]);
    });

    test('assignTask assigns through shift repository', () async {
      await container.read(animalPendingTasksProvider(7).future);

      await container
          .read(animalPendingTasksProvider(7).notifier)
          .assignTask(3, 10, 99);

      expect(fakeShiftRepository.assignedTasks, [(3, 99)]);
    });
  });
}
