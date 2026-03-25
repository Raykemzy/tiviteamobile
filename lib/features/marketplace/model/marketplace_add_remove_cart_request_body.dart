import 'package:json_annotation/json_annotation.dart';

part 'marketplace_add_remove_cart_request_body.g.dart';

@JsonSerializable()
class MarketplaceAddRemoveCartRequestBody {
  MarketplaceAddRemoveCartRequestBody({
    required this.action,
    required this.quantity,
  });

  final String action;
  final int quantity;

  factory MarketplaceAddRemoveCartRequestBody.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MarketplaceAddRemoveCartRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MarketplaceAddRemoveCartRequestBodyToJson(this);
}
