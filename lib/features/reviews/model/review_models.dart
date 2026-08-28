import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/models/user_model.dart';

part 'review_models.g.dart';

/// A client's review of a booked listing.
/// `GET /bookings/partner/booking-reviews`, `POST /bookings/{id}/reviews`.
@JsonSerializable(createToJson: false)
class BookingReviewModel {
  final String? id;
  final int? rating;
  final String? note;
  final String? status;
  final ListingResponseModel? listing;
  final ReviewParty? client;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  BookingReviewModel({
    this.id,
    this.rating,
    this.note,
    this.status,
    this.listing,
    this.client,
    this.dateCreated,
  });

  factory BookingReviewModel.fromJson(Map<String, dynamic> json) =>
      _$BookingReviewModelFromJson(json);
}

/// A client's review of an artisan.
/// `GET /bookings/artisan-reviews/{artisanId}`,
/// `POST /bookings/{bookingId}/artisan-reviews`.
@JsonSerializable(createToJson: false)
class ArtisanReviewModel {
  final String? id;
  final int? rating;
  final String? note;

  /// The booking the review was left against. Kept loosely typed: the sample
  /// payload returns it with most fields blank, so nothing should depend on
  /// its shape.
  final Map<String, dynamic>? booking;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  ArtisanReviewModel({
    this.id,
    this.rating,
    this.note,
    this.booking,
    this.dateCreated,
  });

  factory ArtisanReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ArtisanReviewModelFromJson(json);
}

/// The person who left a review.
@JsonSerializable(createToJson: false)
class ReviewParty {
  final String? id;
  final User? user;

  ReviewParty({this.id, this.user});

  String get displayName {
    final first = user?.firstName?.trim() ?? '';
    final last = user?.lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? 'Customer' : full;
  }

  factory ReviewParty.fromJson(Map<String, dynamic> json) =>
      _$ReviewPartyFromJson(json);
}

/// Body for every review endpoint — booking, artisan and marketplace item all
/// take the same two fields.
@JsonSerializable(createFactory: false)
class SubmitReviewRequestBody {
  final int rating;
  final String note;

  SubmitReviewRequestBody({required this.rating, this.note = ''});

  Map<String, dynamic> toJson() => _$SubmitReviewRequestBodyToJson(this);
}
