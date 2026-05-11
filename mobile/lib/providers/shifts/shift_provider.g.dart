// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shiftRepository)
final shiftRepositoryProvider = ShiftRepositoryProvider._();

final class ShiftRepositoryProvider
    extends
        $FunctionalProvider<ShiftRepository, ShiftRepository, ShiftRepository>
    with $Provider<ShiftRepository> {
  ShiftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shiftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shiftRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShiftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShiftRepository create(Ref ref) {
    return shiftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShiftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShiftRepository>(value),
    );
  }
}

String _$shiftRepositoryHash() => r'05743adc948c5fae527a8a2f8282e4eddcb0c65d';

@ProviderFor(Shifts)
final shiftsProvider = ShiftsFamily._();

final class ShiftsProvider extends $AsyncNotifierProvider<Shifts, List<Shift>> {
  ShiftsProvider._({
    required ShiftsFamily super.from,
    required (int, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'shiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shiftsHash();

  @override
  String toString() {
    return r'shiftsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Shifts create() => Shifts();

  @override
  bool operator ==(Object other) {
    return other is ShiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shiftsHash() => r'78b68c736bfbe7760ecd7344a15c40e3f35905e7';

final class ShiftsFamily extends $Family
    with
        $ClassFamilyOverride<
          Shifts,
          AsyncValue<List<Shift>>,
          List<Shift>,
          FutureOr<List<Shift>>,
          (int, DateTime)
        > {
  ShiftsFamily._()
    : super(
        retry: null,
        name: r'shiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShiftsProvider call(int refugeId, DateTime weekStart) =>
      ShiftsProvider._(argument: (refugeId, weekStart), from: this);

  @override
  String toString() => r'shiftsProvider';
}

abstract class _$Shifts extends $AsyncNotifier<List<Shift>> {
  late final _$args = ref.$arg as (int, DateTime);
  int get refugeId => _$args.$1;
  DateTime get weekStart => _$args.$2;

  FutureOr<List<Shift>> build(int refugeId, DateTime weekStart);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Shift>>, List<Shift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Shift>>, List<Shift>>,
              AsyncValue<List<Shift>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
