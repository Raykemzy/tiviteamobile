import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_text.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_quantity_stepper.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';

const double _kCartTileMinHeight = 145;

/// Favorites-style row with optional image, details, line total, and quantity stepper.
class MarketplaceCartLineTile extends ConsumerWidget {
  const MarketplaceCartLineTile({
    super.key,
    required this.line,
  });

  final MarketplaceCartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartBusy = ref.watch(
      marketplaceCartProvider.select((s) => s.loadState == LoadState.loading),
    );
    final listing = line.listing;
    final images = listing.images;
    final hasImage = images != null && images.any((e) => e.trim().isNotEmpty);
    final imagePath =
        hasImage ? images.firstWhere((e) => e.trim().isNotEmpty) : '';
    final primary = context.theme.primaryColor;
    final radius = BorderRadius.circular(8.r);

    return Container(
      constraints: BoxConstraints(minHeight: _kCartTileMinHeight.h),
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
          color: const Color(0xFFD8D8DD),
        ),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage)
              SizedBox(
                width: _kCartTileMinHeight.w,
                child: AppImageWidget(
                  imagePath: imagePath,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomLeft: Radius.circular(8.r),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 36.w, 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.theme.textTheme.titleLarge?.copyWith(
                              fontSize: 16.sp,
                              color: primary,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: cartBusy
                                ? null
                                : () => ref
                                    .read(marketplaceCartProvider.notifier)
                                    .removeLine(
                                      line,
                                      onError: (m) => context.showError(m),
                                    ),
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(6.r),
                              child: Icon(
                                Icons.delete_outline,
                                size: 20.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.verticalSpace,
                    Text.rich(
                      TextSpan(
                        style: context.theme.textTheme.labelMedium?.copyWith(
                          fontSize: 9.8.sp,
                          color: const Color(0xFF737380),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Seller: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: marketplaceSellerValue(listing) ?? '—',
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    20.verticalSpace,
                    line.lineSubtotal.getCurrencyText(
                      style: context.theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primary,
                        fontSize: 14.sp,
                      ),
                    ),
                    15.verticalSpace,
                    Row(
                      children: [
                        AbsorbPointer(
                          absorbing: cartBusy,
                          child: Opacity(
                            opacity: cartBusy ? 0.45 : 1,
                            child: MarketplaceQuantityStepper(
                              quantity: line.quantity,
                              primary: primary,
                              onDecrement: () => ref
                                  .read(marketplaceCartProvider.notifier)
                                  .decrement(
                                    line,
                                    onError: (m) => context.showError(m),
                                  ),
                              onIncrement: line.canIncrement
                                  ? () => ref
                                      .read(marketplaceCartProvider.notifier)
                                      .increment(
                                        line,
                                        onError: (m) => context.showError(m),
                                      )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
