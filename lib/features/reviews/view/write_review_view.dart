import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/reviews/view/widgets/star_rating_input.dart';
import 'package:tivi_tea/features/reviews/view_model/reviews_notifier.dart';

/// What is being reviewed. All three take the same rating/note body but post
/// to different endpoints.
enum ReviewSubject { booking, artisan, marketplaceItem }

/// Arguments for [WriteReviewView], passed via `state.extra`.
class WriteReviewArgs {
  const WriteReviewArgs({
    required this.subject,
    required this.targetId,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.imageUrl,
  });

  final ReviewSubject subject;

  /// Booking id for booking/artisan reviews; item id for marketplace.
  final String targetId;
  final String title;
  final String? subtitle;

  /// The room or package name shown to the right of the title in the design.
  final String? trailingLabel;
  final String? imageUrl;
}

/// The "Reviews" screen: hero image, subject, star selector, free-text note.
class WriteReviewView extends ConsumerStatefulWidget {
  const WriteReviewView({super.key, required this.args});

  final WriteReviewArgs args;

  @override
  ConsumerState<WriteReviewView> createState() => _WriteReviewViewState();
}

class _WriteReviewViewState extends ConsumerState<WriteReviewView> {
  final _noteController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isBusy = ref.watch(
          reviewsNotifierProvider.select((value) => value.submitState),
        ) ==
        LoadState.loading;

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Reviews',
        showHamburgerMenu: true,
        showBackButtonForHomeScreenAppBar: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((args.imageUrl ?? '').isNotEmpty)
              SizedBox(
                height: 200.h,
                width: double.infinity,
                child: AppImageWidget(
                  imagePath: args.imageUrl!,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            16.verticalSpace,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        args.title,
                        style: context.theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18.sp,
                          color: context.theme.primaryColor,
                        ),
                      ),
                      if ((args.subtitle ?? '').isNotEmpty)
                        Text(
                          args.subtitle!,
                          style: context.theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if ((args.trailingLabel ?? '').isNotEmpty) ...[
                  Icon(Icons.arrow_forward, size: 18.sp),
                  8.horizontalSpace,
                  Flexible(
                    child: Text(
                      args.trailingLabel!,
                      style: context.theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
            30.verticalSpace,
            Center(
              child: Text(
                'Your overall rating of this product',
                style: context.theme.textTheme.bodySmall,
              ),
            ),
            12.verticalSpace,
            StarRatingInput(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            24.verticalSpace,
            Text(
              'Add detailed review',
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.primaryColor,
              ),
            ),
            10.verticalSpace,
            TextField(
              controller: _noteController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Type Here',
                filled: true,
                fillColor: const Color(0xFFF1F1F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            24.verticalSpace,
            AppButton(
              buttonText: 'Submit',
              isLoading: isBusy,
              onPressed: isBusy ? null : _submit,
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_rating < 1) {
      context.showError('Please select a rating.');
      return;
    }
    final notifier = ref.read(reviewsNotifierProvider.notifier);
    final note = _noteController.text.trim();

    void onSuccess(String message) {
      if (!mounted) return;
      context.showSuccess(message);
      if (context.canPop()) context.pop(true);
    }

    void onError(String message) {
      if (mounted) context.showError(message);
    }

    switch (widget.args.subject) {
      case ReviewSubject.booking:
        notifier.reviewBooking(
          bookingId: widget.args.targetId,
          rating: _rating,
          note: note,
          onSuccess: onSuccess,
          onError: onError,
        );
      case ReviewSubject.artisan:
        notifier.reviewArtisan(
          bookingId: widget.args.targetId,
          rating: _rating,
          note: note,
          onSuccess: onSuccess,
          onError: onError,
        );
      case ReviewSubject.marketplaceItem:
        notifier.reviewMarketplaceItem(
          itemId: widget.args.targetId,
          rating: _rating,
          note: note,
          onSuccess: onSuccess,
          onError: onError,
        );
    }
  }
}
