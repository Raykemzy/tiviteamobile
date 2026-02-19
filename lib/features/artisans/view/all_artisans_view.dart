import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/config/extensions/string_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/artisans/view_model/artisans_notifier.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/search_text_field.dart';
import 'package:tivi_tea/features/onboarding/view/widgets/slide_indicator.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_appbar.dart';

class AllArtisansView extends ConsumerStatefulWidget {
  const AllArtisansView({super.key});

  @override
  ConsumerState<AllArtisansView> createState() => _AllArtisansViewState();
}

class _AllArtisansViewState extends ConsumerState<AllArtisansView> {
  static const int _defaultItemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(artisansNotifierProvider.notifier).getArtisansList();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(artisansNotifierProvider);
    final searchTerm = _searchController.text.trim().toLowerCase();
    final filteredArtisans = state.artisans.where((artisan) {
      if (searchTerm.isEmpty) return true;

      final firstName = artisan.user?.firstName?.toLowerCase() ?? '';
      final lastName = artisan.user?.lastName?.toLowerCase() ?? '';
      final serviceType = artisan.serviceTypeSummary?.toLowerCase() ?? '';
      final city = artisan.address?.city?.toLowerCase() ?? '';
      final stateName = artisan.address?.state?.toLowerCase() ?? '';

      return firstName.contains(searchTerm) ||
          lastName.contains(searchTerm) ||
          '$firstName $lastName'.trim().contains(searchTerm) ||
          serviceType.contains(searchTerm) ||
          city.contains(searchTerm) ||
          stateName.contains(searchTerm);
    }).toList();

    final totalResults =
        state.totalItems > 0 ? state.totalItems : state.artisans.length;
    final hasSearch = searchTerm.isNotEmpty;

    int start = 0;
    int end = 0;

    if (filteredArtisans.isNotEmpty) {
      start = hasSearch
          ? 1
          : ((math.max(state.currentPage, 1) - 1) * _defaultItemsPerPage) + 1;
      end = hasSearch
          ? filteredArtisans.length
          : start + filteredArtisans.length - 1;
      if (totalResults > 0) {
        end = math.min(end, totalResults);
      }
    }

    final isInitialLoading =
        state.loadState == LoadState.loading && state.artisans.isEmpty;

    return AppScaffold(
      appbar: const RegistrationAppBar(
        headerSectionTitle: 'All Artisans',
        headerSectionSubtitle:
            'Find all artisans available for your engagement',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: context.width,
                child: SearchTextField(
                  hintText: 'Search artisans',
                  controller: _searchController,
                  padding: SizedBox(height: 14.h),
                ),
              ),
              10.verticalSpace,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing $start - $end out of $totalResults Results',
                  style: context.theme.textTheme.labelMedium,
                ),
              ),
              12.verticalSpace,
              Builder(
                builder: (context) {
                  if (isInitialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.loadState == LoadState.error &&
                      state.artisans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Failed to load artisans'),
                          12.verticalSpace,
                          ElevatedButton(
                            onPressed: () => _onRetry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredArtisans.isEmpty) {
                    return const Center(child: Text('No artisans found'));
                  }

                  return GridView.builder(
                    itemCount: filteredArtisans.length,
                    padding: EdgeInsets.only(bottom: 16.h),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.64,
                    ),
                    itemBuilder: (context, index) {
                      final artisan = filteredArtisans[index];
                      return InkWell(
                        onTap: () => context.push(
                          '${AppRoutes.servicesView}/${AppRoutes.artisanDetailsView}',
                          extra: artisan,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        child: _ArtisanListingCard(artisan: artisan),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRetry() {
    final notifier = ref.read(artisansNotifierProvider.notifier);
    notifier.getArtisansList();
  }
}

class _ArtisanListingCard extends StatefulWidget {
  const _ArtisanListingCard({required this.artisan});

  final ArtisanResponseModel artisan;

  @override
  State<_ArtisanListingCard> createState() => _ArtisanListingCardState();
}

class _ArtisanListingCardState extends State<_ArtisanListingCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.artisan.galleryImages ?? const <String>[];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140.h,
            margin: EdgeInsets.only(bottom: 7.h),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
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
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return AppImageWidget(imagePath: images[index]);
                            },
                          ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Visibility(
                    visible: images.length > 1,
                    child: SlideIndicatorWidget(
                      slideLength: images.length,
                      currentIndex: _currentImageIndex,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5.w,
                  children: [
                    Flexible(
                      child: Text(
                        _fullName(widget.artisan),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    if (widget.artisan.kycIsVerified ?? false)
                      Icon(
                        Icons.verified_rounded,
                        size: 16.sp,
                        color: const Color(0xFF006400),
                      ),
                  ],
                ),
                4.verticalSpace,
                Text(
                  widget.artisan.serviceType?.capiTalizeFirst ?? 'Artisan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.textTheme.labelLarge,
                ),
                4.verticalSpace,
                Text(
                  _location(widget.artisan),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF737380),
                  ),
                ),
                8.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC8305),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          2.horizontalSpace,
                          Text(
                            (widget.artisan.rating ?? 0).toString(),
                            style:
                                context.theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${widget.artisan.reviewsCount?.toString()} ${widget.artisan.reviewsCount == 1 ? 'review' : 'reviews'}",
                      style: context.theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF737380),
                      ),
                    ),
                    // const Spacer(),
                    // AppButton(
                    //   buttonText: 'Hire Now',
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                8.verticalSpace,
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fullName(ArtisanResponseModel artisan) {
    final firstName = artisan.user?.firstName?.trim() ?? '';
    final lastName = artisan.user?.lastName?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : 'Unknown Artisan';
  }

  String _location(ArtisanResponseModel artisan) {
    final city = artisan.address?.city?.trim();
    final state = artisan.address?.state?.trim();

    if ((city ?? '').isNotEmpty && (state ?? '').isNotEmpty) {
      return '$city, $state';
    }

    if ((city ?? '').isNotEmpty) {
      return city!;
    }

    if ((state ?? '').isNotEmpty) {
      return state!;
    }

    return 'Location unavailable';
  }
}
