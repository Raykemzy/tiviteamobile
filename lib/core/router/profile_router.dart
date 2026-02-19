import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/features/payment/view/payment_view.dart';
import 'package:tivi_tea/features/payment/view/withdrawl_view.dart';
import 'package:tivi_tea/features/profile/view/artisan_gallery_view.dart';
import 'package:tivi_tea/features/marketplace/view/pages/add_marketplace_item_view.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';
import 'package:tivi_tea/features/marketplace/view/pages/edit_marketplace_item_view.dart';
import 'package:tivi_tea/features/marketplace/view/pages/my_marketplace_view.dart';
import 'package:tivi_tea/features/profile/view/artisan_job_history_view.dart';
import 'package:tivi_tea/features/profile/view/change_password_view.dart';
import 'package:tivi_tea/features/profile/view/edit_profile_view.dart';
import 'package:tivi_tea/features/settings/view/pages/settings.dart';

class ProfileRouter {
  static final editProfile = GoRoute(
    path: AppRoutes.editProfileView,
    builder: (BuildContext context, GoRouterState state) {
      return const EditProfileView();
    },
  );
  static final changePassword = GoRoute(
    path: AppRoutes.changePasswordView,
    builder: (BuildContext context, GoRouterState state) {
      return const ChangePasswordView();
    },
  );
  static final settings = GoRoute(
    path: AppRoutes.settingsView,
    builder: (BuildContext context, GoRouterState state) {
      return const SettingsPage();
    },
  );
  static final paymentView = GoRoute(
    path: AppRoutes.paymentView,
    builder: (BuildContext context, GoRouterState state) {
      return const PaymentView();
    },
  );
  static final withdrawalView = GoRoute(
    path: AppRoutes.withdrawalView,
    builder: (BuildContext context, GoRouterState state) {
      return const WithdrawalView();
    },
  );
  static final artisanGalleryView = GoRoute(
    path: AppRoutes.artisanGalleryView,
    builder: (BuildContext context, GoRouterState state) {
      return const ArtisanGalleryView();
    },
  );
  static final jobHistoryView = GoRoute(
    path: AppRoutes.jobHistoryView,
    builder: (BuildContext context, GoRouterState state) {
      return const JobHistoryView();
    },
  );
  static final myMarketplaceView = GoRoute(
    path: AppRoutes.myMarketplaceView,
    builder: (BuildContext context, GoRouterState state) {
      return const MyMarketplaceView();
    },
    routes: [
      GoRoute(
        path: AppRoutes.addMarketplaceItemView,
        builder: (BuildContext context, GoRouterState state) {
          return const AddMarketplaceItemView();
        },
      ),
      GoRoute(
        path: AppRoutes.editMarketplaceItemView,
        builder: (BuildContext context, GoRouterState state) {
          final item = state.extra as OwnerMarketplaceItemModel;
          return EditMarketplaceItemView(item: item);
        },
      ),
    ],
  );
}
