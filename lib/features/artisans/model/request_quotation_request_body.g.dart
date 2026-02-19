// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_quotation_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestQuotationRequestBody _$RequestQuotationRequestBodyFromJson(
        Map<String, dynamic> json) =>
    RequestQuotationRequestBody(
      clientNote: json['client_note'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      clientEndDate: json['client_end_date'] as String,
    );

Map<String, dynamic> _$RequestQuotationRequestBodyToJson(
        RequestQuotationRequestBody instance) =>
    <String, dynamic>{
      'client_note': instance.clientNote,
      'images': instance.images,
      'client_end_date': instance.clientEndDate,
    };
