import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette for the Bargain Quotation screen, taken from the Figma frame
/// (Design / "Bargain Quotation", 6730:20202) rather than approximated.
abstract final class QuotationColors {
  static const primary = Color(0xFF000050);
  static const bubble = Color(0xFF5E6C93); // used at 15% as the bubble ground
  static const bubbleText = Color(0xFF0E0E1B);
  static const tail = Color(0xFFE7E9EF);
  static const label = Color(0xFF8A8A99);
  static const border = Color(0xFFD8D8DD);
  static const cardBorder = Color(0xFFE8E8EB);
  static const muted = Color(0xFF737380);
  static const avatar = Color(0xFFD9D9D9);
}

/// One message in the negotiation thread.
///
/// The design nests a white, outlined header strip — avatar, name, role,
/// posted date — inside a tinted bubble, with a triangular tail pointing back
/// at its author.
class QuotationBubble extends StatelessWidget {
  const QuotationBubble({
    super.key,
    required this.author,
    required this.alignRight,
    this.role,
    this.postedOn,
    this.note,
    this.priceLabel,
    this.price,
    this.endDate,
    this.avatarUrl,
  });

  final String author;
  final bool alignRight;
  final String? role;
  final DateTime? postedOn;
  final String? note;
  final String? priceLabel;
  final num? price;
  final DateTime? endDate;
  final String? avatarUrl;

  /// dd/MM/yyyy, as the design writes it.
  static String dateOf(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        // 15% of #5E6C93 — a slate tint, not a flat grey.
        color: QuotationColors.bubble.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            author: author,
            role: role,
            postedOn: postedOn,
            avatarUrl: avatarUrl,
          ),
          8.verticalSpace,
          if ((note ?? '').isNotEmpty) ...[
            Text(note!, style: _body()),
            6.verticalSpace,
          ],
          if (price != null) ...[
            Text('${priceLabel ?? 'Quote'}: ${money(price!)}',
                style: _body(weight: FontWeight.w600)),
            6.verticalSpace,
          ],
          if (endDate != null)
            Text('Expected conclusion date: ${dateOf(endDate!)}',
                style: _body()),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!alignRight) _Tail(pointsLeft: true),
          Flexible(child: bubble),
          if (alignRight) _Tail(pointsLeft: false),
        ],
      ),
    );
  }

  /// Thousands-separated, matching "Artisan Quote: 35,000".
  static String money(num value) {
    final whole = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return buf.toString();
  }

  TextStyle _body({FontWeight weight = FontWeight.w400}) => GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: weight,
        color: QuotationColors.bubbleText,
      );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.author,
    this.role,
    this.postedOn,
    this.avatarUrl,
  });

  final String author;
  final String? role;
  final DateTime? postedOn;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: QuotationColors.bubble, width: 1.4),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: const BoxDecoration(
              color: QuotationColors.avatar,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: (avatarUrl ?? '').isEmpty
                ? null
                : Image.network(avatarUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // The design sets the names in DM Sans, not the app's Poppins.
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: QuotationColors.primary,
                  ),
                ),
                if ((role ?? '').isNotEmpty)
                  Text(
                    role!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      color: QuotationColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          if (postedOn != null) ...[
            6.horizontalSpace,
            Text(
              'Posted: ${QuotationBubble.dateOf(postedOn!)}',
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: QuotationColors.bubbleText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tail extends StatelessWidget {
  const _Tail({required this.pointsLeft});

  final bool pointsLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: CustomPaint(
        size: Size(14.w, 16.h),
        painter: _TailPainter(pointsLeft: pointsLeft),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter({required this.pointsLeft});

  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = QuotationColors.tail;
    final path = Path();
    if (pointsLeft) {
      path.moveTo(0, size.height * 0.35);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, size.height * 0.35);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant _TailPainter old) =>
      old.pointsLeft != pointsLeft;
}
