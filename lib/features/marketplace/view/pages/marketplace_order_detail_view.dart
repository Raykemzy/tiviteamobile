import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_order_models.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_order_notifier.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_text.dart';
import 'package:tivi_tea/features/payment/view/payment_webview.dart';

/// A placed order: what it cost, where it is going, and — while it is unpaid —
/// a way to finish paying.
///
/// Checkout has three failure paths that tell the buyer to "check your
/// orders"; before this screen existed there was nowhere for them to go.
class MarketplaceOrderDetailView extends ConsumerStatefulWidget {
  const MarketplaceOrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<MarketplaceOrderDetailView> createState() =>
      _MarketplaceOrderDetailViewState();
}

class _MarketplaceOrderDetailViewState
    extends ConsumerState<MarketplaceOrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(marketplaceOrderNotifierProvider.notifier)
          .viewOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceOrderNotifierProvider);
    final order = state.order;

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Order Details',
        showBackButtonForHomeScreenAppBar: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(marketplaceOrderNotifierProvider.notifier)
            .viewOrder(widget.orderId),
        child: Builder(
          builder: (context) {
            if (state.loadState == LoadState.loading && order == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (order == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  Center(
                    child: Text(
                      state.errorMessage ?? 'Order not found.',
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }
            return _OrderBody(order: order, onPay: () => _pay(order));
          },
        ),
      ),
    );
  }

  void _pay(MarketplaceOrderModel order) {
    final url = order.paymentLink?.authorizationUrl;
    if (url == null || url.isEmpty) {
      context.showError('No payment link on this order yet.');
      return;
    }
    context
        .push(
          AppRoutes.paymentWebview,
          extra: PaymentWebviewArgs.marketplaceOrder(paystackUrl: url),
        )
        .then((_) {
      if (!mounted) return;
      ref
          .read(marketplaceOrderNotifierProvider.notifier)
          .viewOrder(widget.orderId);
    });
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order, required this.onPay});

  final MarketplaceOrderModel order;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final items = order.orderedItems ?? const <OrderedItemModel>[];
    final address = order.deliveryAddress;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      children: [
        _StatusChips(order: order),
        20.verticalSpace,
        _Section(
          title: 'Items',
          child: Column(
            children: [
              for (final item in items) _OrderLine(item: item),
              if (items.isEmpty)
                Text(
                  'No items on this order.',
                  style: context.theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        if (address != null) ...[
          16.verticalSpace,
          _Section(
            title: 'Delivery',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.recipient.isNotEmpty)
                  Text(
                    address.recipient,
                    style: context.theme.textTheme.bodyMedium,
                  ),
                4.verticalSpace,
                Text(
                  address.address ?? '—',
                  style: context.theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
        16.verticalSpace,
        _Section(
          title: 'Total',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total cost', style: context.theme.textTheme.bodySmall),
              Text(
                formatMarketplaceNaira(order.totalCost),
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                  color: context.theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        24.verticalSpace,
        if (!order.isPaid)
          AppButton(buttonText: 'Complete payment', onPressed: onPay),
        20.verticalSpace,
      ],
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.order});

  final MarketplaceOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: order.statusLabel,
          color: const Color(0xFF2196F3),
        ),
        8.horizontalSpace,
        _Chip(
          label: order.paymentStatus ?? '—',
          color: order.isPaid
              ? const Color(0xFF02952B)
              : const Color(0xFFF5A623),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.theme.textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.theme.textTheme.titleLarge?.copyWith(
              fontSize: 14.sp,
              color: context.theme.primaryColor,
            ),
          ),
          10.verticalSpace,
          child,
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.item});

  final OrderedItemModel item;

  @override
  Widget build(BuildContext context) {
    // The endpoint returns only the item id, so there is no product name or
    // image to show here without a second lookup per line.
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qty ${item.quantity ?? 1}',
                  style: context.theme.textTheme.bodyMedium,
                ),
                if ((item.deliveryFee ?? 0) > 0)
                  Text(
                    'Delivery ${formatMarketplaceNaira(item.deliveryFee)}',
                    style: context.theme.textTheme.bodySmall,
                  ),
                if (item.status != null)
                  Text(
                    item.status!.replaceAll('_', ' '),
                    style: context.theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            formatMarketplaceNaira(item.price),
            style: context.theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
