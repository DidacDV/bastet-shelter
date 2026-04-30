// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_step_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(formStepContent)
final formStepContentProvider = FormStepContentFamily._();

final class FormStepContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdoptionFormContent>,
          AdoptionFormContent,
          FutureOr<AdoptionFormContent>
        >
    with
        $FutureModifier<AdoptionFormContent>,
        $FutureProvider<AdoptionFormContent> {
  FormStepContentProvider._({
    required FormStepContentFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'formStepContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formStepContentHash();

  @override
  String toString() {
    return r'formStepContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdoptionFormContent> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdoptionFormContent> create(Ref ref) {
    final argument = this.argument as int;
    return formStepContent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FormStepContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formStepContentHash() => r'8fa1b93ec9c5a970a876296760defdd21ce0e58d';

final class FormStepContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdoptionFormContent>, int> {
  FormStepContentFamily._()
    : super(
        retry: null,
        name: r'formStepContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FormStepContentProvider call(int processId) =>
      FormStepContentProvider._(argument: processId, from: this);

  @override
  String toString() => r'formStepContentProvider';
}
