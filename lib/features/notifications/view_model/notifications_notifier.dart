import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';
import 'package:tivi_tea/features/notifications/view_model/notifications_state.dart';
import 'package:tivi_tea/repositories/notifications/notifications_repo.dart';

part 'notifications_notifier.g.dart';

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  late final NotificationsRepo _repo;

  @override
  NotificationsState build() {
    _repo = NotificationsRepo(restClient: ref.read(restClient));
    return NotificationsState.initial();
  }

  Future<void> getNotifications({int page = 1, bool loadMore = false}) async {
    if (loadMore &&
        (state.loadState == LoadState.loadmore || !state.hasMorePages)) {
      return;
    }

    state = state.copyWith(
      loadState: loadMore ? LoadState.loadmore : LoadState.loading,
      errorMessage: null,
    );

    try {
      final response = await _repo.getNotifications(page);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Unable to load notifications';
      }

      final payload = response.data;
      final results = payload?.results ?? const <NotificationModel>[];
      state = state.copyWith(
        loadState: (payload?.page ?? page) < (payload?.totalPages ?? 1)
            ? LoadState.success
            : LoadState.done,
        notifications:
            loadMore ? [...state.notifications, ...results] : results,
        currentPage: payload?.page ?? page,
        totalPages: payload?.totalPages ?? state.totalPages,
        totalItems: payload?.totalItems ?? state.totalItems,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (notificationId.isEmpty || _isNotificationRead(notificationId)) {
      return;
    }

    final markingIds = {...state.markingNotificationIds, notificationId};
    state = state.copyWith(markingNotificationIds: markingIds);

    try {
      final response = await _repo.markAsRead([notificationId]);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Unable to mark notification as read';
      }
      _applyReadState([notificationId]);
    } catch (_) {
      state = state.copyWith(
        markingNotificationIds: {...state.markingNotificationIds}
          ..remove(notificationId),
      );
    }
  }

  Future<void> markDayAsRead({
    required String groupKey,
    required List<String> notificationIds,
  }) async {
    final unreadIds =
        notificationIds.where((id) => !_isNotificationRead(id)).toList();
    if (unreadIds.isEmpty) {
      return;
    }

    state = state.copyWith(
      markingGroupKeys: {...state.markingGroupKeys, groupKey},
    );

    try {
      final response = await _repo.markAsRead(unreadIds);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Unable to mark notifications as read';
      }
      _applyReadState(
        unreadIds,
        groupKeyToRemove: groupKey,
      );
    } catch (e) {
      state = state.copyWith(
        markingGroupKeys: {...state.markingGroupKeys}..remove(groupKey),
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (state.markingAllAsRead) {
      return;
    }

    state = state.copyWith(markingAllAsRead: true);
    try {
      final response = await _repo.markAllAsRead();
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Unable to mark all notifications as read';
      }
      state = state.copyWith(
        markingAllAsRead: false,
        notifications: state.notifications
            .map((item) => item.copyWith(isRead: true))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        markingAllAsRead: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> archiveNotification(String notificationId) async {
    if (notificationId.isEmpty) {
      return;
    }

    state = state.copyWith(
      archivingNotificationIds: {
        ...state.archivingNotificationIds,
        notificationId
      },
    );

    try {
      final response = await _repo.archiveNotifications([notificationId]);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Unable to archive notification';
      }

      state = state.copyWith(
        archivingNotificationIds: {...state.archivingNotificationIds}
          ..remove(notificationId),
        notifications: state.notifications
            .where((item) => item.id != notificationId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        archivingNotificationIds: {...state.archivingNotificationIds}
          ..remove(notificationId),
        errorMessage: e.toString(),
      );
    }
  }

  bool _isNotificationRead(String notificationId) {
    return state.notifications.any(
      (item) => item.id == notificationId && item.isRead,
    );
  }

  void _applyReadState(
    List<String> notificationIds, {
    String? groupKeyToRemove,
  }) {
    state = state.copyWith(
      markingNotificationIds: {...state.markingNotificationIds}
        ..removeAll(notificationIds),
      markingGroupKeys: groupKeyToRemove == null
          ? state.markingGroupKeys
          : ({...state.markingGroupKeys}..remove(groupKeyToRemove)),
      notifications: state.notifications.map((item) {
        if (notificationIds.contains(item.id)) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList(),
    );
  }
}
