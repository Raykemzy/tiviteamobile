import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/reviews/model/review_models.dart';
import 'package:tivi_tea/features/reviews/view/widgets/star_rating_input.dart';
import 'package:tivi_tea/features/reviews/view_model/reviews_notifier.dart';

/// Reviews customers have left on the signed-in partner's listings.
/// `GET /bookings/partner/booking-reviews`.
class PartnerReviewsView extends ConsumerStatefulWidget {
  const PartnerReviewsView({super.key});

  @override
  ConsumerState<PartnerReviewsView> createState() => _PartnerReviewsViewState();
}

class _PartnerReviewsViewState extends ConsumerState<PartnerReviewsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reviewsNotifierProvider.notifier).getPartnerBookingReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewsNotifierProvider);
    final reviews = state.bookingReviews;
    final notifier = ref.read(reviewsNotifierProvider.notifier);

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Customer Reviews',
        showHamburgerMenu: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.getPartnerBookingReviews(),
        child: Builder(
          builder: (context) {
            if (state.listState == LoadState.loading && reviews.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reviews.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  Center(
                    child: Text(
                      state.listState == LoadState.error
                          ? 'Could not load reviews.'
                          : 'No reviews yet.',
                      style: context.theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => 12.verticalSpace,
              itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final BookingReviewModel review;

  @override
  Widget build(BuildContext context) {
    final created = review.dateCreated;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.client?.displayName ?? 'Customer',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontSize: 14.sp,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
              StarRatingDisplay(rating: review.rating ?? 0),
            ],
          ),
          if ((review.listing?.name ?? '').isNotEmpty) ...[
            4.verticalSpace,
            Text(
              review.listing!.name!,
              style: context.theme.textTheme.bodySmall,
            ),
          ],
          if ((review.note ?? '').isNotEmpty) ...[
            10.verticalSpace,
            Text(review.note!, style: context.theme.textTheme.bodyMedium),
          ],
          if (created != null) ...[
            8.verticalSpace,
            Text(
              '${created.day}/${created.month}/${created.year}',
              style: context.theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
