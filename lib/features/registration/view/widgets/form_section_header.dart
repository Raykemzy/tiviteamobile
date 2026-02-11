import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  const FormSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.secondaryHeaderColor,
      margin: EdgeInsets.symmetric(vertical: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 5.h),
      child: Text(
        title,
        style: context.theme.textTheme.bodyLarge,
      ),
    );
  }
}