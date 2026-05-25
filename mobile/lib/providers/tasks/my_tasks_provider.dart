import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_tasks_provider.g.dart';

@riverpod
class MyTasks extends _$MyTasks {
  @override
  Future<List<MyShiftTasksGroup>> build() async {
    return ref.read(shiftRepositoryProvider).getMyTasks();
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
      invalidateRelatedShiftTaskProviders(
        ref,
        shiftId: task.shiftId,
        animalId: task.animal?.id,
        invalidateMyTasks: false,
      );
      invalidateAnimalTaskCaches(ref, animalId: task.animal?.id);
    });
  }

  Future<void> unassignTask(
    int shiftTaskId,
    int shiftId, {
    int? animalId,
  }) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).unassignTask(shiftTaskId);

      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current
              .map(
                (group) => MyShiftTasksGroup(
                  shift: group.shift,
                  tasks: group.tasks
                      .where((task) => task.id != shiftTaskId)
                      .toList(),
                ),
              )
              .where((group) => group.tasks.isNotEmpty)
              .toList(),
        );
      }

      invalidateRelatedShiftTaskProviders(
        ref,
        shiftId: shiftId,
        animalId: animalId,
        invalidateMyTasks: false,
      );
    });
  }
}
