import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';

class ArtisanProfessionalSummarySection extends StatelessWidget {
  const ArtisanProfessionalSummarySection({
    super.key,
    required this.artisan,
  });

  final ArtisanResponseModel artisan;

  static const int _gridCount = 4;

  @override
  Widget build(BuildContext context) {
    final images = artisan.galleryImages ?? const <String>[];
    final hasMoreThanFour = images.length > _gridCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Professional Summary',
              style: context.theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.theme.primaryColor,
              ),
            ),
            if (hasMoreThanFour)
              GestureDetector(
                onTap: () => context.push(
                  '${AppRoutes.servicesView}/${AppRoutes.artisanDetailsView}/${AppRoutes.artisanGalleryFullView}',
                  extra: images,
                ),
                child: Text(
                  'See All',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
        12.verticalSpace,
        if (images.isEmpty)
          Text(
            'No photos yet',
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF737380),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1,
            ),
            itemCount: images.length > _gridCount ? _gridCount : images.length,
            itemBuilder: (_, index) => ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: AppImageWidget(imagePath: images[index]),
            ),
          ),
      ],
    );
  }
}
