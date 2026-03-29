import 'package:bastetshelter/features/geo/data/geo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bastetshelter/core/service_locator.dart';

import 'package:bastetshelter/features/geo/data/province_model.dart';

part 'geo_provider.g.dart';

@riverpod
GeoRepository geoRepository(Ref ref) {
  return getIt<GeoRepository>();
}

@riverpod
class Geo extends _$Geo {
  @override
  Future<List<Province>> build() async {
    return ref.read(geoRepositoryProvider).getAllProvinces();
  }
}
