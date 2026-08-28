import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/payment/model/payout_models.dart';
import 'package:tivi_tea/features/payment/model/wallet_details_model.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';

final class WalletRepo {
  final RestClient restClient;

  WalletRepo({
    required this.restClient,
  });

  Future<BaseResponse<WalletDetailsModel>> getWalletDetails() async {
    try {
      return await restClient.getWalletDetails();
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse> createTransactionPin(UpdatePinModel data) async {
    try {
      return await restClient.createTransactionPin(data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse> withdrawFromWallet(WithdrawFromWalletModel data) async {
    try {
      return await restClient.withdrawFromWallet(data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<WalletTransactionModel>>>
      getWalletTransactions(int page) async {
    try {
      return await restClient.getWalletTransactions(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<TransferModel>>> getTransfers(
    int page,
  ) async {
    try {
      return await restClient.getTransfers(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<TransferModel>> getTransfer(String transferId) async {
    try {
      return await restClient.getTransfer(transferId);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<PaymentInstrumentModel>>>
      getPaymentInstruments(int page) async {
    try {
      return await restClient.getPaymentInstruments(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}