import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:bastetshelter/providers/tasks/my_tasks_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_pending_tasks_provider.g.dart';

@riverpod
class AnimalPendingTasks extends _$AnimalPendingTasks {
  @override
  Future<List<MyShiftTasksGroup>> build(int animalId) async {
    ref.keepAlive();
    return ref.read(animalRepositoryProvider).getPendingTasks(animalId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> toggleCompletion(ShiftTask task) async {
    await genericApiCall(() async {
      final isCompleted = task.status == ShiftTaskStatus.completed;
      if (isCompleted) {
        await ref.read(shiftRepositoryProvider).uncompleteTask(task.id);
      } else {
        await ref.read(shiftRepositoryProvider).completeTask(task.id);
      }
      ref.invalidateSelf();
      ref.invalidate(shiftDetailProvider(task.shiftId));
      ref.invalidate(myTasksProvider);
      invalidateAnimalTaskCaches(ref, animalId: task.animal?.id ?? animalId);
    });
  }

  Future<void> unassignTask(int shiftTaskId, int shiftId) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).unassignTask(shiftTaskId);
      ref.invalidateSelf();
      ref.invalidate(shiftDetailProvider(shiftId));
      ref.invalidate(myTasksProvider);
    });
  }

  Future<void> assignTask(
    int shiftTaskId,
    int shiftId,
    int participantId,
  ) async {
    await genericApiCall(() async {
      await ref
          .read(shiftRepositoryProvider)
          .assignTask(shiftTaskId, participantId);
      ref.invalidateSelf();
      ref.invalidate(shiftDetailProvider(shiftId));
      ref.invalidate(myTasksProvider);
    });
  }
}
