import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage_impl.dart';
import 'package:tivi_tea/core/services/token_expiration_service.dart';
import 'package:tivi_tea/features/common/session_expiration_listener.dart';
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

void main() {
  testWidgets('clears the session and triggers UI callback when token expires',
      (
    tester,
  ) async {
    final storage = MockLocalStorage();
    final userRepo = UserRepoImpl(storage);
    final tokenService = TokenExpirationService();
    await userRepo.saveToken('access-token');
    await userRepo.saveRefreshToken('refresh-token');
    await userRepo.saveRememberMe(true);

    var callbackTriggered = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDB.overrideWithValue(storage),
          userRepositoryProvider.overrideWithValue(userRepo),
          tokenExpirationServiceProvider.overrideWithValue(tokenService),
        ],
        child: MaterialApp(
          home: SessionExpirationListener(
            onSessionExpired: () {
              callbackTriggered = true;
            },
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    tokenService.emitTokenExpired();
    await tester.pumpAndSettle();

    expect(callbackTriggered, isTrue);
    expect(userRepo.getToken(), isEmpty);
    expect(userRepo.getRefreshToken(), isEmpty);
    expect(userRepo.getRememberMe(), isFalse);
  });
}
