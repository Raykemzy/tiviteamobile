import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/features/profile/view/widgets/create_other_entity_account_sheet.dart';
import 'package:tivi_tea/features/profile/model/profile_item_model.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/enums/enums.dart';

mixin ProfileItemMixin {
  List<ProfileItemModel> getProfileItems({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final user = ref.watch(userNotifierProvider);
    final entityType = user.entityType ?? EntityType.client;
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
      if (entityType == EntityType.client)
        ProfileItemModel(
          label: 'Create Artisan Account',
          onTap: () => context.showBottomSheet(
            title: 'Create Artisan Account',
            showButton: false,
            child: const CreateOtherEntityAccountSheet(
              entityType: EntityType.artisan,
            ),
          ),
        ),
      ProfileItemModel(
        label: context.l10n.changePassword,
        icon: Assets.svgs.profilePassword.path,
        onTap: () => context.push(
          '${AppRoutes.profile}/${AppRoutes.changePasswordView}',
        ),
      ),
      if (entityType == EntityType.artisan || entityType == EntityType.partner)
        ProfileItemModel(
          label: entityType == EntityType.artisan
              ? 'Switch to Partner'
              : 'Switch to Artisan',
          onTap: () {
            ref.read(profileNotiferProvider.notifier).switchAccount(
              entityType == EntityType.artisan
                  ? EntityType.partner
                  : EntityType.artisan,
              onSuccess: () {
                context.showSuccess('Profile switched successfully.');
              },
              onError: (message) => context.showError(message),
            );
          },
        ),
    ];
  }
}
