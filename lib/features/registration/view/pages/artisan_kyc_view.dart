import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_checkbox.dart';
import 'package:tivi_tea/features/common/app_dropdown.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/kyc/model/client_kyc_request_body.dart';
import 'package:tivi_tea/features/kyc/model/enums.dart';
import 'package:tivi_tea/features/kyc/view/widgets/bottom_sheet_widget.dart';
import 'package:tivi_tea/features/kyc/view_model/artisan/artisan_kyc_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_appbar.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_scaffold.dart';
import 'package:tivi_tea/features/registration/view/widgets/uplaod_document_container.dart';
import 'package:tivi_tea/features/services/view_model/service_provider/partner_services_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';

class ArtisanKycView extends StatefulWidget {
  const ArtisanKycView({super.key});

  @override
  State<ArtisanKycView> createState() => _ArtisanKycViewState();
}

class _ArtisanKycViewState extends State<ArtisanKycView> {
  final TextEditingController ninNumberController = TextEditingController();
  ValueNotifier<XFile?> selectedFrontImage = ValueNotifier<XFile?>(null);
  ValueNotifier<XFile?> selectedBackImage = ValueNotifier<XFile?>(null);

  @override
  void dispose() {
    ninNumberController.dispose();
    selectedFrontImage.dispose();
    selectedBackImage.dispose();

    super.dispose();
  }

  DocumentType documentType = DocumentType.nin;

  List<String> documentTypes = DocumentTypeExt.stringValues;

  @override
  Widget build(BuildContext context) {
    final selectedDocumentName = documentType.getDisplayName();
    return RegistrationScaffold(
      appbar: RegistrationAppBar(
        headerSectionTitle: context.l10n.proofOfIdentity,
        headerSectionSubtitle: context.l10n.provideInfo,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              context.l10n.uploadProofOfIdentity,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.displayLarge,
            ),
            10.verticalSpace,
            Text(
              context.l10n.provideCorrectInfoToVerifyAccount,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.displaySmall?.copyWith(
                color: const Color(0xFF737380),
              ),
            ),
            20.verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.documentType,
                style: context.theme.textTheme.bodyMedium,
              ),
            ),
            10.verticalSpace,
            AppDropdown<String>(
              items: documentTypes,
              onItemSelected: (value) {
                documentType = DocumentTypeExt.fromString(value);
                setState(() {});
              },
            ),
            20.verticalSpace,
            AppTextField(
              controller: ninNumberController,
              label: '$selectedDocumentName Number',
              hintText: "Enter $selectedDocumentName Number",
            ),
            20.verticalSpace,
            ValueListenableBuilder(
              valueListenable: selectedFrontImage,
              builder: (context, value, child) {
                if (value == null) {
                  return UploadDocumentContainer(
                    isFront: true,
                    onTap: () => _showBottomSheet(context, true),
                  );
                }
                return SelectedDocumentContainer(
                  file: value,
                  isFront: true,
                  onDelete: () => selectedFrontImage.value = null,
                );
              },
            ),
            20.verticalSpace,
            ValueListenableBuilder(
              valueListenable: selectedBackImage,
              builder: (context, value, child) {
                if (value == null) {
                  return UploadDocumentContainer(
                    isFront: false,
                    onTap: () => _showBottomSheet(context, false),
                  );
                }
                return SelectedDocumentContainer(
                  file: value,
                  isFront: false,
                  onDelete: () => selectedBackImage.value = null,
                );
              },
            ),
            20.verticalSpace,
            Row(
              children: [
                AppCheckbox(onChanged: (value) {}),
                10.horizontalSpace,
                Flexible(
                  child: Text(
                    context.l10n.confirmUploadedValidIdCard,
                    style: context.theme.textTheme.displaySmall?.copyWith(
                      color: context.theme.primaryColor,
                    ),
                  ),
                )
              ],
            ),
            20.verticalSpace,
            Consumer(
              builder: (context, ref, _) {
                final submitState = ref.watch(
                  artisanKycNotifierProvider
                      .select((value) => value.kycLoadState),
                );
                final uploadState = ref.watch(
                  partnerServicesNotiferProvider.select(
                    (value) => value.cloudinaryUploadState,
                  ),
                );
                final isLoading = submitState == LoadState.loading ||
                    uploadState == LoadState.loading;
                return AppButton(
                  isLoading: isLoading,
                  onPressed: () => _submit(ref),
                  buttonText: context.l10n.submitDocuments,
                );
              },
            ),
            50.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _submit(WidgetRef ref) async {
    if (ninNumberController.text.trim().isEmpty) {
      context.showError('Please enter your document number');
      return;
    }

    if (selectedFrontImage.value == null || selectedBackImage.value == null) {
      context.showError('Please upload both front and back images');
      return;
    }

    final frontImage = await _uploadImage(ref, selectedFrontImage.value);
    final backImage = await _uploadImage(ref, selectedBackImage.value);

    if (frontImage == null || backImage == null) {
      if (mounted) {
        context.showError('Failed to upload document images');
      }
      return;
    }

    final data = ClientKYCRequestBody(
      documentType: documentType.getDisplayName(),
      documentId: ninNumberController.text.trim(),
      frontImage: frontImage,
      backImage: backImage,
    );

    final notifier = ref.read(artisanKycNotifierProvider.notifier);
    notifier.submitArtisanKYC(
      data,
      onSuccess: () {
        final notifier = ref.read(loginNotifierProvider.notifier);
        notifier.setAppAccessState(AppAccessState.user);
        context.go(AppRoutes.homeView, extra: EntityType.artisan);
      },
      onError: (error) => context.showError(error),
    );
  }

  void _showBottomSheet(BuildContext context, bool isFront) {
    context.showBottomSheet(
      title: context.l10n.uploadDocument,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            BottomSheetWidget(
              chooseFileType: ChooseFileType.takePhoto,
              onImageSelected: (file) => _onImageSelected(file, isFront),
            ),
            BottomSheetWidget(
              chooseFileType: ChooseFileType.selectFromGallery,
              onImageSelected: (file) => _onImageSelected(file, isFront),
            ),
            BottomSheetWidget(
              chooseFileType: ChooseFileType.selectFromFiles,
              onImageSelected: (file) => _onImageSelected(file, isFront),
            ),
          ],
        ),
      ),
    );
  }

  void _onImageSelected(XFile file, bool isFront) {
    if (isFront) {
      selectedFrontImage.value = file;
    } else {
      selectedBackImage.value = file;
    }
  }

  Future<String?> _uploadImage(WidgetRef ref, XFile? file) async {
    if (file == null) return null;
    final notifier = ref.read(partnerServicesNotiferProvider.notifier);
    final imageUrls = await notifier.uploadImages([file]);
    if (imageUrls.isEmpty) return null;
    return imageUrls.first;
  }
}
