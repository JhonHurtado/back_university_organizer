import 'package:flutter/material.dart';
import '../models/notification.dart';

/// Provider for managing notifications
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Get unread notifications
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Get unread count
  int get unreadCount => unreadNotifications.length;

  /// Get notifications by category
  List<AppNotification> getNotificationsByCategory(
      NotificationCategory category) {
    return _notifications.where((n) => n.category == category).toList();
  }

  /// Load notifications (mock data for now)
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    _notifications = [
      AppNotification(
        id: '1',
        userId: 'user-1',
        title: 'Welcome to University Organizer',
        message: 'Start by creating your first career to track your academic journey.',
        type: NotificationType.info,
        category: NotificationCategory.system,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  /// Mark notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    _notifications = _notifications.map((n) {
      if (!n.isRead) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();
    notifyListeners();
  }

  /// Delete notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Add a notification (for testing)
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
