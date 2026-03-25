import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_delivery_notifier.g.dart';

enum MarketplaceDeliveryOption {
  deliverToMe,
  pickup,
}

extension MarketplaceDeliveryOptionX on MarketplaceDeliveryOption {
  String get title => switch (this) {
        MarketplaceDeliveryOption.deliverToMe => 'Deliver to me',
        MarketplaceDeliveryOption.pickup => 'Pickup',
      };

  /// Extra delivery charge (₦). Pickup has no delivery fee.
  num get fee => switch (this) {
        MarketplaceDeliveryOption.deliverToMe => 2500,
        MarketplaceDeliveryOption.pickup => 0,
      };
}

@Riverpod(keepAlive: true)
class MarketplaceDeliverySelection extends _$MarketplaceDeliverySelection {
  @override
  MarketplaceDeliveryOption build() => MarketplaceDeliveryOption.pickup;

  void select(MarketplaceDeliveryOption option) => state = option;
}
