// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adoptionRepository)
final adoptionRepositoryProvider = AdoptionRepositoryProvider._();

final class AdoptionRepositoryProvider
    extends
        $FunctionalProvider<
          AdoptionRepository,
          AdoptionRepository,
          AdoptionRepository
        >
    with $Provider<AdoptionRepository> {
  AdoptionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdoptionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdoptionRepository create(Ref ref) {
    return adoptionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdoptionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdoptionRepository>(value),
    );
  }
}

String _$adoptionRepositoryHash() =>
    r'c427f214197e81b04baa7987ba06cb8f4db42f0b';
