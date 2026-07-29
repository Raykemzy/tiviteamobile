import 'package:json_annotation/json_annotation.dart';

part 'marketplace_create_order_request_body.g.dart';

@JsonSerializable()
class MarketplaceCreateOrderRequestBody {
  MarketplaceCreateOrderRequestBody({
    required this.cartItemIds,
    required this.pickUp,
    this.deliveryAddress,
  });

  @JsonKey(name: 'cart_item_ids')
  final List<String> cartItemIds;

  @JsonKey(name: 'pick_up')
  final bool pickUp;

  /// Omitted from the payload for pickup orders.
  @JsonKey(name: 'delivery_address', includeIfNull: false)
  final String? deliveryAddress;

  factory MarketplaceCreateOrderRequestBody.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MarketplaceCreateOrderRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MarketplaceCreateOrderRequestBodyToJson(this);
}
