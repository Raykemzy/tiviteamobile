import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage_impl.dart';
import 'package:tivi_tea/core/services/remember_me_service.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';
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

void main() {
  group('SplashScreen Remember Me Logic Tests', () {
    late MockLocalStorage mockStorage;
    late UserRepoImpl userRepoImpl;
    late RememberMeService rememberMeService;
    late ProviderContainer container;

    setUp(() {
      mockStorage = MockLocalStorage();
      userRepoImpl = UserRepoImpl(mockStorage);
      rememberMeService = RememberMeService(userRepoImpl);
      
      // Setup ProviderContainer for testing
      container = ProviderContainer(
        overrides: [
          localDB.overrideWithValue(mockStorage),
          userRepositoryProvider.overrideWithValue(userRepoImpl),
          rememberMeServiceProvider.overrideWithValue(rememberMeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Remember Me Validation Logic', () {
      test('should validate remember me data correctly for navigation', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          signedInEntityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        userRepoImpl.saveToken('valid_access_token');
        userRepoImpl.saveRefreshToken('valid_refresh_token');

        // Act
        final shouldNavigateToHome = rememberMeService.shouldUseRememberMe();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(shouldNavigateToHome, equals(true));
        expect(validatedUser, isNotNull);
        expect(validatedUser!.id, equals('123'));
        expect(validatedUser.email, equals('test@example.com'));
      });

      test('should reject invalid remember me data for navigation', () async {
        // Arrange
        userRepoImpl.saveRememberMe(false); // Remember me disabled

        // Act
        final shouldNavigateToHome = rememberMeService.shouldUseRememberMe();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(shouldNavigateToHome, equals(false));
        expect(validatedUser, isNull);
      });

      test('should clear remember me data when validation fails', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        // No user data or tokens saved (invalid state)

        // Act
        final shouldNavigateToHome = rememberMeService.shouldUseRememberMe();
        
        // Simulate the splash screen logic
        if (!shouldNavigateToHome && userRepoImpl.getRememberMe() == true) {
          await rememberMeService.clearRememberMeData();
        }

        // Assert
        expect(userRepoImpl.getRememberMe(), equals(false));
        expect(rememberMeService.shouldUseRememberMe(), equals(false));
      });
    });

    group('User Data Validation Integration', () {
      test('should validate complete user data correctly', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final completeUser = User(
          id: '456',
          email: 'complete@example.com',
          firstName: 'Alice',
          lastName: 'Johnson',
          phoneNumber: '+1234567890',
          signedInEntityType: EntityType.client,
          isActive: true,
          isVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await userRepoImpl.saveUser(completeUser);
        userRepoImpl.saveToken('complete_access_token');
        userRepoImpl.saveRefreshToken('complete_refresh_token');

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(true));
        expect(validatedUser, isNotNull);
        expect(validatedUser!.id, equals('456'));
        expect(validatedUser.email, equals('complete@example.com'));
        expect(validatedUser.firstName, equals('Alice'));
        expect(validatedUser.entityType, equals(EntityType.client));
      });

      test('should reject incomplete user data', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final incompleteUser = User(
          id: '789',
          // Missing email
          signedInEntityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(incompleteUser);
        userRepoImpl.saveToken('incomplete_access_token');
        userRepoImpl.saveRefreshToken('incomplete_refresh_token');

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });

      test('should reject user with missing tokens', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final validUser = User(
          id: '101',
          email: 'valid@example.com',
          signedInEntityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(validUser);
        // No tokens saved

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });

      test('should reject inactive user', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final inactiveUser = User(
          id: '202',
          email: 'inactive@example.com',
          signedInEntityType: EntityType.client,
          isActive: false, // Inactive user
        );
        await userRepoImpl.saveUser(inactiveUser);
        userRepoImpl.saveToken('inactive_access_token');
        userRepoImpl.saveRefreshToken('inactive_refresh_token');

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });
    });

    group('Remember Me Service Integration', () {
      test('should handle remember me service lifecycle correctly', () async {
        // Test 1: Enable remember me with valid data
        userRepoImpl.saveRememberMe(true);
        final user = User(
          id: '303',
          email: 'lifecycle@example.com',
          signedInEntityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(user);
        userRepoImpl.saveToken('lifecycle_access_token');
        userRepoImpl.saveRefreshToken('lifecycle_refresh_token');

        expect(rememberMeService.shouldUseRememberMe(), equals(true));
        expect(rememberMeService.getValidatedUser(), isNotNull);

        // Test 2: Clear remember me data
        await rememberMeService.clearRememberMeData();
        
        expect(rememberMeService.shouldUseRememberMe(), equals(false));
        expect(rememberMeService.getValidatedUser(), isNull);
        expect(userRepoImpl.getRememberMe(), equals(false));
        expect(userRepoImpl.getUser().id, isNull);
        expect(userRepoImpl.getToken(), equals(''));
      });

      test('should handle partner entity type correctly', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final partnerUser = User(
          id: '404',
          email: 'partner@example.com',
          firstName: 'Partner',
          lastName: 'User',
          signedInEntityType: EntityType.partner,
          isActive: true,
        );
        await userRepoImpl.saveUser(partnerUser);
        userRepoImpl.saveToken('partner_access_token');
        userRepoImpl.saveRefreshToken('partner_refresh_token');

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(true));
        expect(validatedUser, isNotNull);
        expect(validatedUser!.entityType, equals(EntityType.partner));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty storage gracefully', () {
        // Arrange - No data in storage

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });

      test('should handle corrupted user data gracefully', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        // Save corrupted user data (empty JSON)
        await userRepoImpl.saveUser(User());
        userRepoImpl.saveToken('corrupted_access_token');
        userRepoImpl.saveRefreshToken('corrupted_refresh_token');

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });

      test('should handle token expiration gracefully', () async {
        // Arrange
        userRepoImpl.saveRememberMe(true);
        final user = User(
          id: '505',
          email: 'expired@example.com',
          signedInEntityType: EntityType.client,
          isActive: true,
        );
        await userRepoImpl.saveUser(user);
        userRepoImpl.saveToken(''); // Empty token (expired)
        userRepoImpl.saveRefreshToken(''); // Empty refresh token

        // Act
        final isValid = rememberMeService.validateRememberMeData();
        final validatedUser = rememberMeService.getValidatedUser();

        // Assert
        expect(isValid, equals(false));
        expect(validatedUser, isNull);
      });
    });
  });
}
