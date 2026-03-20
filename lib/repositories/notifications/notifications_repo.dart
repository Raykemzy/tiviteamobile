import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/response/generic_paginated_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/notifications/model/notification_ids_request_body.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';

final class NotificationsRepo {
  const NotificationsRepo({
    required this.restClient,
  });

  final RestClient restClient;

  Future<BaseResponse<GenericPaginatedResponse<NotificationModel>>>
      getNotifications(int page) async {
    try {
      return await restClient.getNotifications(page);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> markAsRead(List<String> notificationIds) async {
    try {
      return await restClient.markNotificationsAsRead(
        NotificationIdsRequestBody(notificationIds: notificationIds).toJson(),
      );
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> markAllAsRead() async {
    try {
      return await restClient.markAllNotificationsAsRead();
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> archiveNotifications(
    List<String> notificationIds,
  ) async {
    try {
      return await restClient.archiveNotifications(
        NotificationIdsRequestBody(notificationIds: notificationIds).toJson(),
      );
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
