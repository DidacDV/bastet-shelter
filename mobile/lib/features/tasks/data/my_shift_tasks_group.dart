import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';

class MyShiftTasksGroup {
  final Shift shift;
  final List<ShiftTask> tasks;

  const MyShiftTasksGroup({required this.shift, required this.tasks});

  factory MyShiftTasksGroup.fromJson(Map<String, dynamic> json) {
    return MyShiftTasksGroup(
      shift: Shift.fromJson(json['shift'] as Map<String, dynamic>),
      tasks: ShiftTask.listFromJson(json['tasks'] as List<dynamic>),
    );
  }

  static List<MyShiftTasksGroup> listFromJson(Map<String, dynamic> json) {
    final list = json['my_shift_tasks'] as List<dynamic>? ?? [];
    return list
        .map((e) => MyShiftTasksGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<MyShiftTasksGroup> pendingTasksListFromJson(
    Map<String, dynamic> json,
  ) {
    final list = json['pending_tasks'] as List<dynamic>? ?? [];
    return list
        .map((e) => MyShiftTasksGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
