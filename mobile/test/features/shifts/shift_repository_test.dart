import 'package:bastetshelter/features/shifts/data/shift_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/recording_api_client.dart';

void main() {
  group('ShiftRepository', () {
    late RecordingApiClient apiClient;
    late ShiftRepository repository;

    setUp(() {
      apiClient = RecordingApiClient();
      repository = ShiftRepository(apiClient);
    });

    test('getShifts builds query params and parses shifts', () async {
      apiClient.defaultGetResponse = {
        'shifts': [sampleShiftJson],
      };

      final day = DateTime.parse('2026-05-25');
      final weekStart = DateTime.parse('2026-05-19');
      final shifts = await repository.getShifts(
        refugeId: 10,
        day: day,
        weekStart: weekStart,
      );

      expect(apiClient.getCalls.single, contains('/shifts/?'));
      expect(apiClient.getCalls.single, contains('refuge_id=10'));
      expect(apiClient.getCalls.single, contains('day=2026-05-25'));
      expect(apiClient.getCalls.single, contains('week_start=2026-05-19'));
      expect(shifts.single.id, 1);
    });

    test('getShiftDetail calls shift detail endpoint', () async {
      apiClient.defaultGetResponse = {
        ...sampleShiftJson,
        'shift_tasks': [shiftTaskJson()],
        'is_joined': false,
      };

      final detail = await repository.getShiftDetail(3);

      expect(apiClient.getCalls.single, '/shifts/3');
      expect(detail.shiftTasks, hasLength(1));
    });

    test('assignTask calls assign endpoint with participant id', () async {
      await repository.assignTask(15, 99);

      expect(
        apiClient.patchCalls.single,
        '/shifts/tasks/15/assign?participant_id=99',
      );
    });

    test('unassignTask calls unassign endpoint', () async {
      await repository.unassignTask(15);

      expect(apiClient.patchCalls.single, '/shifts/tasks/15/unassign');
    });

    test('completeTask calls complete endpoint', () async {
      await repository.completeTask(8);

      expect(apiClient.patchCalls.single, '/shifts/tasks/8/complete');
    });

    test('uncompleteTask calls uncomplete endpoint', () async {
      await repository.uncompleteTask(8);

      expect(apiClient.patchCalls.single, '/shifts/tasks/8/uncomplete');
    });

    test('getMyTasks calls tasks/me endpoint', () async {
      apiClient.defaultGetResponse = {
        'my_shift_tasks': [
          {
            'shift': sampleShiftJson,
            'tasks': [shiftTaskJson()],
          },
        ],
      };

      final groups = await repository.getMyTasks();

      expect(apiClient.getCalls.single, '/tasks/me');
      expect(groups, hasLength(1));
    });

    test('addTaskToShift posts with task and animal ids', () async {
      await repository.addTaskToShift(shiftId: 2, taskId: 5, animalId: 8);

      expect(
        apiClient.postCalls.single,
        '/shifts/2/tasks?task_id=5&animal_id=8',
      );
    });

    test('removeTask deletes shift task endpoint', () async {
      await repository.removeTask(44);

      expect(apiClient.deleteCalls.single, '/shifts/tasks/44');
    });
  });
}
