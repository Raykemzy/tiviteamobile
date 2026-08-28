// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_request_bodies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SendQuotationRequestBodyToJson(
        SendQuotationRequestBody instance) =>
    <String, dynamic>{
      'artisan_note': instance.artisanNote,
      'artisan_price': instance.artisanPrice,
      'artisan_end_date': instance.artisanEndDate,
    };

Map<String, dynamic> _$CounterQuotationRequestBodyToJson(
        CounterQuotationRequestBody instance) =>
    <String, dynamic>{
      if (instance.clientNote case final value?) 'client_note': value,
      if (instance.clientCounterPrice case final value?)
        'client_counter_price': value,
      if (instance.clientCounterEndDate case final value?)
        'client_counter_end_date': value,
      if (instance.artisanNote case final value?) 'artisan_note': value,
      if (instance.artisanCounterPrice case final value?)
        'artisan_counter_price': value,
      if (instance.artisanCounterEndDate case final value?)
        'artisan_counter_end_date': value,
    };
