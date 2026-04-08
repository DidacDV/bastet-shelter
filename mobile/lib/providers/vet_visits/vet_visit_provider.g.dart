// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vet_visit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vetVisitRepository)
final vetVisitRepositoryProvider = VetVisitRepositoryProvider._();

final class VetVisitRepositoryProvider
    extends
        $FunctionalProvider<
          VetVisitRepository,
          VetVisitRepository,
          VetVisitRepository
        >
    with $Provider<VetVisitRepository> {
  VetVisitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vetVisitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vetVisitRepositoryHash();

  @$internal
  @override
  $ProviderElement<VetVisitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VetVisitRepository create(Ref ref) {
    return vetVisitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VetVisitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VetVisitRepository>(value),
    );
  }
}

String _$vetVisitRepositoryHash() =>
    r'8dffa41ffced14c2ec0f5788c3732806d2ac29da';

@ProviderFor(VetVisits)
final vetVisitsProvider = VetVisitsFamily._();

final class VetVisitsProvider
    extends $AsyncNotifierProvider<VetVisits, List<VetVisit>> {
  VetVisitsProvider._({
    required VetVisitsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'vetVisitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vetVisitsHash();

  @override
  String toString() {
    return r'vetVisitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VetVisits create() => VetVisits();

  @override
  bool operator ==(Object other) {
    return other is VetVisitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vetVisitsHash() => r'5563055435314887c229189aeb196eb0a0c50f0e';

final class VetVisitsFamily extends $Family
    with
        $ClassFamilyOverride<
          VetVisits,
          AsyncValue<List<VetVisit>>,
          List<VetVisit>,
          FutureOr<List<VetVisit>>,
          int
        > {
  VetVisitsFamily._()
    : super(
        retry: null,
        name: r'vetVisitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VetVisitsProvider call(int animalId) =>
      VetVisitsProvider._(argument: animalId, from: this);

  @override
  String toString() => r'vetVisitsProvider';
}

abstract class _$VetVisits extends $AsyncNotifier<List<VetVisit>> {
  late final _$args = ref.$arg as int;
  int get animalId => _$args;

  FutureOr<List<VetVisit>> build(int animalId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<VetVisit>>, List<VetVisit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VetVisit>>, List<VetVisit>>,
              AsyncValue<List<VetVisit>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
