import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_pricing.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_cart_line_tile.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_payment_summary_card.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';

class MyCartView extends ConsumerStatefulWidget {
  const MyCartView({super.key});

  @override
  ConsumerState<MyCartView> createState() => _MyCartViewState();
}

class _MyCartViewState extends ConsumerState<MyCartView> {
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
    final itemsSubtotal = lines.itemsSubtotal;
    final pricing = MarketplaceCartPricing.compute(
      itemsSubtotal: itemsSubtotal,
      deliveryFee: 0,
    );

    return AppScaffold(
      appbar: const CustomAppBar(title: 'My cart'),
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < lines.length; i++) ...[
                                    if (i > 0) 6.verticalSpace,
                                    MarketplaceCartLineTile(line: lines[i]),
                                  ],
                                ],
                              ),
                            ),
                            30.verticalSpace,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: MarketplacePaymentSummaryCard(
                                pricing: pricing,
                              ),
                            ),
                            50.verticalSpace,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: AppButton(
                                buttonText: 'Choose delivery',
                                onPressed: () async {
                                  // Make sure quantity edits are saved before
                                  // moving toward checkout.
                                  await ref
                                      .read(marketplaceCartProvider.notifier)
                                      .commitPendingQuantity();
                                  if (!context.mounted) return;
                                  context.push(
                                    '${AppRoutes.servicesView}/${AppRoutes.marketplaceDeliveryView}',
                                  );
                                },
                              ),
                            ),
                            16.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
