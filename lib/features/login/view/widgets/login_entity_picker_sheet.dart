import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';

/// Asks which entity to sign in as, for accounts that own more than one.
///
/// Pops the chosen [EntityType], or null when the user backs out.
class LoginEntityPickerSheet extends StatelessWidget {
  const LoginEntityPickerSheet({super.key, required this.options});

  final List<EntityType> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'This account has more than one profile. Choose the one you want to '
          'sign in as.',
          style: context.theme.textTheme.displaySmall?.copyWith(
            color: const Color(0xFF737380),
          ),
        ),
        20.verticalSpace,
        for (final option in options)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => Navigator.of(context).pop(option),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: context.theme.dividerColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${option.label} account',
                        style: context.theme.textTheme.labelMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: context.theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        16.verticalSpace,
      ],
    );
  }
}
