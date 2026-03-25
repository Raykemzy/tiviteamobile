import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
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
    final pricing = MarketplaceCartPricing.orderSummaryTotals(
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
                                Text('VAT (5%)', style: labelStyle),
                                pricing.vat.getCurrencyText(style: valueStyle),
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
    final addr = pickUp
        ? (lines.firstListingAddress ?? '')
        : deliveryAddress.trim();

    final body = MarketplaceCreateOrderRequestBody(
      cartItemIds: ids,
      pickUp: pickUp,
      deliveryAddress: addr,
    );

    try {
      final orderId = await ref
          .read(marketplaceCheckoutProvider.notifier)
          .createOrder(body);
      if (!mounted) return;
      if (orderId != null && orderId.isNotEmpty) {
        ref.read(marketplacePendingOrderIdProvider.notifier).state = orderId;
      }
      ref.read(marketplaceCheckoutProvider.notifier).reset();
      context.showSuccess(
        orderId != null && orderId.isNotEmpty
            ? 'Order created. Order ref: $orderId'
            : 'Order created.',
      );
    } catch (e) {
      if (!mounted) return;
      context.showError(e.toString());
      ref.read(marketplaceCheckoutProvider.notifier).reset();
    }
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
