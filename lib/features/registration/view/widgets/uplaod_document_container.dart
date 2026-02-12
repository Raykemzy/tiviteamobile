import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class UploadDocumentContainer extends StatelessWidget {
  final bool isFront;
  final VoidCallback onTap;
  const UploadDocumentContainer({
    super.key,
    required this.isFront,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: context.width,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xFFE8E8EB).withValues(alpha: 0.3),
          border:
              Border.all(color: const Color(0xFFE8E8EB).withValues(alpha: 0.1)),
        ),
        child: Column(
          spacing: 10,
          children: [
            AppSvgWidget(path: Assets.svgs.cloudUpload.path),
            Text(
              isFront ? context.l10n.uploadFront : context.l10n.uploadBack,
              style: context.theme.textTheme.labelMedium,
            ),
            SizedBox(
              width: context.width * 0.5,
              child: Text(
                isFront
                    ? context.l10n.uploadFrontDesc
                    : context.l10n.uploadBackDesc,
                textAlign: TextAlign.center,
                style: context.theme.textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF5C5C66),
                  fontSize: 12.sp,
                ),
              ),
            ),
            10.verticalSpace,
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.primaryColor),
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Text(
                context.l10n.chooseAFile,
                style: context.theme.textTheme.labelSmall?.copyWith(
                  color: context.theme.primaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedDocumentContainer extends StatelessWidget {
  final XFile file;
  final bool isFront;
  final VoidCallback onDelete;

  const SelectedDocumentContainer({
    super.key,
    required this.file,
    required this.isFront,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    return Container(
      width: context.width,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xFFE8E8EB).withValues(alpha: 0.3),
        border: Border.all(
          color: const Color(0xFFE8E8EB).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          AppSvgWidget(path: Assets.svgs.doc.path),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFront ? context.l10n.uploadFront : context.l10n.uploadBack,
                  style: context.theme.textTheme.labelMedium,
                ),
                4.verticalSpace,
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF5C5C66),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDelete,
            child: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
