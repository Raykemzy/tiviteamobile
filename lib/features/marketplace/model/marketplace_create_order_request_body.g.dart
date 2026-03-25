// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_create_order_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceCreateOrderRequestBody _$MarketplaceCreateOrderRequestBodyFromJson(
        Map<String, dynamic> json) =>
    MarketplaceCreateOrderRequestBody(
      cartItemIds: (json['cart_item_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pickUp: json['pick_up'] as bool,
      deliveryAddress: json['delivery_address'] as String,
    );

Map<String, dynamic> _$MarketplaceCreateOrderRequestBodyToJson(
        MarketplaceCreateOrderRequestBody instance) =>
    <String, dynamic>{
      'cart_item_ids': instance.cartItemIds,
      'pick_up': instance.pickUp,
      'delivery_address': instance.deliveryAddress,
    };
