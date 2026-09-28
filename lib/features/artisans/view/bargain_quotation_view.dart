import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/view/widgets/quotation_bubble.dart';
import 'package:tivi_tea/features/artisans/view_model/quotation_notifier.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';

/// "Bargain Quotation" — built to the Figma frame 6730:20202.
///
/// One outlined card holds the whole negotiation: the message thread in its
/// own scrolling panel, then the two inputs, then SEND MESSAGE. The current
/// quote and the accept action sit below it.
///
/// Both sides share this screen; the signed-in entity decides which fields are
/// sent. The backend caps each side at two counters and then refuses, so the
/// send control retires itself rather than letting someone hit that wall.
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
      if (!mounted) return;
      final notifier = ref.read(quotationNotifierProvider.notifier);
      // Seed so the screen renders immediately, then pull the full record —
      // a notification only hands us the id.
      notifier.seed(widget.quotation);
      final id = widget.quotation.id;
      if (id != null && id.isNotEmpty) notifier.load(id);
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
    final isBusy = state.actionState == LoadState.loading ||
        state.loadState == LoadState.loading;
    final closed = quotation.isAccepted || quotation.isDeclined;
    final countersLeft = quotation.countersLeftFor(artisan: _isArtisan);
    final currentQuote = quotation.currentQuote;
    // Until the artisan names a price there is nothing to accept or counter.
    final hasQuote = quotation.hasArtisanQuote;
    // The artisan's first move is an opening quote, not a counter.
    final canSend = !closed && (!hasQuote ? _isArtisan : countersLeft > 0);

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Bargain Quotation',
        showHamburgerMenu: true,
        showBackButtonForHomeScreenAppBar: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: QuotationColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Thread(quotation: quotation, viewerIsArtisan: _isArtisan),
                  if (canSend) ...[
                    18.verticalSpace,
                    _Field(
                      label: 'New Cost',
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: _inputStyle(),
                        decoration: _inputDecoration(
                          'Enter cost you are proposing',
                        ),
                      ),
                    ),
                    _Field(
                      label: 'Note',
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        style: _inputStyle(),
                        decoration: _inputDecoration('Add a message'),
                      ),
                    ),
                    _Field(
                      label: 'New completion date',
                      child: InkWell(
                        onTap: _pickDate,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 16.h,
                          ),
                          child: Text(
                            _endDate == null
                                ? '--/--/----'
                                : QuotationBubble.dateOf(_endDate!),
                            style: _endDate == null
                                ? _hintStyle()
                                : _inputStyle(),
                          ),
                        ),
                      ),
                    ),
                    10.verticalSpace,
                    _PillButton(
                      label: 'SEND MESSAGE',
                      filled: false,
                      isLoading: isBusy,
                      onPressed: isBusy ? null : () => _submit(quotation),
                    ),
                  ] else if (!closed && hasQuote) ...[
                    14.verticalSpace,
                    Text(
                      'No counters left — accept or decline the current quote.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: QuotationColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (closed) ...[
              20.verticalSpace,
              _ClosedBanner(status: quotation.status ?? ''),
            ] else if (!hasQuote) ...[
              20.verticalSpace,
              Text(
                _isArtisan
                    ? 'Send your price to start the negotiation.'
                    : 'Waiting for the artisan to send their quote.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: QuotationColors.muted,
                ),
              ),
            ] else ...[
              22.verticalSpace,
              Center(
                child: Text(
                  'Current quote (${QuotationBubble.money(currentQuote)})',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: QuotationColors.bubbleText,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              18.verticalSpace,
              _PillButton(
                label: _isArtisan
                    ? 'ACCEPT CURRENT QUOTE'
                    : 'ACCEPT CURRENT QUOTE - HIRE NOW',
                filled: true,
                isLoading: isBusy,
                onPressed: isBusy ? null : () => _respond(quotation, true),
              ),
              6.verticalSpace,
              Center(
                child: TextButton(
                  onPressed: isBusy ? null : () => _respond(quotation, false),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _inputStyle() => GoogleFonts.poppins(
        fontSize: 12.sp,
        color: QuotationColors.bubbleText,
      );

  TextStyle _hintStyle() => GoogleFonts.poppins(
        fontSize: 12.sp,
        color: QuotationColors.muted,
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: _hintStyle(),
        isDense: true,
        border: InputBorder.none,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _submit(QuotationModel quotation) {
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
    final isOpeningQuote = _isArtisan && !quotation.hasArtisanQuote;

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
          onSuccess: (m) {
            if (mounted) context.showSuccess(m);
          },
          onError: (m) {
            if (mounted) context.showError(m);
          },
        );
  }
}

/// The scrolling message panel at the top of the card.
class _Thread extends StatelessWidget {
  const _Thread({required this.quotation, required this.viewerIsArtisan});

  final QuotationModel quotation;
  final bool viewerIsArtisan;

  /// The design labels the reader's own messages "Name (Me)".
  static String _name(QuotationParty? party, String fallback,
      {required bool isMe}) {
    final name = party?.displayName ?? '';
    if (name.isEmpty) return fallback;
    return isMe ? '$name (Me)' : name;
  }

  @override
  Widget build(BuildContext context) {
    final messages = <Widget>[];

    if ((quotation.clientNote ?? '').isNotEmpty ||
        quotation.clientEndDate != null) {
      messages.add(
        QuotationBubble(
          author: _name(quotation.client, viewerIsArtisan ? 'Client' : 'You',
              isMe: !viewerIsArtisan),
          alignRight: !viewerIsArtisan,
          avatarUrl: quotation.client?.user?.profilePicture,
          postedOn: quotation.dateCreated,
          note: quotation.clientNote,
          endDate: quotation.clientEndDate,
        ),
      );
    }

    if ((quotation.artisanPrice ?? 0) > 0 ||
        (quotation.artisanNote ?? '').isNotEmpty) {
      messages.add(
        QuotationBubble(
          author: _name(quotation.artisan, viewerIsArtisan ? 'You' : 'Artisan',
              isMe: viewerIsArtisan),
          alignRight: viewerIsArtisan,
          role: quotation.artisan?.serviceType,
          avatarUrl: quotation.artisan?.user?.profilePicture,
          note: quotation.artisanNote,
          priceLabel: 'Artisan Quote',
          price: quotation.artisanPrice,
          endDate: quotation.artisanEndDate,
        ),
      );
    }

    final meta = quotation.meta;
    if (meta != null) {
      for (var round = 1; round <= 2; round++) {
        for (final side in const ['client', 'artisan']) {
          final raw = meta['${side}_counter_price_$round'];
          if (raw == null) continue;
          final isArtisanSide = side == 'artisan';
          messages.add(
            QuotationBubble(
              author: isArtisanSide == viewerIsArtisan
                  ? 'You'
                  : (isArtisanSide ? 'Artisan' : 'Client'),
              alignRight: isArtisanSide == viewerIsArtisan,
              priceLabel: 'Counter offer',
              price: raw is num ? raw : num.tryParse('$raw'),
            ),
          );
        }
      }
    }

    return Container(
      height: 300.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: QuotationColors.border),
      ),
      child: messages.isEmpty
          ? Center(
              child: Text(
                // An artisan arriving from a notification holds only the
                // quotation id; the request itself appears once they reply.
                viewerIsArtisan
                    ? 'Send your price below to see the full request.'
                    : 'No messages yet.',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: QuotationColors.muted,
                ),
              ),
            )
          : Scrollbar(
              child: SingleChildScrollView(
                child: Column(children: messages),
              ),
            ),
    );
  }
}

/// Label above an outlined input, per the design.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        // stretch, or the date row shrinks to its placeholder width while the
        // text fields fill the card.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: QuotationColors.label,
            ),
          ),
          8.verticalSpace,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: QuotationColors.border),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// The design's pill button: 56 high, fully rounded, arrow on the right.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final bool filled;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : QuotationColors.primary;
    return SizedBox(
      height: 52.h,
      child: Material(
        color: filled ? QuotationColors.primary : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
          side: const BorderSide(color: QuotationColors.primary),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 18.sp,
                    width: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(foreground),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      Icon(Icons.arrow_forward,
                          size: 17.sp, color: foreground),
                    ],
                  ),
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        accepted
            ? 'This quotation was accepted.'
            : 'This quotation was declined.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: accepted ? const Color(0xFF02952B) : const Color(0xFFE53935),
        ),
      ),
    );
  }
}
