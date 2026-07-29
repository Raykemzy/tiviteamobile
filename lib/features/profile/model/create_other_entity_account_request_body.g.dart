// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_other_entity_account_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOtherEntityAccountRequestBody
    _$CreateOtherEntityAccountRequestBodyFromJson(Map<String, dynamic> json) =>
        CreateOtherEntityAccountRequestBody(
          entityType: $enumDecode(_$EntityTypeEnumMap, json['entity_type']),
          address: Address.fromJson(json['address'] as Map<String, dynamic>),
          serviceType: json['service_type'] as String?,
          summary: json['summary'] as String?,
          companyName: json['company_name'] as String?,
          businessType: json['business_type'] as String?,
          businessDescription: json['business_description'] as String?,
          website: json['website'] as String?,
          alternatePhoneNumber: json['alternate_phone_number'] as String?,
        );

Map<String, dynamic> _$CreateOtherEntityAccountRequestBodyToJson(
        CreateOtherEntityAccountRequestBody instance) =>
    <String, dynamic>{
      'entity_type': _$EntityTypeEnumMap[instance.entityType]!,
      'address': instance.address,
      if (instance.serviceType case final value?) 'service_type': value,
      if (instance.summary case final value?) 'summary': value,
      if (instance.companyName case final value?) 'company_name': value,
      if (instance.businessType case final value?) 'business_type': value,
      if (instance.businessDescription case final value?)
        'business_description': value,
      if (instance.website case final value?) 'website': value,
      if (instance.alternatePhoneNumber case final value?)
        'alternate_phone_number': value,
    };

const _$EntityTypeEnumMap = {
  EntityType.partner: 'partner',
  EntityType.client: 'client',
  EntityType.artisan: 'artisan',
};
