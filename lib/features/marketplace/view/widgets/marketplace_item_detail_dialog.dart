import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_text.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';

class MarketplaceItemDetailDialog extends ConsumerStatefulWidget {
  const MarketplaceItemDetailDialog({super.key, required this.item});

  final ListingResponseModel item;

  static Future<void> show(BuildContext context, ListingResponseModel item) {
    return context.showCustomDialog<void>(
      dismissible: true,
      horizontalPadding: 18,
      verticalPadding: 24,
      child: MarketplaceItemDetailDialog(item: item),
    );
  }

  @override
  ConsumerState<MarketplaceItemDetailDialog> createState() =>
      _MarketplaceItemDetailDialogState();
}

class _MarketplaceItemDetailDialogState
    extends ConsumerState<MarketplaceItemDetailDialog> {
  late int _selectedIndex;
  late final ScrollController _thumbScrollController;
  static const int _visibleThumbs = 3;

  bool _isAddingToCart = false;
  bool _isBuyingNow = false;

  /// Adds the item to the cart, returning true on success.
  /// [busy] toggles the matching button's loading spinner.
  Future<bool> _addToCart(void Function(bool) setBusy) async {
    setBusy(true);
    final ok = await ref.read(marketplaceCartProvider.notifier).addItem(
          widget.item,
          onError: (m) {
            if (mounted) context.showError(m);
          },
        );
    if (mounted) setBusy(false);
    return ok;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _thumbScrollController = ScrollController();
  }

  @override
  void dispose() {
    _thumbScrollController.dispose();
    super.dispose();
  }

  double get _thumbSlot => 56.w + 8.w;

  void _scrollThumbs(double delta) {
    if (!_thumbScrollController.hasClients) return;
    final maxExtent = _thumbScrollController.position.maxScrollExtent;
    final next = (_thumbScrollController.offset + delta).clamp(0.0, maxExtent);
    _thumbScrollController.animateTo(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _thumbnailStrip({
    required List<String> images,
    required List<int> thumbIndices,
    required Color primary,
    required bool showChevrons,
    required double viewportWidth,
  }) {
    final list = ListView.separated(
      controller: _thumbScrollController,
      scrollDirection: Axis.horizontal,
      itemCount: thumbIndices.length,
      separatorBuilder: (_, __) => SizedBox(width: 8.w),
      itemBuilder: (context, i) {
        final imageIndex = thumbIndices[i];
        final selected = imageIndex == _selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = imageIndex),
          child: Container(
            width: 56.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                width: selected ? 2 : 1,
                color: selected ? primary : Colors.grey.shade300,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppImageWidget(imagePath: images[imageIndex]),
          ),
        );
      },
    );
    if (showChevrons) {
      return SizedBox(width: viewportWidth, height: 56.h, child: list);
    }
    return Expanded(child: SizedBox(height: 56.h, child: list));
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item.images ?? const <String>[];
    final reviewCount = marketplaceVisibleReviewCount(widget.item);
    final seller = marketplaceSellerValue(widget.item);
    final location = marketplaceLocationValue(widget.item);
    final theme = context.theme;
    final primary = theme.primaryColor;

    // Thumbnails = all images except the first (per spec); hero can still show any index.
    final thumbIndices = images.length > 1
        ? List<int>.generate(images.length - 1, (i) => i + 1)
        : <int>[];
    final thumbCount = thumbIndices.length;
    final showChevrons = thumbCount > _visibleThumbs;
    final viewportWidth = _thumbSlot * _visibleThumbs - 8.w;

    const surfaceWhite = Colors.white;
    const onSurfaceDark = Color(0xFF2E2E3A);
    final dialogTheme = theme.copyWith(
      scaffoldBackgroundColor: surfaceWhite,
      canvasColor: surfaceWhite,
      cardColor: surfaceWhite,
      dialogTheme: theme.dialogTheme.copyWith(backgroundColor: surfaceWhite),
      iconTheme: theme.iconTheme.copyWith(color: onSurfaceDark),
      textTheme: theme.textTheme.apply(
        bodyColor: onSurfaceDark,
        displayColor: onSurfaceDark,
      ),
      colorScheme: theme.colorScheme.copyWith(
        surface: surfaceWhite,
        onSurface: onSurfaceDark,
      ),
    );

    return Theme(
      data: dialogTheme,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (images.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: AppImageWidget(imagePath: images[_selectedIndex]),
                ),
              ),
              if (thumbCount > 0) ...[
                12.verticalSpace,
                Row(
                  children: [
                    if (showChevrons)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () =>
                            _scrollThumbs(-_thumbSlot * _visibleThumbs),
                        icon: const Icon(Icons.chevron_left),
                      ),
                    _thumbnailStrip(
                      images: images,
                      thumbIndices: thumbIndices,
                      primary: primary,
                      showChevrons: showChevrons,
                      viewportWidth: viewportWidth,
                    ),
                    if (showChevrons)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () =>
                            _scrollThumbs(_thumbSlot * _visibleThumbs),
                        icon: const Icon(Icons.chevron_right),
                      ),
                  ],
                ),
              ],
            ],
            16.verticalSpace,
            Text(
              widget.item.name ?? 'Untitled',
              style: dialogTheme.textTheme.titleMedium?.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: onSurfaceDark,
              ),
            ),
            if (seller != null) ...[
              8.verticalSpace,
              Text.rich(
                TextSpan(
                  style: dialogTheme.textTheme.labelSmall
                      ?.copyWith(fontSize: 12.sp),
                  children: [
                    TextSpan(
                      text: 'Seller: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: seller,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF737380),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (location != null) ...[
              6.verticalSpace,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Location: ',
                      style: dialogTheme.textTheme.labelSmall?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: location,
                      style: dialogTheme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.sp,
                        color: const Color(0xFF737380),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            12.verticalSpace,
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
                      style: dialogTheme.textTheme.labelSmall?.copyWith(
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  10.horizontalSpace,
                ],
                Flexible(
                  child: Text(
                    formatMarketplaceNaira(widget.item.amount),
                    textAlign: TextAlign.end,
                    style: dialogTheme.textTheme.labelMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
            20.verticalSpace,
            AppButton(
              expandWidth: true,
              backgroundColor: Colors.white,
              borderColor: primary,
              textColor: primary,
              buttonText: 'ADD TO CART',
              isLoading: _isAddingToCart,
              isEnabled: !_isBuyingNow,
              onPressed: () async {
                final ok = await _addToCart(
                  (busy) => setState(() => _isAddingToCart = busy),
                );
                if (ok && context.mounted) Navigator.of(context).pop();
              },
              textStyle: dialogTheme.textTheme.labelSmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            10.verticalSpace,
            AppButton(
              expandWidth: true,
              buttonText: 'BUY NOW',
              isLoading: _isBuyingNow,
              isEnabled: !_isAddingToCart,
              onPressed: () async {
                final ok = await _addToCart(
                  (busy) => setState(() => _isBuyingNow = busy),
                );
                if (!context.mounted) return;
                if (ok) {
                  Navigator.of(context).pop();
                  context.push(
                    '${AppRoutes.servicesView}/${AppRoutes.myCartView}',
                  );
                }
              },
              textStyle: dialogTheme.textTheme.labelSmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
