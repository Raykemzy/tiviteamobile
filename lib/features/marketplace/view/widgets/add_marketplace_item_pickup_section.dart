import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';

class AddMarketplaceItemPickupSection extends StatelessWidget {
  const AddMarketplaceItemPickupSection({
    super.key,
    required this.pickupLocationController,
  });

  final TextEditingController pickupLocationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AppTextField(
        controller: pickupLocationController,
        hintText: 'Pickup location',
      ),
    );
  }
}
