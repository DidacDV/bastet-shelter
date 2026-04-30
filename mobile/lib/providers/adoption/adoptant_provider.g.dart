// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoptant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adoptantRepository)
final adoptantRepositoryProvider = AdoptantRepositoryProvider._();

final class AdoptantRepositoryProvider
    extends
        $FunctionalProvider<
          AdoptantRepository,
          AdoptantRepository,
          AdoptantRepository
        >
    with $Provider<AdoptantRepository> {
  AdoptantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptantRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptantRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdoptantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdoptantRepository create(Ref ref) {
    return adoptantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdoptantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdoptantRepository>(value),
    );
  }
}

String _$adoptantRepositoryHash() =>
    r'd2ec8e619d0a22a9032fff4444ca7bfe671df2c5';

@ProviderFor(adoptantDetail)
final adoptantDetailProvider = AdoptantDetailFamily._();

final class AdoptantDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdoptantResponse>,
          AdoptantResponse,
          FutureOr<AdoptantResponse>
        >
    with $FutureModifier<AdoptantResponse>, $FutureProvider<AdoptantResponse> {
  AdoptantDetailProvider._({
    required AdoptantDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'adoptantDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adoptantDetailHash();

  @override
  String toString() {
    return r'adoptantDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdoptantResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdoptantResponse> create(Ref ref) {
    final argument = this.argument as int;
    return adoptantDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdoptantDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adoptantDetailHash() => r'c7b8589021409953d41414bbc886b839d1520c23';

final class AdoptantDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdoptantResponse>, int> {
  AdoptantDetailFamily._()
    : super(
        retry: null,
        name: r'adoptantDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdoptantDetailProvider call(int adoptantId) =>
      AdoptantDetailProvider._(argument: adoptantId, from: this);

  @override
  String toString() => r'adoptantDetailProvider';
}
