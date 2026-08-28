import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/features/home/model/service_provider/service_provider_dashboard_model.dart';

part 'marketplace_order_models.g.dart';

/// A placed marketplace order. `GET /listings/market-place/view-order/{id}`.
@JsonSerializable(createToJson: false)
class MarketplaceOrderModel {
  final String? id;

  /// e.g. "Order_placed".
  final String? status;

  /// e.g. "Pending", "Success".
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  /// Present while the order is unpaid — lets the buyer resume checkout
  /// instead of starting a fresh order.
  @JsonKey(name: 'payment_link')
  final OrderPaymentLink? paymentLink;

  @JsonKey(name: 'total_cost')
  final num? totalCost;

  @JsonKey(name: 'delivery_address')
  final OrderDeliveryAddress? deliveryAddress;

  @JsonKey(name: 'ordered_items')
  final List<OrderedItemModel>? orderedItems;

  MarketplaceOrderModel({
    this.id,
    this.status,
    this.paymentStatus,
    this.paymentLink,
    this.totalCost,
    this.deliveryAddress,
    this.orderedItems,
  });

  bool get isPaid => paymentStatus?.toLowerCase() == 'success';

  /// A readable status: "Order placed" rather than "Order_placed".
  String get statusLabel => (status ?? '—').replaceAll('_', ' ');

  factory MarketplaceOrderModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceOrderModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class OrderPaymentLink {
  final String? reference;
  @JsonKey(name: 'access_code')
  final String? accessCode;
  @JsonKey(name: 'authorization_url')
  final String? authorizationUrl;

  OrderPaymentLink({this.reference, this.accessCode, this.authorizationUrl});

  factory OrderPaymentLink.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentLinkFromJson(json);
}

@JsonSerializable(createToJson: false)
class OrderDeliveryAddress {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? address;

  OrderDeliveryAddress({
    this.id,
    this.firstName,
    this.lastName,
    this.address,
  });

  String get recipient => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory OrderDeliveryAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryAddressFromJson(json);
}

/// A single line on an order.
///
/// [item] is only an id — the endpoint does not embed the product, so a name
/// or image needs a separate lookup.
@JsonSerializable(createToJson: false)
class OrderedItemModel {
  final String? id;
  final num? price;
  final int? quantity;
  final String? status;
  @JsonKey(name: 'delivery_fee')
  final num? deliveryFee;
  @JsonKey(name: 'delivered_at')
  final DateTime? deliveredAt;
  final String? order;
  final String? item;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;

  OrderedItemModel({
    this.id,
    this.price,
    this.quantity,
    this.status,
    this.deliveryFee,
    this.deliveredAt,
    this.order,
    this.item,
    this.dateCreated,
  });

  /// The cart and order tables are the same table; "In_cart" rows are not
  /// orders and must not be shown as such.
  bool get isInCart => status?.toLowerCase() == 'in_cart';

  factory OrderedItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderedItemModelFromJson(json);
}

/// `GET /dashboard/marketplace`.
@JsonSerializable(createToJson: false)
class MarketplaceSellerDashboardModel {
  @JsonKey(name: 'total_sales')
  final num? totalSales;

  /// Parsed leniently — the sibling dashboards return this pre-formatted.
  @JsonKey(name: 'total_earnings', fromJson: readDashboardAmount)
  final String? totalEarnings;

  @JsonKey(name: 'bar_chart')
  final BarChart? barChart;

  @JsonKey(name: 'order_history')
  final List<OrderedItemModel>? orderHistory;

  MarketplaceSellerDashboardModel({
    this.totalSales,
    this.totalEarnings,
    this.barChart,
    this.orderHistory,
  });

  factory MarketplaceSellerDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceSellerDashboardModelFromJson(json);
}
