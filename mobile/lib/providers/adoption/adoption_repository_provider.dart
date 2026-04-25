import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/adoption/data/adoption_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adoption_repository_provider.g.dart';

@riverpod
AdoptionRepository adoptionRepository(Ref ref) {
  return getIt<AdoptionRepository>();
}
