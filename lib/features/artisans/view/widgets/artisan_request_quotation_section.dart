import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/kyc/model/enums.dart';
import 'package:tivi_tea/features/kyc/view/widgets/bottom_sheet_widget.dart';
import 'package:tivi_tea/features/artisans/view_model/artisans_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class ArtisanRequestQuotationSection extends ConsumerStatefulWidget {
  const ArtisanRequestQuotationSection({
    super.key,
    required this.artisanId,
  });

  final String artisanId;

  @override
  ConsumerState<ArtisanRequestQuotationSection> createState() =>
      _ArtisanRequestQuotationSectionState();
}

class _ArtisanRequestQuotationSectionState
    extends ConsumerState<ArtisanRequestQuotationSection> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _samplePhotoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  XFile? _samplePhoto;

  @override
  void dispose() {
    _descriptionController.dispose();
    _samplePhotoController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestQuotationLoadState = ref.watch(
      artisansNotifierProvider
          .select((value) => value.requestQuotationLoadState),
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request a Quotation',
            style: context.theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.theme.primaryColor,
            ),
          ),
          10.verticalSpace,
          Divider(color: context.theme.dividerColor),
          12.verticalSpace,
          AppTextField(
            controller: _descriptionController,
            hintText: 'Describe what you want the artisan to do',
            maxLines: 5,
            borderSide: BorderSide(color: context.theme.dividerColor),
          ),
          16.verticalSpace,
          _SamplePhotoField(
            controller: _samplePhotoController,
            samplePhoto: _samplePhoto,
            onPhotoSelected: (file) {
              _samplePhoto = file;
              _samplePhotoController.text = file.path;
              setState(() {});
            },
            onClear: () {
              _samplePhoto = null;
              _samplePhotoController.clear();
              setState(() {});
            },
          ),
          16.verticalSpace,
          AppTextField(
            controller: _dateController,
            label: 'Expected completion date',
            labelColor: const Color(0xFF8A8A99),
            borderSide: BorderSide(color: context.theme.dividerColor),
            hintText: 'Select date',
            readOnly: true,
            onTap: () => _pickDate(context),
          ),
          20.verticalSpace,
          Center(
            child: AppButton(
              buttonText: 'REQUEST A QUOTE',
              isLoading: requestQuotationLoadState == LoadState.loading,
              onPressed: _handleRequestQuote,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && context.mounted) {
      _selectedDate = picked;
      _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      setState(() {});
    }
  }

  Future<void> _handleRequestQuote() async {
    if (widget.artisanId.isEmpty) {
      context.showError('Invalid artisan selected.');
      return;
    }

    final note = _descriptionController.text.trim();
    if (note.isEmpty) {
      context.showError('Please describe what you want the artisan to do.');
      return;
    }

    if (_selectedDate == null) {
      context.showError('Please select expected completion date.');
      return;
    }

    final images = _samplePhoto == null ? <XFile>[] : [_samplePhoto!];

    final notifier = ref.read(artisansNotifierProvider.notifier);

    await notifier.requestQuotation(
      artisanId: widget.artisanId,
      clientNote: note,
      clientEndDate: _selectedDate!,
      images: images,
      onSuccess: (message, quotation) {
        if (!mounted) return;
        context.showSuccess(message);
        if (quotation == null) {
          context.go(AppRoutes.homeView);
          return;
        }
        // Drop straight into the negotiation — the request response is the
        // only chance to load the quotation, since the backend exposes no GET
        // for one.
        context.pushReplacement(
          '${AppRoutes.servicesView}/${AppRoutes.bargainQuotationView}',
          extra: quotation,
        );
      },
      onError: (message) {
        if (!mounted) return;
        context.showError(message);
      },
    );
  }
}

class _SamplePhotoField extends StatelessWidget {
  const _SamplePhotoField({
    required this.controller,
    required this.samplePhoto,
    required this.onPhotoSelected,
    required this.onClear,
  });

  final TextEditingController controller;
  final XFile? samplePhoto;
  final void Function(XFile) onPhotoSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Photo (Optional)',
          style: context.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A8A99),
          ),
        ),
        8.verticalSpace,
        InkWell(
          onTap: () => _showImageBottomSheet(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: context.width,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty
                        ? 'Tap to add photo'
                        : controller.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: controller.text.isEmpty
                          ? const Color(0xFF737380)
                          : null,
                    ),
                  ),
                ),
                if (samplePhoto != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close, size: 20.sp, color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageBottomSheet(BuildContext context) {
    context.showBottomSheet(
      title: context.l10n.uploadDocument,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BottomSheetWidget(
              chooseFileType: ChooseFileType.takePhoto,
              onImageSelected: onPhotoSelected,
            ),
            20.horizontalSpace,
            BottomSheetWidget(
              chooseFileType: ChooseFileType.selectFromGallery,
              onImageSelected: onPhotoSelected,
            ),
          ],
        ),
      ),
    );
  }
}
