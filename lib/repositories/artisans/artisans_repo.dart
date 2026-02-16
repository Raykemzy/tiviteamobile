import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';

final class ArtisansRepo {
  final RestClient restClient;

  ArtisansRepo({required this.restClient});

  Future<BaseResponse<GenericPaginatedResponse<ArtisanResponseModel>>>
      getArtisansList(int page) async {
    try {
      return await restClient.getArtisansList(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
