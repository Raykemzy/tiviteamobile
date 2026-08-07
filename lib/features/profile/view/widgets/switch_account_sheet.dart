import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/profile/view/widgets/create_other_entity_account_sheet.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';

/// Lists every entity the user could be signed in as, other than the current
/// one.
///
/// Entities the user already owns switch immediately. Entities they don't own
/// drop into the create form first and then switch automatically once it
/// succeeds — one choice from the user, regardless of which path it takes.
class SwitchAccountSheet extends ConsumerWidget {
  const SwitchAccountSheet({super.key, required this.hostContext});

  /// Context of the page that opened this sheet. Dismissing the sheet
  /// defunctions its own context, and the follow-up sheet and the snackbars
  /// both outlive it — the snackbars in particular need a context sitting
  /// below an [Overlay], which a navigator's own context is not.
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final currentEntity = user.signedInEntityType ?? EntityType.client;
    final owned = user.availableEntityTypes;
    final targets =
        EntityType.values.where((e) => e != currentEntity).toList();
    final isSwitching = ref.watch(
          profileNotiferProvider.select((v) => v.switchAccountLoadState),
        ) ==
        LoadState.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'You are signed in as ${currentEntity.label.toLowerCase()}. '
          'Choose the account you want to switch to.',
          style: context.theme.textTheme.displaySmall?.copyWith(
            color: const Color(0xFF737380),
          ),
        ),
        20.verticalSpace,
        for (final target in targets)
          _EntityOptionTile(
            entityType: target,
            isOwned: owned.contains(target),
            isBusy: isSwitching,
            onTap: () => _onTargetSelected(
              sheetContext: context,
              ref: ref,
              target: target,
              isOwned: owned.contains(target),
            ),
          ),
        16.verticalSpace,
      ],
    );
  }

  void _onTargetSelected({
    required BuildContext sheetContext,
    required WidgetRef ref,
    required EntityType target,
    required bool isOwned,
  }) {
    final sheetNavigator = Navigator.of(sheetContext);
    if (sheetNavigator.canPop()) sheetNavigator.pop();

    if (isOwned) {
      _switchTo(ref: ref, target: target);
      return;
    }

    // Not owned yet — collect the entity's details, then continue into the
    // switch without asking the user to pick again.
    hostContext.showBottomSheet(
      title: 'Create ${target.label} Account',
      showButton: false,
      // The partner form in particular is long; cap it so the sheet stays a
      // sheet and scrolls internally instead of covering the screen.
      maxHeightFactor: .7,
      child: CreateOtherEntityAccountSheet(
        entityType: target,
        onCreated: () {
          final createNavigator = Navigator.of(hostContext);
          if (createNavigator.canPop()) createNavigator.pop();
          _switchTo(ref: ref, target: target);
        },
      ),
    );
  }

  void _switchTo({
    required WidgetRef ref,
    required EntityType target,
  }) {
    ref.read(profileNotiferProvider.notifier).switchAccount(
          target,
          onSuccess: () => hostContext.showSuccess(
            'Switched to your ${target.label.toLowerCase()} account.',
          ),
          onError: (message) => hostContext.showError(message),
        );
  }
}

class _EntityOptionTile extends StatelessWidget {
  const _EntityOptionTile({
    required this.entityType,
    required this.isOwned,
    required this.isBusy,
    required this.onTap,
  });

  final EntityType entityType;
  final bool isOwned;
  final bool isBusy;
  final VoidCallback onTap;

  String get _subtitle {
    if (isOwned) {
      return 'Switch to this account';
    }
    switch (entityType) {
      case EntityType.partner:
        return 'Not set up yet — add your business details to continue';
      case EntityType.artisan:
        return 'Not set up yet — add your service details to continue';
      case EntityType.client:
        return 'Not set up yet — confirm your address to continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: isBusy ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entityType.label} account',
                      style: context.theme.textTheme.labelMedium,
                    ),
                    4.verticalSpace,
                    Text(
                      _subtitle,
                      style: context.theme.textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF737380),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isOwned ? Icons.swap_horiz_rounded : Icons.add_rounded,
                size: 20.sp,
                color: context.theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
