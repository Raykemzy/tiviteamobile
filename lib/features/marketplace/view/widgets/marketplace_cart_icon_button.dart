import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';

/// Cart icon with a badge showing the number of items in the cart.
/// Tapping navigates to the cart view.
class MarketplaceCartIconButton extends ConsumerStatefulWidget {
  const MarketplaceCartIconButton({super.key});

  @override
  ConsumerState<MarketplaceCartIconButton> createState() =>
      _MarketplaceCartIconButtonState();
}

class _MarketplaceCartIconButtonState
    extends ConsumerState<MarketplaceCartIconButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceCartProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(marketplaceCartProvider).lines.totalQuantity;
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: () => context.push(
        '${AppRoutes.servicesView}/${AppRoutes.myCartView}',
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 26.sp,
              color: context.theme.primaryColor,
            ),
            if (count > 0)
              Positioned(
                right: -6.w,
                top: -6.h,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  constraints: BoxConstraints(
                    minWidth: 18.w,
                    minHeight: 18.w,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC8305),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9.sp,
                      height: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
