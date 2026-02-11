import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/kyc/model/client_kyc_request_body.dart';
import 'package:tivi_tea/features/kyc/view_model/artisan/artisan_kyc_state.dart';
import 'package:tivi_tea/repositories/authentication/general/general_authetication_repo.dart';

part 'artisan_kyc_notifier.g.dart';

@riverpod
class ArtisanKycNotifier extends _$ArtisanKycNotifier {
  late final GeneralAuthenticationRepo _repo;

  @override
  ArtisanKYCState build() {
    _repo = GeneralAuthenticationRepo(restClient: ref.read(restClient));
    return ArtisanKYCState.initial();
  }

  void submitArtisanKYC(
    ClientKYCRequestBody data, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    state = state.copyWith(kycLoadState: LoadState.loading);
    try {
      final response = await _repo.submitArtisanKyc(data);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? '';
      }
      onSuccess();
      state = state.copyWith(kycLoadState: LoadState.success);
    } catch (e) {
      state = state.copyWith(kycLoadState: LoadState.error);
      onError(e.toString());
    }
  }
}
