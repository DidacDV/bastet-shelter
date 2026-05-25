import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/providers/community/advertisement_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'advertisement_detail_provider.g.dart';

@riverpod
class AdvertisementDetailController extends _$AdvertisementDetailController {
  @override
  Future<AdvertisementDetail> build(int adId) async {
    return ref
        .read(advertisementRepositoryProvider)
        .getAdvertisementDetail(adId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
