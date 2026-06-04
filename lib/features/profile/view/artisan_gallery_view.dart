import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/media_tile.dart';
import 'package:tivi_tea/features/home/view/service_provider/service_provider_dashboard.dart';
import 'package:tivi_tea/features/profile/view_model/artisan_gallery_notifier.dart';
import 'package:tivi_tea/features/services/view_model/room_image_selector_notifier.dart';

class ArtisanGalleryView extends ConsumerStatefulWidget {
  const ArtisanGalleryView({super.key});

  @override
  ConsumerState<ArtisanGalleryView> createState() => _ArtisanGalleryViewState();
}

class _ArtisanGalleryViewState extends ConsumerState<ArtisanGalleryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomImageSelectorNotifierProvider.notifier).clearMedia();
      ref.read(artisanGalleryNotifierProvider.notifier).fetchGallery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(artisanGalleryNotifierProvider);
    final pendingMedia = ref.watch(roomImageSelectorNotifierProvider);
    final isUploading = galleryState.uploadState == LoadState.loading;

    return AppScaffold(
      appbar: const CustomAppBar(
        homeScreenAppBar: true,
        title: 'Artisan Gallery',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    text: 'Add Media',
                    iconColor: Colors.black,
                    textColor: Colors.black,
                    backgroundColor: const Color(0xFFE8E8EB),
                    onTap: isUploading ? null : () => _showPickerSheet(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            if (galleryState.fetchState == LoadState.loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (galleryState.media.isEmpty && pendingMedia.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: Text('No media yet.')),
              ),
            if (pendingMedia.isNotEmpty) ...[
              Text(
                'Selected (not yet uploaded)',
                style: context.theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 10.h),
              _MediaGrid(
                count: pendingMedia.length,
                tileBuilder: (index) => MediaTile(
                  path: pendingMedia[index].path,
                  isNetwork: false,
                  onDelete: isUploading
                      ? null
                      : () => ref
                          .read(roomImageSelectorNotifierProvider.notifier)
                          .deleteImage(pendingMedia[index].path),
                ),
              ),
              SizedBox(height: 16.h),
              AppButton(
                isLoading: isUploading,
                buttonText: 'UPLOAD',
                onPressed: isUploading ? null : _uploadPending,
              ),
              SizedBox(height: 24.h),
            ],
            if (galleryState.media.isNotEmpty) ...[
              Text(
                'My Gallery',
                style: context.theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 10.h),
              _MediaGrid(
                count: galleryState.media.length,
                tileBuilder: (index) => MediaTile(
                  path: galleryState.media[index],
                  isNetwork: true,
                  onDelete: isUploading
                      ? null
                      : () => _confirmRemove(galleryState.media[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _uploadPending() {
    final files = ref.read(roomImageSelectorNotifierProvider);
    if (files.isEmpty) return;
    ref.read(artisanGalleryNotifierProvider.notifier).addMedia(
          files,
          onSuccess: (message) {
            ref.read(roomImageSelectorNotifierProvider.notifier).clearMedia();
            if (mounted) context.showSuccess(message);
          },
          onError: (message) {
            if (mounted) context.showError(message);
          },
        );
  }

  void _confirmRemove(String url) {
    ref.read(artisanGalleryNotifierProvider.notifier).removeMedia(
          url,
          onSuccess: (message) {
            if (mounted) context.showSuccess(message);
          },
          onError: (message) {
            if (mounted) context.showError(message);
          },
        );
  }

  void _showPickerSheet(BuildContext context) {
    final notifier = ref.read(roomImageSelectorNotifierProvider.notifier);
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

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.count, required this.tileBuilder});

  final int count;
  final Widget Function(int index) tileBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) => tileBuilder(index),
    );
  }
}
