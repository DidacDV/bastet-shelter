import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_summary.dart';
import 'package:bastetshelter/providers/adoption/adoption_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adoption_list_search_provider.g.dart';

@riverpod
class AdoptionSearchQuery extends _$AdoptionSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

@riverpod
AsyncValue<List<AdoptionProcessSummary>> filteredAdoptionList(Ref ref) {
  final listAsync = ref.watch(adoptionListProvider);
  final query = ref.watch(adoptionSearchQueryProvider).toLowerCase();

  return listAsync.whenData((list) {
    if (query.isEmpty) return list;

    //filter by both the animal name AND the adoptant name
    return list.where((process) {
      final animalMatch = process.animalName.toLowerCase().contains(query);
      final adoptantMatch = process.adoptantName.toLowerCase().contains(query);

      return animalMatch || adoptantMatch;
    }).toList();
  });
}
