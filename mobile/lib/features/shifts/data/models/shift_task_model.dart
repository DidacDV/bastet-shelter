import 'package:bastetshelter/features/tasks/data/task_model.dart';

enum ShiftTaskStatus { notCompleted, completed }

ShiftTaskStatus _statusFromJson(String raw) => switch (raw) {
  'COMPLETED' => ShiftTaskStatus.completed,
  _ => ShiftTaskStatus.notCompleted,
};

class ShiftTask {
  final int id;
  final ShiftTaskStatus status;
  final DateTime assignedDate;
  final int shiftId;
  final int taskId;
  final Task task;
  final int? participantId;
  final int? animalId;

  const ShiftTask({
    required this.id,
    required this.status,
    required this.assignedDate,
    required this.shiftId,
    required this.taskId,
    required this.task,
    this.participantId,
    this.animalId,
  });

  factory ShiftTask.fromJson(Map<String, dynamic> json) {
    return ShiftTask(
      id: json['id'] as int,
      status: _statusFromJson(json['status'] as String),
      assignedDate: DateTime.parse(json['assigned_date'] as String),
      shiftId: json['shift_id'] as int,
      taskId: json['task_id'] as int,
      task: Task.fromJson(json['task'] as Map<String, dynamic>),
      participantId: json['participant_id'] as int?,
      animalId: json['animal_id'] as int?,
    );
  }

  static List<ShiftTask> listFromJson(List<dynamic> list) =>
      list.map((e) => ShiftTask.fromJson(e as Map<String, dynamic>)).toList();
}
