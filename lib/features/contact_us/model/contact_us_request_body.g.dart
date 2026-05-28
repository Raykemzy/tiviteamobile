// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_us_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactUsRequestBody _$ContactUsRequestBodyFromJson(
        Map<String, dynamic> json) =>
    ContactUsRequestBody(
      name: json['name'] as String,
      email: json['email'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ContactUsRequestBodyToJson(
        ContactUsRequestBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'subject': instance.subject,
      'message': instance.message,
    };
