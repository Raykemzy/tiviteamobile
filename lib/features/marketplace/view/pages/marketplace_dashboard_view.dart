import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/home/view/widgets/dashboard_grid.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_order_models.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_text.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_order_notifier.dart';

/// Seller-side marketplace figures, from `GET /dashboard/marketplace`.
class MarketplaceDashboardView extends ConsumerStatefulWidget {
  const MarketplaceDashboardView({super.key});

  @override
  ConsumerState<MarketplaceDashboardView> createState() =>
      _MarketplaceDashboardViewState();
}

class _MarketplaceDashboardViewState
    extends ConsumerState<MarketplaceDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(marketplaceOrderNotifierProvider.notifier).getSellerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceOrderNotifierProvider);
    final dashboard = state.dashboard;
    // "In_cart" rows share this table with real orders and are not sales.
    final sales = (dashboard?.orderHistory ?? const <OrderedItemModel>[])
        .where((item) => !item.isInCart)
        .toList();

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Marketplace',
        showHamburgerMenu: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(marketplaceOrderNotifierProvider.notifier)
            .getSellerDashboard(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          children: [
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.w,
                runSpacing: 15.h,
                children: [
                  DashboardInfoContainer(
                    title: 'Total Sales',
                    value: '${dashboard?.totalSales ?? 0}',
                    bookingContainerColor: const Color(0xFF2196F3),
                    onViewAll: () => context.go(
                      '${AppRoutes.profile}/${AppRoutes.myMarketplaceView}',
                    ),
                  ),
                  DashboardInfoContainer(
                    title: 'Total Earnings',
                    value: dashboard?.totalEarnings ?? '0',
                    bookingContainerColor: const Color(0xFF02952B),
                    onViewAll: () => context.go(
                      '${AppRoutes.profile}/${AppRoutes.withdrawalView}',
                    ),
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text(
                'Recent sales',
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                  color: context.theme.primaryColor,
                ),
              ),
            ),
            10.verticalSpace,
            if (state.loadState == LoadState.loading && dashboard == null)
              const Center(child: CircularProgressIndicator())
            else if (sales.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Center(
                  child: Text(
                    state.loadState == LoadState.error
                        ? 'Could not load your marketplace figures.'
                        : 'No sales yet.',
                    style: context.theme.textTheme.bodySmall,
                  ),
                ),
              )
            else
              for (final sale in sales)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                  child: _SaleRow(sale: sale),
                ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale});

  final OrderedItemModel sale;

  @override
  Widget build(BuildContext context) {
    final created = sale.dateCreated;
    final orderId = sale.order;
    return InkWell(
      onTap: orderId == null || orderId.isEmpty
          ? null
          : () => context.push(
                '${AppRoutes.profile}/${AppRoutes.myMarketplaceView}/'
                '${AppRoutes.marketplaceOrderDetailView}',
                extra: orderId,
              ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8DD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qty ${sale.quantity ?? 1}',
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  if (created != null)
                    Text(
                      '${created.day}/${created.month}/${created.year}',
                      style: context.theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Text(
              formatMarketplaceNaira(sale.price),
              style: context.theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
