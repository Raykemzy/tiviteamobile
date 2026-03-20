import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/remember_me_service.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

// Mock LocalStorage implementation for testing
class MockLocalStorage implements LocalStorage {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _storage[key.toString()] = value;
  }

  @override
  dynamic get<T>(String key) {
    return _storage[key];
  }

  @override
  dynamic getAt(int key) {
    return _storage.values.elementAt(key);
  }

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

String _buildJwt({required DateTime expiresAt}) {
  String encode(Map<String, dynamic> data) {
    return base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
  }

  final header = encode({'alg': 'HS256', 'typ': 'JWT'});
  final payload = encode({
    'exp': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
  });
  return '$header.$payload.signature';
}

void main() {
  group('RememberMeService Tests', () {
    late MockLocalStorage mockStorage;
    late UserRepoImpl userRepoImpl;
    late RememberMeService rememberMeService;

    setUp(() {
      mockStorage = MockLocalStorage();
      userRepoImpl = UserRepoImpl(mockStorage);
      rememberMeService = RememberMeService(userRepoImpl);
    });

    group('validateRememberMeData Tests', () {
      test('should return false when remember me is disabled', () {
        // Arrange
        userRepoImpl.saveRememberMe(false);

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when remember me is null', () {
        // Arrange - No remember me value set

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test(
          'should return false when remember me is true but user data is invalid',
          () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        // No user data saved

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when user data is incomplete', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final incompleteUser = User(
          id: '123',
          // Missing email
          entityType: EntityType.client,
        );
        await userRepoImpl.saveUser(incompleteUser);

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when user is inactive', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final inactiveUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: false, // Inactive user
        );
        await userRepoImpl.saveUser(inactiveUser);

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when tokens are missing', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        // No tokens saved

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when access token is empty', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken(''); // Empty token
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return false when refresh token is empty', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken(''); // Empty refresh token

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should return true when all data is valid', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          entityType: EntityType.client,
          isActive: true,
          isVerified: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(true));
      });

      test(
          'should return true when access token is expired but refresh token is still valid',
          () async {
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        await userRepoImpl.saveToken(
          _buildJwt(
              expiresAt:
                  DateTime.now().toUtc().subtract(const Duration(minutes: 5))),
        );
        await userRepoImpl.saveRefreshToken(
          _buildJwt(
              expiresAt: DateTime.now().toUtc().add(const Duration(days: 7))),
        );

        final result = rememberMeService.validateRememberMeData();

        expect(result, equals(true));
      });

      test(
          'should return false when both access and refresh tokens are expired',
          () async {
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        final expiredToken = _buildJwt(
          expiresAt:
              DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        );
        await userRepoImpl.saveToken(expiredToken);
        await userRepoImpl.saveRefreshToken(expiredToken);

        final result = rememberMeService.validateRememberMeData();

        expect(result, equals(false));
      });

      test('should return true for partner entity type', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '456',
          email: 'partner@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          entityType: EntityType.partner,
          isActive: true,
          isVerified: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(true));
      });
    });

    group('getValidatedUser Tests', () {
      test('should return null when validation fails', () {
        // Arrange
        userRepoImpl.saveRememberMe(false);

        // Act
        final result = rememberMeService.getValidatedUser();

        // Assert
        expect(result, isNull);
      });

      test('should return user when validation passes', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.getValidatedUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('123'));
        expect(result.email, equals('test@example.com'));
        expect(result.entityType, equals(EntityType.client));
      });
    });

    group('shouldUseRememberMe Tests', () {
      test('should return false when validation fails', () {
        // Arrange
        userRepoImpl.saveRememberMe(false);

        // Act
        final result = rememberMeService.shouldUseRememberMe();

        // Assert
        expect(result, equals(false));
      });

      test('should return true when validation passes', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.shouldUseRememberMe();

        // Assert
        expect(result, equals(true));
      });
    });

    group('clearRememberMeData Tests', () {
      test('should clear user session and disable remember me', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final user = User(
          id: '123',
          email: 'test@example.com',
          entityType: EntityType.client,
        );
        await userRepoImpl.saveUser(user);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Verify data exists
        expect(userRepoImpl.getRememberMe(), equals(true));
        expect(userRepoImpl.getUser().id, equals('123'));
        expect(userRepoImpl.getToken(), equals('valid_access_token'));

        // Act
        await rememberMeService.clearRememberMeData();

        // Assert
        expect(userRepoImpl.getRememberMe(), equals(false));
        expect(userRepoImpl.getUser().id, isNull);
        expect(userRepoImpl.getToken(), equals(''));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle user with null entity type', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final userWithNullEntityType = User(
          id: '123',
          email: 'test@example.com',
          entityType: null, // Null entity type
          isActive: true,
        );
        await userRepoImpl.saveUser(userWithNullEntityType);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        // Note: Due to User model's defaultValue: EntityType.client,
        // null entityType gets converted to EntityType.client during serialization
        // So this test actually passes validation
        expect(result, equals(true));
      });

      test('should handle user with empty id', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final userWithEmptyId = User(
          id: '', // Empty id
          email: 'test@example.com',
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(userWithEmptyId);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should handle user with empty email', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final userWithEmptyEmail = User(
          id: '123',
          email: '', // Empty email
          entityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(userWithEmptyEmail);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();

        // Assert
        expect(result, equals(false));
      });

      test('should handle comprehensive user data validation', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final comprehensiveUser = User(
          id: '789',
          email: 'comprehensive@example.com',
          firstName: 'Alice',
          lastName: 'Johnson',
          phoneNumber: '+1234567890',
          entityType: EntityType.client,
          isActive: true,
          isVerified: true,
          isStaff: false,
          isSuperuser: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          profilePicture: 'https://example.com/avatar.jpg',
        );
        await userRepoImpl.saveUser(comprehensiveUser);
        userRepoImpl.saveToken('comprehensive_access_token');
        userRepoImpl.saveRefreshToken('comprehensive_refresh_token');

        // Act
        final result = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(result, equals(true));
        expect(validatedUser, isNotNull);
        expect(validatedUser!.id, equals('789'));
        expect(validatedUser.email, equals('comprehensive@example.com'));
        expect(validatedUser.firstName, equals('Alice'));
        expect(validatedUser.lastName, equals('Johnson'));
        expect(validatedUser.phoneNumber, equals('+1234567890'));
        expect(validatedUser.entityType, equals(EntityType.client));
        expect(validatedUser.isActive, equals(true));
        expect(validatedUser.isVerified, equals(true));
      });
    });
  });
}
