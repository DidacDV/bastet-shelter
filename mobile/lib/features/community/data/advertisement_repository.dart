import 'dart:io';

import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:image_picker/image_picker.dart';

class AdvertisementRepository {
  final ApiClient _apiClient;

  AdvertisementRepository(this._apiClient);

  Future<AdvertisementDetail> createAdvertisement({
    required String title,
    required String description,
    required AdCategory category,
    required String provinceName,
  }) async {
    final response = await _apiClient.post(
      '/advertisements/',
      body: {
        'title': title,
        'description': description,
        'category': category.value,
        'province_name': provinceName,
      },
    );
    return AdvertisementDetail.fromJson(response);
  }

  Future<List<AdvertisementSummary>> getMyAdvertisements() async {
    final response = await _apiClient.get('/advertisements/me');
    return AdvertisementSummary.listFromJson(
      response['advertisements'] as List<dynamic>,
    );
  }

  Future<List<AdvertisementSummary>> getAdvertisements({
    String? provinceName,
    AdCategory? category,
  }) async {
    final queryParams = <String, String>{};
    if (provinceName != null) queryParams['province_name'] = provinceName;
    if (category != null) queryParams['category'] = category.value;

    final queryString = Uri(queryParameters: queryParams).query;
    final response = await _apiClient.get('/advertisements/?$queryString');

    return AdvertisementSummary.listFromJson(
      response['advertisements'] as List<dynamic>,
    );
  }

  Future<AdvertisementDetail> getAdvertisementDetail(int adId) async {
    final response = await _apiClient.get('/advertisements/$adId');
    return AdvertisementDetail.fromJson(response);
  }

  Future<AdvertisementDetail> deactivateAdvertisement(int adId) async {
    final response = await _apiClient.patch('/advertisements/$adId/deactivate');
    return AdvertisementDetail.fromJson(response);
  }

  Future<AdvertisementDetail> uploadImage(int adId, XFile imageFile) async {
    final response = await _apiClient.postMultipart(
      '/advertisements/$adId/image',
      File(imageFile.path),
    );
    return AdvertisementDetail.fromJson(response);
  }

  Future<AdvertisementDetail> deleteImage(int adId) async {
    final response = await _apiClient.delete('/advertisements/$adId/image');
    return AdvertisementDetail.fromJson(response);
  }
}
