import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/marketplace/model/create_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/edit_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_add_remove_cart_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_item_model.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_create_order_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_order_create_response.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';

final class MarketplaceRepo {
  final RestClient restClient;

  MarketplaceRepo({required this.restClient});

  Future<BaseResponse<GenericPaginatedResponse<ListingResponseModel>>>
      getMarketPlaceItems({required int page}) async {
    try {
      return await restClient.getMarketPlaceItems(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<GenericPaginatedResponse<OwnerMarketplaceItemModel>>>
      getOwnersMarketPlaceItems({required int page}) async {
    try {
      return await restClient.getOwnersMarketPlaceItems(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> createMarketplaceItem(
    CreateMarketplaceItemRequestBody data,
  ) async {
    try {
      return await restClient.createMarketplaceItem(data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> editMarketplaceItem(
    String itemId,
    EditMarketplaceItemRequestBody data,
  ) async {
    try {
      return await restClient.editMarketplaceItem(itemId, data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> publishMarketplaceItem(String itemId) async {
    try {
      return await restClient.publishMarketplaceItem(
        itemId,
        const {'action': 'publish'},
      );
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> deleteMarketplaceItem(String itemId) async {
    try {
      await restClient.deleteMarketplaceItem(itemId);
      return BaseResponse(status: 'success');
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<ListingResponseModel>> getMarketPlaceItem(
    String itemId,
  ) async {
    try {
      return await restClient.getMarketPlaceItem(itemId);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> addOrRemoveMarketPlaceCartItem({
    required String itemId,
    required String action,
    required int quantity,
  }) async {
    try {
      return await restClient.addOrRemoveMarketPlaceCartItem(
        itemId,
        MarketplaceAddRemoveCartRequestBody(
          action: action,
          quantity: quantity,
        ),
      );
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<
      BaseResponse<
          GenericPaginatedResponse<MarketplaceCartItemModel>>> getMarketPlaceCartItems() async {
    try {
      return await restClient.getMarketPlaceCartItems();
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<MarketplaceOrderCreateResponse>> createMarketPlaceOrder(
    MarketplaceCreateOrderRequestBody body,
  ) async {
    try {
      return await restClient.createMarketPlaceOrder(body);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> cancelMarketPlaceOrderItem(
    String orderId,
  ) async {
    try {
      return await restClient.cancelMarketPlaceOrderItem(orderId);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
