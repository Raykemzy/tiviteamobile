import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/profile/model/create_other_entity_account_request_body.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifier_state.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/repositories/dashboard/general_dashboard_repo.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

part 'profile_notifer.g.dart';

@riverpod
class ProfileNotifer extends _$ProfileNotifer {
  late GeneralDashboardRepo _repo;

  @override
  ProfileNotifierState build() {
    _repo = GeneralDashboardRepo(
      restClient: ref.read(restClient),
      userRepository: ref.read(userRepositoryProvider),
    );
    return ProfileNotifierState.initial();
  }

  void getUserProfile() async {
    state = state.copyWith(profileLoadState: LoadState.loading);
    try {
      final result = await _repo.getUserProfile();
      if (result.isSuccess() == false) throw result.message ?? '';
      _syncUserState();
      state = state.copyWith(profileLoadState: LoadState.success);
    } catch (e) {
      state = state.copyWith(profileLoadState: LoadState.error);
    }
  }

  void updateProfile(
    EditProfileModel data, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    state = state.copyWith(editProfileLoadState: LoadState.loading);
    try {
      final result = await _repo.updateUserProfile(_mergeWithCurrentUser(data));
      if (result.isSuccess() == false) throw result.message ?? '';
      // Refetch so the cache reflects anything the update endpoint didn't
      // echo back. Either way the repository has already persisted a merged
      // user, so syncing from the cache is correct even if this call fails.
      await _repo.getUserProfile();
      _syncUserState();
      state = state.copyWith(editProfileLoadState: LoadState.success);
      onSuccess();
    } catch (e) {
      state = state.copyWith(editProfileLoadState: LoadState.error);
      onError(e.toString());
    }
  }

  EditProfileModel _mergeWithCurrentUser(EditProfileModel data) {
    final user = ref.read(userRepositoryProvider).getUser();
    return EditProfileModel(
      phoneNumber: data.phoneNumber ?? user.phoneNumber ?? '',
      profilePicture: data.profilePicture ?? user.profilePicture ?? '',
      firstName: data.firstName ?? user.firstName ?? '',
      lastName: data.lastName ?? user.lastName ?? '',
      // Only sent when a gallery update is in progress; omitted otherwise so
      // ordinary profile edits never touch the artisan's gallery.
      artisanGalleryImages: data.artisanGalleryImages,
    );
  }

  /// Pulls the in-memory user back from storage.
  ///
  /// Always reads the cache rather than taking the raw response object: the
  /// repository merges each response over the cached user so fields the
  /// endpoint omits (address, owned entities, signed-in entity) survive.
  /// Pushing the raw response here instead would leave the notifier holding a
  /// less complete user than the one on disk.
  void _syncUserState() {
    ref.read(userNotifierProvider.notifier).refreshUser();
  }

  void switchAccount(
    EntityType targetEntityType, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    state = state.copyWith(switchAccountLoadState: LoadState.loading);
    try {
      final result = await _repo.switchAccount(targetEntityType);
      if (result.isSuccess() == false) {
        throw result.error?.message ??
            result.message ??
            'Unable to switch account';
      }

      final refreshedUser = await _repo.getUserProfile();
      if (!refreshedUser.isSuccess() || refreshedUser.data?.user == null) {
        // Profile refetch failed, so record the switch locally — otherwise the
        // app would keep rendering the entity the user just switched away from.
        final existingUser = ref.read(userRepositoryProvider).getUser();
        await ref.read(userRepositoryProvider).saveUser(
              existingUser.copyWith(signedInEntityType: targetEntityType),
            );
      }

      _syncUserState();
      state = state.copyWith(switchAccountLoadState: LoadState.success);
      onSuccess();
    } catch (e) {
      state = state.copyWith(switchAccountLoadState: LoadState.error);
      onError(e.toString());
    }
  }

  void createOtherEntityAccount(
    CreateOtherEntityAccountRequestBody data, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    state = state.copyWith(
      createOtherEntityAccountLoadState: LoadState.loading,
    );
    try {
      final result = await _repo.createOtherEntityAccount(data);
      if (result.isSuccess() == false) {
        throw result.error?.message ??
            result.message ??
            'Unable to create account';
      }

      await _repo.getUserProfile();
      ref.read(userNotifierProvider.notifier).refreshUser();
      state = state.copyWith(
        createOtherEntityAccountLoadState: LoadState.success,
      );
      onSuccess();
    } catch (e) {
      state = state.copyWith(
        createOtherEntityAccountLoadState: LoadState.error,
      );
      onError(e.toString());
    }
  }
}
