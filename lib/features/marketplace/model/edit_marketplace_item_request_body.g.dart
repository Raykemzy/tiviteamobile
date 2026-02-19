// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_marketplace_item_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditMarketplaceItemRequestBody _$EditMarketplaceItemRequestBodyFromJson(
        Map<String, dynamic> json) =>
    EditMarketplaceItemRequestBody(
      price: json['price'] as num,
      inStock: json['in_stock'] as bool,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$EditMarketplaceItemRequestBodyToJson(
        EditMarketplaceItemRequestBody instance) =>
    <String, dynamic>{
      'price': instance.price,
      'in_stock': instance.inStock,
      'quantity': instance.quantity,
    };
