// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_advertisements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyAdvertisements)
final myAdvertisementsProvider = MyAdvertisementsProvider._();

final class MyAdvertisementsProvider
    extends
        $AsyncNotifierProvider<MyAdvertisements, List<AdvertisementSummary>> {
  MyAdvertisementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAdvertisementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAdvertisementsHash();

  @$internal
  @override
  MyAdvertisements create() => MyAdvertisements();
}

String _$myAdvertisementsHash() => r'c895e0b498780d1f65fff53c0bff0df2bd6eacc9';

abstract class _$MyAdvertisements
    extends $AsyncNotifier<List<AdvertisementSummary>> {
  FutureOr<List<AdvertisementSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdvertisementSummary>>,
              List<AdvertisementSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdvertisementSummary>>,
                List<AdvertisementSummary>
              >,
              AsyncValue<List<AdvertisementSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
