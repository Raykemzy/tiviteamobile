// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_marketplace_payment_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMarketplacePaymentRequestBody
    _$CreateMarketplacePaymentRequestBodyFromJson(Map<String, dynamic> json) =>
        CreateMarketplacePaymentRequestBody(
          saveCard: json['save_card'] as bool? ?? true,
        );

Map<String, dynamic> _$CreateMarketplacePaymentRequestBodyToJson(
        CreateMarketplacePaymentRequestBody instance) =>
    <String, dynamic>{
      'save_card': instance.saveCard,
    };
