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

String _$shiftsHash() => r'a9a969fc4d92dcc0cdf15dfe06fab575f8bfabb9';

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

@ProviderFor(ShiftDetailNotifier)
final shiftDetailProvider = ShiftDetailNotifierFamily._();

final class ShiftDetailNotifierProvider
    extends $AsyncNotifierProvider<ShiftDetailNotifier, ShiftDetail> {
  ShiftDetailNotifierProvider._({
    required ShiftDetailNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'shiftDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shiftDetailNotifierHash();

  @override
  String toString() {
    return r'shiftDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShiftDetailNotifier create() => ShiftDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is ShiftDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shiftDetailNotifierHash() =>
    r'f05deb02607ef61f4f9bb19ffc96030825738f0c';

final class ShiftDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ShiftDetailNotifier,
          AsyncValue<ShiftDetail>,
          ShiftDetail,
          FutureOr<ShiftDetail>,
          int
        > {
  ShiftDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'shiftDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShiftDetailNotifierProvider call(int shiftId) =>
      ShiftDetailNotifierProvider._(argument: shiftId, from: this);

  @override
  String toString() => r'shiftDetailProvider';
}

abstract class _$ShiftDetailNotifier extends $AsyncNotifier<ShiftDetail> {
  late final _$args = ref.$arg as int;
  int get shiftId => _$args;

  FutureOr<ShiftDetail> build(int shiftId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ShiftDetail>, ShiftDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ShiftDetail>, ShiftDetail>,
              AsyncValue<ShiftDetail>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
