import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_requests/adoption_requests.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'adoption_repository_provider.dart';
import 'adoption_list_provider.dart';

part 'adoption_detail_provider.g.dart';

@riverpod
class AdoptionDetail extends _$AdoptionDetail {
  @override
  Future<AdoptionProcessDetails> build(int processId) async {
    return ref
        .read(adoptionRepositoryProvider)
        .getAdoptionProcessManager(processId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> advanceStep({String? notes}) async {
    await genericApiCall(() async {
      await ref
          .read(adoptionRepositoryProvider)
          .advanceCurrentStep(processId, AdvanceStepRequest(notes: notes));
      _invalidateAndRefresh();
    });
  }

  Future<void> rejectProcess(String reason) async {
    await genericApiCall(() async {
      await ref
          .read(adoptionRepositoryProvider)
          .rejectAdoptionProcess(processId, RejectionRequest(reason: reason));

      ref.invalidateSelf();
      ref.invalidate(adoptionDetailProvider(processId));
    });
  }

  Future<void> skipStep() async {
    await genericApiCall(() async {
      await ref.read(adoptionRepositoryProvider).skipStep(processId);
      _invalidateAndRefresh();
    });
  }

  Future<void> scheduleInterview(DateTime date) async {
    await genericApiCall(() async {
      await ref
          .read(adoptionRepositoryProvider)
          .setInterviewDate(processId, ScheduledDateUpdate(scheduledAt: date));
      _invalidateAndRefresh();
    });
  }

  Future<void> scheduleShelterVisit(DateTime date) async {
    await genericApiCall(() async {
      await ref
          .read(adoptionRepositoryProvider)
          .setShelterVisitDate(
            processId,
            ScheduledDateUpdate(scheduledAt: date),
          );
      _invalidateAndRefresh();
    });
  }

  Future<void> scheduleAnimalPickup(DateTime date) async {
    await genericApiCall(() async {
      await ref
          .read(adoptionRepositoryProvider)
          .setAnimalPickupDate(
            processId,
            ScheduledDateUpdate(scheduledAt: date),
          );
      _invalidateAndRefresh();
    });
  }

  void _invalidateAndRefresh() {
    ref.invalidateSelf();
    ref.invalidate(adoptionListProvider);
  }
}
