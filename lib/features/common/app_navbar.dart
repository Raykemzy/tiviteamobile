import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_drawer.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class _NavbarDestinationItem {
  const _NavbarDestinationItem({
    required this.branchIndex,
    required this.destination,
  });

  final int branchIndex;
  final NavigationDestination destination;
}

class Navbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const Navbar({Key? key, required this.navigationShell})
      : super(key: key ?? const ValueKey('NavbarWithNestedNavigation'));

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: navigationShell,
      drawer: const AppDrawer(),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                );
              } else {
                return GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737380),
                );
              }
            },
          ),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(userNotifierProvider);
            final isClient = user.entityType == EntityType.client;
            final isArtisan = user.entityType == EntityType.artisan;
            final appAccessState =
                ref.watch(loginNotifierProvider).appAccessState;
            final destinations = <_NavbarDestinationItem>[
              _NavbarDestinationItem(
                branchIndex: 0,
                destination: NavigationDestination(
                  label: context.l10n.home,
                  icon: AppSvgWidget(
                    path: Assets.svgs.homeNavBarIcon.path,
                    color: const Color(0xFF737380),
                  ),
                  selectedIcon:
                      AppSvgWidget(path: Assets.svgs.homeNavBarIcon.path),
                ),
              ),
              _NavbarDestinationItem(
                branchIndex: 1,
                destination: NavigationDestination(
                  label: context.l10n.services,
                  icon: AppSvgWidget(path: Assets.svgs.servicesNavBarIcon.path),
                  selectedIcon: AppSvgWidget(
                    path: Assets.svgs.servicesNavBarIcon.path,
                    color: Colors.white,
                  ),
                ),
              ),
              if (appAccessState != AppAccessState.guest && !isArtisan)
                _NavbarDestinationItem(
                  branchIndex: 2,
                  destination: NavigationDestination(
                    label: isClient
                        ? context.l10n.myFavorites
                        : context.l10n.myListing,
                    icon:
                        AppSvgWidget(path: Assets.svgs.historyNavBarIcon.path),
                    selectedIcon: AppSvgWidget(
                      path: Assets.svgs.historyNavBarIcon.path,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (appAccessState != AppAccessState.guest)
                _NavbarDestinationItem(
                  branchIndex: 3,
                  destination: NavigationDestination(
                    label: context.l10n.profile,
                    icon:
                        AppSvgWidget(path: Assets.svgs.profileNavBarIcon.path),
                    selectedIcon: AppSvgWidget(
                      path: Assets.svgs.profileNavBarIcon.path,
                      color: Colors.white,
                    ),
                  ),
                ),
            ];
            final selectedIndex = destinations.indexWhere(
              (item) => item.branchIndex == navigationShell.currentIndex,
            );

            return NavigationBar(
              selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
              backgroundColor: context.theme.primaryColor,
              height: 80.h,
              indicatorColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations:
                  destinations.map((item) => item.destination).toList(),
              onDestinationSelected: (index) {
                _goBranch(destinations[index].branchIndex);
              },
            );
          },
        ),
      ),
    );
  }
}
