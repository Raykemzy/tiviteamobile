import 'package:dio/dio.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/utils/logger.dart';

class AppException {
  static BaseResponse<T> handleError<T>(
    DioException e, {
    T? data,
  }) {
    final response = e.response;
    if (response != null && DioExceptionType.badResponse == e.type) {
      final statusCode = response.statusCode ?? 0;

      // Server-side failures: never surface the raw body — it's usually an
      // HTML error page, not something a user should read.
      if (statusCode >= 500) {
        return BaseResponse(
          status: "SERVER_ERROR",
          message: "A server error occurred. Please try again later.",
          data: data,
        );
      }

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final errorData = responseData["error"];

        // Check if error field exists in the response
        if (errorData is Map<String, dynamic>) {
          debugLog(errorData);
          return BaseResponse(
            status: responseData["status"] ?? "",
            data: data,
            message: errorData["message"] ?? _friendlyForStatus(statusCode),
            error: ErrorResponseObject(
              reason: errorData["reason"] ?? "",
              message: errorData["message"] ?? "",
            ),
          );
        }

        debugLog(responseData);
        return BaseResponse(
          status: responseData["status"] ?? "",
          data: data,
          message: responseData["message"] ?? _friendlyForStatus(statusCode),
        );
      }

      // Non-JSON body (raw HTML / plain-text error page). Map it to a friendly
      // message instead of dumping the raw response to the user.
      debugLog(responseData);
      return BaseResponse(
        status: "",
        data: data,
        message: _friendlyForStatus(statusCode),
      );
    }
    return BaseResponse(
      status: "",
      data: data,
      message: _mapException(e.type),
    );
  }

  static String _friendlyForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
        return "Your session has expired. Please log in again.";
      case 403:
        return "You don't have permission to perform this action.";
      case 404:
        return "We couldn't find what you were looking for.";
      case 400:
        return "Something went wrong with your request. Please try again.";
      default:
        return "An error occurred. Please try again.";
    }
  }

  static String _mapException(DioExceptionType? error) {
    if (DioExceptionType.connectionTimeout == error ||
        DioExceptionType.receiveTimeout == error ||
        DioExceptionType.sendTimeout == error) {
      return "Your connection timed out";
    } else if (DioExceptionType.connectionError == error) {
      return "Please check your internet connection";
    }
    return "An error occurred";
  }
}
