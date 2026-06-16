import 'package:bastetshelter/features/shifts/data/models/shift_participant_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShiftParticipant', () {
    test('fromJson parses participant fields', () {
      final participant = ShiftParticipant.fromJson({
        'id': 5,
        'shift_id': 1,
        'volunteer_id': 88,
        'name': 'John',
        'last_name_1': 'Doe',
      });

      expect(participant.id, 5);
      expect(participant.shiftId, 1);
      expect(participant.memberId, 88);
      expect(participant.displayName, 'John Doe');
    });

    test('displayName ignores empty parts', () {
      const participant = ShiftParticipant(id: 1, shiftId: 1, name: 'Solo');

      expect(participant.displayName, 'Solo');
    });
  });
}
