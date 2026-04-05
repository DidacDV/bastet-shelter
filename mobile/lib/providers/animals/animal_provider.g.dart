// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animalRepository)
final animalRepositoryProvider = AnimalRepositoryProvider._();

final class AnimalRepositoryProvider
    extends
        $FunctionalProvider<
          AnimalRepository,
          AnimalRepository,
          AnimalRepository
        >
    with $Provider<AnimalRepository> {
  AnimalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnimalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimalRepository create(Ref ref) {
    return animalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalRepository>(value),
    );
  }
}

String _$animalRepositoryHash() => r'dee4e24d8c1c97259fd1edc943aded579149e5b6';

@ProviderFor(Animals)
final animalsProvider = AnimalsProvider._();

final class AnimalsProvider
    extends $AsyncNotifierProvider<Animals, List<AnimalSummary>> {
  AnimalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalsHash();

  @$internal
  @override
  Animals create() => Animals();
}

String _$animalsHash() => r'da27cf3b349a355ca140e027121710cbec8baae9';

abstract class _$Animals extends $AsyncNotifier<List<AnimalSummary>> {
  FutureOr<List<AnimalSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AnimalSummary>>, List<AnimalSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AnimalSummary>>, List<AnimalSummary>>,
              AsyncValue<List<AnimalSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
