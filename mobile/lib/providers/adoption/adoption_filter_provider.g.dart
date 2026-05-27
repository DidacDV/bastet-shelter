// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdoptionFilter)
final adoptionFilterProvider = AdoptionFilterProvider._();

final class AdoptionFilterProvider
    extends $NotifierProvider<AdoptionFilter, AdoptionFilterState> {
  AdoptionFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptionFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptionFilterHash();

  @$internal
  @override
  AdoptionFilter create() => AdoptionFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdoptionFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdoptionFilterState>(value),
    );
  }
}

String _$adoptionFilterHash() => r'c60d443b9edb66b65ced63314f450cf8316e6e85';

abstract class _$AdoptionFilter extends $Notifier<AdoptionFilterState> {
  AdoptionFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AdoptionFilterState, AdoptionFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdoptionFilterState, AdoptionFilterState>,
              AdoptionFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
