import 'package:json_annotation/json_annotation.dart';

part 'create_marketplace_payment_request_body.g.dart';

/// Body for POST `/payment/market-place/:order_id` (wire in payment flow later).
@JsonSerializable()
class CreateMarketplacePaymentRequestBody {
  CreateMarketplacePaymentRequestBody({this.saveCard = true});

  @JsonKey(name: 'save_card')
  final bool saveCard;

  factory CreateMarketplacePaymentRequestBody.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CreateMarketplacePaymentRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateMarketplacePaymentRequestBodyToJson(this);
}
