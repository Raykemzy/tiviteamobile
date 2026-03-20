import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage_impl.dart';
import 'package:tivi_tea/features/login/model/general/login_request_object.dart';
import 'package:tivi_tea/features/login/model/general/login_response_object.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';

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

class FakeRestClient implements RestClient {
  FakeRestClient(this._loginHandler);

  final Future<BaseResponse<LoginResponseObject>> Function(LoginRequestObject)
      _loginHandler;

  @override
  Future<BaseResponse<LoginResponseObject>> login(LoginRequestObject data) {
    return _loginHandler(data);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LoginNotifier remember me persistence', () {
    late MockLocalStorage storage;
    late UserRepoImpl userRepo;
    late ProviderContainer container;

    setUp(() {
      storage = MockLocalStorage();
      userRepo = UserRepoImpl(storage);
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          localDB.overrideWithValue(storage),
          userRepositoryProvider.overrideWithValue(userRepo),
          restClient.overrideWithValue(
            FakeRestClient((_) async {
              return BaseResponse<LoginResponseObject>(
                status: 'success',
                data: LoginResponseObject(
                  user: User(
                    id: '1',
                    email: 'user@example.com',
                    entityType: EntityType.client,
                    isActive: true,
                  ),
                  tokens: Tokens(
                    access: 'access-token',
                    refresh: 'refresh-token',
                  ),
                ),
              );
            }),
          ),
        ],
      );
    }

    test('stores remember me as true after successful login', () async {
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);
      final completer = Completer<void>();

      notifier.login(
        LoginRequestObject(email: 'user@example.com', password: 'password'),
        rememberMe: true,
        onSuccess: (_) => completer.complete(),
        onError: completer.completeError,
      );

      await completer.future;

      expect(userRepo.getRememberMe(), isTrue);
    });

    test('overwrites a previously saved true value when remember me is false',
        () async {
      await userRepo.saveRememberMe(true);
      container = createContainer();
      final notifier = container.read(loginNotifierProvider.notifier);
      final completer = Completer<void>();

      notifier.login(
        LoginRequestObject(email: 'user@example.com', password: 'password'),
        rememberMe: false,
        onSuccess: (_) => completer.complete(),
        onError: completer.completeError,
      );

      await completer.future;

      expect(userRepo.getRememberMe(), isFalse);
    });
  });
}
