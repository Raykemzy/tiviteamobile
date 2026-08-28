import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/home/view/service_provider/service_provider_dashboard.dart';
import 'package:tivi_tea/features/home/view/widgets/booking_summary.dart';
import 'package:tivi_tea/features/home/view/widgets/dashboard_grid.dart';
import 'package:tivi_tea/features/home/view/widgets/financial_summary.dart';
import 'package:tivi_tea/features/home/view/widgets/welcome_back_text.dart';
import 'package:tivi_tea/features/home/view_model/dashboard_notifier.dart';

/// Artisan-facing dashboard.
///
/// Artisans previously landed on [ServiceProviderDashboard], which surfaces
/// listing counts and a "Create Listing" action they have no permission to
/// use — every tap ended in "unauthorized user". This screen reads
/// `GET /dashboard/artisan` and offers gallery management instead.
class ArtisanDashboard extends ConsumerStatefulWidget {
  const ArtisanDashboard({super.key});

  @override
  ConsumerState<ArtisanDashboard> createState() => _ArtisanDashboardState();
}

class _ArtisanDashboardState extends ConsumerState<ArtisanDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(dashboardNotiferProvider.notifier).getArtisanDashboardDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    const galleryPath = '${AppRoutes.profile}/${AppRoutes.artisanGalleryView}';
    final dashboard = ref.watch(
      dashboardNotiferProvider.select((value) => value.artisanDashboardModel),
    );

    return AppScaffold(
      appbar: const CustomAppBar(showHamburgerMenu: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeBackText(dashboard: true),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CreateListingButton(
                    text: 'Add to Gallery',
                    onTap: () => context.go(galleryPath),
                  ),
                  30.verticalSpace,
                ],
              ),
            ),
            20.verticalSpace,
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.w,
                runSpacing: 15.h,
                children: [
                  DashboardInfoContainer(
                    title: 'Total Jobs',
                    value: '${dashboard?.totalJobs ?? 0}',
                    bookingContainerColor: const Color(0xFF2196F3),
                    onViewAll: () => context.go(
                      '${AppRoutes.profile}/${AppRoutes.jobHistoryView}',
                    ),
                  ),
                  DashboardInfoContainer(
                    title: 'Total Earnings',
                    value: dashboard?.totalEarnings ?? '0',
                    bookingContainerColor: const Color(0xFF02952B),
                    onViewAll: () => context.go(
                      '${AppRoutes.profile}/${AppRoutes.paymentView}',
                    ),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            const BookingSummarySection(),
            20.verticalSpace,
            const FinancialSummary(),
          ],
        ),
      ),
    );
  }
}
