// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animalDetail)
final animalDetailProvider = AnimalDetailFamily._();

final class AnimalDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnimalDetails>,
          AnimalDetails,
          FutureOr<AnimalDetails>
        >
    with $FutureModifier<AnimalDetails>, $FutureProvider<AnimalDetails> {
  AnimalDetailProvider._({
    required AnimalDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'animalDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$animalDetailHash();

  @override
  String toString() {
    return r'animalDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AnimalDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AnimalDetails> create(Ref ref) {
    final argument = this.argument as int;
    return animalDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnimalDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$animalDetailHash() => r'f5254b0823f12415b03ddb67576d2dbd3aba4511';

final class AnimalDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AnimalDetails>, int> {
  AnimalDetailFamily._()
    : super(
        retry: null,
        name: r'animalDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnimalDetailProvider call(int animalId) =>
      AnimalDetailProvider._(argument: animalId, from: this);

  @override
  String toString() => r'animalDetailProvider';
}
