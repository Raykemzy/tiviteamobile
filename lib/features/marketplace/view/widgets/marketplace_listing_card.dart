import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_text.dart';
import 'package:tivi_tea/features/onboarding/view/widgets/slide_indicator.dart';

class MarketplaceListingCard extends StatefulWidget {
  const MarketplaceListingCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final ListingResponseModel item;
  final VoidCallback? onTap;

  @override
  State<MarketplaceListingCard> createState() => _MarketplaceListingCardState();
}

class _MarketplaceListingCardState extends State<MarketplaceListingCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.item.images ?? const <String>[];
    final reviewCount = marketplaceVisibleReviewCount(widget.item);

    // Grid tiles have a fixed height; Align + mainAxisSize.min keeps the card
    // only as tall as its content instead of stretching the white box.
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 5),
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 120.h,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.r),
                          ),
                          child: images.isEmpty
                              ? Container(
                                  color: context.theme.dividerColor,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No Image',
                                    style: context.theme.textTheme.labelSmall,
                                  ),
                                )
                              : PageView.builder(
                                  itemCount: images.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentImageIndex = i),
                                  itemBuilder: (_, i) =>
                                      AppImageWidget(imagePath: images[i]),
                                ),
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: SlideIndicatorWidget(
                            slideLength: images.length,
                            currentIndex: _currentImageIndex,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.item.name ?? 'Untitled',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.theme.textTheme.titleMedium
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                              ),
                              6.horizontalSpace,
                              Flexible(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    formatMarketplaceNaira(widget.item.amount),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: context.theme.textTheme.labelMedium
                                        ?.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: context.theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (marketplaceSellerValue(widget.item) != null) ...[
                            4.verticalSpace,
                            Text(
                              'Seller: ${marketplaceSellerValue(widget.item)!}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  context.theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (marketplaceLocationValue(widget.item) !=
                              null) ...[
                            2.verticalSpace,
                            Text(
                              marketplaceLocationValue(widget.item)!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  context.theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                color: const Color(0xFF737380),
                              ),
                            ),
                          ],
                        ],
                      ),
                      15.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (reviewCount != null) ...[
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC8305),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$reviewCount',
                                style: context.theme.textTheme.labelSmall
                                    ?.copyWith(
                                  fontSize: 9.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            6.horizontalSpace,
                          ],
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 30.h,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: context.theme.primaryColor,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'ADD TO CART',
                                style: context.theme.textTheme.labelSmall
                                    ?.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
