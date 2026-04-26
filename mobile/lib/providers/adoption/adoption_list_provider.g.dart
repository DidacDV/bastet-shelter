// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdoptionList)
final adoptionListProvider = AdoptionListProvider._();

final class AdoptionListProvider
    extends $AsyncNotifierProvider<AdoptionList, List<AdoptionProcessSummary>> {
  AdoptionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptionListHash();

  @$internal
  @override
  AdoptionList create() => AdoptionList();
}

String _$adoptionListHash() => r'f4bb222829f5a9abea21951c5b4a0e5750d5813d';

abstract class _$AdoptionList
    extends $AsyncNotifier<List<AdoptionProcessSummary>> {
  FutureOr<List<AdoptionProcessSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdoptionProcessSummary>>,
              List<AdoptionProcessSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdoptionProcessSummary>>,
                List<AdoptionProcessSummary>
              >,
              AsyncValue<List<AdoptionProcessSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
