import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/image_picker_notifier.dart';
import 'package:tivi_tea/core/widget/reusable_add_text_button.dart';
import 'package:tivi_tea/features/services/view/widgets/delete_icon.dart';

class AddMarketplaceItemImagesSection extends ConsumerWidget {
  const AddMarketplaceItemImagesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImages = ref.watch(imagePickerNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Images of the item',
          style: context.theme.textTheme.displayLarge?.copyWith(
            color: context.theme.primaryColor,
            fontSize: 20.sp,
          ),
        ),
        SizedBox(height: 20.h),
        selectedImages.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Center(
                  child: Text('No images selected.'),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) => _MarketplaceImageTile(
                  imagePath: selectedImages[index].path,
                  onDelete: () => ref
                      .read(imagePickerNotifierProvider.notifier)
                      .deleteImage(selectedImages[index].path),
                ),
              ),
        SizedBox(height: 10.h),
        IntrinsicWidth(
          child: ReusableAddTextButton(
            onTap: () => _showImageSourceSheet(context, ref),
            title: 'Add Images',
            color: const Color(0xFFE8E8EB),
            fontColor: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet(BuildContext context, WidgetRef ref) {
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
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(imagePickerNotifierProvider.notifier)
                    .selectImages(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(imagePickerNotifierProvider.notifier)
                    .selectImages(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceImageTile extends StatelessWidget {
  const _MarketplaceImageTile({
    required this.imagePath,
    required this.onDelete,
  });

  final String imagePath;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: SizedBox(
            height: 160.h,
            width: context.width,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: DeleteIcon(deleteImage: onDelete),
        ),
      ],
    );
  }
}
