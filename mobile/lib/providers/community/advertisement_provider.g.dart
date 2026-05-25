// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(advertisementRepository)
final advertisementRepositoryProvider = AdvertisementRepositoryProvider._();

final class AdvertisementRepositoryProvider
    extends
        $FunctionalProvider<
          AdvertisementRepository,
          AdvertisementRepository,
          AdvertisementRepository
        >
    with $Provider<AdvertisementRepository> {
  AdvertisementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'advertisementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$advertisementRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdvertisementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdvertisementRepository create(Ref ref) {
    return advertisementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdvertisementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdvertisementRepository>(value),
    );
  }
}

String _$advertisementRepositoryHash() =>
    r'adecc8700bf93ebdf1ca0acdc87da76c839ff324';

@ProviderFor(Advertisements)
final advertisementsProvider = AdvertisementsProvider._();

final class AdvertisementsProvider
    extends $AsyncNotifierProvider<Advertisements, List<AdvertisementSummary>> {
  AdvertisementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'advertisementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$advertisementsHash();

  @$internal
  @override
  Advertisements create() => Advertisements();
}

String _$advertisementsHash() => r'cf0819bbb3bd9a9fb91d3de6ba29bb5b4a3f4b04';

abstract class _$Advertisements
    extends $AsyncNotifier<List<AdvertisementSummary>> {
  FutureOr<List<AdvertisementSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdvertisementSummary>>,
              List<AdvertisementSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdvertisementSummary>>,
                List<AdvertisementSummary>
              >,
              AsyncValue<List<AdvertisementSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
