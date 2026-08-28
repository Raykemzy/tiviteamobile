// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceOrderModel _$MarketplaceOrderModelFromJson(
        Map<String, dynamic> json) =>
    MarketplaceOrderModel(
      id: json['id'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentLink: json['payment_link'] == null
          ? null
          : OrderPaymentLink.fromJson(
              json['payment_link'] as Map<String, dynamic>),
      totalCost: json['total_cost'] as num?,
      deliveryAddress: json['delivery_address'] == null
          ? null
          : OrderDeliveryAddress.fromJson(
              json['delivery_address'] as Map<String, dynamic>),
      orderedItems: (json['ordered_items'] as List<dynamic>?)
          ?.map((e) => OrderedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

OrderPaymentLink _$OrderPaymentLinkFromJson(Map<String, dynamic> json) =>
    OrderPaymentLink(
      reference: json['reference'] as String?,
      accessCode: json['access_code'] as String?,
      authorizationUrl: json['authorization_url'] as String?,
    );

OrderDeliveryAddress _$OrderDeliveryAddressFromJson(
        Map<String, dynamic> json) =>
    OrderDeliveryAddress(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      address: json['address'] as String?,
    );

OrderedItemModel _$OrderedItemModelFromJson(Map<String, dynamic> json) =>
    OrderedItemModel(
      id: json['id'] as String?,
      price: json['price'] as num?,
      quantity: (json['quantity'] as num?)?.toInt(),
      status: json['status'] as String?,
      deliveryFee: json['delivery_fee'] as num?,
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      order: json['order'] as String?,
      item: json['item'] as String?,
      dateCreated: json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
    );

MarketplaceSellerDashboardModel _$MarketplaceSellerDashboardModelFromJson(
        Map<String, dynamic> json) =>
    MarketplaceSellerDashboardModel(
      totalSales: json['total_sales'] as num?,
      totalEarnings: readDashboardAmount(json['total_earnings']),
      barChart: json['bar_chart'] == null
          ? null
          : BarChart.fromJson(json['bar_chart'] as Map<String, dynamic>),
      orderHistory: (json['order_history'] as List<dynamic>?)
          ?.map((e) => OrderedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
