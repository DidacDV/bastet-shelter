// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geoRepository)
final geoRepositoryProvider = GeoRepositoryProvider._();

final class GeoRepositoryProvider
    extends $FunctionalProvider<GeoRepository, GeoRepository, GeoRepository>
    with $Provider<GeoRepository> {
  GeoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geoRepositoryHash();

  @$internal
  @override
  $ProviderElement<GeoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeoRepository create(Ref ref) {
    return geoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeoRepository>(value),
    );
  }
}

String _$geoRepositoryHash() => r'385a236d13a1239ac094d5be6c09bc80f42202ab';

@ProviderFor(Geo)
final geoProvider = GeoProvider._();

final class GeoProvider extends $AsyncNotifierProvider<Geo, List<Province>> {
  GeoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geoHash();

  @$internal
  @override
  Geo create() => Geo();
}

String _$geoHash() => r'5304f521c22e40785e3f9b185cdb5d38386cbcec';

abstract class _$Geo extends $AsyncNotifier<List<Province>> {
  FutureOr<List<Province>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Province>>, List<Province>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Province>>, List<Province>>,
              AsyncValue<List<Province>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
