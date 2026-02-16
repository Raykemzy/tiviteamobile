import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/user_model.dart';

part 'artisan_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ArtisanResponseModel {
  const ArtisanResponseModel({
    this.id,
    this.user,
    this.address,
    this.serviceTypeSummary,
    this.hasUploadedKycDocuments,
    this.rating,
    this.reviewsCount,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.isDeleted,
    this.deletedAt,
    this.serviceType,
    this.galleryImages,
    this.kycIsVerified,
  });

  final String? id;
  final User? user;
  final Address? address;
  @JsonKey(name: 'service_type_summary')
  final String? serviceTypeSummary;
  @JsonKey(name: 'has_uploaded_kyc_documents')
  final bool? hasUploadedKycDocuments;
  final num? rating;
  @JsonKey(name: 'reviews_count')
  final int? reviewsCount;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'is_deleted')
  final bool? isDeleted;
  @JsonKey(name: 'deleted_at')
  final dynamic deletedAt;
  @JsonKey(name: 'service_type')
  final String? serviceType;
  @JsonKey(name: 'gallery_images')
  final List<String>? galleryImages;
  @JsonKey(name: 'kyc_is_verified')
  final bool? kycIsVerified;

  factory ArtisanResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ArtisanResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanResponseModelToJson(this);
}
