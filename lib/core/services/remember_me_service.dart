import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/repositories/user/user_repo.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

/// Service to handle remember me functionality and validation
class RememberMeService {
  RememberMeService(this._userRepo);

  final UserRepository _userRepo;

  /// Validates if the stored user data is complete and valid for remember me
  bool validateRememberMeData() {
    // Check if remember me is enabled
    final isRememberMeEnabled = _userRepo.getRememberMe() ?? false;
    if (!isRememberMeEnabled) {
      return false;
    }

    // Check if user data exists and is valid
    final user = _userRepo.getUser();
    if (!_isValidUser(user)) {
      return false;
    }

    final token = _userRepo.getToken();
    final refreshToken = _userRepo.getRefreshToken();
    if (token.isEmpty || refreshToken.isEmpty) {
      return false;
    }

    // Allow persisted login when at least one token is still usable.
    if (!_isTokenUsable(token) && !_isTokenUsable(refreshToken)) {
      return false;
    }

    return true;
  }

  /// Checks if user data is valid and complete
  bool _isValidUser(User user) {
    // Check essential user fields
    if (user.id == null || user.id!.isEmpty) {
      return false;
    }

    if (user.email == null || user.email!.isEmpty) {
      return false;
    }

    if (user.entityType == null) {
      return false;
    }

    // Check if user is active (null is considered active for remember me)
    if (user.isActive == false) {
      return false;
    }

    return true;
  }

  /// Clears remember me data when validation fails
  Future<void> clearRememberMeData() async {
    await _userRepo.clearUserSession();
    _userRepo.saveRememberMe(false);
  }

  /// Gets the validated user data for remember me
  User? getValidatedUser() {
    if (validateRememberMeData()) {
      return _userRepo.getUser();
    }
    return null;
  }

  /// Checks if remember me should be used and data is valid
  bool shouldUseRememberMe() {
    return validateRememberMeData();
  }

  bool _isTokenUsable(String token) {
    if (token.trim().isEmpty) {
      return false;
    }

    final expiry = _getTokenExpiry(token);
    if (expiry == null) {
      return true;
    }

    return expiry.isAfter(DateTime.now().toUtc());
  }

  DateTime? _getTokenExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      final exp = json['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          exp * 1000,
          isUtc: true,
        );
      }
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          exp.toInt() * 1000,
          isUtc: true,
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

/// Provider for RememberMeService
final rememberMeServiceProvider = Provider<RememberMeService>((ref) {
  final userRepo = ref.read(userRepositoryProvider);
  return RememberMeService(userRepo);
});
