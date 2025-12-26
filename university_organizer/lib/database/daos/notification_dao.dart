import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/notification.dart';
import '../app_database.dart';

/// Data Access Object for Notifications
class NotificationDao {
  final AppDatabase _db;

  NotificationDao(this._db);

  /// Cache TTL duration (5 minutes - notifications need frequent updates)
  static const Duration cacheTTL = Duration(minutes: 5);

  /// Insert or update a notification with cache TTL
  Future<void> insertOrUpdate(AppNotification notification, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'notifications',
      {
        'id': notification.id,
        'userId': notification.userId,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type.name.toUpperCase(),
        'category': notification.category.name.toUpperCase(),
        'isRead': notification.isRead ? 1 : 0,
        'readAt': notification.readAt?.toIso8601String(),
        'actionUrl': notification.actionUrl,
        'actionLabel': notification.actionLabel,
        'metadata': notification.metadata != null
            ? jsonEncode(notification.metadata)
            : null,
        'imageUrl': notification.imageUrl,
        'notificationExpiresAt': notification.expiresAt?.toIso8601String(),
        'createdAt': notification.createdAt.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Notification cached: ${notification.title} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple notifications
  Future<void> insertOrUpdateBatch(List<AppNotification> notifications, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final notification in notifications) {
      batch.insert(
        'notifications',
        {
          'id': notification.id,
          'userId': notification.userId,
          'title': notification.title,
          'message': notification.message,
          'type': notification.type.name.toUpperCase(),
          'category': notification.category.name.toUpperCase(),
          'isRead': notification.isRead ? 1 : 0,
          'readAt': notification.readAt?.toIso8601String(),
          'actionUrl': notification.actionUrl,
          'actionLabel': notification.actionLabel,
          'metadata': notification.metadata != null
              ? jsonEncode(notification.metadata)
              : null,
          'imageUrl': notification.imageUrl,
          'notificationExpiresAt': notification.expiresAt?.toIso8601String(),
          'createdAt': notification.createdAt.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${notifications.length} notifications');
  }

  /// Get notification by ID
  Future<AppNotification?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached notification expired: ${map['title']}');
      return null;
    }

    return _mapToNotification(map);
  }

  /// Get all notifications for a user
  Future<List<AppNotification>> getByUserId(String userId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'notifications',
      where: includeExpired ? 'userId = ?' : 'userId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [userId] : [userId, now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToNotification(map)).toList();
  }

  /// Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'notifications',
      where: includeExpired ? 'isRead = 0' : 'isRead = 0 AND expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToNotification(map)).toList();
  }

  /// Get all notifications
  Future<List<AppNotification>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'notifications',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToNotification(map)).toList();
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final database = await _db.database;
    await database.update(
      'notifications',
      {
        'isRead': 1,
        'readAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('✅ Notification marked as read: $id');
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final database = await _db.database;
    await database.update(
      'notifications',
      {
        'isRead': 1,
        'readAt': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('✅ All notifications marked as read');
  }

  /// Delete notification by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all notifications
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('notifications');
  }

  /// Clear read notifications
  Future<int> clearReadNotifications() async {
    final database = await _db.database;
    return await database.delete(
      'notifications',
      where: 'isRead = 1',
    );
  }

  /// Convert database map to AppNotification model
  AppNotification _mapToNotification(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: _parseNotificationType(map['type'] as String),
      category: _parseNotificationCategory(map['category'] as String),
      isRead: (map['isRead'] as int) == 1,
      readAt: map['readAt'] != null
          ? DateTime.parse(map['readAt'] as String)
          : null,
      actionUrl: map['actionUrl'] as String?,
      actionLabel: map['actionLabel'] as String?,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
      imageUrl: map['imageUrl'] as String?,
      expiresAt: map['notificationExpiresAt'] != null
          ? DateTime.parse(map['notificationExpiresAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String type) {
    switch (type.toUpperCase()) {
      case 'SUCCESS':
        return NotificationType.success;
      case 'WARNING':
        return NotificationType.warning;
      case 'ERROR':
        return NotificationType.error;
      default:
        return NotificationType.info;
    }
  }

  /// Parse notification category from string
  NotificationCategory _parseNotificationCategory(String category) {
    switch (category.toUpperCase()) {
      case 'ACADEMIC':
        return NotificationCategory.academic;
      case 'GRADE':
        return NotificationCategory.grade;
      case 'SCHEDULE':
        return NotificationCategory.schedule;
      case 'PAYMENT':
        return NotificationCategory.payment;
      case 'SUBSCRIPTION':
        return NotificationCategory.subscription;
      case 'REMINDER':
        return NotificationCategory.reminder;
      default:
        return NotificationCategory.system;
    }
  }
}
