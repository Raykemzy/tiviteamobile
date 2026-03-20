import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';
import 'package:tivi_tea/features/notifications/view_model/notifications_notifier.dart';

class NotificationDetailView extends ConsumerWidget {
  const NotificationDetailView({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchiving = ref.watch(
      notificationsNotifierProvider.select(
        (value) => value.archivingNotificationIds.contains(notification.id),
      ),
    );

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Notification',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE8E8EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    notification.description,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C5C66),
                    ),
                  ),
                  if (notification.createdAt != null) ...[
                    16.verticalSpace,
                    Text(
                      DateFormat('EEE, d MMM yyyy • h:mm a')
                          .format(notification.createdAt!),
                      style: context.theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF8A8A99),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            16.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isArchiving
                    ? null
                    : () async {
                        await ref
                            .read(notificationsNotifierProvider.notifier)
                            .archiveNotification(notification.id);
                        if (!context.mounted) return;
                        context.go(AppRoutes.notificationsView);
                      },
                child: isArchiving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Archive notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
