// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type:
          $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.info,
      category:
          $enumDecodeNullable(
            _$NotificationCategoryEnumMap,
            json['category'],
          ) ??
          NotificationCategory.system,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      actionUrl: json['action_url'] as String?,
      actionLabel: json['action_label'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      imageUrl: json['image_url'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'category': _$NotificationCategoryEnumMap[instance.category]!,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'action_url': instance.actionUrl,
      'action_label': instance.actionLabel,
      'metadata': instance.metadata,
      'image_url': instance.imageUrl,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.info: 'INFO',
  NotificationType.success: 'SUCCESS',
  NotificationType.warning: 'WARNING',
  NotificationType.error: 'ERROR',
};

const _$NotificationCategoryEnumMap = {
  NotificationCategory.system: 'SYSTEM',
  NotificationCategory.academic: 'ACADEMIC',
  NotificationCategory.grade: 'GRADE',
  NotificationCategory.schedule: 'SCHEDULE',
  NotificationCategory.payment: 'PAYMENT',
  NotificationCategory.subscription: 'SUBSCRIPTION',
  NotificationCategory.reminder: 'REMINDER',
};
