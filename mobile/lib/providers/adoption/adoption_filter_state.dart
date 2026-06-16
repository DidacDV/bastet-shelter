import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_summary.dart';

class AdoptionFilterState {
  final AdoptionProcessStatus? status;

  const AdoptionFilterState({this.status});

  bool get hasActiveFilters => status != null;

  AdoptionFilterState copyWith({Object? status = _sentinel}) {
    return AdoptionFilterState(
      status: status == _sentinel
          ? this.status
          : status as AdoptionProcessStatus?,
    );
  }

  List<AdoptionProcessSummary> apply(List<AdoptionProcessSummary> all) {
    if (status == null) return all;

    return all.where((process) => process.status == status).toList();
  }
}

const _sentinel = Object();
