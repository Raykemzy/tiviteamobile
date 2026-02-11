import 'package:tivi_tea/core/utils/enums.dart';

class ArtisanKYCState {
  ArtisanKYCState({
    required this.kycLoadState,
  });

  factory ArtisanKYCState.initial() {
    return ArtisanKYCState(
      kycLoadState: LoadState.idle,
    );
  }

  final LoadState kycLoadState;

  ArtisanKYCState copyWith({
    LoadState? kycLoadState,
  }) {
    return ArtisanKYCState(
      kycLoadState: kycLoadState ?? this.kycLoadState,
    );
  }
}
