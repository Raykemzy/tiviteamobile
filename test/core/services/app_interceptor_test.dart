import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/services/auth_token_service.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/rest_client/app_interceptor.dart';
import 'package:tivi_tea/core/services/token_expiration_service.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

class MockLocalStorage implements LocalStorage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _storage[key.toString()] = value;
  }

  @override
  dynamic get<T>(String key) => _storage[key];

  @override
  dynamic getAt(int key) => _storage.values.elementAt(key);

  @override
  Future<int> add(dynamic value) async {
    final index = _storage.length;
    _storage[index.toString()] = value;
    return index;
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<void> delete(dynamic value) async {
    _storage.remove(value.toString());
  }

  @override
  Future<void> putAll(Map<String, dynamic> entries) async {
    _storage.addAll(entries);
  }
}

/// Stands in for the real service so a refresh never leaves the test process.
/// `implements` rather than `extends` keeps the live `Dio()` call out of reach.
class FakeAuthTokenService implements AuthTokenService {
  FakeAuthTokenService(this.onRefresh);

  final Future<Map<String, dynamic>> Function(String refreshToken) onRefresh;

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) =>
      onRefresh(refreshToken);
}

class TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? forwardedError;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    forwardedError = err;
  }

  @override
  void reject(DioException err, [bool? callFollowingErrorInterceptor]) {
    forwardedError = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}

class SuccessfulRetryAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"status":"success"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('DioInterceptor', () {
    late MockLocalStorage storage;
    late UserRepoImpl userRepo;
    late TokenExpirationService tokenExpirationService;
    late Dio dio;

    setUp(() async {
      storage = MockLocalStorage();
      userRepo = UserRepoImpl(storage);
      tokenExpirationService = TokenExpirationService();
      await userRepo.saveToken('old-access');
      await userRepo.saveRefreshToken('valid-refresh');
      dio = Dio()..httpClientAdapter = SuccessfulRetryAdapter();
    });

    test('retries the original request after a successful refresh', () async {
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService(
          (_) async => {
            'access': 'new-access',
            'refresh': 'new-refresh',
          },
        ),
      );
      final handler = TestErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 401,
          data: {'message': 'Invalid or expired token'},
        ),
      );

      await interceptor.onError(error, handler);

      expect(userRepo.getToken(), equals('new-access'));
      expect(userRepo.getRefreshToken(), equals('new-refresh'));
      expect(handler.resolvedResponse?.statusCode, equals(200));
    });

    test('emits token expired when refresh fails', () async {
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService(
          (_) async => throw DioException(
            requestOptions: RequestOptions(path: '/user/token/refresh'),
          ),
        ),
      );
      final handler = TestErrorInterceptorHandler();
      final emitted = <bool>[];
      final subscription = tokenExpirationService.tokenExpiredStream.listen(
        emitted.add,
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 401,
          data: {'reason': 'unauthorized'},
        ),
      );

      await interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, contains(true));
      expect(handler.forwardedError, same(error));
      await subscription.cancel();
    });

    test(
        'does not attempt token refresh for login endpoint unauthorized responses',
        () async {
      var refreshCalled = false;
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService((_) async {
          refreshCalled = true;
          return {'access': 'unused', 'refresh': 'unused'};
        }),
      );
      final handler = TestErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/authentication/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/authentication/login'),
          statusCode: 401,
          data: {'reason': 'unauthorized'},
        ),
      );

      await interceptor.onError(error, handler);

      expect(refreshCalled, isFalse);
      expect(handler.forwardedError, same(error));
    });

    /// Captured verbatim from api.tivitea.africa on an expired access token.
    /// Note the status is 403 (not 401), reason is "Forbidden", and the only
    /// usable marker is inside a stringified Python dict.
    Map<String, dynamic> expiredTokenBody() => {
          'code': 403,
          'status': 'INTERNAL_SERVER_ERROR',
          'error': {
            'reason': 'Forbidden',
            'message':
                "{'detail': ErrorDetail(string='Given token not valid for any "
                    "token type', code='token_not_valid'), 'code': "
                    "ErrorDetail(string='token_not_valid', "
                    "code='token_not_valid')}",
          },
        };

    test('refreshes on the real 403 token_not_valid body', () async {
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService(
          (_) async => {'access': 'new-access', 'refresh': 'new-refresh'},
        ),
      );
      final handler = TestErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 403,
          data: expiredTokenBody(),
        ),
      );

      await interceptor.onError(error, handler);

      expect(userRepo.getToken(), equals('new-access'));
      expect(handler.resolvedResponse?.statusCode, equals(200));
    });

    test('leaves a genuine permission 403 alone', () async {
      var refreshCalled = false;
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService((_) async {
          refreshCalled = true;
          return {'access': 'unused', 'refresh': 'unused'};
        }),
      );
      final handler = TestErrorInterceptorHandler();
      final emitted = <bool>[];
      final subscription =
          tokenExpirationService.tokenExpiredStream.listen(emitted.add);
      final error = DioException(
        requestOptions: RequestOptions(path: '/listings'),
        response: Response(
          requestOptions: RequestOptions(path: '/listings'),
          statusCode: 403,
          data: {
            'code': 403,
            'status': 'FAILED',
            'error': {'reason': 'Forbidden', 'message': 'unauthorized user'},
          },
        ),
      );

      await interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      expect(refreshCalled, isFalse, reason: 'permission error is not expiry');
      expect(emitted, isEmpty, reason: 'must not log the user out');
      expect(handler.forwardedError, same(error));
      await subscription.cancel();
    });

    test('concurrent auth failures share a single refresh', () async {
      var refreshCalls = 0;
      final interceptor = DioInterceptor(
        dio: dio,
        userRepository: userRepo,
        tokenExpirationService: tokenExpirationService,
        authTokenService: FakeAuthTokenService((_) async {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return {'access': 'new-access', 'refresh': 'new-refresh'};
        }),
      );

      DioException failing(String path) => DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 403,
              data: expiredTokenBody(),
            ),
          );

      await Future.wait<void>([
        Future<void>.value(
          interceptor.onError(failing('/a'), TestErrorInterceptorHandler()),
        ),
        Future<void>.value(
          interceptor.onError(failing('/b'), TestErrorInterceptorHandler()),
        ),
        Future<void>.value(
          interceptor.onError(failing('/c'), TestErrorInterceptorHandler()),
        ),
      ]);

      expect(
        refreshCalls,
        equals(1),
        reason: 'the backend rotates refresh tokens; a stampede kills them all',
      );
    });
  });
}
