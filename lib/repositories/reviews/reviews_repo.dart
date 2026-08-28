import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/reviews/model/review_models.dart';

final class ReviewsRepo {
  final RestClient restClient;

  ReviewsRepo({required this.restClient});

  Future<BaseResponse<BookingReviewModel>> reviewBooking(
    String bookingId,
    SubmitReviewRequestBody data,
  ) async {
    try {
      return await restClient.reviewBooking(bookingId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  /// Returns 204 with no body, so a success response is synthesised.
  Future<BaseResponse<dynamic>> deleteBookingReview(
    String bookingId,
    String reviewId,
  ) async {
    try {
      await restClient.deleteBookingReview(bookingId, reviewId);
      return BaseResponse(status: 'success');
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<BookingReviewModel>>>
      getPartnerBookingReviews(int page) async {
    try {
      return await restClient.getPartnerBookingReviews(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<ArtisanReviewModel>> reviewArtisan(
    String bookingId,
    SubmitReviewRequestBody data,
  ) async {
    try {
      return await restClient.reviewArtisan(bookingId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<ArtisanReviewModel>>>
      getArtisanReviews(String artisanId, int page) async {
    try {
      return await restClient.getArtisanReviews(artisanId, page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> deleteArtisanReview(String reviewId) async {
    try {
      await restClient.deleteArtisanReview(reviewId);
      return BaseResponse(status: 'success');
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> reviewMarketplaceItem(
    String itemId,
    SubmitReviewRequestBody data,
  ) async {
    try {
      return await restClient.reviewMarketplaceItem(itemId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> confirmServiceCompletion(
    String bookingId,
  ) async {
    try {
      return await restClient.confirmServiceCompletion(bookingId);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
