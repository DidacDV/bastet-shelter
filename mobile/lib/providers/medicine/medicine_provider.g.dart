// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(medicineRepository)
final medicineRepositoryProvider = MedicineRepositoryProvider._();

final class MedicineRepositoryProvider
    extends
        $FunctionalProvider<
          MedicineRepository,
          MedicineRepository,
          MedicineRepository
        >
    with $Provider<MedicineRepository> {
  MedicineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'medicineRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$medicineRepositoryHash();

  @$internal
  @override
  $ProviderElement<MedicineRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MedicineRepository create(Ref ref) {
    return medicineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MedicineRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MedicineRepository>(value),
    );
  }
}

String _$medicineRepositoryHash() =>
    r'eb1737de0c365dc6d1f08d1bff148adf276bd59b';

@ProviderFor(Medicines)
final medicinesProvider = MedicinesProvider._();

final class MedicinesProvider
    extends $AsyncNotifierProvider<Medicines, List<Medicine>> {
  MedicinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'medicinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$medicinesHash();

  @$internal
  @override
  Medicines create() => Medicines();
}

String _$medicinesHash() => r'536b4690d80635eb398aa65e296364f0b849879f';

abstract class _$Medicines extends $AsyncNotifier<List<Medicine>> {
  FutureOr<List<Medicine>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Medicine>>, List<Medicine>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Medicine>>, List<Medicine>>,
              AsyncValue<List<Medicine>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
