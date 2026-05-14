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
    });
  }

  Future<void> unassignTask(int shiftTaskId, int shiftId) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).unassignTask(shiftTaskId);
      ref.invalidateSelf();
      ref.invalidate(shiftDetailProvider(shiftId));
    });
  }
}
