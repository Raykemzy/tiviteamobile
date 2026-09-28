import 'package:json_annotation/json_annotation.dart';

part 'quotation_model.g.dart';

/// A quotation negotiation between a client and an artisan.
///
/// Shape verified against a live negotiation on api.tivitea.africa. The flow
/// is: client requests → artisan sends a price → either side may counter
/// (capped at two counters each, after which the backend replies "Cannot
/// counter price because the limit is 2 times. Accept or decline offer.") →
/// either side accepts or declines.
///
/// Read via `GET /bookings/quotation/list` (paginated, scoped to the caller)
/// and `GET /bookings/quote/{id}`; every action also returns the updated
/// record.
@JsonSerializable()
class QuotationModel {
  final String? id;
  final String? status;
  @JsonKey(name: 'booking_id')
  final String? bookingId;
  @JsonKey(name: 'current_counter_price')
  final num? currentCounterPrice;
  @JsonKey(name: 'client_note')
  final String? clientNote;
  @JsonKey(name: 'client_end_date')
  final DateTime? clientEndDate;
  @JsonKey(name: 'artisan_note')
  final String? artisanNote;
  @JsonKey(name: 'artisan_price')
  final num? artisanPrice;
  @JsonKey(name: 'artisan_end_date')
  final DateTime? artisanEndDate;
  final List<String>? images;

  /// Carries `client_counter_count`, `artisan_counter_count` and the numbered
  /// counter history the backend keeps.
  final Map<String, dynamic>? meta;

  /// The two sides. Parsed so the thread can show real names and the artisan's
  /// trade, as the design does, rather than generic role labels. Read-only —
  /// a quotation is never serialised back out.
  @JsonKey(includeToJson: false)
  final QuotationParty? artisan;
  @JsonKey(includeToJson: false)
  final QuotationParty? client;

  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  QuotationModel({
    this.id,
    this.status,
    this.bookingId,
    this.currentCounterPrice,
    this.clientNote,
    this.clientEndDate,
    this.artisanNote,
    this.artisanPrice,
    this.artisanEndDate,
    this.images,
    this.meta,
    this.artisan,
    this.client,
    this.dateCreated,
  });

  bool get isAccepted => status?.toLowerCase() == 'accepted';
  bool get isDeclined => status?.toLowerCase() == 'declined';

  /// Whether the artisan has named a price yet. The backend serialises an
  /// unpriced request as `artisan_price: 0` (not null), so a null check is
  /// not enough — that mistake offered "Accept current quote (0)".
  bool get hasArtisanQuote =>
      (artisanPrice ?? 0) > 0 || (currentCounterPrice ?? 0) > 0;

  /// The figure on the table right now: latest counter, else opening quote.
  num get currentQuote {
    final counter = currentCounterPrice ?? 0;
    return counter > 0 ? counter : (artisanPrice ?? 0);
  }

  /// Counters remaining for the given side before the backend refuses.
  int countersLeftFor({required bool artisan}) {
    final used = (meta?[artisan ? 'artisan_counter_count' : 'client_counter_count']
            as num?)
        ?.toInt() ??
        0;
    final left = 2 - used;
    return left < 0 ? 0 : left;
  }

  factory QuotationModel.fromJson(Map<String, dynamic> json) =>
      _$QuotationModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuotationModelToJson(this);
}

/// One side of a negotiation. The payload nests a full user; only what the
/// thread renders is modelled.
@JsonSerializable(createToJson: false)
class QuotationParty {
  final String? id;
  final QuotationPartyUser? user;

  /// Artisans only — "photographer", "carpenter".
  @JsonKey(name: 'service_type')
  final String? serviceType;

  QuotationParty({this.id, this.user, this.serviceType});

  String get displayName {
    final name = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    return name.isEmpty ? '' : name;
  }

  factory QuotationParty.fromJson(Map<String, dynamic> json) =>
      _$QuotationPartyFromJson(json);
}

@JsonSerializable(createToJson: false)
class QuotationPartyUser {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  QuotationPartyUser({
    this.id,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory QuotationPartyUser.fromJson(Map<String, dynamic> json) =>
      _$QuotationPartyUserFromJson(json);
}
