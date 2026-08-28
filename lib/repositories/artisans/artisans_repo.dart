import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/model/quotation_request_bodies.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/artisans/model/request_quotation_request_body.dart';

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

  Future<BaseResponse<QuotationModel>> sendQuotation(
    String quotationId,
    SendQuotationRequestBody data,
  ) async {
    try {
      return await restClient.sendQuotation(quotationId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<QuotationModel>> counterQuotationPrice(
    String quotationId,
    CounterQuotationRequestBody data,
  ) async {
    try {
      return await restClient.counterQuotationPrice(quotationId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  /// [accept] false declines the quotation.
  Future<BaseResponse<QuotationModel>> acceptOrDeclineQuotation(
    String quotationId, {
    required bool accept,
  }) async {
    try {
      return await restClient.acceptOrDeclineQuotation(
        quotationId,
        {'action': accept ? 'accept' : 'decline'},
      );
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

  Future<BaseResponse<QuotationModel>> requestQuotation(
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
