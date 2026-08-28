class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isRead,
    required this.createdAt,
    this.objectModel,
    this.objectId,
    this.raw = const {},
  });

  final String id;
  final String title;
  final String description;
  final bool isRead;
  final DateTime? createdAt;

  /// Domain object this notification points at, e.g. "Booking",
  /// "Authentication", "Marketplace".
  final String? objectModel;

  /// Id of that object. For quotation notifications this is the *quotation*
  /// id — verified live: `object_model` is "Booking" for all three quotation
  /// notifications ("Quotation Request.", "Quotation Received.", "Your
  /// Quotation Has A New Status.") and `object_id` is the quotation.
  final String? objectId;

  /// True when this notification is about an artisan quotation, which is only
  /// distinguishable by its title — `object_model` is the generic "Booking".
  bool get isQuotation =>
      objectModel == 'Booking' && title.toLowerCase().contains('quotation');

  final Map<String, dynamic> raw;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _readString(json, const ['id', 'notification_id']) ?? '',
      title: _readString(json, const ['title', 'heading', 'subject']) ??
          'Notification',
      description: _readString(
              json, const ['description', 'message', 'body', 'content']) ??
          '',
      isRead: _readBool(json, const ['is_read', 'isRead', 'read']) ?? false,
      createdAt: _readDateTime(
        json,
        const ['date_created', 'created_at', 'createdAt', 'timestamp'],
      ),
      objectModel: _readString(json, const ['object_model', 'objectModel']),
      objectId: _readString(json, const ['object_id', 'objectId']),
      raw: json,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isRead,
    DateTime? createdAt,
    String? objectModel,
    String? objectId,
    Map<String, dynamic>? raw,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      objectModel: objectModel ?? this.objectModel,
      objectId: objectId ?? this.objectId,
      createdAt: createdAt ?? this.createdAt,
      raw: raw ?? this.raw,
    );
  }

  static String? _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
    }
    return null;
  }

  static DateTime? _readDateTime(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value)?.toLocal();
      }
    }
    return null;
  }
}
