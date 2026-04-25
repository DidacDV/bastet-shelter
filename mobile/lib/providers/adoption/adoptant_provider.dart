import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/adoption/data/adoptant_repository.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_adoptant/adoptant_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adoptant_provider.g.dart';

@riverpod
AdoptantRepository adoptantRepository(Ref ref) {
  return getIt<AdoptantRepository>();
}

@riverpod
Future<AdoptantResponse> adoptantDetail(Ref ref, int adoptantId) async {
  return ref.read(adoptantRepositoryProvider).getAdoptant(adoptantId);
}
