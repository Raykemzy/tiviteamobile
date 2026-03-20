import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/kyc/model/enums.dart';
import 'package:tivi_tea/features/kyc/view/widgets/bottom_sheet_widget.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/view/widgets/profile_appbar_header.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/services/view_model/service_provider/partner_services_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/repositories/user/user_repo_impl.dart';

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final profilePicLoadState = ref.watch(profileNotiferProvider.select(
      (value) => value.editProfileLoadState,
    ));
    final imageUploadState = ref.watch(partnerServicesNotiferProvider.select(
      (value) => value.cloudinaryUploadState,
    ));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const ProfileAppbarHeader(),
        AnimatedPositioned(
          left: 0,
          right: 0,
          bottom: -80,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              profilePicLoadState == LoadState.loading ||
                      imageUploadState == LoadState.loading
                  ? const CupertinoActivityIndicator()
                  : GestureDetector(
                      onTap: () => _showBottomSheet(context, ref),
                      child: Stack(
                        children: [
                          user.profilePicture == null
                              ? const CircleAvatar(radius: 50)
                              : Container(
                                  width: 90.w,
                                  height: 90.h,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                  child: AppImageWidget(
                                    borderRadius: BorderRadius.circular(50),
                                    imagePath: user.profilePicture ?? '',
                                  ),
                                ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  context.theme.primaryColor.withValues(
                                alpha: 0.5,
                              ),
                              child: AppSvgWidget(
                                path: Assets.svgs.camera.path,
                                width: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              10.verticalSpace,
              Text(
                '${user.firstName} ${user.lastName}',
                style: context.theme.textTheme.titleLarge?.copyWith(
                  color: context.theme.primaryColor,
                  fontSize: 20.sp,
                ),
              ),
            ],
          ),
        ),
        if ((user.entityType == EntityType.artisan ||
            user.entityType == EntityType.partner))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileTypeSwitchTag(entityType: user.entityType!),
            ],
          ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref) {
    context.showBottomSheet(
      title: context.l10n.uploadDocument,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BottomSheetWidget(
              chooseFileType: ChooseFileType.takePhoto,
              onImageSelected: (file) => _updateProfilePic(file, ref, context),
            ),
            20.horizontalSpace,
            BottomSheetWidget(
              chooseFileType: ChooseFileType.selectFromGallery,
              onImageSelected: (file) => _updateProfilePic(file, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfilePic(
    XFile file,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final notifier = ref.read(profileNotiferProvider.notifier);
    final user = ref.read(userRepositoryProvider).getUser();
    final image = await _uploadImages(file, ref);
    final data = EditProfileModel(
      phoneNumber: user.phoneNumber,
      profilePicture: image.first,
    );
    notifier.updateProfile(
      data,
      onSuccess: () {
        context.showSuccess('Profile Picture successfully uploaded');
        ref.read(userNotifierProvider.notifier).refreshUser();
      },
      onError: (message) => context.showError(message),
    );
  }

  Future<List<String>> _uploadImages(XFile file, WidgetRef ref) async {
    final notifier = ref.read(partnerServicesNotiferProvider.notifier);
    final imageUrls = await notifier.uploadImages([file]);

    return imageUrls;
  }

  @override
  Size get preferredSize => const Size.fromHeight(150);
}

class _ProfileTypeSwitchTag extends ConsumerStatefulWidget {
  const _ProfileTypeSwitchTag({required this.entityType});

  final EntityType entityType;

  @override
  ConsumerState<_ProfileTypeSwitchTag> createState() =>
      _ProfileTypeSwitchTagState();
}

class _ProfileTypeSwitchTagState extends ConsumerState<_ProfileTypeSwitchTag> {
  bool _isExpanded = false;
  Timer? _collapseTimer;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final switchLoadState = ref.watch(
      profileNotiferProvider.select((value) => value.switchAccountLoadState),
    );
    final isLoading = switchLoadState == LoadState.loading;
    final currentEntityType =
        ref.watch(userNotifierProvider).entityType ?? widget.entityType;
    final targetEntityType = _getSwitchTarget(currentEntityType);
    final isSwitchable = targetEntityType != null;
    final collapsedLabel = _getProfileLabel(currentEntityType);
    final expandedLabel = _getSwitchLabel(targetEntityType);

    if (!isSwitchable) {
      return const SizedBox.shrink();
    }

    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : () => _handleTap(context, targetEntityType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: _isExpanded ? 18.w : 16.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: context.theme.dividerColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isLoading
                        ? 'Switching...'
                        : (_isExpanded ? expandedLabel : collapsedLabel),
                    key: ValueKey(
                      '${_isExpanded}_${isLoading}_${currentEntityType.name}',
                    ),
                    style: context.theme.textTheme.displayLarge?.copyWith(
                      color: Colors.black.withValues(alpha: 0.55),
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                if (isLoading || _isExpanded) 8.horizontalSpace,
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 16.w,
                          height: 16.w,
                          child: const CupertinoActivityIndicator(radius: 8),
                        )
                      : _isExpanded
                          ? Icon(
                              Icons.swap_horiz_rounded,
                              key: const ValueKey('switchIcon'),
                              size: 18.sp,
                              color: Colors.black.withValues(alpha: 0.55),
                            )
                          : const SizedBox(key: ValueKey('emptyIcon')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, EntityType? targetEntityType) {
    if (targetEntityType == null) {
      return;
    }

    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
      _startCollapseTimer();
      return;
    }

    _collapseTimer?.cancel();
    ref.read(profileNotiferProvider.notifier).switchAccount(
      targetEntityType,
      onSuccess: () {
        if (!mounted) return;
        context.showSuccess('Profile switched successfully.');
        context.go(AppRoutes.homeView);
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isExpanded = false;
        });
        context.showError(message);
      },
    );
  }

  void _startCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_isExpanded) {
        return;
      }
      setState(() {
        _isExpanded = false;
      });
    });
  }

  EntityType? _getSwitchTarget(EntityType? entityType) {
    switch (entityType) {
      case EntityType.partner:
        return EntityType.artisan;
      case EntityType.artisan:
        return EntityType.partner;
      case EntityType.client:
      case null:
        return null;
    }
  }

  String _getProfileLabel(EntityType? entityType) {
    switch (entityType) {
      case EntityType.partner:
        return 'Partner Profile';
      case EntityType.artisan:
        return 'Artisan Profile';
      case EntityType.client:
      case null:
        return 'Profile';
    }
  }

  String _getSwitchLabel(EntityType? targetEntityType) {
    switch (targetEntityType) {
      case EntityType.partner:
        return 'Switch to Partner';
      case EntityType.artisan:
        return 'Switch to Artisan';
      case EntityType.client:
      case null:
        return 'Switch Profile';
    }
  }
}
