import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';

class ArtisanGalleryFullView extends StatelessWidget {
  const ArtisanGalleryFullView({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Gallery',
        showBackButton: true,
      ),
      body: imageUrls.isEmpty
          ? Center(
              child: Text(
                'No images',
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF737380),
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: AppImageWidget(imagePath: imageUrls[index]),
              ),
            ),
    );
  }
}
