import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/view_model/quotation_notifier.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';

/// The "Bargain Quotation" screen.
///
/// Both sides of a negotiation share this screen; which fields get sent is
/// decided by the signed-in entity. The backend caps each side at two
/// counters, after which it refuses and the only moves left are accept or
/// decline — so the counter form hides itself once they are spent.
class BargainQuotationView extends ConsumerStatefulWidget {
  const BargainQuotationView({super.key, required this.quotation});

  final QuotationModel quotation;

  @override
  ConsumerState<BargainQuotationView> createState() =>
      _BargainQuotationViewState();
}

class _BargainQuotationViewState extends ConsumerState<BargainQuotationView> {
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(quotationNotifierProvider.notifier).seed(widget.quotation);
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isArtisan =>
      ref.read(userNotifierProvider).signedInEntityType == EntityType.artisan;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quotationNotifierProvider);
    final quotation = state.quotation ?? widget.quotation;
    final isBusy = state.actionState == LoadState.loading;
    final closed = quotation.isAccepted || quotation.isDeclined;
    final countersLeft = quotation.countersLeftFor(artisan: _isArtisan);
    final currentQuote =
        quotation.currentCounterPrice ?? quotation.artisanPrice ?? 0;

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Bargain Quotation',
        showHamburgerMenu: true,
        showBackButtonForHomeScreenAppBar: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuotationThread(quotation: quotation, viewerIsArtisan: _isArtisan),
            20.verticalSpace,
            if (closed)
              _ClosedBanner(status: quotation.status ?? '')
            else ...[
              if (countersLeft > 0) ...[
                AppTextField(
                  controller: _priceController,
                  label: 'New Cost',
                  hintText: 'Enter cost you are proposing',
                  keyboardType: TextInputType.number,
                ),
                AppTextField(
                  controller: _noteController,
                  label: 'Note',
                  hintText: 'Add a message',
                ),
                _DateField(
                  label: 'New completion date',
                  value: _endDate,
                  onPick: (date) => setState(() => _endDate = date),
                ),
                10.verticalSpace,
                AppButton(
                  buttonText: 'SEND MESSAGE',
                  isLoading: isBusy,
                  backgroundColor: Colors.white,
                  textColor: context.theme.primaryColor,
                  borderColor: context.theme.primaryColor,
                  onPressed: isBusy ? null : () => _submitCounter(quotation),
                ),
                8.verticalSpace,
                Text(
                  countersLeft == 1
                      ? 'You have 1 counter left.'
                      : 'You have $countersLeft counters left.',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall,
                ),
              ] else
                Text(
                  'No counters left — accept or decline the current quote.',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall,
                ),
              20.verticalSpace,
              Text(
                'Current quote (${currentQuote.toString()})',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
              15.verticalSpace,
              AppButton(
                buttonText: _isArtisan
                    ? 'ACCEPT CURRENT QUOTE'
                    : 'ACCEPT CURRENT QUOTE - HIRE NOW',
                isLoading: isBusy,
                onPressed: isBusy ? null : () => _respond(quotation, true),
              ),
              10.verticalSpace,
              TextButton(
                onPressed: isBusy ? null : () => _respond(quotation, false),
                child: Text(
                  'Decline',
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            ],
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _submitCounter(QuotationModel quotation) {
    final price = num.tryParse(_priceController.text.trim());
    final id = quotation.id;
    if (id == null || price == null || price <= 0) {
      context.showError('Enter a valid amount.');
      return;
    }
    if (_endDate == null) {
      context.showError('Pick a completion date.');
      return;
    }

    final notifier = ref.read(quotationNotifierProvider.notifier);
    // The artisan's first reply to a request is `send-quotation`; every reply
    // after that — and every client reply — is a counter.
    final isOpeningQuote = _isArtisan && quotation.artisanPrice == null;

    void onSuccess(String message) {
      if (!mounted) return;
      _priceController.clear();
      _noteController.clear();
      setState(() => _endDate = null);
      context.showSuccess(message);
    }

    void onError(String message) {
      if (mounted) context.showError(message);
    }

    if (isOpeningQuote) {
      notifier.sendQuotation(
        quotationId: id,
        note: _noteController.text.trim(),
        price: price,
        endDate: _endDate!,
        onSuccess: onSuccess,
        onError: onError,
      );
      return;
    }

    notifier.counter(
      quotationId: id,
      asArtisan: _isArtisan,
      note: _noteController.text.trim(),
      price: price,
      endDate: _endDate!,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  void _respond(QuotationModel quotation, bool accept) {
    final id = quotation.id;
    if (id == null) return;
    ref.read(quotationNotifierProvider.notifier).respond(
          quotationId: id,
          accept: accept,
          onSuccess: (message) {
            if (mounted) context.showSuccess(message);
          },
          onError: (message) {
            if (mounted) context.showError(message);
          },
        );
  }
}

/// The negotiation so far, newest last, as the alternating bubbles in the
/// design. The backend keeps the counter history in `meta`, keyed
/// `client_counter_price_1`, `artisan_counter_price_1`, and so on.
class _QuotationThread extends StatelessWidget {
  const _QuotationThread({
    required this.quotation,
    required this.viewerIsArtisan,
  });

  final QuotationModel quotation;
  final bool viewerIsArtisan;

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[];

    if ((quotation.clientNote ?? '').isNotEmpty ||
        quotation.clientEndDate != null) {
      entries.add(
        _Bubble(
          author: viewerIsArtisan ? 'Client' : 'You',
          alignRight: !viewerIsArtisan,
          note: quotation.clientNote,
          endDate: quotation.clientEndDate,
        ),
      );
    }

    if (quotation.artisanPrice != null || (quotation.artisanNote ?? '').isNotEmpty) {
      entries.add(
        _Bubble(
          author: viewerIsArtisan ? 'You' : 'Artisan',
          alignRight: viewerIsArtisan,
          note: quotation.artisanNote,
          price: quotation.artisanPrice,
          priceLabel: 'Artisan Quote',
          endDate: quotation.artisanEndDate,
        ),
      );
    }

    for (final counter in _counterHistory()) {
      entries.add(counter);
    }

    if (entries.isEmpty) {
      entries.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'No messages yet.',
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D8DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: entries),
    );
  }

  List<Widget> _counterHistory() {
    final meta = quotation.meta;
    if (meta == null) return const [];
    final out = <Widget>[];
    for (var round = 1; round <= 2; round++) {
      for (final side in const ['client', 'artisan']) {
        final price = meta['${side}_counter_price_$round'];
        if (price == null) continue;
        final isArtisanSide = side == 'artisan';
        out.add(
          _Bubble(
            author: (isArtisanSide == viewerIsArtisan)
                ? 'You'
                : (isArtisanSide ? 'Artisan' : 'Client'),
            alignRight: isArtisanSide == viewerIsArtisan,
            price: price is num ? price : num.tryParse('$price'),
            priceLabel: 'Counter offer',
          ),
        );
      }
    }
    return out;
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.author,
    required this.alignRight,
    this.note,
    this.price,
    this.priceLabel,
    this.endDate,
  });

  final String author;
  final bool alignRight;
  final String? note;
  final num? price;
  final String? priceLabel;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(10.w),
        constraints: BoxConstraints(maxWidth: 260.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontSize: 13.sp,
                color: context.theme.primaryColor,
              ),
            ),
            if ((note ?? '').isNotEmpty) ...[
              6.verticalSpace,
              Text(note!, style: context.theme.textTheme.bodySmall),
            ],
            if (price != null) ...[
              6.verticalSpace,
              Text(
                '${priceLabel ?? 'Quote'}: $price',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                ),
              ),
            ],
            if (endDate != null) ...[
              4.verticalSpace,
              Text(
                'Expected conclusion date: '
                '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                style: context.theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.theme.textTheme.bodyMedium),
        8.verticalSpace,
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 365 * 2)),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8D8DD)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value == null
                  ? '--/--/----'
                  : '${value!.day}/${value!.month}/${value!.year}',
              style: context.theme.textTheme.bodySmall,
            ),
          ),
        ),
        16.verticalSpace,
      ],
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final accepted = status.toLowerCase() == 'accepted';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: accepted ? const Color(0xFFE7F5EC) : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        accepted
            ? 'This quotation was accepted.'
            : 'This quotation was declined.',
        textAlign: TextAlign.center,
        style: context.theme.textTheme.bodyMedium?.copyWith(
          color: accepted ? const Color(0xFF02952B) : Colors.red,
        ),
      ),
    );
  }
}
