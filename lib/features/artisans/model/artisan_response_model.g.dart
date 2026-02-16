// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtisanResponseModel _$ArtisanResponseModelFromJson(
        Map<String, dynamic> json) =>
    ArtisanResponseModel(
      id: json['id'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      serviceTypeSummary: json['service_type_summary'] as String?,
      hasUploadedKycDocuments: json['has_uploaded_kyc_documents'] as bool?,
      rating: json['rating'] as num?,
      reviewsCount: (json['reviews_count'] as num?)?.toInt(),
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      meta: json['meta'] as Map<String, dynamic>?,
      isDeleted: json['is_deleted'] as bool?,
      deletedAt: json['deleted_at'],
      serviceType: json['service_type'] as String?,
      galleryImages: (json['gallery_images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      kycIsVerified: json['kyc_is_verified'] as bool?,
    );

Map<String, dynamic> _$ArtisanResponseModelToJson(
        ArtisanResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user?.toJson(),
      'address': instance.address?.toJson(),
      'service_type_summary': instance.serviceTypeSummary,
      'has_uploaded_kyc_documents': instance.hasUploadedKycDocuments,
      'rating': instance.rating,
      'reviews_count': instance.reviewsCount,
      'date_created': instance.dateCreated?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'meta': instance.meta,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'service_type': instance.serviceType,
      'gallery_images': instance.galleryImages,
      'kyc_is_verified': instance.kycIsVerified,
    };
