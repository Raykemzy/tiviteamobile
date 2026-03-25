import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';

/// One row from GET `/listings/market-place/cart/items`.
class MarketplaceCartItemModel {
  MarketplaceCartItemModel({
    required this.id,
    required this.quantity,
    required this.listing,
  });

  final String id;
  final int quantity;
  final ListingResponseModel listing;

  factory MarketplaceCartItemModel.fromJson(Map<String, dynamic> json) {
    final nested = json['listing'] ??
        json['item'] ??
        json['market_place_item'] ??
        json['listing_item'];
    if (nested is! Map) {
      throw FormatException(
        'Cart item JSON missing listing (tried listing/item/market_place_item)',
      );
    }
    return MarketplaceCartItemModel(
      id: json['id']?.toString() ?? '',
      quantity: switch (json['quantity']) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v) ?? 1,
        _ => 1,
      },
      listing: ListingResponseModel.fromJson(
        Map<String, dynamic>.from(nested),
      ),
    );
  }
}
