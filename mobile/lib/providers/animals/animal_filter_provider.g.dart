// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// holds the current filters state (so widgets don't directly access to filter state)

@ProviderFor(AnimalFilter)
final animalFilterProvider = AnimalFilterProvider._();

/// holds the current filters state (so widgets don't directly access to filter state)
final class AnimalFilterProvider
    extends $NotifierProvider<AnimalFilter, AnimalFilterState> {
  /// holds the current filters state (so widgets don't directly access to filter state)
  AnimalFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animalFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animalFilterHash();

  @$internal
  @override
  AnimalFilter create() => AnimalFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimalFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimalFilterState>(value),
    );
  }
}

String _$animalFilterHash() => r'94b2c51dbd7dacae754d259ba35cc9b3d200a1ca';

/// holds the current filters state (so widgets don't directly access to filter state)

abstract class _$AnimalFilter extends $Notifier<AnimalFilterState> {
  AnimalFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AnimalFilterState, AnimalFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnimalFilterState, AnimalFilterState>,
              AnimalFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredAnimals)
final filteredAnimalsProvider = FilteredAnimalsProvider._();

final class FilteredAnimalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnimalSummary>>,
          AsyncValue<List<AnimalSummary>>,
          AsyncValue<List<AnimalSummary>>
        >
    with $Provider<AsyncValue<List<AnimalSummary>>> {
  FilteredAnimalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredAnimalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredAnimalsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<AnimalSummary>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<AnimalSummary>> create(Ref ref) {
    return filteredAnimals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<AnimalSummary>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<AnimalSummary>>>(
        value,
      ),
    );
  }
}

String _$filteredAnimalsHash() => r'df4bc292e0cb581587977f1a0fbb36c5bff6c1e2';
