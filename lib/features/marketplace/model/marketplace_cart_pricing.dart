/// Marketplace totals: items subtotal + delivery fee.
///
/// The backend charges a delivery fee only — there is no service charge or
/// VAT on marketplace orders, so the summary must not add any. Keeping this in
/// sync with the backend avoids showing the customer a total they won't be
/// charged at payment.
class MarketplaceCartPricing {
  const MarketplaceCartPricing({
    required this.itemsSubtotal,
    required this.deliveryFee,
    required this.total,
  });

  final num itemsSubtotal;
  final num deliveryFee;
  final num total;

  static MarketplaceCartPricing compute({
    required num itemsSubtotal,
    num deliveryFee = 0,
  }) {
    return MarketplaceCartPricing(
      itemsSubtotal: itemsSubtotal,
      deliveryFee: deliveryFee,
      total: itemsSubtotal + deliveryFee,
    );
  }
}
