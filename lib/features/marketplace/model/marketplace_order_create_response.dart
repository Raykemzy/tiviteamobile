import 'package:json_annotation/json_annotation.dart';

part 'marketplace_order_create_response.g.dart';

@JsonSerializable()
class MarketplaceOrderCreateResponse {
  MarketplaceOrderCreateResponse({
    this.id,
    this.orderId,
  });

  final String? id;

  @JsonKey(name: 'order_id')
  final String? orderId;

  String? get resolvedOrderId => orderId ?? id;

  factory MarketplaceOrderCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceOrderCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MarketplaceOrderCreateResponseToJson(this);
}
