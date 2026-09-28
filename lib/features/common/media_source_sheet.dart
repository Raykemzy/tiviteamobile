import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/gen/assets.gen.dart';

/// Where a piece of media can come from.
enum MediaSource {
  gallery,
  camera,
  video,
  document;

  String get label => switch (this) {
        MediaSource.gallery => 'Choose photos & videos',
        MediaSource.camera => 'Take a photo',
        MediaSource.video => 'Record a video',
        MediaSource.document => 'Upload a document',
      };

  String get description => switch (this) {
        MediaSource.gallery => 'Pick from your library',
        MediaSource.camera => 'Use your camera',
        MediaSource.video => 'Record with your camera',
        MediaSource.document => 'PDF, Word or text file',
      };

  String get icon => switch (this) {
        MediaSource.gallery => Assets.svgs.addPhoto.path,
        MediaSource.camera => Assets.svgs.camera.path,
        MediaSource.video => Assets.svgs.video.path,
        MediaSource.document => Assets.svgs.doc.path,
      };
}

/// The app's one media picker sheet, in the same language as the rest of the
/// app's sheets (rounded white [AppBottomSheet] with a title and close
/// button) rather than bare Material list tiles.
///
/// Calls [onSelected] after the sheet closes, so any picker it opens is not
/// fighting the sheet's dismissal animation.
Future<void> showMediaSourceSheet(
  BuildContext context, {
  required List<MediaSource> sources,
  required void Function(MediaSource source) onSelected,
  String title = 'Add media',
}) async {
  MediaSource? choice;
  await context.showBottomSheet<void>(
    title: title,
    maxHeightFactor: .6,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final source in sources) ...[
          _SourceTile(
            source: source,
            onTap: () {
              choice = source;
              context.pop();
            },
          ),
          if (source != sources.last) 12.verticalSpace,
        ],
        10.verticalSpace,
      ],
    ),
  );
  final selected = choice;
  if (selected != null) onSelected(selected);
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source, required this.onTap});

  final MediaSource source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFCCCCDC).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE6E6EE)),
        ),
        child: Row(
          children: [
            // The source icons have wildly different intrinsic sizes
            // (53×45 down to 13×16), so each is boxed to one size and
            // scaled to fit rather than drawn at its natural size.
            SizedBox.square(
              dimension: 22.sp,
              child: AppSvgWidget(
                path: source.icon,
                color: context.theme.primaryColor,
                width: 22.sp,
                height: 22.sp,
              ),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.label,
                    style: context.theme.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      color: context.theme.primaryColor,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    source.description,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: const Color(0xFF77797D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: const Color(0xFF77797D),
            ),
          ],
        ),
      ),
    );
  }
}
