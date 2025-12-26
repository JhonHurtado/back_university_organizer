import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../database/daos/notification_dao.dart';
import '../database/app_database.dart';

/// Provider for managing notifications with cache-first strategy
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final NotificationDao _notificationDao;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  NotificationProvider(this._notificationService)
      : _notificationDao = NotificationDao(AppDatabase.instance);

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

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

  /// Load notifications with cache-first strategy
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    try {
      _isLoading = true;
      _error = null;

      if (refresh) {
        _currentPage = 1;
        _notifications.clear();
        _hasMore = true;
      }

      notifyListeners();

      if (!refresh && _currentPage == 1) {
        // Try to load from cache first (only for first page)
        final cachedNotifications = await _notificationDao.getAll();
        if (cachedNotifications.isNotEmpty) {
          _notifications = cachedNotifications;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedNotifications.length} notifications from cache');

          // Fetch fresh data in background
          _fetchAndCacheNotifications(refresh: true);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheNotifications(refresh: refresh);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading notifications: $e');

      // Try to load expired cache as fallback
      if (_currentPage == 1) {
        final expiredCache = await _notificationDao.getAll(includeExpired: true);
        if (expiredCache.isNotEmpty) {
          _notifications = expiredCache;
          debugPrint('⚠️  Loaded ${expiredCache.length} notifications from expired cache');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch notifications from API and cache them
  Future<void> _fetchAndCacheNotifications({bool refresh = false}) async {
    try {
      final response = await _notificationService.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      // Parse notifications from response
      final List<dynamic> notificationsData = response['notifications'] ?? [];
      final newNotifications = notificationsData
          .map((json) => AppNotification.fromJson(json))
          .toList();

      // Cache only first page notifications
      if (_currentPage == 1) {
        await _notificationDao.insertOrUpdateBatch(newNotifications);
      }

      if (refresh || _currentPage == 1) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }

      // Update pagination
      final pagination = response['pagination'];
      if (pagination != null) {
        _currentPage = pagination['currentPage'] ?? _currentPage;
        _hasMore = pagination['hasMore'] ?? false;
      } else {
        _hasMore = newNotifications.length >= 20;
      }

      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched ${newNotifications.length} notifications from API');
    } catch (e) {
      debugPrint('❌ Error fetching notifications from API: $e');
      rethrow;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _currentPage++;
    await loadNotifications();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);

      // Update cache
      await _notificationDao.markAsRead(id);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }

      debugPrint('✅ Notification marked as read: $id');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update cache
      await _notificationDao.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      notifyListeners();

      debugPrint('✅ All notifications marked as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);

      // Remove from cache
      await _notificationDao.delete(id);

      // Update local state
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();

      debugPrint('✅ Notification deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      // Clear from cache
      await _notificationDao.clearAll();

      _notifications.clear();
      notifyListeners();

      debugPrint('✅ All notifications cleared');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
      rethrow;
    }
  }

  /// Clear read notifications
  Future<void> clearReadNotifications() async {
    try {
      // Clear from cache
      await _notificationDao.clearReadNotifications();

      _notifications.removeWhere((n) => n.isRead);
      notifyListeners();

      debugPrint('✅ Read notifications cleared');
    } catch (e) {
      debugPrint('❌ Error clearing read notifications: $e');
      rethrow;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _notificationDao.clearAll();
    debugPrint('🗑️  Notification cache cleared');
  }
}
