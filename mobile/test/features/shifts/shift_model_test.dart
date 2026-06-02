import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Shift', () {
    test('fromJson parses shift fields', () {
      final shift = Shift.fromJson(sampleShiftJson);

      expect(shift.id, 1);
      expect(shift.refugeId, 10);
      expect(shift.maxParticipants, 5);
      expect(shift.currentParticipants, 2);
      expect(shift.day, DateTime.parse('2026-05-25'));
    });

    test('listFromJson parses multiple shifts', () {
      final shifts = Shift.listFromJson([
        sampleShiftJson,
        {...sampleShiftJson, 'id': 2},
      ]);

      expect(shifts.map((shift) => shift.id), [1, 2]);
    });
  });

  group('ShiftDetail', () {
    test('fromJson parses tasks and join info', () {
      final detail = ShiftDetail.fromJson({
        ...sampleShiftJson,
        'shift_tasks': [shiftTaskJson(id: 1), shiftTaskJson(id: 2)],
        'is_joined': true,
        'my_participant_id': 42,
      });

      expect(detail.shiftTasks, hasLength(2));
      expect(detail.isJoined, isTrue);
      expect(detail.myParticipantId, 42);
    });

    test('fromJson defaults join flags when missing', () {
      final detail = ShiftDetail.fromJson(sampleShiftJson);

      expect(detail.shiftTasks, isEmpty);
      expect(detail.isJoined, isFalse);
      expect(detail.myParticipantId, isNull);
    });
  });
}
