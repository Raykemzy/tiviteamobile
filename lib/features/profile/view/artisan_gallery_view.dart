import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/home/view/service_provider/service_provider_dashboard.dart';
import 'package:tivi_tea/features/services/view_model/room_image_selector_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class ArtisanGalleryView extends ConsumerWidget {
  const ArtisanGalleryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appbar: const CustomAppBar(
        homeScreenAppBar: true,
        title: 'Artisan Gallery',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artisan Gallery',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    color: context.theme.primaryColor,
                  ),
                ),
                IntrinsicWidth(
                  child: CreateListingButton(
                    text: context.l10n.addImage,
                    iconColor: Colors.black,
                    textColor: Colors.black,
                    backgroundColor: const Color(0xFFE8E8EB),
                    onTap: () => _pickImages(ref),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImages(WidgetRef ref) async {
    final notifier = ref.read(roomImageSelectorNotifierProvider.notifier);
    notifier.selectImages();
  }

  // void _deleteImage(WidgetRef ref, String imagePath) {
  //   final notifier = ref.read(roomImageSelectorNotifierProvider.notifier);
  //   notifier.deleteImage(imagePath);
  // }
}
