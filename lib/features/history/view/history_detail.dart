import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/config/extensions/date_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/history/model/booking_history_model.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/reviews/view/service_completion_view.dart';
import 'package:tivi_tea/features/reviews/view/write_review_view.dart';
import 'package:tivi_tea/features/services/view_model/booking_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';

class HistoryDetailView extends ConsumerStatefulWidget {
  final String bookingId;
  const HistoryDetailView({super.key, required this.bookingId});

  @override
  ConsumerState<HistoryDetailView> createState() => _HistoryDetailViewState();
}

class _HistoryDetailViewState extends ConsumerState<HistoryDetailView> {
  BookingHistoryModel? _booking;
  File? _eTicket;
  bool _recieptLoading = true;
  bool _isError = false;
  bool isCurrentTimeWithinCheckInPeriod = false;
  final ScreenshotController _screenController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entityType = ref.read(userNotifierProvider).signedInEntityType ??
          EntityType.client;
      getBookingDetails();

      if (entityType == EntityType.client) {
        generateTicket();
      }
    });
  }

  void getBookingDetails() {
    final notifier = ref.read(bookingNotiferProvider.notifier);
    notifier.getSingleBookingDetails(widget.bookingId, onSuccess: (booking) {
      _booking = booking;
      isCurrentTimeWithinCheckInPeriod = booking.pickUpDate
              ?.isCurrentTimeWithinCheckInPeriod(
                  checkOutDate: booking.returnDate ?? DateTime.now()) ??
          false;
      setState(() {});
    });
  }

  void generateTicket() {
    _recieptLoading = true;
    setState(() {});
    final notifier = ref.read(bookingNotiferProvider.notifier);
    notifier.generateBookingTicket(widget.bookingId, onSuccess: (data) {
      setState(() {
        _eTicket = data;
        _isError = false;
        _recieptLoading = false;
      });
    }, onError: (message) {
      setState(() {
        _isError = true;
        _recieptLoading = false;
      });
      context.showError('An error occurred while e-Ticket');
    });
  }

  /// Completed bookings are the only ones that can be confirmed or reviewed.
  bool get _isCompleted =>
      (_booking?.status ?? '').toLowerCase() == 'completed';

  @override
  Widget build(BuildContext context) {
    final entityType = ref.watch(userNotifierProvider).signedInEntityType ??
        EntityType.client;
    return AppScaffold(
      appbar: CustomAppBar(
        title: context.l10n.bookingHistoryView,
        onTap: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => getBookingDetails(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.symmetric(horizontal: 15) +
                  const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD8D8DD),
                ),
              ),
              child: SingleChildScrollView(
                child: (_booking == null)
                    ? const Center(child: CupertinoActivityIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow(
                            context,
                            title: context.l10n.customer,
                            value:
                                '${_booking?.client?.user?.firstName ?? ''} ${_booking?.client?.user?.lastName ?? ''}',
                          ),
                          20.verticalSpace,
                          _buildRow(
                            context,
                            title: context.l10n.status,
                            value: _booking?.status ?? '',
                          ),
                          20.verticalSpace,
                          _buildRow(
                            context,
                            title: 'Service',
                            value: _booking?.listing?.listingType ?? '',
                          ),
                          20.verticalSpace,
                          _buildRow(
                            context,
                            title: 'Amount',
                            value: (_booking?.amount ?? 0).formatAmount,
                          ),
                          if (entityType == EntityType.partner) ...[
                            50.verticalSpace,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: AppButton(
                                backgroundColor: Colors.white,
                                borderColor: context.theme.primaryColor,
                                textColor: context.theme.primaryColor,
                                buttonText: 'Scan QR Code',
                                onPressed: () => context.push(
                                  '${AppRoutes.homeView}${AppRoutes.scanQRCodeView}',
                                  extra: _booking?.id,
                                ),
                              ),
                            ),
                          ] else ...[
                            50.verticalSpace,
                            // Once the job is done the client confirms it,
                            // which is also what unlocks leaving a review.
                            if (_isCompleted) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: AppButton(
                                  buttonText: 'Confirm service completion',
                                  onPressed: () => context.push(
                                    AppRoutes.serviceCompletionView,
                                    extra: ServiceCompletionArgs(
                                      bookingId: widget.bookingId,
                                      name:
                                          _booking?.listing?.name ?? 'Booking',
                                      serviceType:
                                          _booking?.listing?.listingType,
                                      date: _booking?.pickUpDate == null
                                          ? null
                                          : '${_booking!.pickUpDate!.day}/'
                                              '${_booking!.pickUpDate!.month}/'
                                              '${_booking!.pickUpDate!.year}',
                                      totalPayment:
                                          (_booking?.amount ?? 0).formatAmount,
                                    ),
                                  ),
                                ),
                              ),
                              12.verticalSpace,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: AppButton(
                                  buttonText: 'Leave a review',
                                  backgroundColor: Colors.white,
                                  borderColor: context.theme.primaryColor,
                                  textColor: context.theme.primaryColor,
                                  onPressed: () => context.push(
                                    AppRoutes.writeReviewView,
                                    extra: WriteReviewArgs(
                                      subject: ReviewSubject.booking,
                                      targetId: widget.bookingId,
                                      title:
                                          _booking?.listing?.name ?? 'Booking',
                                      subtitle: _booking?.listing?.address,
                                      trailingLabel:
                                          _booking?.listing?.listingType,
                                      imageUrl:
                                          (_booking?.listing?.images ?? [])
                                                  .isEmpty
                                              ? null
                                              : _booking!.listing!.images!.first,
                                    ),
                                  ),
                                ),
                              ),
                              20.verticalSpace,
                            ],
                            if (isCurrentTimeWithinCheckInPeriod)
                              Consumer(builder: (context, ref, child) {
                                final checkInCheckOutLoadState = ref.watch(
                                  bookingNotiferProvider.select(
                                    (state) => state.checkInCheckOutLoadState,
                                  ),
                                );
                                return AppButton(
                                  buttonText: 'Check in manually',
                                  borderColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  textColor: context.theme.primaryColor,
                                  isLoading: checkInCheckOutLoadState ==
                                      LoadState.loading,
                                  onPressed: () =>
                                      _checkInCheckOut(widget.bookingId),
                                );
                              }),
                            if (_recieptLoading)
                              const Center(
                                child: CupertinoActivityIndicator(),
                              )
                            else
                              (_eTicket == null)
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: EdgeInsets.only(bottom: 20.h),
                                      child: Screenshot(
                                        controller: _screenController,
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: PDFView(
                                            filePath: _eTicket?.path ?? '',
                                            enableSwipe: true,
                                            swipeHorizontal: true,
                                            autoSpacing: false,
                                            pageFling: false,
                                            backgroundColor: Colors.grey,
                                            fitPolicy: FitPolicy.BOTH,
                                            onRender: (pages) {
                                              debugLog('Total Pages: $pages');
                                            },
                                            onError: (error) {
                                              debugLog(
                                                  'PDF Error: ${error.toString()}');
                                            },
                                            onPageError: (page, error) {
                                              debugLog(
                                                  'PDF Page Error: $page: ${error.toString()}');
                                            },
                                            onViewCreated: (PDFViewController
                                                pdfViewController) {
                                              debugLog('PDF View Created');
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                            if (_isError)
                              AppButton(
                                buttonText: 'Retry',
                                borderColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                textColor: context.theme.primaryColor,
                                onPressed: () => generateTicket(),
                              ),
                            if (_canCancel) ...[
                              20.verticalSpace,
                              Consumer(builder: (context, ref, child) {
                                final cancelLoadState = ref.watch(
                                  bookingNotiferProvider.select(
                                    (state) => state.cancelBookingLoadState,
                                  ),
                                );
                                return AppButton(
                                  buttonText: 'Cancel booking',
                                  backgroundColor: Colors.white,
                                  borderColor: Colors.red,
                                  textColor: Colors.red,
                                  isLoading:
                                      cancelLoadState == LoadState.loading,
                                  onPressed: _confirmCancel,
                                );
                              }),
                            ],
                          ]
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A booking can only be cancelled while it's still live — no point offering
  /// it on one that's already cancelled or finished.
  bool get _canCancel {
    final status = _booking?.status?.toLowerCase();
    if (status == null) return false;
    return status != 'cancelled' &&
        status != 'canceled' &&
        status != 'completed';
  }

  void _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Cancel booking?',
          style: context.theme.textTheme.titleMedium,
        ),
        content: Text(
          'This cancels your booking. It cannot be undone.',
          style: context.theme.textTheme.displaySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    ref.read(bookingNotiferProvider.notifier).cancelBooking(
      widget.bookingId,
      onSuccess: (message) {
        if (!mounted) return;
        context.showSuccess(message);
        // Back to the history list, which the notifier has already pruned.
        CustomAppBar.goBack(context);
      },
      onError: (message) {
        if (!mounted) return;
        context.showError(message);
      },
    );
  }

  void _checkInCheckOut(String bookingId) {
    final notifier = ref.read(bookingNotiferProvider.notifier);
    notifier.checkInCheckOut(
      bookingId,
      onSuccess: (message) => context.showSuccess(message),
      onError: (message) => context.showError(message),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final amount = double.tryParse(value);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.theme.textTheme.displaySmall),
        amount == null
            ? Text(
                value,
                style: context.theme.textTheme.displaySmall?.copyWith(
                  color: Colors.grey,
                ),
              )
            : amount.getCurrencyText(),
      ],
    );
  }
}
