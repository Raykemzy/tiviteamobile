import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';

/// One row in the marketplace cart with a quantity.
class MarketplaceCartLine {
  const MarketplaceCartLine({
    this.cartItemId,
    required this.listing,
    required this.quantity,
  });

  /// Server cart line id (GET `/listings/market-place/cart/items`).
  final String? cartItemId;
  final ListingResponseModel listing;
  final int quantity;

  num get lineSubtotal => (listing.amount ?? 0) * quantity;
}

extension MarketplaceCartLinesX on List<MarketplaceCartLine> {
  num get itemsSubtotal =>
      fold<num>(0, (sum, line) => sum + line.lineSubtotal);

  /// First non-empty listing address (e.g. pickup location).
  String? get firstListingAddress {
    for (final line in this) {
      final a = line.listing.address?.trim();
      if (a != null && a.isNotEmpty) return a;
    }
    return null;
  }
}

String marketplaceCartLineKey(ListingResponseModel listing) {
  final id = listing.id?.trim();
  if (id != null && id.isNotEmpty) return id;
  return '${listing.name}_${listing.amount}';
}

String marketplaceLineKey(MarketplaceCartLine line) {
  final cid = line.cartItemId?.trim();
  if (cid != null && cid.isNotEmpty) return cid;
  return marketplaceCartLineKey(line.listing);
}
