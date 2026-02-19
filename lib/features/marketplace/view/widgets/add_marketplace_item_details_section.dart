import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';

class AddMarketplaceItemDetailsSection extends StatelessWidget {
  const AddMarketplaceItemDetailsSection({
    super.key,
    required this.nameController,
    required this.shortDescriptionController,
    required this.addressController,
    this.nameValidator,
    this.descriptionValidator,
    this.addressValidator,
  });

  final TextEditingController nameController;
  final TextEditingController shortDescriptionController;
  final TextEditingController addressController;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? descriptionValidator;
  final String? Function(String?)? addressValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Details',
          style: context.theme.textTheme.displayLarge?.copyWith(
            color: context.theme.primaryColor,
            fontSize: 20.sp,
          ),
        ),
        SizedBox(height: 20.h),
        AppTextField(
          controller: nameController,
          hintText: 'Name of item',
          validateFunction: nameValidator,
        ),
        AppTextField(
          controller: shortDescriptionController,
          hintText: 'Short description',
          maxLines: 3,
          validateFunction: descriptionValidator,
        ),
        AppTextField(
          controller: addressController,
          hintText: 'Address',
          validateFunction: addressValidator,
        ),
      ],
    );
  }
}
