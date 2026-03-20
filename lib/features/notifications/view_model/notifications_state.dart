import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';

class NotificationsState {
  const NotificationsState({
    required this.loadState,
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.markingAllAsRead,
    required this.markingGroupKeys,
    required this.markingNotificationIds,
    required this.archivingNotificationIds,
    this.errorMessage,
  });

  factory NotificationsState.initial() {
    return const NotificationsState(
      loadState: LoadState.idle,
      notifications: [],
      currentPage: 0,
      totalPages: 1,
      totalItems: 0,
      markingAllAsRead: false,
      markingGroupKeys: <String>{},
      markingNotificationIds: <String>{},
      archivingNotificationIds: <String>{},
      errorMessage: null,
    );
  }

  final LoadState loadState;
  final List<NotificationModel> notifications;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool markingAllAsRead;
  final Set<String> markingGroupKeys;
  final Set<String> markingNotificationIds;
  final Set<String> archivingNotificationIds;
  final String? errorMessage;

  bool get hasMorePages => currentPage < totalPages;

  NotificationsState copyWith({
    LoadState? loadState,
    List<NotificationModel>? notifications,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? markingAllAsRead,
    Set<String>? markingGroupKeys,
    Set<String>? markingNotificationIds,
    Set<String>? archivingNotificationIds,
    String? errorMessage,
  }) {
    return NotificationsState(
      loadState: loadState ?? this.loadState,
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      markingAllAsRead: markingAllAsRead ?? this.markingAllAsRead,
      markingGroupKeys: markingGroupKeys ?? this.markingGroupKeys,
      markingNotificationIds:
          markingNotificationIds ?? this.markingNotificationIds,
      archivingNotificationIds:
          archivingNotificationIds ?? this.archivingNotificationIds,
      errorMessage: errorMessage,
    );
  }
}
