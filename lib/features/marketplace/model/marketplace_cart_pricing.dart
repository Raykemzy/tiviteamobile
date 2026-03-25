/// Service charge and VAT are calculated on the items subtotal only.
class MarketplaceCartPricing {
  const MarketplaceCartPricing({
    required this.itemsSubtotal,
    required this.serviceCharge,
    required this.vat,
    required this.deliveryFee,
    required this.total,
  });

  final num itemsSubtotal;
  final num serviceCharge;
  final num vat;
  final num deliveryFee;
  final num total;

  static const double serviceChargeRate = 0.03;
  static const double vatRate = 0.05;

  static MarketplaceCartPricing compute({
    required num itemsSubtotal,
    num deliveryFee = 0,
  }) {
    final service = itemsSubtotal * serviceChargeRate;
    final vat = itemsSubtotal * vatRate;
    final total = itemsSubtotal + service + vat + deliveryFee;
    return MarketplaceCartPricing(
      itemsSubtotal: itemsSubtotal,
      serviceCharge: service,
      vat: vat,
      deliveryFee: deliveryFee,
      total: total,
    );
  }

  /// Order summary: items + delivery + VAT (5%) only — no service charge row.
  static MarketplaceCartPricing orderSummaryTotals({
    required num itemsSubtotal,
    required num deliveryFee,
  }) {
    final vat = itemsSubtotal * vatRate;
    final total = itemsSubtotal + deliveryFee + vat;
    return MarketplaceCartPricing(
      itemsSubtotal: itemsSubtotal,
      serviceCharge: 0,
      vat: vat,
      deliveryFee: deliveryFee,
      total: total,
    );
  }
}
