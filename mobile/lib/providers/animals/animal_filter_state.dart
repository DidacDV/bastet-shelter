import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';

class AnimalFilterState {
  final String query;
  final bool? inAdoption; //null = show all, true or false = filtered
  final bool hasPendingTasks; //true = only animals with tasks > 0

  const AnimalFilterState({
    this.query = '',
    this.inAdoption,
    this.hasPendingTasks = false,
  });

  bool get isEmpty => query.isEmpty && inAdoption == null && !hasPendingTasks;

  int get activeFilterCount =>
      (inAdoption != null ? 1 : 0) + (hasPendingTasks ? 1 : 0);

  AnimalFilterState copyWith({
    String? query,
    Object? inAdoption = _sentinel,
    bool? hasPendingTasks,
  }) {
    return AnimalFilterState(
      query: query ?? this.query,
      inAdoption: inAdoption == _sentinel
          ? this.inAdoption
          : inAdoption as bool?,
      hasPendingTasks: hasPendingTasks ?? this.hasPendingTasks,
    );
  }

  List<AnimalSummary> apply(List<AnimalSummary> all) {
    return all.where((a) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesName = a.name.toLowerCase().contains(q);
        final matchesRefuge = a.refugeName.toLowerCase().contains(q);
        if (!matchesName && !matchesRefuge) return false;
      }

      if (inAdoption != null && a.inAdoption != inAdoption) return false;
      if (hasPendingTasks && a.pendingShiftTasks == 0) return false;

      return true;
    }).toList();
  }
}

const _sentinel = Object();
