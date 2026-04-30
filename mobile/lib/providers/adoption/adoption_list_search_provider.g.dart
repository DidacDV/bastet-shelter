// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_list_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdoptionSearchQuery)
final adoptionSearchQueryProvider = AdoptionSearchQueryProvider._();

final class AdoptionSearchQueryProvider
    extends $NotifierProvider<AdoptionSearchQuery, String> {
  AdoptionSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptionSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptionSearchQueryHash();

  @$internal
  @override
  AdoptionSearchQuery create() => AdoptionSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$adoptionSearchQueryHash() =>
    r'b3128e56d32655831041a56afb5943fbee952caa';

abstract class _$AdoptionSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredAdoptionList)
final filteredAdoptionListProvider = FilteredAdoptionListProvider._();

final class FilteredAdoptionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdoptionProcessSummary>>,
          AsyncValue<List<AdoptionProcessSummary>>,
          AsyncValue<List<AdoptionProcessSummary>>
        >
    with $Provider<AsyncValue<List<AdoptionProcessSummary>>> {
  FilteredAdoptionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredAdoptionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredAdoptionListHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<AdoptionProcessSummary>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<AdoptionProcessSummary>> create(Ref ref) {
    return filteredAdoptionList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<AdoptionProcessSummary>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<AdoptionProcessSummary>>>(value),
    );
  }
}

String _$filteredAdoptionListHash() =>
    r'654f213c3fd9c72203159c9acc080f2b90ac249c';
