import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/tasks/data/task_model.dart';
import 'package:bastetshelter/features/tasks/data/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_provider.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  return getIt<TaskRepository>();
}

@riverpod
class Tasks extends _$Tasks {
  @override
  Future<List<Task>> build() async {
    ref.keepAlive();
    return ref.read(taskRepositoryProvider).getTasks();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addTask({
    required String title,
    required String description,
    required int numPeople,
  }) async {
    final previousState = await future;

    final newTask = await ref
        .read(taskRepositoryProvider)
        .createTask(
          title: title,
          description: description,
          numPeople: numPeople,
        );

    state = AsyncValue.data([...previousState, newTask]);
  }

  Future<void> updateTask({
    required int id,
    String? title,
    String? description,
    int? numPeople,
  }) async {
    final previousState = await future;

    final updatedTask = await ref
        .read(taskRepositoryProvider)
        .updateTask(
          id: id,
          title: title,
          description: description,
          numPeople: numPeople,
        );

    state = AsyncValue.data([
      for (final task in previousState)
        if (task.id == id) updatedTask else task,
    ]);
  }

  Future<void> deleteTask(int id) async {
    final previousState = await future;

    await ref.read(taskRepositoryProvider).deleteTask(id);

    state = AsyncValue.data(
      previousState.where((task) => task.id != id).toList(),
    );
  }
}
