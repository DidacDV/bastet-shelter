// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_treatment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(medicalTreatmentRepository)
final medicalTreatmentRepositoryProvider =
    MedicalTreatmentRepositoryProvider._();

final class MedicalTreatmentRepositoryProvider
    extends
        $FunctionalProvider<
          MedicalTreatmentRepository,
          MedicalTreatmentRepository,
          MedicalTreatmentRepository
        >
    with $Provider<MedicalTreatmentRepository> {
  MedicalTreatmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'medicalTreatmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$medicalTreatmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<MedicalTreatmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MedicalTreatmentRepository create(Ref ref) {
    return medicalTreatmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MedicalTreatmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MedicalTreatmentRepository>(value),
    );
  }
}

String _$medicalTreatmentRepositoryHash() =>
    r'879a7cf3db2a5d3f894e590a7b7b561f08c4e4af';

@ProviderFor(MedicalTreatments)
final medicalTreatmentsProvider = MedicalTreatmentsFamily._();

final class MedicalTreatmentsProvider
    extends $AsyncNotifierProvider<MedicalTreatments, List<MedicalTreatment>> {
  MedicalTreatmentsProvider._({
    required MedicalTreatmentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'medicalTreatmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$medicalTreatmentsHash();

  @override
  String toString() {
    return r'medicalTreatmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MedicalTreatments create() => MedicalTreatments();

  @override
  bool operator ==(Object other) {
    return other is MedicalTreatmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$medicalTreatmentsHash() => r'8ade5520a6d0db4fd6975a1dca80e367150792a5';

final class MedicalTreatmentsFamily extends $Family
    with
        $ClassFamilyOverride<
          MedicalTreatments,
          AsyncValue<List<MedicalTreatment>>,
          List<MedicalTreatment>,
          FutureOr<List<MedicalTreatment>>,
          int
        > {
  MedicalTreatmentsFamily._()
    : super(
        retry: null,
        name: r'medicalTreatmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MedicalTreatmentsProvider call(int animalId) =>
      MedicalTreatmentsProvider._(argument: animalId, from: this);

  @override
  String toString() => r'medicalTreatmentsProvider';
}

abstract class _$MedicalTreatments
    extends $AsyncNotifier<List<MedicalTreatment>> {
  late final _$args = ref.$arg as int;
  int get animalId => _$args;

  FutureOr<List<MedicalTreatment>> build(int animalId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MedicalTreatment>>, List<MedicalTreatment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MedicalTreatment>>,
                List<MedicalTreatment>
              >,
              AsyncValue<List<MedicalTreatment>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
