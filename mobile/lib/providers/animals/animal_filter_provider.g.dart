// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds and mutates the current filter state.
/// Widgets call methods on the notifier; they never mutate state directly.

@ProviderFor(AnimalFilter)
final animalFilterProvider = AnimalFilterProvider._();

/// Holds and mutates the current filter state.
/// Widgets call methods on the notifier; they never mutate state directly.
final class AnimalFilterProvider
    extends $NotifierProvider<AnimalFilter, AnimalFilterState> {
  /// Holds and mutates the current filter state.
  /// Widgets call methods on the notifier; they never mutate state directly.
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

String _$animalFilterHash() => r'26a51ac0f87a240c7efaf22899d803f32db93a42';

/// Holds and mutates the current filter state.
/// Widgets call methods on the notifier; they never mutate state directly.

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

/// Derived provider — no network call, just in-memory filtering.
/// Automatically recomputes whenever the raw list OR the filter state changes.
/// Widgets watch this, not animalsProvider directly.

@ProviderFor(filteredAnimals)
final filteredAnimalsProvider = FilteredAnimalsProvider._();

/// Derived provider — no network call, just in-memory filtering.
/// Automatically recomputes whenever the raw list OR the filter state changes.
/// Widgets watch this, not animalsProvider directly.

final class FilteredAnimalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnimalSummary>>,
          AsyncValue<List<AnimalSummary>>,
          AsyncValue<List<AnimalSummary>>
        >
    with $Provider<AsyncValue<List<AnimalSummary>>> {
  /// Derived provider — no network call, just in-memory filtering.
  /// Automatically recomputes whenever the raw list OR the filter state changes.
  /// Widgets watch this, not animalsProvider directly.
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
