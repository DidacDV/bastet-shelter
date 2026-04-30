// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adoption_screen_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adoptionScreenData)
final adoptionScreenDataProvider = AdoptionScreenDataFamily._();

final class AdoptionScreenDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdoptionScreenState>,
          AdoptionScreenState,
          FutureOr<AdoptionScreenState>
        >
    with
        $FutureModifier<AdoptionScreenState>,
        $FutureProvider<AdoptionScreenState> {
  AdoptionScreenDataProvider._({
    required AdoptionScreenDataFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'adoptionScreenDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adoptionScreenDataHash();

  @override
  String toString() {
    return r'adoptionScreenDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdoptionScreenState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdoptionScreenState> create(Ref ref) {
    final argument = this.argument as int;
    return adoptionScreenData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdoptionScreenDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adoptionScreenDataHash() =>
    r'8e412bc218fac39f0eb5d1f8712afd04836bee1b';

final class AdoptionScreenDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdoptionScreenState>, int> {
  AdoptionScreenDataFamily._()
    : super(
        retry: null,
        name: r'adoptionScreenDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdoptionScreenDataProvider call(int processId) =>
      AdoptionScreenDataProvider._(argument: processId, from: this);

  @override
  String toString() => r'adoptionScreenDataProvider';
}
