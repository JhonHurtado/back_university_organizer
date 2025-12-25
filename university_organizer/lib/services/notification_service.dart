import 'api_client.dart';
import 'api_exception.dart';

/// Service for managing notifications
class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  /// Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (isRead != null) 'isRead': isRead,
        if (type != null) 'type': type,
      };

      final response = await _apiClient.get(
        '/notifications/notifications',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response =
          await _apiClient.get('/notifications/notifications/unread/count');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return data['count'] ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(
        '/notifications/notifications/$notificationId/read',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post('/notifications/notifications/mark-all-read');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('/notifications/notifications/$notificationId');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all read notifications
  Future<void> deleteAllRead() async {
    try {
      await _apiClient.delete('/notifications/notifications/read');
    } catch (e) {
      rethrow;
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response =
          await _apiClient.get('/notifications/notifications/settings');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update notification settings
  Future<void> updateSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? gradeNotifications,
    bool? scheduleNotifications,
    bool? assignmentNotifications,
  }) async {
    try {
      await _apiClient.patch(
        '/notifications/notifications/settings',
        data: {
          if (emailNotifications != null)
            'emailNotifications': emailNotifications,
          if (pushNotifications != null)
            'pushNotifications': pushNotifications,
          if (gradeNotifications != null)
            'gradeNotifications': gradeNotifications,
          if (scheduleNotifications != null)
            'scheduleNotifications': scheduleNotifications,
          if (assignmentNotifications != null)
            'assignmentNotifications': assignmentNotifications,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
