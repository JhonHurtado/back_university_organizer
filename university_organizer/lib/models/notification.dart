import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// Notification type enum
enum NotificationType {
  @JsonValue('INFO')
  info,
  @JsonValue('SUCCESS')
  success,
  @JsonValue('WARNING')
  warning,
  @JsonValue('ERROR')
  error,
}

/// Notification category enum
enum NotificationCategory {
  @JsonValue('SYSTEM')
  system,
  @JsonValue('ACADEMIC')
  academic,
  @JsonValue('GRADE')
  grade,
  @JsonValue('SCHEDULE')
  schedule,
  @JsonValue('PAYMENT')
  payment,
  @JsonValue('SUBSCRIPTION')
  subscription,
  @JsonValue('REMINDER')
  reminder,
}

/// Notification model
@JsonSerializable()
class AppNotification {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  final String title;
  final String message;
  final NotificationType type;
  final NotificationCategory category;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  @JsonKey(name: 'action_url')
  final String? actionUrl;

  @JsonKey(name: 'action_label')
  final String? actionLabel;

  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.category = NotificationCategory.system,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    this.actionLabel,
    this.metadata,
    this.imageUrl,
    this.expiresAt,
    required this.createdAt,
  });

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification has action
  bool get hasAction => actionUrl != null && actionLabel != null;

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// JSON serialization
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  /// Create copy with modifications
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationCategory? category,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    String? actionLabel,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
