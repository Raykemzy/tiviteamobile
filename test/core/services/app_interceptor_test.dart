import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
        refreshTokenRequest: (_) async => {
          'access': 'new-access',
          'refresh': 'new-refresh',
        },
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
        refreshTokenRequest: (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/user/token/refresh'),
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
        refreshTokenRequest: (_) async {
          refreshCalled = true;
          return {'access': 'unused', 'refresh': 'unused'};
        },
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
  });
}
