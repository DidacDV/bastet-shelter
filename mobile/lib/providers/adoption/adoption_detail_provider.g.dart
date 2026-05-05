// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdoptionDetail)
final adoptionDetailProvider = AdoptionDetailFamily._();

final class AdoptionDetailProvider
    extends $AsyncNotifierProvider<AdoptionDetail, AdoptionProcessDetails> {
  AdoptionDetailProvider._({
    required AdoptionDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'adoptionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adoptionDetailHash();

  @override
  String toString() {
    return r'adoptionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdoptionDetail create() => AdoptionDetail();

  @override
  bool operator ==(Object other) {
    return other is AdoptionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adoptionDetailHash() => r'0ca6068b7bb6b4b022e0f1dd5d252a49a9d419a7';

final class AdoptionDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          AdoptionDetail,
          AsyncValue<AdoptionProcessDetails>,
          AdoptionProcessDetails,
          FutureOr<AdoptionProcessDetails>,
          int
        > {
  AdoptionDetailFamily._()
    : super(
        retry: null,
        name: r'adoptionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdoptionDetailProvider call(int processId) =>
      AdoptionDetailProvider._(argument: processId, from: this);

  @override
  String toString() => r'adoptionDetailProvider';
}

abstract class _$AdoptionDetail extends $AsyncNotifier<AdoptionProcessDetails> {
  late final _$args = ref.$arg as int;
  int get processId => _$args;

  FutureOr<AdoptionProcessDetails> build(int processId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AdoptionProcessDetails>, AdoptionProcessDetails>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdoptionProcessDetails>,
                AdoptionProcessDetails
              >,
              AsyncValue<AdoptionProcessDetails>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
