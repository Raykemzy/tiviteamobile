import 'package:json_annotation/json_annotation.dart';

part 'edit_marketplace_item_request_body.g.dart';

@JsonSerializable()
class EditMarketplaceItemRequestBody {
  const EditMarketplaceItemRequestBody({
    required this.price,
    required this.inStock,
    required this.quantity,
  });

  final num price;
  @JsonKey(name: 'in_stock')
  final bool inStock;
  final int quantity;

  factory EditMarketplaceItemRequestBody.fromJson(Map<String, dynamic> json) =>
      _$EditMarketplaceItemRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$EditMarketplaceItemRequestBodyToJson(this);
}
