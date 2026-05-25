// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_pending_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnimalPendingTasks)
final animalPendingTasksProvider = AnimalPendingTasksFamily._();

final class AnimalPendingTasksProvider
    extends
        $AsyncNotifierProvider<AnimalPendingTasks, List<MyShiftTasksGroup>> {
  AnimalPendingTasksProvider._({
    required AnimalPendingTasksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'animalPendingTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$animalPendingTasksHash();

  @override
  String toString() {
    return r'animalPendingTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AnimalPendingTasks create() => AnimalPendingTasks();

  @override
  bool operator ==(Object other) {
    return other is AnimalPendingTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$animalPendingTasksHash() =>
    r'79f3ad94af445da03922926cb660d2b4be6394cc';

final class AnimalPendingTasksFamily extends $Family
    with
        $ClassFamilyOverride<
          AnimalPendingTasks,
          AsyncValue<List<MyShiftTasksGroup>>,
          List<MyShiftTasksGroup>,
          FutureOr<List<MyShiftTasksGroup>>,
          int
        > {
  AnimalPendingTasksFamily._()
    : super(
        retry: null,
        name: r'animalPendingTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnimalPendingTasksProvider call(int animalId) =>
      AnimalPendingTasksProvider._(argument: animalId, from: this);

  @override
  String toString() => r'animalPendingTasksProvider';
}

abstract class _$AnimalPendingTasks
    extends $AsyncNotifier<List<MyShiftTasksGroup>> {
  late final _$args = ref.$arg as int;
  int get animalId => _$args;

  FutureOr<List<MyShiftTasksGroup>> build(int animalId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MyShiftTasksGroup>>,
              List<MyShiftTasksGroup>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MyShiftTasksGroup>>,
                List<MyShiftTasksGroup>
              >,
              AsyncValue<List<MyShiftTasksGroup>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
