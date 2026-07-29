import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/features/profile/model/profile_item_model.dart';
import 'package:tivi_tea/features/profile/view/widgets/switch_account_sheet.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

mixin ProfileItemMixin {
  List<ProfileItemModel> getProfileItems({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final user = ref.watch(userNotifierProvider);
    return [
      ProfileItemModel(
        label: '${user.firstName} ${user.lastName}',
        icon: Assets.svgs.profileEdit.path,
        onTap: () {},
      ),
      ProfileItemModel(
        label: user.phoneNumber ?? '',
        icon: Assets.svgs.profilePhone.path,
        onTap: () {},
      ),
      ProfileItemModel(
        label: user.email ?? '',
        icon: Assets.svgs.profileMail.path,
        onTap: () {},
      ),
      ProfileItemModel(
        label: context.l10n.changePassword,
        icon: Assets.svgs.profilePassword.path,
        onTap: () => context.push(
          '${AppRoutes.profile}/${AppRoutes.changePasswordView}',
        ),
      ),
      // One entry for every other entity — the sheet handles creating the
      // entity first when the user doesn't own it yet.
      ProfileItemModel(
        label: 'Switch account',
        onTap: () => context.showBottomSheet(
          title: 'Switch account',
          showButton: false,
          child: SwitchAccountSheet(hostContext: context),
        ),
      ),
    ];
  }
}
