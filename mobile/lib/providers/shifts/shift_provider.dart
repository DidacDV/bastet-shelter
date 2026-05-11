import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bastetshelter/features/shifts/data/shift_repository.dart';

part 'shift_provider.g.dart';

@riverpod
ShiftRepository shiftRepository(Ref ref) {
  return getIt<ShiftRepository>();
}

//FAMILY PROVIDER, used for shifts data based on a refuge and a week start.
//for each unique pair of refuge id and week, we create another instance
@riverpod
class Shifts extends _$Shifts {
  @override
  Future<List<Shift>> build(int refugeId, DateTime weekStart) async {
    ref.keepAlive();
    return ref
        .read(shiftRepositoryProvider)
        .getShifts(refugeId: refugeId, weekStart: weekStart);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createShift({
    required DateTime startTime,
    required DateTime endTime,
    required DateTime day,
    int? maxParticipants,
  }) async {
    await genericApiCall(() async {
      await ref
          .read(shiftRepositoryProvider)
          .createShift(
            refugeId: refugeId,
            startTime: startTime,
            endTime: endTime,
            day: day,
            maxParticipants: maxParticipants,
          );
      //invalidate only the current week, not the entire shiftsProvider
      ref.invalidateSelf();
    });
  }

  Future<void> deleteShift(int shiftId) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).deleteShift(shiftId);
      ref.invalidateSelf();
    });
  }

  Future<void> joinShift(int shiftId) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).joinShift(shiftId);
      ref.invalidateSelf();
    });
  }

  Future<void> leaveShift(int shiftId) async {
    await genericApiCall(() async {
      await ref.read(shiftRepositoryProvider).leaveShift(shiftId);
      ref.invalidateSelf();
    });
  }

  Future<void> copyWeek({
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  }) async {
    await genericApiCall(() async {
      await ref
          .read(shiftRepositoryProvider)
          .copyWeek(
            refugeId: refugeId,
            sourceWeekStart: sourceWeekStart,
            targetWeekStart: targetWeekStart,
          );
      ref.invalidate(shiftsProvider);
    });
  }

  Future<void> clearDay(DateTime day) async {
    await genericApiCall(() async {
      await ref
          .read(shiftRepositoryProvider)
          .clearDay(refugeId: refugeId, day: day);
      ref.invalidateSelf();
    });
  }

  Future<void> clearWeek(DateTime targetWeekStart) async {
    await genericApiCall(() async {
      await ref
          .read(shiftRepositoryProvider)
          .clearWeek(refugeId: refugeId, weekStart: targetWeekStart);
      ref.invalidateSelf(); //no need to invalidate all weeks
    });
  }
}
