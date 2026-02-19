// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_marketplace_item_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMarketplaceItemRequestBody _$CreateMarketplaceItemRequestBodyFromJson(
        Map<String, dynamic> json) =>
    CreateMarketplaceItemRequestBody(
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as num,
      inStock: json['in_stock'] as bool,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      pickUpAddress: json['pick_up_address'] as String,
      condition: json['condition'] as String,
    );

Map<String, dynamic> _$CreateMarketplaceItemRequestBodyToJson(
        CreateMarketplaceItemRequestBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'in_stock': instance.inStock,
      'images': instance.images,
      'category': instance.category,
      'quantity': instance.quantity,
      'pick_up_address': instance.pickUpAddress,
      'condition': instance.condition,
    };
