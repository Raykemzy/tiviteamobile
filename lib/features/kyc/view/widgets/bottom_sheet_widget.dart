import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/utils/image_picker_notifier.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/kyc/model/enums.dart';
import 'package:tivi_tea/features/services/view/pages/booking_summary_view.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class BottomSheetWidget extends ConsumerWidget {
  final ChooseFileType chooseFileType;
  final Function(XFile) onImageSelected;
  const BottomSheetWidget({
    super.key,
    required this.chooseFileType,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _onTap(chooseFileType, ref, context),
      child: DottedWidget(
        radius: 8.sp,
        child: Container(
          width: 135.w,
          height: 135.h,
          decoration: BoxDecoration(
            color: const Color(0xFFCCCCDC).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSvgWidget(
                path: switch (chooseFileType) {
                  ChooseFileType.takePhoto => Assets.svgs.camera.path,
                  ChooseFileType.selectFromGallery => Assets.svgs.addPhoto.path,
                  ChooseFileType.selectFromFiles => Assets.svgs.doc.path,
                },
              ),
              20.verticalSpace,
              Text(
                switch (chooseFileType) {
                  ChooseFileType.takePhoto => context.l10n.takeAPicture,
                  ChooseFileType.selectFromGallery => context.l10n.gallery,
                  ChooseFileType.selectFromFiles => context.l10n.pdf,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(
    ChooseFileType fileType,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final notifier = ref.read(imagePickerNotifierProvider.notifier);
    switch (fileType) {
      case ChooseFileType.takePhoto:
        final image = await notifier.selectSingleImage(
          source: ImageSource.camera,
        );
        if (image == null) return;
        onImageSelected(image);
        break;

      case ChooseFileType.selectFromGallery:
        final image = await notifier.selectSingleImage();
        if (image == null) return;
        onImageSelected(image);
        break;

      case ChooseFileType.selectFromFiles:
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result == null || result.files.single.path == null) return;
        onImageSelected(XFile(result.files.single.path!));
        break;
    }

    if (context.mounted) {
      context.pop();
    }
  }
}
