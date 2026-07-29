import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_navbar.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/common/customizable_row.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({
    this.homeScreenAppBar = false,
    this.showBackButton = true,
    this.showBackButtonForHomeScreenAppBar = false,
    this.showHamburgerMenu = false,
    this.title,
    this.userName,
    this.onTap,
    this.color,
    this.padding,
    super.key,
  });
  final bool homeScreenAppBar;
  final bool showHamburgerMenu;
  final bool showBackButton;
  final bool showBackButtonForHomeScreenAppBar;
  final String? title;
  final String? userName;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  /// Back navigation that can't dead-end. `context.pop()` throws when there's
  /// nothing on the stack to pop — which happens whenever a screen is reached
  /// via `go` rather than `push` — so fall back to the home tab.
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.homeView);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appAccessState = ref.watch(loginNotifierProvider).appAccessState;
    final isGuest = appAccessState == AppAccessState.guest;
    final user = ref.watch(userNotifierProvider);
    return Container(
      padding: padding ??
          EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 18.w,
            right: 18.w,
            bottom: 10.h,
          ),
      decoration: BoxDecoration(color: color ?? Colors.white),
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          if (homeScreenAppBar) ...[
            Builder(
              builder: (context) {
                return InkWell(
                  onTap: () => showBackButtonForHomeScreenAppBar
                      ? goBack(context)
                      : scaffoldKey.currentState?.openDrawer(),
                  child: AppSvgWidget(
                    path: showBackButtonForHomeScreenAppBar
                        ? Assets.svgs.chevronLeft.path
                        : Assets.svgs.hamburger.path,
                  ),
                );
              },
            ),
            if (title != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 30.w),
                  child: Center(
                    child: Text(
                      title!,
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16.sp,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            if (!isGuest)
              InkWell(
                onTap: () => context.push(AppRoutes.notificationsView),
                child: AppSvgWidget(path: Assets.svgs.notificationIcon.path),
              ),
            if (!isGuest) 10.horizontalSpace,
            user.profilePicture == null
                ? const CircleAvatar()
                : Container(
                    width: 40.w,
                    height: 40.h,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.theme.colorScheme.onPrimaryContainer,
                    ),
                    child: AppImageWidget(
                      borderRadius: BorderRadius.circular(50),
                      imagePath: user.profilePicture ?? '',
                    ),
                  ),
          ] else ...[
            Expanded(
              child: CustomizableRow(
                flexValues: const [1, 4, 1],
                children: [
                  if (showHamburgerMenu)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                            onTap: () => showBackButtonForHomeScreenAppBar
                                ? goBack(context)
                                : scaffoldKey.currentState?.openDrawer(),
                            child: showBackButtonForHomeScreenAppBar
                                ? IconButton(
                                    onPressed: () => goBack(context),
                                    icon: const Icon(
                                      CupertinoIcons.chevron_back,
                                    ),
                                  )
                                : AppSvgWidget(
                                    path: showBackButtonForHomeScreenAppBar
                                        ? Assets.svgs.chevronLeft.path
                                        : Assets.svgs.hamburger.path,
                                  ),
                          );
                        },
                      ),
                    )
                  else
                    switch (showBackButton) {
                      true => IconButton(
                          onPressed: () =>
                              onTap != null ? onTap!() : goBack(context),
                          icon: const Icon(CupertinoIcons.chevron_back),
                        ),
                      // AppSvgWidget(
                      //     path: Assets.svgs.chevronLeft,
                      //     onTap: onTap ?? () => context.pop(),
                      //   ),
                      _ => const SizedBox(),
                    },
                  Center(
                    child: Text(
                      title ?? '',
                      style: context.theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16.sp,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isGuest)
                          InkWell(
                            onTap: () =>
                                context.push(AppRoutes.notificationsView),
                            child: AppSvgWidget(
                              path: Assets.svgs.notificationIcon.path,
                            ),
                          ),
                        10.horizontalSpace,
                        user.profilePicture == null
                            ? const CircleAvatar()
                            : Container(
                                width: 40.w,
                                height: 40.h,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(5),
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
                      ],
                    ),
                  )
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  static final _appBar = AppBar();

  @override
  Size get preferredSize => _appBar.preferredSize;
}
