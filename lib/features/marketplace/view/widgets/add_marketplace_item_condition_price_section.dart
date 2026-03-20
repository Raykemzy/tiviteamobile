import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_condition_dropdown.dart';

class AddMarketplaceItemConditionPriceSection extends StatelessWidget {
  const AddMarketplaceItemConditionPriceSection({
    super.key,
    required this.selectedCondition,
    required this.onConditionSelected,
    required this.priceController,
    this.priceValidator,
  });

  final String? selectedCondition;
  final void Function(String) onConditionSelected;
  final TextEditingController priceController;
  final String? Function(String?)? priceValidator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketplaceConditionDropdown(
            selectedCondition: selectedCondition,
            onSelected: onConditionSelected,
          ),
          SizedBox(height: 16.h),
          AppTextField(
            controller: priceController,
            hintText: 'Price of item',
            keyboardType: TextInputType.number,
            validateFunction: priceValidator,
          ),
        ],
      ),
    );
  }
}
