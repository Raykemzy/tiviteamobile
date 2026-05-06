import 'dart:async';

import 'package:dio/dio.dart';
import 'package:tivi_tea/core/services/auth_token_service.dart';
import 'package:tivi_tea/core/services/token_expiration_service.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/repositories/user/user_repo.dart';

class DioInterceptor extends Interceptor {
  final Dio dio;
  final UserRepository userRepository;
  final TokenExpirationService tokenExpirationService;
  final AuthTokenService authTokenService;

  DioInterceptor({
    required this.dio,
    required this.userRepository,
    required this.tokenExpirationService,
    required this.authTokenService,
  });

  @override
  FutureOr<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final String token = userRepository.getToken();
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'JWT $token';
        debugLog('[TOKEN]$token');
      }
    } catch (e) {
      debugLog(e);
    }

    debugLog('[URL]${options.uri}');
    debugLog('[BODY] ${options.data}');
    debugLog('[METHOD] ${options.method} => PATH: ${options.path}');
    debugLog('[QUERIES]${options.queryParameters}');

    handler.next(options);
    return options;
  }

  @override
  FutureOr<dynamic> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugLog(
      '[RESPONSE FROM ${response.requestOptions.path}]: ${response.data}',
    );

    handler.next(response);
    return response;
  }

  @override
  FutureOr<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugLog('[ERROR] ${err.response?.data}');
    debugLog('[ERROR STATUS] ${err.response?.statusCode}');
    debugLog('[ERROR PATH] ${err.requestOptions.path}');
    debugLog('[ERROR RESPONSE TYPE] ${err.requestOptions.responseType}');

    final shouldHandleUnauthorized = _shouldHandleUnauthorized(err);
    if (shouldHandleUnauthorized) {
      await _refreshToken(err, handler, dio, userRepository);
      return;
    }
    debugLog('[ERROR] ${err.requestOptions.uri}');
    debugLog('[ERROR] ${err.response}');
    handler.next(err);
    return err;
  }

  bool _shouldHandleUnauthorized(DioException err) {
    final response = err.response;
    if (response == null) return false;
    if (_hasAlreadyRetried(err.requestOptions)) {
      tokenExpirationService.emitTokenExpired();
      return false;
    }

    if (_shouldSkipRefresh(err.requestOptions.path)) {
      return false;
    }

    if (userRepository.getRefreshToken().isEmpty) {
      return false;
    }

    final data = response.data;
    final message = _extractMessage(data)?.toLowerCase();
    final reason = _extractReason(data)?.toLowerCase();
    final code = _extractCode(data)?.toLowerCase();
    final statusCode = response.statusCode;

    // Keep existing behavior: do not trigger auth refresh for verification flow.
    final isUserNotVerified = message?.contains('user not verified') == true;
    if (isUserNotVerified) return false;

    final isUnauthorizedByStatus = statusCode == 401;
    final isUnauthorizedByReason = reason == 'unauthorized';
    final isUnauthorizedByCode = code == 'token_not_valid';
    final isUnauthorizedByMessage =
        message?.contains('invalid or expired token') == true ||
            message?.contains('token is invalid or expired') == true;

    return isUnauthorizedByStatus ||
        isUnauthorizedByReason ||
        isUnauthorizedByCode ||
        isUnauthorizedByMessage;
  }

  bool _shouldSkipRefresh(String path) {
    return path.contains('/authentication/login') ||
        path.contains('/user/token/refresh') ||
        path.contains('/forgot-password') ||
        path.contains('/change-password');
  }

  bool _hasAlreadyRetried(RequestOptions requestOptions) {
    return requestOptions.extra['retriedAfterRefresh'] == true;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final errorMessage = error['message'];
        if (errorMessage is String) return errorMessage;
      }
    }
    return null;
  }

  String? _extractReason(dynamic data) {
    if (data is Map<String, dynamic>) {
      final reason = data['reason'];
      if (reason is String) return reason;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final errorReason = error['reason'];
        if (errorReason is String) return errorReason;
      }
    }
    return null;
  }

  String? _extractCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code is String) return code;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final errorCode = error['code'];
        if (errorCode is String) return errorCode;
      }
    }
    return null;
  }

  Future<void> handleError(
    ErrorInterceptorHandler handler,
    DioException err,
    Dio dio,
  ) async {
    final opts = Options(
      method: err.requestOptions.method,
      headers: {
        ...err.requestOptions.headers,
        'Authorization': 'JWT ${userRepository.getToken()}',
      },
      responseType: err.requestOptions.responseType,
      extra: {
        ...err.requestOptions.extra,
        'retriedAfterRefresh': true,
      },
    );
    final cloneReq = await dio.request(
      err.requestOptions.path,
      options: opts,
      data: err.requestOptions.data,
      queryParameters: err.requestOptions.queryParameters,
    );

    return handler.resolve(cloneReq);
  }

  Future<void> _refreshToken(
    DioException error,
    ErrorInterceptorHandler handler,
    Dio dio,
    UserRepository userRepository,
  ) async {
    final refreshToken = userRepository.getRefreshToken();
    try {
      final refreshedTokens = await authTokenService.refreshToken(refreshToken);
      await userRepository
          .saveToken(refreshedTokens['access'] as String? ?? '');
      await userRepository.saveRefreshToken(
        refreshedTokens['refresh'] as String? ?? refreshToken,
      );
      debugLog("Access Token gotten and saved");
      return handleError(handler, error, dio);
    } on DioException catch (e) {
      debugLog('refresh error===>> $e');
      // Emit token expiration event when refresh fails
      tokenExpirationService.emitTokenExpired();
      handler.next(error);
      return;
    }
  }
}
