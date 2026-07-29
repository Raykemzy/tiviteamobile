import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';

/// Reusable quantity stepper (− qty +) used in the cart and on marketplace cards.
class MarketplaceQuantityStepper extends StatelessWidget {
  const MarketplaceQuantityStepper({
    super.key,
    required this.quantity,
    required this.primary,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final Color primary;

  /// A null callback disables (greys out) the corresponding button — e.g.
  /// [onIncrement] is null when the cart quantity has reached available stock.
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.remove,
          color: primary,
          onTap: onDecrement,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            '$quantity',
            style: context.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
        _CircleIconButton(
          icon: Icons.add,
          color: primary,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Opacity(
          opacity: disabled ? 0.4 : 1,
          child: Container(
            width: 28.r,
            height: 28.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD8D8DD),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
