import 'package:json_annotation/json_annotation.dart';

part 'quotation_request_bodies.g.dart';

/// Artisan's opening price. `POST /bookings/send-quotation/{quotation_id}`.
@JsonSerializable(includeIfNull: false, createFactory: false)
class SendQuotationRequestBody {
  @JsonKey(name: 'artisan_note')
  final String artisanNote;
  @JsonKey(name: 'artisan_price')
  final num artisanPrice;
  @JsonKey(name: 'artisan_end_date')
  final String artisanEndDate;

  SendQuotationRequestBody({
    required this.artisanNote,
    required this.artisanPrice,
    required this.artisanEndDate,
  });

  Map<String, dynamic> toJson() => _$SendQuotationRequestBodyToJson(this);
}

/// `POST /bookings/counter-quotation-price/{quotation_id}`.
///
/// The same URL serves both sides; which fields are sent decides who is
/// countering, so the two constructors are kept distinct rather than leaving
/// callers to remember the convention.
@JsonSerializable(includeIfNull: false, createFactory: false)
class CounterQuotationRequestBody {
  @JsonKey(name: 'client_note')
  final String? clientNote;
  @JsonKey(name: 'client_counter_price')
  final num? clientCounterPrice;
  @JsonKey(name: 'client_counter_end_date')
  final String? clientCounterEndDate;
  @JsonKey(name: 'artisan_note')
  final String? artisanNote;
  @JsonKey(name: 'artisan_counter_price')
  final num? artisanCounterPrice;
  @JsonKey(name: 'artisan_counter_end_date')
  final String? artisanCounterEndDate;

  const CounterQuotationRequestBody._({
    this.clientNote,
    this.clientCounterPrice,
    this.clientCounterEndDate,
    this.artisanNote,
    this.artisanCounterPrice,
    this.artisanCounterEndDate,
  });

  factory CounterQuotationRequestBody.client({
    required String note,
    required num price,
    required String endDate,
  }) =>
      CounterQuotationRequestBody._(
        clientNote: note,
        clientCounterPrice: price,
        clientCounterEndDate: endDate,
      );

  factory CounterQuotationRequestBody.artisan({
    required String note,
    required num price,
    required String endDate,
  }) =>
      CounterQuotationRequestBody._(
        artisanNote: note,
        artisanCounterPrice: price,
        artisanCounterEndDate: endDate,
      );

  Map<String, dynamic> toJson() => _$CounterQuotationRequestBodyToJson(this);
}
