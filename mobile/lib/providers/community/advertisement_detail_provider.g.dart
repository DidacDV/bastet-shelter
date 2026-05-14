// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisement_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdvertisementDetailController)
final advertisementDetailControllerProvider =
    AdvertisementDetailControllerFamily._();

final class AdvertisementDetailControllerProvider
    extends
        $AsyncNotifierProvider<
          AdvertisementDetailController,
          AdvertisementDetail
        > {
  AdvertisementDetailControllerProvider._({
    required AdvertisementDetailControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'advertisementDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$advertisementDetailControllerHash();

  @override
  String toString() {
    return r'advertisementDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdvertisementDetailController create() => AdvertisementDetailController();

  @override
  bool operator ==(Object other) {
    return other is AdvertisementDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$advertisementDetailControllerHash() =>
    r'7a5b4dc6dd00ac94ff235bca1961a297f2a7cd80';

final class AdvertisementDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AdvertisementDetailController,
          AsyncValue<AdvertisementDetail>,
          AdvertisementDetail,
          FutureOr<AdvertisementDetail>,
          int
        > {
  AdvertisementDetailControllerFamily._()
    : super(
        retry: null,
        name: r'advertisementDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdvertisementDetailControllerProvider call(int adId) =>
      AdvertisementDetailControllerProvider._(argument: adId, from: this);

  @override
  String toString() => r'advertisementDetailControllerProvider';
}

abstract class _$AdvertisementDetailController
    extends $AsyncNotifier<AdvertisementDetail> {
  late final _$args = ref.$arg as int;
  int get adId => _$args;

  FutureOr<AdvertisementDetail> build(int adId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AdvertisementDetail>, AdvertisementDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdvertisementDetail>, AdvertisementDetail>,
              AsyncValue<AdvertisementDetail>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
