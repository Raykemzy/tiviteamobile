import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';

class ArtisanDetailHeader extends StatelessWidget {
  const ArtisanDetailHeader({super.key, required this.artisan});

  final ArtisanResponseModel artisan;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(context),
        16.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 5.w,
                children: [
                  Text(
                    artisan.fullName,
                    style: context.theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (artisan.kycIsVerified ?? false)
                    Icon(
                      Icons.verified_rounded,
                      size: 16.sp,
                      color: const Color(0xFF006400),
                    ),
                ],
              ),
              4.verticalSpace,
              Text(
                artisan.serviceTypeDisplay,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF737380),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    final pic = artisan.user?.profilePicture;
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.theme.dividerColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: pic != null && pic.isNotEmpty
          ? AppImageWidget(imagePath: pic, borderRadius: BorderRadius.zero)
          : Icon(Icons.person, size: 32.sp, color: Colors.grey.shade400),
    );
  }
}
