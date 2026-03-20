import 'package:tivi_tea/core/utils/enums.dart';

class ProfileNotifierState {
  ProfileNotifierState({
    required this.profileLoadState,
    required this.editProfileLoadState,
    required this.profilePicLoadState,
    required this.switchAccountLoadState,
  });
  factory ProfileNotifierState.initial() {
    return ProfileNotifierState(
      profileLoadState: LoadState.idle,
      editProfileLoadState: LoadState.idle,
      profilePicLoadState: LoadState.idle,
      switchAccountLoadState: LoadState.idle,
    );
  }
  final LoadState profileLoadState;
  final LoadState editProfileLoadState;
  final LoadState profilePicLoadState;
  final LoadState switchAccountLoadState;

  ProfileNotifierState copyWith({
    LoadState? profileLoadState,
    LoadState? editProfileLoadState,
    LoadState? profilePicLoadState,
    LoadState? switchAccountLoadState,
  }) {
    return ProfileNotifierState(
      profileLoadState: profileLoadState ?? this.profileLoadState,
      profilePicLoadState: profilePicLoadState ?? this.profilePicLoadState,
      editProfileLoadState: editProfileLoadState ?? this.editProfileLoadState,
      switchAccountLoadState:
          switchAccountLoadState ?? this.switchAccountLoadState,
    );
  }
}
