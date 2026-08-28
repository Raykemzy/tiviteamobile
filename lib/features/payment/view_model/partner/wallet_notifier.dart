import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/features/payment/model/wallet_details_model.dart';
import 'package:tivi_tea/features/payment/view_model/partner/wallet_state.dart';
import 'package:tivi_tea/repositories/wallet/wallet_repo.dart';

part 'wallet_notifier.g.dart';

@riverpod
class WalletNotifier extends _$WalletNotifier {
  late final WalletRepo walletRepo;

  @override
  WalletState build() {
    walletRepo = WalletRepo(
      restClient: ref.read(restClient),
    );

    return WalletState.initial();
  }

  void getWalletDetails({
    required void Function(String) onError,
  }) async {
    try {
          final response = await walletRepo.getWalletDetails();
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? '';
      }
      state = state.copyWith(
        getWalletDetailsState: LoadState.success,
        walletDetails: response.data,
      );
    } catch (e) {
      state = state.copyWith(getWalletDetailsState: LoadState.error);
      onError(e.toString());
    }
  }

  void createTransactionPin({
    required UpdatePinModel data,
    required void Function() onSuccess,
    required void Function(String) onError,
  }) async {
    state = state.copyWith(createTransactionPinState: LoadState.loading);
    try {
          final response = await walletRepo.createTransactionPin(data);
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? '';
      }
      getWalletDetails(onError: (e) => debugLog(e.toString()));

      onSuccess();
      state = state.copyWith(createTransactionPinState: LoadState.success);
    } catch (e) {
      state = state.copyWith(createTransactionPinState: LoadState.error);
      onError(e.toString());
    }
  }

  void withdrawFromWallet({
    required WithdrawFromWalletModel data,
    required void Function() onSuccess,
    required void Function(String) onError,
  }) async {
    state = state.copyWith(withdrawFromWalletState: LoadState.loading);
    try {
      final response = await walletRepo.withdrawFromWallet(data);
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? '';
      }
      getWalletDetails(onError: (e) => debugLog(e.toString()));
      
      onSuccess();
      state = state.copyWith(withdrawFromWalletState: LoadState.success);
    } catch (e) {
      state = state.copyWith(withdrawFromWalletState: LoadState.error);
      onError(e.toString());
    }
  }

  /// Wallet ledger. Loaded alongside the balance so the withdrawal screen can
  /// show where the money came from instead of a bare figure.
  Future<void> getWalletTransactions({int page = 1}) async {
    state = state.copyWith(transactionsState: LoadState.loading);
    try {
      final response = await walletRepo.getWalletTransactions(page);
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? '';
      }
      state = state.copyWith(
        transactionsState: LoadState.success,
        transactions: response.data?.results ?? const [],
      );
    } catch (e) {
      debugLog(e.toString());
      state = state.copyWith(transactionsState: LoadState.error);
    }
  }

  /// Payouts already sent to the bank.
  Future<void> getTransfers({int page = 1}) async {
    state = state.copyWith(transfersState: LoadState.loading);
    try {
      final response = await walletRepo.getTransfers(page);
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? '';
      }
      state = state.copyWith(
        transfersState: LoadState.success,
        transfers: response.data?.results ?? const [],
      );
    } catch (e) {
      debugLog(e.toString());
      state = state.copyWith(transfersState: LoadState.error);
    }
  }
}
