import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage_impl.dart';

import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/login/model/general/login_request_object.dart';
import 'package:tivi_tea/features/login/model/general/multi_entity_login_prompt.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/profile/model/change_password_model.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/registration/model/client/social_auth_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/repositories/authentication/general/general_authetication_repo.dart';
import 'package:tivi_tea/repositories/authentication/general/third_party_auth.dart';
import 'package:tivi_tea/repositories/user/user_repo.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

part 'login_notifier.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final GeneralAuthenticationRepo _repo;
  late final UserRepository _userRepo;
  late final ThirdPartyAuthRepo _thirdPartyAuthRepo;
  @override
  LoginState build() {
    _userRepo = ref.read(userRepositoryProvider);
    _repo = GeneralAuthenticationRepo(
      restClient: ref.read(restClient),
      userRepository: _userRepo,
    );
    _thirdPartyAuthRepo = ThirdPartyAuthRepo(
      googleSignIn: GoogleSignIn(),
      localStorage: ref.read(localDB),
    );
    return LoginState.initial();
  }

  void login(
    LoginRequestObject data, {
    bool rememberMe = false,

    ///Pass [EntityType] to determine what dashboard would be loaded
    void Function(User?)? onSuccess,
    void Function(String)? onError,

    /// Called when the account owns several entities and the backend needs to
    /// be told which one to sign in as. Retry [login] with
    /// `data.withEntityType(choice)`.
    void Function(List<EntityType> options)? onEntityRequired,
  }) async {
    state = state.copyWith(loadState: LoadState.loading);
    try {
      final response = await _repo.login(
        data,
        saveUserState: (user) async {
          await _userRepo.saveRememberMe(rememberMe);
          final userStateNotifier = ref.read(userNotifierProvider.notifier);
          userStateNotifier.updateUser(user);
        },
      );
      if (!response.isSuccess()) {
        final message =
            response.error?.message ?? response.message ?? 'An error occurred';

        // Only prompt on the first attempt — if a retry that already named an
        // entity comes back the same way, surface it as a normal error rather
        // than asking again.
        final prompt = data.entityType == null && onEntityRequired != null
            ? MultiEntityLoginPrompt.tryParse(message)
            : null;
        if (prompt != null) {
          state = state.copyWith(loadState: LoadState.idle);
          onEntityRequired!(prompt.options);
          return;
        }
        throw message;
      }

      state = state.copyWith(loadState: LoadState.success);
      if (onSuccess != null) {
        final user = _userRepo.getUser();
        onSuccess(user);
      }
    } catch (e) {
      state = state.copyWith(loadState: LoadState.error);
      if (onError != null) onError(e.toString());
    }
  }

  void signUpWithSocialAuth(
    SocialAuthModel data, {
    ///Pass [EntityType] to determine what dashboard would be loaded
    void Function(User?)? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(loadState: LoadState.loading);
    try {
      final response =
          await _repo.signUpWithSocialAuth(data, saveUserState: (user) async {
        final userStateNotifier = ref.read(userNotifierProvider.notifier);
        userStateNotifier.updateUser(user);
      });
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }
      state = state.copyWith(loadState: LoadState.success);
      if (onSuccess != null) onSuccess(response.data?.user);
    } catch (e) {
      state = state.copyWith(loadState: LoadState.error);
      if (onError != null) onError(e.toString());
    }
  }

  void forgotPassword(
    ForgotPasswordRequestObject data, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(forgotPasswordLoadState: LoadState.loading);
    try {
      final response = await _repo.forgotPassword(data);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }
      state = state.copyWith(forgotPasswordLoadState: LoadState.success);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(forgotPasswordLoadState: LoadState.error);
      if (onError != null) onError(e.toString());
    }
  }

  void changePassword(
    ChangePasswordModel data, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(changePasswordLoadState: LoadState.loading);
    try {
      final response = await _repo.changePassword(data);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }
      state = state.copyWith(changePasswordLoadState: LoadState.success);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(changePasswordLoadState: LoadState.error);
      if (onError != null) onError(e.toString());
    }
  }

  void rememberUser(bool value) {
    _userRepo.saveRememberMe(value);
  }

  bool getRememberUserValue() {
    return _userRepo.getRememberMe() ?? false;
  }

  void logout({required VoidCallback onDataCleared}) {
    state = state.copyWith(logoutState: LoadState.loading);
    try {
      _repo.logout(onDataCleared: onDataCleared);
      // Session data is gone from storage; drop the in-memory copy as well so
      // no screen renders the signed-out user.
      ref.read(userNotifierProvider.notifier).refreshUser();
      state = state.copyWith(
        logoutState: LoadState.success,
        appAccessState: AppAccessState.guest,
      );
    } catch (e) {
      state = state.copyWith(logoutState: LoadState.error);
    }
  }

  void signInWithGoogle({
    void Function(User?)? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(signInWithGoogleLoadState: LoadState.loading);
    final response = await _thirdPartyAuthRepo.signIn();
    if (response.isSuccess()) {
      if (response.data != null) {
        signUpWithSocialAuth(
          response.data!,
          onSuccess: onSuccess,
          onError: onError,
        );
      }
      state = state.copyWith(signInWithGoogleLoadState: LoadState.success);
    } else {
      state = state.copyWith(signInWithGoogleLoadState: LoadState.error);
      if (onError != null) onError(response.message ?? 'An error occurred');
    }
  }

  void signInWithApple({
    void Function(User?)? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(signInWithAppleLoadState: LoadState.loading);
    final response = await _thirdPartyAuthRepo.signInWithApple();
    if (response.isSuccess()) {
      if (response.data != null) {
        signUpWithSocialAuth(
          response.data!,
          onSuccess: onSuccess,
          onError: onError,
        );
      }
      state = state.copyWith(signInWithAppleLoadState: LoadState.success);
    } else {
      state = state.copyWith(signInWithAppleLoadState: LoadState.error);
      if (onError != null) onError(response.message ?? 'An error occurred');
    }
  }

  void deleteAccount({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = state.copyWith(loadState: LoadState.loading);
    try {
      final response = await _repo.deleteAccount();
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }
      state = state.copyWith(loadState: LoadState.success);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(loadState: LoadState.error);
      if (onError != null) onError(e.toString());
    }
  }

  void setAppAccessState(AppAccessState appAccessState) {
    state = state.copyWith(appAccessState: appAccessState);
  }

  Future<void> continueAsGuest() async {
    await _userRepo.clearUserSession();
    await _userRepo.saveRememberMe(false);
    ref.read(userNotifierProvider.notifier).refreshUser();
    state = state.copyWith(appAccessState: AppAccessState.guest);
  }

  void updateLoginEntityType(EntityType? type) {
    state = state.copyWith(loginEntityType: type);
  }
}
