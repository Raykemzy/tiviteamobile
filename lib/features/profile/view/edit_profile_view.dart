import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_phone_text_field.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_success_content.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/services/view_model/service_provider/partner_services_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userNotifierProvider);
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      emailNameController.text = user.email ?? '';
      phoneNumber = user.phoneNumber ?? '';
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;
    final uploadNotifier = ref.read(partnerServicesNotiferProvider.notifier);
    final profileNotifier = ref.read(profileNotiferProvider.notifier);
    final uploadedImages = await uploadNotifier.uploadImages([picked]);
    if (!mounted) return;
    if (uploadedImages.isEmpty) {
      context.showError('Failed to upload profile picture');
      return;
    }
    profileNotifier.updateProfile(
      EditProfileModel(profilePicture: uploadedImages.first),
      onSuccess: () {
        if (mounted) context.showSuccess('Profile picture updated');
      },
      onError: (message) {
        if (mounted) context.showError(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    return AppScaffold(
      appbar: const CustomAppBar(homeScreenAppBar: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final cloudinaryLoadState = ref.watch(
                        partnerServicesNotiferProvider.select(
                          (value) => value.cloudinaryUploadState,
                        ),
                      );
                      final editProfileLoadState = ref.watch(
                        profileNotiferProvider.select(
                          (value) => value.editProfileLoadState,
                        ),
                      );
                      final isProfileImageBusy =
                          cloudinaryLoadState == LoadState.loading ||
                          editProfileLoadState == LoadState.loading;
                      return GestureDetector(
                        onTap: isProfileImageBusy
                            ? null
                            : _pickAndUploadProfileImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: user.profilePicture != null &&
                                      user.profilePicture!.isNotEmpty
                                  ? NetworkImage(user.profilePicture!)
                                  : null,
                              child: isProfileImageBusy
                                  ? SizedBox(
                                      width: 30.w,
                                      height: 30.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : (user.profilePicture == null ||
                                          user.profilePicture!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 50.r,
                                          color: Colors.grey.shade500,
                                        )
                                      : null),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16.r,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  10.verticalSpace,
                  Text(
                    '${firstNameController.text} ${lastNameController.text}'.trim(),
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      color: context.theme.primaryColor,
                      fontSize: 20.sp,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSvgWidget(path: Assets.svgs.lock.path),
                      5.horizontalSpace,
                      Text(
                        context.l10n.changePassword,
                        style: context.theme.textTheme.displaySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            Form(
              key: _formKey,
              onChanged: () {
                setState(() {});
              },
              child: Column(
                children: [
                  AppTextField(
                    controller: firstNameController,
                    hintText: user.firstName ?? '',
                    label: 'First Name',
                    textCapitalization: TextCapitalization.words,
                    onChange: (_) => setState(() {}),
                  ),
                  AppTextField(
                    controller: lastNameController,
                    hintText: user.lastName ?? '',
                    label: 'Last Name',
                    textCapitalization: TextCapitalization.words,
                    onChange: (_) => setState(() {}),
                  ),
                  AppPhoneTextField(
                    label: 'Phone Number',
                    initialValue: user.phoneNumber,
                    hintText: user.phoneNumber ?? '',
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                      setState(() {});
                    },
                  ),
                  AppTextField(
                    controller: emailNameController,
                    hintText: user.email ?? '',
                    label: 'Email Address',
                    readOnly: true,
                    enabled: false,
                  ),
                ],
              ),
            ),
            26.verticalSpace,
            Consumer(
              builder: (context, ref, _) {
                final loadState = ref.watch(profileNotiferProvider.select(
                  (value) => value.editProfileLoadState,
                ));
                final user = ref.watch(userNotifierProvider);
                final hasChanges =
                    firstNameController.text.trim() !=
                        (user.firstName ?? '') ||
                    lastNameController.text.trim() !=
                        (user.lastName ?? '') ||
                    phoneNumber != (user.phoneNumber ?? '');
                return AppButton(
                  isLoading: loadState == LoadState.loading,
                  isEnabled: hasChanges,
                  buttonText: context.l10n.updateProfile.toUpperCase(),
                  onPressed: _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final notifier = ref.read(profileNotiferProvider.notifier);
    final data = EditProfileModel(
      phoneNumber: phoneNumber,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );
    notifier.updateProfile(
      data,
      onSuccess: () {
        context.showCustomDialog(
          child: AppSuccessContent(
            title: 'Success',
            subtitle: 'Profile Updated Successfully',
            buttonText: context.l10n.continue_,
            onPressed: () {
              context.pop();
              context.pushReplacement(AppRoutes.profile);
            },
          ),
        );
        ref.read(userNotifierProvider.notifier).refreshUser();
      },
      onError: (message) => context.showError(message),
    );
  }
}
