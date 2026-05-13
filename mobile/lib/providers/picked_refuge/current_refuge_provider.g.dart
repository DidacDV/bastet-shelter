// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_refuge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentRefuge)
final currentRefugeProvider = CurrentRefugeProvider._();

final class CurrentRefugeProvider
    extends $NotifierProvider<CurrentRefuge, int?> {
  CurrentRefugeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentRefugeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentRefugeHash();

  @$internal
  @override
  CurrentRefuge create() => CurrentRefuge();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$currentRefugeHash() => r'033d015417b589b86711cec2c48e3714e9988ba6';

abstract class _$CurrentRefuge extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
