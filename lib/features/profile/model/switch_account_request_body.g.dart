// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_account_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchAccountRequestBody _$SwitchAccountRequestBodyFromJson(
        Map<String, dynamic> json) =>
    SwitchAccountRequestBody(
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entity_type']),
    );

Map<String, dynamic> _$SwitchAccountRequestBodyToJson(
        SwitchAccountRequestBody instance) =>
    <String, dynamic>{
      'entity_type': _$EntityTypeEnumMap[instance.entityType]!,
    };

const _$EntityTypeEnumMap = {
  EntityType.partner: 'partner',
  EntityType.client: 'client',
  EntityType.artisan: 'artisan',
};
