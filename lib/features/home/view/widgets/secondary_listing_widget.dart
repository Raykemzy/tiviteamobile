import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/favorites/model/favorite_listing_model.dart';
import 'package:tivi_tea/features/favorites/view_model/favorite_listing_notifier.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/services/model/enums.dart';
import 'package:tivi_tea/features/services/view_model/services_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class SecondaryListingView extends ConsumerStatefulWidget {
  const SecondaryListingView({
    super.key,
    this.selectedCategoryId,
  });

  final String? selectedCategoryId;

  @override
  ConsumerState<SecondaryListingView> createState() =>
      _SecondaryListingViewState();
}

class _SecondaryListingViewState extends ConsumerState<SecondaryListingView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 200) {
      _maybeLoadMore();
    }
  }

  void _maybeLoadMore() {
    final state = ref.read(servicesNotiferProvider);
    if (state.listingLoadState == LoadState.loadmore ||
        state.listingLoadState == LoadState.loading ||
        state.listingLoadState == LoadState.done ||
        !state.hasMorePages) {
      return;
    }
    ref.read(servicesNotiferProvider.notifier).getListing(
          page: state.currentPage + 1,
          loadmore: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesNotiferProvider);
    final listings = state.listing;
    final listingLoadState = state.listingLoadState;
    final filteredListings = widget.selectedCategoryId == null
        ? listings
        : listings
            .where(
                (listing) => listing.category?.id == widget.selectedCategoryId)
            .toList();
    final notifier = ref.read(servicesNotiferProvider.notifier);
    final isInitialLoading =
        listingLoadState == LoadState.loading && listings.isEmpty;
    final showPaginationIndicator = listingLoadState == LoadState.loadmore;

    if (listingLoadState == LoadState.success && filteredListings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        if (_scrollController.position.extentAfter < 200) {
          _maybeLoadMore();
        }
      });
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await notifier.getListing();
        },
        child: Builder(
          builder: (context) {
            if (isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (listingLoadState == LoadState.error && listings.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 300.h,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ?? 'Failed to load listings',
                            style: context.theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          12.verticalSpace,
                          ElevatedButton(
                            onPressed: () => notifier.getListing(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            if (filteredListings.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 300.h,
                    child: Center(
                      child: Text(
                        'No listings found',
                        style: context.theme.textTheme.displaySmall,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  filteredListings.length + (showPaginationIndicator ? 1 : 0),
              separatorBuilder: (ctx, i) => 10.verticalSpace,
              itemBuilder: (ctx, i) {
                if (i == filteredListings.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return SecondaryListingWidget(
                  listing: filteredListings[i],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SecondaryListingWidget extends StatelessWidget {
  final ListingResponseModel listing;
  const SecondaryListingWidget({
    super.key,
    required this.listing,
  });

  final double containerHeight = 145;

  @override
  Widget build(BuildContext context) {
    final int remainingImageCount = (listing.images?.length ?? 0) - 1;
    final bool moreThanOneImage = (listing.images?.length ?? 0) > 1;
    return InkWell(
      onTap: () => context.go(
        '${AppRoutes.servicesView}/${AppRoutes.listingDetailsView}',
        extra: listing.id,
      ),
      child: Container(
        width: context.width,
        height: containerHeight.h,
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.5,
            color: const Color(0xFFD8D8DD),
          ),
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          children: [
            SizedBox(
              width: containerHeight.w,
              height: containerHeight.h,
              child: Stack(
                children: [
                  if (listing.images?.isNotEmpty ?? false)
                    Positioned.fill(
                      child: AppImageWidget(
                        imagePath: listing.images?.first ?? '',
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.sp),
                          bottomLeft: Radius.circular(8.sp),
                        ),
                      ),
                    ),
                  if (moreThanOneImage)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        margin: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.primaryColor,
                        ),
                        child: Text(
                          '${remainingImageCount.toString()}+',
                          style: context.theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Consumer(
                    builder: (contex, ref, _) {
                      final state = ref.watch(favoriteListingNotifierProvider);

                      //Would not be very performant as data size increases
                      final isFavorite = state.favorites.any(
                        (fav) => fav.id == listing.id,
                      );
                      return Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => _favoriteListing(ref),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            margin: EdgeInsets.all(10.sp),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF3EBEB),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _ImageDetails(listing: listing),
            )
          ],
        ),
      ),
    );
  }

  void _favoriteListing(WidgetRef ref) {
    final notifier = ref.read(
      favoriteListingNotifierProvider.notifier,
    );

    final data = FavoriteListingModel.fromListingModel(listing);

    notifier.toggleFavoriteStatus(data, onSuccess: () {
      ref.read(servicesNotiferProvider.notifier).getListing();
    });
  }
}

class _ImageDetails extends StatelessWidget {
  final ListingResponseModel listing;
  const _ImageDetails({required this.listing});

  @override
  Widget build(BuildContext context) {
    final listingType = listing.listingType?.enumType;
    final isListingTypeWorkSpace = listingType == CreateListingType.workSpace;
    final amount = isListingTypeWorkSpace
        ? listing.rooms?.first.amount
        : listing.amountPlusFootSoldierFee;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.name ?? '',
            style: context.theme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              color: context.theme.primaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          5.verticalSpace,
          Row(
            children: [
              AppSvgWidget(path: Assets.svgs.location.path),
              5.horizontalSpace,
              Expanded(
                child: Text(
                  listing.address ?? '',
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    fontSize: 9.8.sp,
                    color: const Color(0xFF737380),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.l10n.listedBy}:',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9.8.sp,
                        color: context.theme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    5.verticalSpace,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${listing.partner?.user?.firstName ?? ''} ${listing.partner?.user?.lastName ?? ''}',
                            style:
                                context.theme.textTheme.displaySmall?.copyWith(
                              fontSize: 9.8.sp,
                              color: const Color(0xFF77797D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (listing.partner?.user?.isVerified ?? false)
                          Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child:
                                AppSvgWidget(path: Assets.svgs.verified.path),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              8.horizontalSpace,
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: amount.getCurrencyText(
                    style: context.theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
