import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/payment/model/payout_models.dart';
import 'package:tivi_tea/features/payment/view_model/partner/wallet_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

/// The wallet ledger — every credit and debit, from
/// `GET /payment/wallet-transactions`.
///
/// Replaces a stub that rendered a hardcoded empty list behind a "Customer"
/// column it had no data for.
///
/// Note: that endpoint currently answers 401 "Unauthorized User" for client,
/// partner *and* artisan tokens issued seconds earlier, so this renders its
/// empty state until the backend grants access. The request itself is correct.
class PaymentHistoryTable extends ConsumerWidget {
  const PaymentHistoryTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(
      walletNotifierProvider.select((value) => value.transactions),
    );
    final loadState = ref.watch(
      walletNotifierProvider.select((value) => value.transactionsState),
    );
    final notifier = ref.read(walletNotifierProvider.notifier);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8DD)),
          ),
          child: RefreshIndicator(
            onRefresh: () => notifier.getWalletTransactions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Table(
                columnWidths: const {0: FlexColumnWidth(2)},
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFE1E1E6)),
                    children: [
                      _header('Type'),
                      _header('Amount'),
                      _header(context.l10n.date),
                    ],
                  ),
                  for (final transaction in transactions) _row(transaction),
                ],
              ),
            ),
          ),
        ),
        if (loadState == LoadState.loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const CircularProgressIndicator(),
          )
        else if (transactions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              'No transactions yet.',
              style: context.theme.textTheme.bodySmall,
            ),
          ),
        10.verticalSpace,
      ],
    );
  }

  static Widget _header(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(text),
      );

  TableRow _row(WalletTransactionModel transaction) {
    final created = transaction.dateCreated;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            transaction.type ?? '—',
            style: TextStyle(
              color: transaction.isCredit
                  ? const Color(0xFF02952B)
                  : const Color(0xFFFF5B5B),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: (transaction.amount ?? 0).getCurrencyText(),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            created == null
                ? '—'
                : '${created.day}/${created.month}/${created.year}',
          ),
        ),
      ],
    );
  }
}
