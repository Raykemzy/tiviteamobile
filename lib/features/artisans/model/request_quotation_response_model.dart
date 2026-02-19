import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/models/user_model.dart';

part 'request_quotation_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RequestQuotationResponseModel {
  const RequestQuotationResponseModel({
    this.id,
    this.currentCounterPrice,
    this.currentCounterEndDate,
    this.artisan,
    this.client,
    this.bookingId,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.isDeleted,
    this.deletedAt,
    this.clientNote,
    this.clientEndDate,
    this.images,
    this.artisanPrice,
    this.artisanNote,
    this.status,
    this.artisanEndDate,
  });

  final String? id;
  @JsonKey(name: 'current_counter_price')
  final num? currentCounterPrice;
  @JsonKey(name: 'current_counter_end_date')
  final DateTime? currentCounterEndDate;
  final ArtisanResponseModel? artisan;
  final QuotationClientModel? client;
  @JsonKey(name: 'booking_id')
  final String? bookingId;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'is_deleted')
  final bool? isDeleted;
  @JsonKey(name: 'deleted_at')
  final dynamic deletedAt;
  @JsonKey(name: 'client_note')
  final String? clientNote;
  @JsonKey(name: 'client_end_date')
  final DateTime? clientEndDate;
  final List<String>? images;
  @JsonKey(name: 'artisan_price')
  final num? artisanPrice;
  @JsonKey(name: 'artisan_note')
  final String? artisanNote;
  final String? status;
  @JsonKey(name: 'artisan_end_date')
  final DateTime? artisanEndDate;

  factory RequestQuotationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RequestQuotationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RequestQuotationResponseModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class QuotationClientModel {
  const QuotationClientModel({
    this.id,
    this.user,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.isDeleted,
    this.deletedAt,
    this.authProvider,
    this.authId,
    this.kycIsVerified,
    this.favoriteListings,
  });

  final String? id;
  final User? user;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'is_deleted')
  final bool? isDeleted;
  @JsonKey(name: 'deleted_at')
  final dynamic deletedAt;
  @JsonKey(name: 'auth_provider')
  final String? authProvider;
  @JsonKey(name: 'auth_id')
  final String? authId;
  @JsonKey(name: 'kyc_is_verified')
  final bool? kycIsVerified;
  @JsonKey(name: 'favorite_listings')
  final List<dynamic>? favoriteListings;

  factory QuotationClientModel.fromJson(Map<String, dynamic> json) =>
      _$QuotationClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuotationClientModelToJson(this);
}
