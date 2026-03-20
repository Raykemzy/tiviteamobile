import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';
import 'package:tivi_tea/features/notifications/view_model/notifications_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsNotifierProvider.notifier).getNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 200) {
      ref.read(notificationsNotifierProvider.notifier).getNotifications(
            page: ref.read(notificationsNotifierProvider).currentPage + 1,
            loadMore: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final groupedNotifications = _groupNotifications(state.notifications);
    final isInitialLoading =
        state.loadState == LoadState.loading && state.notifications.isEmpty;

    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Builder(
          builder: (context) {
            if (isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.loadState == LoadState.error &&
                state.notifications.isEmpty) {
              return _NotificationsMessageState(
                message: state.errorMessage ?? 'Unable to load notifications.',
                actionLabel: 'Retry',
                onPressed: () => ref
                    .read(notificationsNotifierProvider.notifier)
                    .getNotifications(),
              );
            }

            if (state.notifications.isEmpty) {
              return const _NotificationsMessageState(
                message: 'No notifications yet.',
              );
            }

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: state.markingAllAsRead
                        ? null
                        : () => ref
                            .read(notificationsNotifierProvider.notifier)
                            .markAllAsRead(),
                    child: state.markingAllAsRead
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark all as read'),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(notificationsNotifierProvider.notifier)
                        .getNotifications(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: groupedNotifications.length + 1,
                      itemBuilder: (context, index) {
                        if (index == groupedNotifications.length) {
                          return Visibility(
                            visible: state.loadState == LoadState.loadmore,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        final group = groupedNotifications[index];
                        final unreadIds = group.notifications
                            .where((item) => !item.isRead)
                            .map((item) => item.id)
                            .toList();
                        final isMarkingGroup = state.markingGroupKeys.contains(
                          group.key,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: index == 0 ? 0 : 20.h,
                                bottom: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      group.label,
                                      style: context.theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (unreadIds.isNotEmpty)
                                    TextButton(
                                      onPressed: isMarkingGroup
                                          ? null
                                          : () => ref
                                              .read(
                                                notificationsNotifierProvider
                                                    .notifier,
                                              )
                                              .markDayAsRead(
                                                groupKey: group.key,
                                                notificationIds: unreadIds,
                                              ),
                                      child: isMarkingGroup
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Mark all as read'),
                                    ),
                                ],
                              ),
                            ),
                            ...group.notifications.map(
                              (notification) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _NotificationItem(
                                  notification: notification,
                                  onTap: () async {
                                    await ref
                                        .read(
                                          notificationsNotifierProvider
                                              .notifier,
                                        )
                                        .markNotificationAsRead(
                                            notification.id);
                                    if (!context.mounted) return;
                                    context.push(
                                      '${AppRoutes.notificationsView}/${AppRoutes.notificationDetailsView}',
                                      extra:
                                          notification.copyWith(isRead: true),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_NotificationGroup> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final grouped = <String, List<NotificationModel>>{};
    for (final notification in notifications) {
      final createdAt = notification.createdAt ?? DateTime.now();
      final key = DateFormat('yyyy-MM-dd').format(createdAt);
      grouped.putIfAbsent(key, () => []).add(notification);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return entries.map((entry) {
      final date = DateTime.tryParse(entry.key)?.toLocal();
      return _NotificationGroup(
        key: entry.key,
        label: _groupLabel(date),
        notifications: entry.value,
      );
    }).toList();
  }

  String _groupLabel(DateTime? date) {
    if (date == null) {
      return 'Unknown Date';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Today';
    }
    if (target == yesterday) {
      return 'Yesterday';
    }
    return DateFormat('d MMM yyyy').format(date);
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = notification.isRead
        ? const Color(0xFFE8E8EB)
        : context.theme.primaryColor.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: context.width,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE8E8EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: indicatorColor,
              ),
              child: Center(
                child: AppSvgWidget(
                  path: Assets.svgs.notificationIcon.path,
                  color: notification.isRead
                      ? const Color(0xFF8A8A99)
                      : Colors.white,
                  width: 18.w,
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    notification.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C5C66),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsMessageState extends StatelessWidget {
  const _NotificationsMessageState({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5C5C66),
            ),
          ),
          if (actionLabel != null && onPressed != null) ...[
            12.verticalSpace,
            TextButton(
              onPressed: onPressed,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationGroup {
  const _NotificationGroup({
    required this.key,
    required this.label,
    required this.notifications,
  });

  final String key;
  final String label;
  final List<NotificationModel> notifications;
}
