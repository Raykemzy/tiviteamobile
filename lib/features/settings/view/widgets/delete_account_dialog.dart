import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/services/websocket/notification_websocket_service.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';

/// Confirms, then permanently deletes the signed-in account. Shared by the
/// Profile tab and Settings so App Review finds it from either place.
///
/// The dialog stays open with a spinner until the server answers, so the
/// user always sees the outcome.
void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  context.showCustomDialog(
    dismissible: false,
    child: _DeleteAccountDialog(hostContext: context),
  );
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.hostContext});

  /// The screen that opened the dialog; navigation after deletion happens
  /// from here once the dialog itself is gone.
  final BuildContext hostContext;

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  bool _deleting = false;

  void _delete() {
    setState(() => _deleting = true);
    ref.read(loginNotifierProvider.notifier).deleteAccount(
      onSuccess: () {
        ref.read(notificationWebSocketServiceProvider.notifier).disconnect();
        if (mounted) Navigator.of(context).pop();
        final host = widget.hostContext;
        if (!host.mounted) return;
        host.showSuccess('Your account has been deleted.');
        host.go(AppRoutes.selectUserTypeView);
      },
      onError: (error) {
        if (mounted) setState(() => _deleting = false);
        if (mounted) context.showError('Error deleting account: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Delete Account',
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        20.verticalSpace,
        Text(
          _deleting
              ? 'Deleting your account…'
              : 'Are you sure you want to delete your account? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium,
        ),
        30.verticalSpace,
        Row(
          children: [
            Expanded(
              child: AppButton(
                buttonText: 'Cancel',
                isEnabled: !_deleting,
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: Colors.grey,
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: AppButton(
                buttonText: 'Delete',
                isLoading: _deleting,
                onPressed: _delete,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
