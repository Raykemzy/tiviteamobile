import 'package:json_annotation/json_annotation.dart';

part 'payout_models.g.dart';

/// A payout from the wallet to a bank account. `GET /payment/transfers`.
@JsonSerializable(createToJson: false)
class TransferModel {
  final String? id;
  final num? amount;
  final String? status;
  final String? description;
  final String? recipient;

  @JsonKey(name: 'date_identifier')
  final String? dateIdentifier;
  @JsonKey(name: 'start_period')
  final DateTime? startPeriod;
  @JsonKey(name: 'end_period')
  final DateTime? endPeriod;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  /// Carries `bookings`: the ids settled by this transfer.
  final Map<String, dynamic>? meta;

  TransferModel({
    this.id,
    this.amount,
    this.status,
    this.description,
    this.recipient,
    this.dateIdentifier,
    this.startPeriod,
    this.endPeriod,
    this.dateCreated,
    this.meta,
  });

  List<String> get bookingIds {
    final raw = meta?['bookings'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);
}

/// A single credit or debit against the wallet.
/// `GET /payment/wallet-transactions`.
@JsonSerializable(createToJson: false)
class WalletTransactionModel {
  final String? id;

  /// "Credit" or "Debit".
  final String? type;
  final num? amount;
  final String? currency;

  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  WalletTransactionModel({
    this.id,
    this.type,
    this.amount,
    this.currency,
    this.dateCreated,
  });

  bool get isCredit => type?.toLowerCase() == 'credit';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);
}

/// A saved payout destination. `GET /payment/instruments`.
///
/// Modelled leniently: the endpoint returns an empty list on every account
/// available for testing, so the field set is inferred from the transfer
/// recipient it mirrors rather than observed. Unknown keys are ignored by
/// json_serializable, so extra fields are harmless.
@JsonSerializable(createToJson: false)
class PaymentInstrumentModel {
  final String? id;
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_code')
  final String? bankCode;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  PaymentInstrumentModel({
    this.id,
    this.accountNumber,
    this.accountName,
    this.bankName,
    this.bankCode,
    this.dateCreated,
  });

  factory PaymentInstrumentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentInstrumentModelFromJson(json);
}
