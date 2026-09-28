import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/view/widgets/quotation_bubble.dart';
import 'package:tivi_tea/features/artisans/view_model/quotations_list_notifier.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';

/// Every quotation the signed-in client or artisan is party to. Tapping one
/// opens the negotiation.
class QuotationsView extends ConsumerStatefulWidget {
  const QuotationsView({super.key});

  @override
  ConsumerState<QuotationsView> createState() => _QuotationsViewState();
}

class _QuotationsViewState extends ConsumerState<QuotationsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(quotationsListNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(quotationsListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quotationsListNotifierProvider);
    final isArtisan =
        ref.watch(userNotifierProvider).signedInEntityType == EntityType.artisan;
    final notifier = ref.read(quotationsListNotifierProvider.notifier);

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Quotations',
        showHamburgerMenu: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: switch (state.loadState) {
            LoadState.loading when state.quotations.isEmpty =>
              const Center(child: CupertinoActivityIndicator()),
            LoadState.error when state.quotations.isEmpty => _Message(
                text: state.errorMessage ?? 'Could not load quotations.',
                actionLabel: 'Retry',
                onAction: notifier.refresh,
              ),
            _ when state.quotations.isEmpty &&
                    state.loadState != LoadState.idle =>
              _Message(
                text: isArtisan
                    ? 'No quotation requests yet. When a client asks you for a quote it will show up here.'
                    : 'No quotations yet. Request one from an artisan\'s profile.',
              ),
            _ => ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount:
                    state.quotations.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => 10.verticalSpace,
                itemBuilder: (context, index) {
                  if (index >= state.quotations.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }
                  final quotation = state.quotations[index];
                  return _QuotationCard(
                    quotation: quotation,
                    viewerIsArtisan: isArtisan,
                    onTap: () async {
                      await context.push(
                        '${AppRoutes.servicesView}/${AppRoutes.bargainQuotationView}',
                        extra: quotation,
                      );
                      // Statuses change while negotiating; reflect that on
                      // return without a manual pull.
                      notifier.refresh();
                    },
                  );
                },
              ),
          },
        ),
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.viewerIsArtisan,
    required this.onTap,
  });

  final QuotationModel quotation;
  final bool viewerIsArtisan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Show the other side of the negotiation.
    final other = viewerIsArtisan ? quotation.client : quotation.artisan;
    final name = other?.displayName ?? '';
    final subtitle = viewerIsArtisan ? 'Client' : (quotation.artisan?.serviceType ?? 'Artisan');
    final price = quotation.currentQuote;
    final hasQuote = quotation.hasArtisanQuote;
    final date = quotation.dateCreated;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: QuotationColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: QuotationColors.avatar,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppImageWidget(
                    imagePath: other?.user?.profilePicture ?? '',
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? (viewerIsArtisan ? 'Client' : 'Artisan') : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: QuotationColors.bubbleText,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          color: QuotationColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: quotation.status ?? ''),
              ],
            ),
            if ((quotation.clientNote ?? '').isNotEmpty) ...[
              10.verticalSpace,
              Text(
                quotation.clientNote!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: QuotationColors.bubbleText,
                ),
              ),
            ],
            10.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasQuote
                        ? 'Current quote: ₦${QuotationBubble.money(price)}'
                        : 'Awaiting artisan\'s quote',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: QuotationColors.primary,
                    ),
                  ),
                ),
                if (date != null)
                  Text(
                    QuotationBubble.dateOf(date),
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp,
                      color: QuotationColors.label,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final (label, color) = switch (lower) {
      'accepted' => ('Accepted', const Color(0xFF1B8A4C)),
      'declined' => ('Declined', const Color(0xFFB3261E)),
      _ => ('Open', QuotationColors.primary),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: context.theme.textTheme.bodySmall?.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    // Inside a RefreshIndicator the body must scroll for pull-to-refresh.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 0.25.sh),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: QuotationColors.muted,
            ),
          ),
        ),
        if (actionLabel != null) ...[
          12.verticalSpace,
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
        ],
      ],
    );
  }
}
