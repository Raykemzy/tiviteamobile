import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_pricing.dart';

/// Transparent container with grey border: price, fees, divider, total.
class MarketplacePaymentSummaryCard extends StatelessWidget {
  const MarketplacePaymentSummaryCard({
    super.key,
    required this.pricing,
  });

  final MarketplaceCartPricing pricing;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      color: const Color(0xFF737380),
    );
    final valueStyle = context.theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF333333),
    );
    final totalStyle = context.theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16.sp,
      color: context.theme.primaryColor,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: const Color(0xFFD8D8DD),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: 'Price',
            value: pricing.itemsSubtotal,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          6.verticalSpace,
          _SummaryRow(
            label: 'Service charge (3%)',
            value: pricing.serviceCharge,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          6.verticalSpace,
          _SummaryRow(
            label: 'VAT (5%)',
            value: pricing.vat,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          if (pricing.deliveryFee > 0) ...[
            6.verticalSpace,
            _SummaryRow(
              label: 'Delivery',
              value: pricing.deliveryFee,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ],
          10.verticalSpace,
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFD8D8DD),
          ),
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total payment', style: totalStyle),
              Text(
                '₦${pricing.total.formatAmount}',
                style: totalStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final num value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text('₦${value.formatAmount}', style: valueStyle),
      ],
    );
  }
}
