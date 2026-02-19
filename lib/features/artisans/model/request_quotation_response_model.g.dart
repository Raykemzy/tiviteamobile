// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_quotation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestQuotationResponseModel _$RequestQuotationResponseModelFromJson(
        Map<String, dynamic> json) =>
    RequestQuotationResponseModel(
      id: json['id'] as String?,
      currentCounterPrice: json['current_counter_price'] as num?,
      currentCounterEndDate: json['current_counter_end_date'] == null
          ? null
          : DateTime.parse(json['current_counter_end_date'] as String),
      artisan: json['artisan'] == null
          ? null
          : ArtisanResponseModel.fromJson(
              json['artisan'] as Map<String, dynamic>),
      client: json['client'] == null
          ? null
          : QuotationClientModel.fromJson(
              json['client'] as Map<String, dynamic>),
      bookingId: json['booking_id'] as String?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
      isDeleted: json['is_deleted'] as bool?,
      deletedAt: json['deleted_at'],
      clientNote: json['client_note'] as String?,
      clientEndDate: json['client_end_date'] == null
          ? null
          : DateTime.parse(json['client_end_date'] as String),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      artisanPrice: json['artisan_price'] as num?,
      artisanNote: json['artisan_note'] as String?,
      status: json['status'] as String?,
      artisanEndDate: json['artisan_end_date'] == null
          ? null
          : DateTime.parse(json['artisan_end_date'] as String),
    );

Map<String, dynamic> _$RequestQuotationResponseModelToJson(
        RequestQuotationResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'current_counter_price': instance.currentCounterPrice,
      'current_counter_end_date':
          instance.currentCounterEndDate?.toIso8601String(),
      'artisan': instance.artisan?.toJson(),
      'client': instance.client?.toJson(),
      'booking_id': instance.bookingId,
      'date_created': instance.dateCreated?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'meta': instance.meta,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'client_note': instance.clientNote,
      'client_end_date': instance.clientEndDate?.toIso8601String(),
      'images': instance.images,
      'artisan_price': instance.artisanPrice,
      'artisan_note': instance.artisanNote,
      'status': instance.status,
      'artisan_end_date': instance.artisanEndDate?.toIso8601String(),
    };

QuotationClientModel _$QuotationClientModelFromJson(
        Map<String, dynamic> json) =>
    QuotationClientModel(
      id: json['id'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
      isDeleted: json['is_deleted'] as bool?,
      deletedAt: json['deleted_at'],
      authProvider: json['auth_provider'] as String?,
      authId: json['auth_id'] as String?,
      kycIsVerified: json['kyc_is_verified'] as bool?,
      favoriteListings: json['favorite_listings'] as List<dynamic>?,
    );

Map<String, dynamic> _$QuotationClientModelToJson(
        QuotationClientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user?.toJson(),
      'date_created': instance.dateCreated?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'meta': instance.meta,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'auth_provider': instance.authProvider,
      'auth_id': instance.authId,
      'kyc_is_verified': instance.kycIsVerified,
      'favorite_listings': instance.favoriteListings,
    };
