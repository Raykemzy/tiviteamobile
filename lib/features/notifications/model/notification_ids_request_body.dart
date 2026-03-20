class NotificationIdsRequestBody {
  const NotificationIdsRequestBody({
    required this.notificationIds,
  });

  final List<String> notificationIds;

  Map<String, dynamic> toJson() => {
        'notification_ids': notificationIds,
      };
}
