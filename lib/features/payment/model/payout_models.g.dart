// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferModel _$TransferModelFromJson(Map<String, dynamic> json) =>
    TransferModel(
      id: json['id'] as String?,
      amount: json['amount'] as num?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      recipient: json['recipient'] as String?,
      dateIdentifier: json['date_identifier'] as String?,
      startPeriod: json['start_period'] == null
          ? null
          : DateTime.parse(json['start_period'] as String),
      endPeriod: json['end_period'] == null
          ? null
          : DateTime.parse(json['end_period'] as String),
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
    );

WalletTransactionModel _$WalletTransactionModelFromJson(
        Map<String, dynamic> json) =>
    WalletTransactionModel(
      id: json['id'] as String?,
      type: json['type'] as String?,
      amount: json['amount'] as num?,
      currency: json['currency'] as String?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

PaymentInstrumentModel _$PaymentInstrumentModelFromJson(
        Map<String, dynamic> json) =>
    PaymentInstrumentModel(
      id: json['id'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      bankName: json['bank_name'] as String?,
      bankCode: json['bank_code'] as String?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );
