// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestObject _$LoginRequestObjectFromJson(Map<String, dynamic> json) =>
    LoginRequestObject(
      email: json['email'] as String?,
      password: json['password'] as String?,
      entityType: $enumDecodeNullable(_$EntityTypeEnumMap, json['entity_type']),
    );

Map<String, dynamic> _$LoginRequestObjectToJson(LoginRequestObject instance) =>
    <String, dynamic>{
      if (instance.email case final value?) 'email': value,
      if (instance.password case final value?) 'password': value,
      if (_$EntityTypeEnumMap[instance.entityType] case final value?)
        'entity_type': value,
    };

const _$EntityTypeEnumMap = {
  EntityType.partner: 'partner',
  EntityType.client: 'client',
  EntityType.artisan: 'artisan',
};

ForgotPasswordRequestObject _$ForgotPasswordRequestObjectFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequestObject(
      email: json['email'] as String?,
    );

Map<String, dynamic> _$ForgotPasswordRequestObjectToJson(
        ForgotPasswordRequestObject instance) =>
    <String, dynamic>{
      'email': instance.email,
    };
