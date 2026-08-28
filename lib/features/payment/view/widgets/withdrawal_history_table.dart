import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/payment/model/payout_models.dart';
import 'package:tivi_tea/features/payment/view_model/partner/wallet_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

/// Payouts already sent to the bank, from `GET /payment/transfers`.
///
/// This was previously a stub: a hardcoded empty list, a refresh handler that
/// did nothing, a paginator pinned to zero, and row cells that did not line up
/// with their own headers — so the withdrawal screen showed an empty table no
/// matter how many payouts existed.
class WithdrawalHistoryTable extends ConsumerWidget {
  const WithdrawalHistoryTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(
      walletNotifierProvider.select((value) => value.transfers),
    );
    final loadState = ref.watch(
      walletNotifierProvider.select((value) => value.transfersState),
    );
    final notifier = ref.read(walletNotifierProvider.notifier);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8DD)),
          ),
          child: RefreshIndicator(
            onRefresh: () => notifier.getTransfers(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Table(
                columnWidths: const {0: FlexColumnWidth(2)},
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFE1E1E6)),
                    children: [
                      _header('Amount'),
                      _header(context.l10n.status),
                      _header(context.l10n.date),
                    ],
                  ),
                  for (final transfer in transfers) _row(transfer),
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
        else if (transfers.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              loadState == LoadState.error
                  ? 'Could not load your payouts.'
                  : 'No payouts yet.',
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

  TableRow _row(TransferModel transfer) {
    final created = transfer.dateCreated;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: (transfer.amount ?? 0).getCurrencyText(),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(transfer.status ?? '—'),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            created == null
                ? (transfer.dateIdentifier ?? '—')
                : '${created.day}/${created.month}/${created.year}',
          ),
        ),
      ],
    );
  }
}
