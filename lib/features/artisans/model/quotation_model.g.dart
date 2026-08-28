// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotationModel _$QuotationModelFromJson(Map<String, dynamic> json) =>
    QuotationModel(
      id: json['id'] as String?,
      status: json['status'] as String?,
      bookingId: json['booking_id'] as String?,
      currentCounterPrice: json['current_counter_price'] as num?,
      clientNote: json['client_note'] as String?,
      clientEndDate: json['client_end_date'] == null
          ? null
          : DateTime.parse(json['client_end_date'] as String),
      artisanNote: json['artisan_note'] as String?,
      artisanPrice: json['artisan_price'] as num?,
      artisanEndDate: json['artisan_end_date'] == null
          ? null
          : DateTime.parse(json['artisan_end_date'] as String),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      meta: json['meta'] as Map<String, dynamic>?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

Map<String, dynamic> _$QuotationModelToJson(QuotationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'booking_id': instance.bookingId,
      'current_counter_price': instance.currentCounterPrice,
      'client_note': instance.clientNote,
      'client_end_date': instance.clientEndDate?.toIso8601String(),
      'artisan_note': instance.artisanNote,
      'artisan_price': instance.artisanPrice,
      'artisan_end_date': instance.artisanEndDate?.toIso8601String(),
      'images': instance.images,
      'meta': instance.meta,
      'date_created': instance.dateCreated?.toIso8601String(),
    };
