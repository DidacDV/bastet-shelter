// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyTasks)
final myTasksProvider = MyTasksProvider._();

final class MyTasksProvider
    extends $AsyncNotifierProvider<MyTasks, List<MyShiftTasksGroup>> {
  MyTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTasksHash();

  @$internal
  @override
  MyTasks create() => MyTasks();
}

String _$myTasksHash() => r'830ca3aef587e8366301d671e43554aeb5e06dd8';

abstract class _$MyTasks extends $AsyncNotifier<List<MyShiftTasksGroup>> {
  FutureOr<List<MyShiftTasksGroup>> build();
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
    element.handleCreate(ref, build);
  }
}
