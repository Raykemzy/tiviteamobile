// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_add_remove_cart_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceAddRemoveCartRequestBody
    _$MarketplaceAddRemoveCartRequestBodyFromJson(Map<String, dynamic> json) =>
        MarketplaceAddRemoveCartRequestBody(
          action: json['action'] as String,
          quantity: (json['quantity'] as num).toInt(),
        );

Map<String, dynamic> _$MarketplaceAddRemoveCartRequestBodyToJson(
        MarketplaceAddRemoveCartRequestBody instance) =>
    <String, dynamic>{
      'action': instance.action,
      'quantity': instance.quantity,
    };
