// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shelterRepository)
final shelterRepositoryProvider = ShelterRepositoryProvider._();

final class ShelterRepositoryProvider
    extends
        $FunctionalProvider<
          ShelterRepository,
          ShelterRepository,
          ShelterRepository
        >
    with $Provider<ShelterRepository> {
  ShelterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shelterRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shelterRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShelterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShelterRepository create(Ref ref) {
    return shelterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShelterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShelterRepository>(value),
    );
  }
}

String _$shelterRepositoryHash() => r'd7f9634e24b7763521c22c6a673185e921c05ec7';

@ProviderFor(ShelterNotifier)
final shelterProvider = ShelterNotifierProvider._();

final class ShelterNotifierProvider
    extends $AsyncNotifierProvider<ShelterNotifier, Shelter> {
  ShelterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shelterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shelterNotifierHash();

  @$internal
  @override
  ShelterNotifier create() => ShelterNotifier();
}

String _$shelterNotifierHash() => r'13e7d1e3b4fcc594388c662660245abf964298db';

abstract class _$ShelterNotifier extends $AsyncNotifier<Shelter> {
  FutureOr<Shelter> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Shelter>, Shelter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Shelter>, Shelter>,
              AsyncValue<Shelter>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
