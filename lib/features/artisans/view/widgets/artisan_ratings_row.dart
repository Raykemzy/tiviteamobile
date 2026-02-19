import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';

class ArtisanRatingsRow extends StatelessWidget {
  const ArtisanRatingsRow({super.key, required this.artisan});

  final ArtisanResponseModel artisan;

  @override
  Widget build(BuildContext context) {
    final rating = artisan.rating ?? 0;
    final count = artisan.reviewsCount ?? 0;

    return Row(
      spacing: 5.w,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            spacing: 2.w,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 16.sp,
                color: Colors.white,
              ),
              Text(
                rating.toString(),
                style: context.theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Text(
          count == 1 ? '1 review' : '$count reviews',
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
