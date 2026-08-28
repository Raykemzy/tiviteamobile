import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/payment/model/payout_models.dart';
import 'package:tivi_tea/features/payment/model/wallet_details_model.dart';

class WalletState {
  final LoadState getWalletDetailsState;
  final WalletDetailsModel? walletDetails;
  final LoadState createTransactionPinState;
  final LoadState withdrawFromWalletState;

  /// Wallet ledger — every credit and debit.
  final LoadState transactionsState;
  final List<WalletTransactionModel> transactions;

  /// Payouts to the bank.
  final LoadState transfersState;
  final List<TransferModel> transfers;

  WalletState({
    this.walletDetails,
    required this.getWalletDetailsState,
    required this.createTransactionPinState,
    required this.withdrawFromWalletState,
    this.transactionsState = LoadState.idle,
    this.transactions = const [],
    this.transfersState = LoadState.idle,
    this.transfers = const [],
  });

  factory WalletState.initial() {
    return WalletState(
      getWalletDetailsState: LoadState.loading,
      createTransactionPinState: LoadState.idle,
      withdrawFromWalletState: LoadState.idle,
    );
  }

  WalletState copyWith({
    LoadState? getWalletDetailsState,
    WalletDetailsModel? walletDetails,
    LoadState? createTransactionPinState,
    LoadState? withdrawFromWalletState,
    LoadState? transactionsState,
    List<WalletTransactionModel>? transactions,
    LoadState? transfersState,
    List<TransferModel>? transfers,
  }) {
    return WalletState(
      getWalletDetailsState: getWalletDetailsState ?? this.getWalletDetailsState,
      walletDetails: walletDetails ?? this.walletDetails,
      createTransactionPinState: createTransactionPinState ?? this.createTransactionPinState,
      withdrawFromWalletState:
          withdrawFromWalletState ?? this.withdrawFromWalletState,
      transactionsState: transactionsState ?? this.transactionsState,
      transactions: transactions ?? this.transactions,
      transfersState: transfersState ?? this.transfersState,
      transfers: transfers ?? this.transfers,
    );
  }
}