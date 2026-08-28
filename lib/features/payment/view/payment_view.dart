import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/home/view/client/client_dashboard.dart';
import 'package:tivi_tea/features/payment/view/widgets/payment_history_table.dart';
import 'package:tivi_tea/features/payment/view_model/partner/wallet_notifier.dart';

class PaymentView extends ConsumerStatefulWidget {
  const PaymentView({super.key});

  @override
  ConsumerState<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<PaymentView> {
  @override
  void initState() {
    super.initState();
    // The ledger was never fetched, so this screen showed an empty table
    // regardless of account activity.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(walletNotifierProvider.notifier).getWalletTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bookingHistory =
        '${AppRoutes.homeView}${AppRoutes.bookingHistoryView}';
    return AppScaffold(
      appbar: const CustomAppBar(title: 'Payment', showHamburgerMenu: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          children: [
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CreateListingButton(
                  text: 'Order History',
                  onTap: () => context.go(bookingHistory),
                  showIcon: false,
                  hasWhiteBackground: true,
                ),
              ],
            ),
            10.verticalSpace,
            const PaymentHistoryTable(),
          ],
        ),
      ),
    );
  }
}
