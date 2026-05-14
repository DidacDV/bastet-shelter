import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/providers/community/advertisement_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_advertisements_provider.g.dart';

@riverpod
class MyAdvertisements extends _$MyAdvertisements {
  @override
  Future<List<AdvertisementSummary>> build() async {
    return ref.read(advertisementRepositoryProvider).getMyAdvertisements();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
