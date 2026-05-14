import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/features/community/data/advertisement_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'advertisement_provider.g.dart';

@riverpod
AdvertisementRepository advertisementRepository(Ref ref) {
  return getIt<AdvertisementRepository>();
}

@riverpod
class Advertisements extends _$Advertisements {
  @override
  Future<List<AdvertisementSummary>> build() async {
    ref.keepAlive();
    return ref.read(advertisementRepositoryProvider).getAdvertisements();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<List<AdvertisementSummary>> filterAdvertisements({
    String? provinceName,
    AdCategory? category,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(advertisementRepositoryProvider)
          .getAdvertisements(provinceName: provinceName, category: category),
    );
    return state.value ?? [];
  }

  Future<List<AdvertisementSummary>> getMyAdvertisements() async {
    return await genericApiCall(() async {
          return await ref
              .read(advertisementRepositoryProvider)
              .getMyAdvertisements();
        }) ??
        [];
  }

  Future<int?> createAdvertisement({
    required String title,
    required String description,
    required AdCategory category,
    required String provinceName,
  }) async {
    final advertisement = await genericApiCall(() async {
      return await ref
          .read(advertisementRepositoryProvider)
          .createAdvertisement(
            title: title,
            description: description,
            category: category,
            provinceName: provinceName,
          );
    });

    if (advertisement == null) return null;

    ref.invalidateSelf();
    return advertisement.id;
  }

  Future<void> deactivateAdvertisement(int adId) async {
    await genericApiCall(() async {
      await ref
          .read(advertisementRepositoryProvider)
          .deactivateAdvertisement(adId);

      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((ad) => ad.id != adId).toList(),
        );
      }
      // ref.invalidate(advertisementDetailProvider(adId));
    });
  }

  Future<void> uploadImage(int adId, XFile imageFile) async {
    await genericApiCall(() async {
      await ref
          .read(advertisementRepositoryProvider)
          .uploadImage(adId, imageFile);

      // ref.invalidate(advertisementDetailProvider(adId));
      ref.invalidateSelf();
    });
  }

  Future<void> deleteImage(int adId) async {
    await genericApiCall(() async {
      await ref.read(advertisementRepositoryProvider).deleteImage(adId);

      // ref.invalidate(advertisementDetailProvider(adId));
      ref.invalidateSelf();
    });
  }
}
