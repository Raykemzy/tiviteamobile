import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/image_picker_notifier.dart';
import 'package:tivi_tea/core/widget/reusable_add_text_button.dart';
import 'package:tivi_tea/features/common/media_tile.dart';

class AddMarketplaceItemImagesSection extends ConsumerWidget {
  const AddMarketplaceItemImagesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMedia = ref.watch(imagePickerNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Images & Videos of the item',
          style: context.theme.textTheme.displayLarge?.copyWith(
            color: context.theme.primaryColor,
            fontSize: 20.sp,
          ),
        ),
        SizedBox(height: 20.h),
        selectedMedia.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Center(
                  child: Text('No media selected.'),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedMedia.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) => MediaTile(
                  path: selectedMedia[index].path,
                  isNetwork: false,
                  onDelete: () => ref
                      .read(imagePickerNotifierProvider.notifier)
                      .deleteImage(selectedMedia[index].path),
                ),
              ),
        SizedBox(height: 10.h),
        IntrinsicWidth(
          child: ReusableAddTextButton(
            onTap: () => _showMediaSourceSheet(context, ref),
            title: 'Add Media',
            color: const Color(0xFFE8E8EB),
            fontColor: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showMediaSourceSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(imagePickerNotifierProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photos & videos'),
              onTap: () {
                Navigator.pop(context);
                notifier.selectMedia();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                notifier.selectImages(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Record a video'),
              onTap: () {
                Navigator.pop(context);
                notifier.selectVideo(source: ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
