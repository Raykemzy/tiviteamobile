import 'package:json_annotation/json_annotation.dart';

part 'create_marketplace_item_request_body.g.dart';

@JsonSerializable()
class CreateMarketplaceItemRequestBody {
  const CreateMarketplaceItemRequestBody({
    required this.name,
    required this.description,
    required this.price,
    required this.inStock,
    required this.images,
    required this.category,
    required this.quantity,
    required this.pickUpAddress,
    required this.condition,
  });

  final String name;
  final String description;
  final num price;
  @JsonKey(name: 'in_stock')
  final bool inStock;
  final List<String> images;
  final String category;
  final int quantity;
  @JsonKey(name: 'pick_up_address')
  final String pickUpAddress;
  final String condition;

  factory CreateMarketplaceItemRequestBody.fromJson(
          Map<String, dynamic> json) =>
      _$CreateMarketplaceItemRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateMarketplaceItemRequestBodyToJson(this);
}
