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
/// Note there is **no GET endpoint** for a quotation: it can only be read from
/// the response of an action you just performed. Listing/detail screens are
/// blocked on the backend exposing one.
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
    this.dateCreated,
  });

  bool get isAccepted => status?.toLowerCase() == 'accepted';
  bool get isDeclined => status?.toLowerCase() == 'declined';

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
