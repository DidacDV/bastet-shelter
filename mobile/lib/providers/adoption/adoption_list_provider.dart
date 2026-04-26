import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'adoption_repository_provider.dart';

part 'adoption_list_provider.g.dart';

@riverpod
class AdoptionList extends _$AdoptionList {
  @override
  Future<List<AdoptionProcessSummary>> build() async {
    ref.keepAlive();
    return ref.read(adoptionRepositoryProvider).getProcessesForShelter();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
