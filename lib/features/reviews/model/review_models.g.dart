// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingReviewModel _$BookingReviewModelFromJson(Map<String, dynamic> json) =>
    BookingReviewModel(
      id: json['id'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      note: json['note'] as String?,
      status: json['status'] as String?,
      listing: json['listing'] == null
          ? null
          : ListingResponseModel.fromJson(
              json['listing'] as Map<String, dynamic>),
      client: json['client'] == null
          ? null
          : ReviewParty.fromJson(json['client'] as Map<String, dynamic>),
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

ArtisanReviewModel _$ArtisanReviewModelFromJson(Map<String, dynamic> json) =>
    ArtisanReviewModel(
      id: json['id'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      note: json['note'] as String?,
      booking: json['booking'] as Map<String, dynamic>?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

ReviewParty _$ReviewPartyFromJson(Map<String, dynamic> json) => ReviewParty(
      id: json['id'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubmitReviewRequestBodyToJson(
        SubmitReviewRequestBody instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'note': instance.note,
    };
