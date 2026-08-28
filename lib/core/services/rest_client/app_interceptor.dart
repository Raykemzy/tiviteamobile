import 'dart:async';
import 'dart:convert';

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
      // The retry carried a freshly minted token and still failed on auth —
      // the session is genuinely unrecoverable.
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

    // Keep existing behavior: do not trigger auth refresh for verification flow.
    final isUserNotVerified =
        _extractMessage(data)?.toLowerCase().contains('user not verified') ==
            true;
    if (isUserNotVerified) return false;

    final statusCode = response.statusCode ?? 0;
    if (statusCode != 401 && statusCode != 403) return false;

    // A bare 401 is unambiguous. A 403 is not — this backend uses it both for
    // "you may not do that" and for "your token died" — so a 403 only counts
    // when the body actually carries a token marker. Without that distinction
    // a permission error would log the user out.
    return statusCode == 401 || _looksLikeTokenFailure(data);
  }

  /// Whether [data] carries one of the backend's expired/invalid-token markers.
  ///
  /// This API reports an expired access token as **403**, with
  /// `status: "INTERNAL_SERVER_ERROR"`, `error.reason: "Forbidden"`, and the
  /// only dependable signal — DRF's `token_not_valid` code — buried inside
  /// `error.message` as a *stringified Python dict*:
  ///
  /// ```
  /// "{'detail': ErrorDetail(string='Given token not valid for any token
  ///   type', code='token_not_valid'), ...}"
  /// ```
  ///
  /// There is no field to read it out of, so the whole serialised body is
  /// searched. Access tokens live 10 minutes, so this path runs constantly.
  bool _looksLikeTokenFailure(dynamic data) {
    final haystack = data is String ? data : jsonEncode(_safe(data));
    final lower = haystack.toLowerCase();
    return lower.contains('token_not_valid') ||
        lower.contains('token not valid') ||
        lower.contains('invalid or expired token') ||
        lower.contains('token is invalid or expired') ||
        lower.contains('authentication credentials were not provided');
  }

  /// jsonEncode chokes on non-encodable values; fall back to toString().
  Object? _safe(dynamic data) {
    try {
      jsonEncode(data);
      return data;
    } catch (_) {
      return data?.toString();
    }
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

  /// Guards against a refresh stampede.
  ///
  /// The backend *rotates* refresh tokens: the first call invalidates the one
  /// every other in-flight request is holding. Several requests failing auth
  /// at once — the home screen fires a handful — would each POST the same
  /// now-dead token, and every loser would report the session as expired and
  /// log the user out. All callers share one refresh instead.
  static Future<bool>? _inFlightRefresh;

  Future<bool> _refreshOnce() {
    return _inFlightRefresh ??= _doRefresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  Future<bool> _doRefresh() async {
    final refreshToken = userRepository.getRefreshToken();
    if (refreshToken.isEmpty) return false;
    try {
      final refreshed = await authTokenService.refreshToken(refreshToken);
      final access = refreshed['access'] as String? ?? '';
      if (access.isEmpty) return false;
      await userRepository.saveToken(access);
      await userRepository.saveRefreshToken(
        refreshed['refresh'] as String? ?? refreshToken,
      );
      debugLog('Access token refreshed');
      return true;
    } on DioException catch (e) {
      debugLog('refresh error===>> $e');
      return false;
    }
  }

  Future<void> _refreshToken(
    DioException error,
    ErrorInterceptorHandler handler,
    Dio dio,
    UserRepository userRepository,
  ) async {
    final refreshed = await _refreshOnce();
    if (!refreshed) {
      tokenExpirationService.emitTokenExpired();
      handler.next(error);
      return;
    }
    try {
      return await handleError(handler, error, dio);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
