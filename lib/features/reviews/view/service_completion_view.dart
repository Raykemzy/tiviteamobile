import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/reviews/view/write_review_view.dart';
import 'package:tivi_tea/features/reviews/view_model/reviews_notifier.dart';

/// Arguments for [ServiceCompletionView], passed via `state.extra`.
class ServiceCompletionArgs {
  const ServiceCompletionArgs({
    required this.bookingId,
    required this.name,
    this.serviceType,
    this.arrivalTime,
    this.exitTime,
    this.date,
    this.totalPayment,
    this.reviewSubject = ReviewSubject.booking,
  });

  final String bookingId;
  final String name;
  final String? serviceType;
  final String? arrivalTime;
  final String? exitTime;
  final String? date;
  final String? totalPayment;

  /// Whether the follow-up review targets the artisan or the listing.
  final ReviewSubject reviewSubject;
}

/// "Service Completion Confirmation" — the client releases a completed
/// booking, then is offered the review step.
///
/// This closes the loop Ayo asked about repeatedly: `POST
/// /bookings/service-confirmation/{id}` existed on the backend but was never
/// called from the app.
class ServiceCompletionView extends ConsumerWidget {
  const ServiceCompletionView({super.key, required this.args});

  final ServiceCompletionArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(
          reviewsNotifierProvider.select((value) => value.submitState),
        ) ==
        LoadState.loading;

    return AppScaffold(
      appbar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: Container(
          padding: EdgeInsets.only(top: 40.h, left: 18.w, right: 18.w),
          decoration: BoxDecoration(color: context.theme.primaryColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.canPop() ? context.pop() : null,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Completion Confirmation',
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 17.sp,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      'Kindly confirm the completion of your service!',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 80.sp,
              color: const Color(0xFF1E7A1E),
            ),
            30.verticalSpace,
            _DetailRow(
              leftLabel: 'Name',
              leftValue: args.name,
              rightLabel: 'Service',
              rightValue: args.serviceType ?? '—',
            ),
            _DetailRow(
              leftLabel: 'Arrival Time',
              leftValue: args.arrivalTime ?? '—',
              rightLabel: 'Exit Time',
              rightValue: args.exitTime ?? '—',
            ),
            _DetailRow(
              leftLabel: 'Date',
              leftValue: args.date ?? '—',
              rightLabel: 'Total Payment',
              rightValue: args.totalPayment ?? '—',
            ),
            40.verticalSpace,
            AppButton(
              buttonText: 'CONFIRM SERVICE COMPLETION',
              isLoading: isBusy,
              onPressed: isBusy ? null : () => _confirm(context, ref),
            ),
            12.verticalSpace,
            AppButton(
              buttonText: 'REPORT AN ISSUE',
              backgroundColor: Colors.white,
              textColor: context.theme.primaryColor,
              borderColor: context.theme.primaryColor,
              onPressed: () => context.push(
                '${AppRoutes.profile}/${AppRoutes.contactUsView}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context, WidgetRef ref) {
    ref.read(reviewsNotifierProvider.notifier).confirmServiceCompletion(
          bookingId: args.bookingId,
          onSuccess: (message) {
            if (!context.mounted) return;
            context.showSuccess(message);
            // Confirming is what unlocks reviewing, so offer it immediately.
            context.pushReplacement(
              AppRoutes.writeReviewView,
              extra: WriteReviewArgs(
                subject: args.reviewSubject,
                targetId: args.bookingId,
                title: args.name,
                subtitle: args.serviceType,
              ),
            );
          },
          onError: (message) {
            if (context.mounted) context.showError(message);
          },
        );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style: context.theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 14.sp),
                ),
                6.verticalSpace,
                Text(leftValue, style: context.theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rightLabel,
                  style: context.theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 14.sp),
                ),
                6.verticalSpace,
                Text(rightValue, style: context.theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
