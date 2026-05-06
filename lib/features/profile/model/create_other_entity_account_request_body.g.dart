// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_other_entity_account_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOtherEntityAccountRequestBody
    _$CreateOtherEntityAccountRequestBodyFromJson(Map<String, dynamic> json) =>
        CreateOtherEntityAccountRequestBody(
          entityType: $enumDecode(_$EntityTypeEnumMap, json['entity_type']),
          serviceType: json['service_type'] as String,
          address: Address.fromJson(json['address'] as Map<String, dynamic>),
          summary: json['summary'] as String,
        );

Map<String, dynamic> _$CreateOtherEntityAccountRequestBodyToJson(
        CreateOtherEntityAccountRequestBody instance) =>
    <String, dynamic>{
      'entity_type': _$EntityTypeEnumMap[instance.entityType]!,
      'service_type': instance.serviceType,
      'address': instance.address,
      'summary': instance.summary,
    };

const _$EntityTypeEnumMap = {
  EntityType.partner: 'partner',
  EntityType.client: 'client',
  EntityType.artisan: 'artisan',
};
