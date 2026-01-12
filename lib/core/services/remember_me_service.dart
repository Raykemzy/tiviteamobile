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

    // Check if tokens exist
    final token = _userRepo.getToken();
    final refreshToken = _userRepo.getRefreshToken();
    if (token.isEmpty || refreshToken.isEmpty) {
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
}

/// Provider for RememberMeService
final rememberMeServiceProvider = Provider<RememberMeService>((ref) {
  final userRepo = ref.read(userRepositoryProvider);
  return RememberMeService(userRepo);
});
