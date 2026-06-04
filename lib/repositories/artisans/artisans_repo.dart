import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/artisans/model/request_quotation_request_body.dart';
import 'package:tivi_tea/features/artisans/model/request_quotation_response_model.dart';

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

  Future<BaseResponse<ArtisanResponseModel>> getArtisan(
    String artisanId,
  ) async {
    try {
      return await restClient.getArtisan(artisanId);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<RequestQuotationResponseModel>> requestQuotation(
    String artisanId,
    RequestQuotationRequestBody data,
  ) async {
    try {
      return await restClient.requestQuotation(artisanId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
