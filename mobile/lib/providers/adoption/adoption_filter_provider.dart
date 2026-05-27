import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'adoption_filter_state.dart';

part 'adoption_filter_provider.g.dart';

@riverpod
class AdoptionFilter extends _$AdoptionFilter {
  @override
  AdoptionFilterState build() {
    ref.keepAlive();
    return const AdoptionFilterState();
  }

  void setStatus(AdoptionProcessStatus status) {
    state = state.copyWith(status: state.status == status ? null : status);
  }
}
