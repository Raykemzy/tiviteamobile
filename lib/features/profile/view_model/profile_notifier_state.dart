import 'package:tivi_tea/core/utils/enums.dart';

class ProfileNotifierState {
  ProfileNotifierState({
    required this.profileLoadState,
    required this.editProfileLoadState,
    required this.switchAccountLoadState,
    required this.createOtherEntityAccountLoadState,
  });
  factory ProfileNotifierState.initial() {
    return ProfileNotifierState(
      profileLoadState: LoadState.idle,
      editProfileLoadState: LoadState.idle,
      switchAccountLoadState: LoadState.idle,
      createOtherEntityAccountLoadState: LoadState.idle,
    );
  }
  final LoadState profileLoadState;
  final LoadState editProfileLoadState;
  final LoadState switchAccountLoadState;
  final LoadState createOtherEntityAccountLoadState;

  ProfileNotifierState copyWith({
    LoadState? profileLoadState,
    LoadState? editProfileLoadState,
    LoadState? switchAccountLoadState,
    LoadState? createOtherEntityAccountLoadState,
  }) {
    return ProfileNotifierState(
      profileLoadState: profileLoadState ?? this.profileLoadState,
      editProfileLoadState: editProfileLoadState ?? this.editProfileLoadState,
      switchAccountLoadState:
          switchAccountLoadState ?? this.switchAccountLoadState,
      createOtherEntityAccountLoadState:
          createOtherEntityAccountLoadState ??
              this.createOtherEntityAccountLoadState,
    );
  }
}
