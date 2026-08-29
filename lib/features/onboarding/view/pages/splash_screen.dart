import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/services/websocket/notification_websocket_service.dart';
import 'package:tivi_tea/core/services/remember_me_service.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/onboarding/view_model/onboarding_notifier.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (mounted) {
        final rememberMeService = ref.read(rememberMeServiceProvider);

        // Check if remember me is enabled and data is valid
        if (rememberMeService.shouldUseRememberMe()) {
          // Get the validated user data
          final user = rememberMeService.getValidatedUser();
          if (user != null) {
            // Update the user notifier with the validated user data
            final userNotifier = ref.read(userNotifierProvider.notifier);
            userNotifier.updateUser(user);

            // Update the login notifier to reflect that user is logged in
            final loginNotifier = ref.read(loginNotifierProvider.notifier);
            loginNotifier.setAppAccessState(AppAccessState.user);

            // A remembered session is a logged-in session: without this the
            // socket only ever connected on a manual login, so restored users
            // got no realtime notifications.
            ref
                .read(notificationWebSocketServiceProvider.notifier)
                .connect();

            // Navigate to home screen
            context.pushReplacement(AppRoutes.homeView);
            return;
          }
        }

        // If remember me validation fails, clear the data
        if (ref.read(getRememberUserStatusProvider)) {
          await rememberMeService.clearRememberMeData();
        }

        if (mounted) {
          context.push(AppRoutes.selectUserTypeView);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.width,
        height: context.height,
        color: context.theme.primaryColor,
        child: Center(
          child: Assets.images.appLogo.image(
            fit: BoxFit.scaleDown,
            height: 100.h,
            width: 150.w,
          ),
        ),
      ),
    );
  }
}
