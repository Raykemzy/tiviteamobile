// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_sign_up_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtisanSignUpRequestBody _$ArtisanSignUpRequestBodyFromJson(
        Map<String, dynamic> json) =>
    ArtisanSignUpRequestBody(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      password: json['password'] as String?,
      confirmPassword: json['confirm_password'] as String?,
      serviceType: json['service_type'] as String?,
      summary: json['summary'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArtisanSignUpRequestBodyToJson(
        ArtisanSignUpRequestBody instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
      'service_type': instance.serviceType,
      'summary': instance.summary,
      'address': instance.address,
    };
