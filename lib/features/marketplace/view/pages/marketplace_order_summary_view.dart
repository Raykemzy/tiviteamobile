import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_success_content.dart';
import 'package:tivi_tea/features/payment/view/payment_webview.dart';
import 'package:tivi_tea/features/payment/view_model/client/client_payment_notifier.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_pricing.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_create_order_request_body.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_checkout_notifier.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_delivery_address_provider.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_delivery_notifier.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_pending_order_provider.dart';

class MarketplaceOrderSummaryView extends ConsumerStatefulWidget {
  const MarketplaceOrderSummaryView({super.key});

  @override
  ConsumerState<MarketplaceOrderSummaryView> createState() =>
      _MarketplaceOrderSummaryViewState();
}

class _MarketplaceOrderSummaryViewState
    extends ConsumerState<MarketplaceOrderSummaryView> {
  /// Set once an order exists, so the failure paths can offer it.
  VoidCallback? _openOrderDetail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceCartProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(marketplaceCartProvider);
    final lines = cart.lines;
    final delivery = ref.watch(marketplaceDeliverySelectionProvider);
    final deliveryAddress = ref.watch(marketplaceDeliveryAddressProvider);
    final deliveryFee = delivery.fee;
    final itemsSubtotal = lines.itemsSubtotal;
    final pricing = MarketplaceCartPricing.compute(
      itemsSubtotal: itemsSubtotal,
      deliveryFee: deliveryFee,
    );
    final primary = context.theme.primaryColor;
    final checkoutBusy =
        ref.watch(marketplaceCheckoutProvider) == LoadState.loading;
    final dateLabel = DateFormat.yMMMEd().format(DateTime.now());
    final locationText = delivery == MarketplaceDeliveryOption.pickup
        ? (lines.firstListingAddress ?? '—')
        : (deliveryAddress.trim().isEmpty ? '—' : deliveryAddress.trim());

    final labelStyle = context.theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      color: const Color(0xFF333333),
    );
    final valueStyle = context.theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF333333),
    );

    return AppScaffold(
      appbar: const CustomAppBar(title: 'Order summary'),
      body: cart.loadState == LoadState.loading && lines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : lines.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: context.theme.textTheme.bodyLarge,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        children: [
                          for (final line in lines) ...[
                            _SummaryCard(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${line.listing.name ?? 'Item'}  ×${line.quantity}',
                                      style: labelStyle,
                                    ),
                                  ),
                                  line.lineSubtotal.getCurrencyText(
                                    style: valueStyle,
                                  ),
                                ],
                              ),
                            ),
                            8.verticalSpace,
                          ],
                          _SummaryCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery cost', style: labelStyle),
                                deliveryFee.getCurrencyText(style: valueStyle),
                              ],
                            ),
                          ),
                          8.verticalSpace,
                          _SummaryCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Date', style: labelStyle),
                                Text(dateLabel, style: valueStyle),
                              ],
                            ),
                          ),
                          8.verticalSpace,
                          _SummaryCard(
                            below: Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                locationText,
                                style: context.theme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF737380),
                                  height: 1.35,
                                ),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Delivery location',
                                style: labelStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          8.verticalSpace,
                          _SummaryCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: labelStyle?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                    color: primary,
                                  ),
                                ),
                                Text(
                                  '₦${pricing.total.formatAmount}',
                                  style: valueStyle?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: AppButton(
                        buttonText: 'Pay now',
                        isLoading: checkoutBusy,
                        onPressed: checkoutBusy
                            ? null
                            : () => _onPayNow(
                                  lines,
                                  delivery,
                                  deliveryAddress,
                                ),
                      ),
                    ),
                    16.verticalSpace,
                  ],
                ),
    );
  }

  Future<void> _onPayNow(
    List<MarketplaceCartLine> lines,
    MarketplaceDeliveryOption delivery,
    String deliveryAddress,
  ) async {
    // Flush any pending quantity edits so the server cart matches the UI.
    await ref.read(marketplaceCartProvider.notifier).commitPendingQuantity();

    final ids = lines
        .map((e) => e.cartItemId?.trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    if (ids.length != lines.length) {
      if (!mounted) return;
      context.showError('Cart is out of sync. Please return to the cart.');
      await ref.read(marketplaceCartProvider.notifier).loadCart();
      return;
    }
    final pickUp = delivery == MarketplaceDeliveryOption.pickup;
    if (!pickUp && deliveryAddress.trim().isEmpty) {
      if (!mounted) return;
      context.showError('Please enter a delivery address.');
      return;
    }
    final body = MarketplaceCreateOrderRequestBody(
      cartItemIds: ids,
      pickUp: pickUp,
      // Pickup orders don't send a delivery address.
      deliveryAddress: pickUp ? null : deliveryAddress.trim(),
    );

    try {
      final orderId = await ref
          .read(marketplaceCheckoutProvider.notifier)
          .createOrder(body);
      if (!mounted) return;
      ref.read(marketplaceCheckoutProvider.notifier).reset();

      if (orderId == null || orderId.isEmpty) {
        // Without an order id there's nothing to charge against.
        context.showError(
          'Order created but no reference was returned. '
          'Please check your orders before paying again.',
        );
        return;
      }
      ref.read(marketplacePendingOrderIdProvider.notifier).state = orderId;
      // Every failure below now sends the buyer to the order, which can resume
      // payment — these messages previously pointed at a screen that did not
      // exist.
      _openOrderDetail = () => context.push(
            '${AppRoutes.profile}/${AppRoutes.myMarketplaceView}/'
            '${AppRoutes.marketplaceOrderDetailView}',
            extra: orderId,
          );
      _startPayment(orderId);
    } catch (e) {
      if (!mounted) return;
      context.showError(e.toString());
      ref.read(marketplaceCheckoutProvider.notifier).reset();
    }
  }

  /// Order exists but is unpaid — get a Paystack authorization for it and hand
  /// off to the webview.
  void _startPayment(String orderId) {
    ref.read(clientPaymentNotifierProvider.notifier).createMarketPlaceOrderPayment(
          orderId,
          onSuccess: (response) {
            final url = response.authorizationUrl;
            if (url == null || url.isEmpty) {
              context.showError(
                'Could not start payment. Please try again from your orders.',
              );
              _openOrderDetail?.call();
              return;
            }
            _openPaymentWebview(url, response.reference ?? '');
          },
          onError: (message) => context.showError(message),
        );
  }

  void _openPaymentWebview(String paystackUrl, String paymentReference) {
    context
        .push(
      AppRoutes.paymentWebview,
      extra: PaymentWebviewArgs.marketplaceOrder(paystackUrl: paystackUrl),
    )
        .then((_) async {
      if (!mounted) return;
      if (paymentReference.isEmpty) {
        // Nothing to poll — the user has to check the order themselves.
        context.showError(
          'Payment status is unknown. Please check your orders.',
        );
        _openOrderDetail?.call();
        return;
      }
      await ref.read(clientPaymentNotifierProvider.notifier).getPaymentStatus(
        paymentReference,
        onSuccess: (isSuccessful, status) {
          if (!mounted) return;
          if (!isSuccessful) {
            // Covers cancelled and still-pending payments. The order stays put
            // so it can be paid or cancelled later.
            context.showError('Your transaction is ${status ?? 'incomplete'}.');
            return;
          }
          _onPaymentSuccessful();
        },
        onError: (message) {
          if (!mounted) return;
          context.showError(message);
        },
      );
    });
  }

  void _onPaymentSuccessful() {
    ref.read(marketplacePendingOrderIdProvider.notifier).state = null;
    // The server empties the cart when the order is paid; resync so the badge
    // and cart view don't keep showing sold items.
    ref.read(marketplaceCartProvider.notifier).loadCart(silent: true);

    context.showCustomDialog(
      dismissible: false,
      child: AppSuccessContent(
        title: 'Payment successful',
        subtitle: 'Your order has been paid for and is being processed.',
        buttonText: 'Continue shopping',
        secondButtonText: 'Back to home',
        onPressed: () {
          context.pop();
          context.go('${AppRoutes.servicesView}/${AppRoutes.marketPlaceView}');
        },
        onSecondButtonPressed: () {
          context.pop();
          context.go(AppRoutes.homeView);
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    this.below,
    required this.child,
  });

  final Widget? below;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD8D8DD),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (below != null) below!,
        ],
      ),
    );
  }
}
