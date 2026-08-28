import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_paginator_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/models/paginator_selector_model.dart';
import 'package:tivi_tea/features/services/view/widgets/kyc_guard.dart';
import 'package:tivi_tea/features/history/model/booking_history_model.dart';
import 'package:tivi_tea/features/home/view/service_provider/service_provider_dashboard.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/services/view_model/booking_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(bookingNotiferProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.getBookingHistory(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final entityType = user.signedInEntityType ?? EntityType.client;

    final state = ref.watch(bookingNotiferProvider);
    final bookingHistoryList = state.bookingHistoryList;
    final isLoadingHistory = state.bookingHistoryLoadstate == LoadState.loading;

    const createListingPath =
        '${AppRoutes.myListingView}/${AppRoutes.createListingView}';

    return AppScaffold(
      appbar: CustomAppBar(
        title: context.l10n.bookingHistory,
        showHamburgerMenu: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (entityType == EntityType.partner)
                    CreateListingButton(
                      text: context.l10n.createListing,
                      onTap: () => guardWithKyc(
                        context,
                        ref,
                        onAllowed: () => context.push(createListingPath),
                      ),
                    ),
                  if (entityType == EntityType.partner) 30.verticalSpace,
                ],
              ),
            ),
            20.verticalSpace,
            (isLoadingHistory)
                ? const CupertinoActivityIndicator()
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD8D8DD),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _currentPage = 1;
                        final notifier =
                            ref.read(bookingNotiferProvider.notifier);
                        notifier.getBookingHistory(page: _currentPage);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        child: Table(
                          columnWidths: const {0: FlexColumnWidth(2)},
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE1E1E6),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 5,
                                  ),
                                  child: Text(context.l10n.customer),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(context.l10n.status),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(context.l10n.price),
                                ),
                              ],
                            ),
                            for (var i = 0; i < bookingHistoryList.length; i++)
                              TableRow(
                                children: _buildRow(bookingHistoryList[i]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
            10.verticalSpace,
            AppPaginatorWidget(
              paginatorSelectorModel: PaginatorSelectorModel(
                currentPage: _currentPage,
                totalPages: state.paginatorSelectorModel?.totalPages ?? 1,
                totalItems: state.paginatorSelectorModel?.totalItems ?? 0,
                itemsPerPage: state.paginatorSelectorModel?.itemsPerPage ?? 10,
              ),
              onPageChanged: _onPageChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    setState(() {});
    final notifier = ref.read(bookingNotiferProvider.notifier);
    notifier.getBookingHistory(page: page);
  }

  List<Widget> _buildRow(BookingHistoryModel booking) {
    const bookingHistoryDetail =
        '${AppRoutes.homeView}${AppRoutes.bookingHistoryDetails}';

    /// Every cell opens the same booking — tapping the status or the price
    /// should work just as well as tapping the customer. `opaque` so the
    /// empty space around a short label stays tappable too.
    Widget cell(Widget child) => TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.push(bookingHistoryDetail, extra: booking.id ?? ''),
            child: child,
          ),
        );

    return [
      cell(
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.h,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
                child: AppImageWidget(
                  borderRadius: BorderRadius.circular(50),
                  imagePath: booking.client?.user?.profilePicture ?? '',
                ),
              ),
              5.horizontalSpace,
              Text(
                '${booking.client?.user?.firstName ?? ''} ${booking.client?.user?.lastName ?? ''}',
              ),
            ],
          ),
        ),
      ),
      cell(Text(booking.status ?? '')),
      cell(booking.amount.getCurrencyText()),
    ];
  }
}
