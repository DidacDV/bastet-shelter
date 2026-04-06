// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trait_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(traitRepository)
final traitRepositoryProvider = TraitRepositoryProvider._();

final class TraitRepositoryProvider
    extends
        $FunctionalProvider<TraitRepository, TraitRepository, TraitRepository>
    with $Provider<TraitRepository> {
  TraitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'traitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$traitRepositoryHash();

  @$internal
  @override
  $ProviderElement<TraitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TraitRepository create(Ref ref) {
    return traitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TraitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TraitRepository>(value),
    );
  }
}

String _$traitRepositoryHash() => r'0c455233cb5d86f8b1008893eadb051e377fc537';

@ProviderFor(Traits)
final traitsProvider = TraitsProvider._();

final class TraitsProvider extends $AsyncNotifierProvider<Traits, List<Trait>> {
  TraitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'traitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$traitsHash();

  @$internal
  @override
  Traits create() => Traits();
}

String _$traitsHash() => r'08aebb8457fae04811bc8b02bcfe85f4212bd508';

abstract class _$Traits extends $AsyncNotifier<List<Trait>> {
  FutureOr<List<Trait>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Trait>>, List<Trait>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Trait>>, List<Trait>>,
              AsyncValue<List<Trait>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
