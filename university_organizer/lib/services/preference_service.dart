import 'api_client.dart';
import 'api_exception.dart';

/// Service for managing user preferences
class PreferenceService {
  final ApiClient _apiClient;

  PreferenceService(this._apiClient);

  /// Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _apiClient.get('/preferences/preferences');

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

  /// Update preferences
  Future<Map<String, dynamic>> updatePreferences({
    // Notification preferences
    bool? enableNotifications,
    bool? gradeNotifications,
    bool? scheduleReminders,
    bool? assignmentReminders,
    bool? examReminders,
    int? reminderMinutesBefore,
    // Academic preferences
    String? gradeScale,
    bool? showGPA,
    bool? autoCalculateGrades,
    bool? showPercentages,
    bool? highlightPassingGrades,
    double? passingGrade,
    // Display preferences
    String? weekStartDay,
    bool? use24HourFormat,
    String? language,
    String? theme,
  }) async {
    try {
      final response = await _apiClient.put(
        '/preferences/preferences',
        data: {
          // Notification preferences
          if (enableNotifications != null)
            'enableNotifications': enableNotifications,
          if (gradeNotifications != null)
            'gradeNotifications': gradeNotifications,
          if (scheduleReminders != null)
            'scheduleReminders': scheduleReminders,
          if (assignmentReminders != null)
            'assignmentReminders': assignmentReminders,
          if (examReminders != null) 'examReminders': examReminders,
          if (reminderMinutesBefore != null)
            'reminderMinutesBefore': reminderMinutesBefore,
          // Academic preferences
          if (gradeScale != null) 'gradeScale': gradeScale,
          if (showGPA != null) 'showGPA': showGPA,
          if (autoCalculateGrades != null)
            'autoCalculateGrades': autoCalculateGrades,
          if (showPercentages != null) 'showPercentages': showPercentages,
          if (highlightPassingGrades != null)
            'highlightPassingGrades': highlightPassingGrades,
          if (passingGrade != null) 'passingGrade': passingGrade,
          // Display preferences
          if (weekStartDay != null) 'weekStartDay': weekStartDay,
          if (use24HourFormat != null) 'use24HourFormat': use24HourFormat,
          if (language != null) 'language': language,
          if (theme != null) 'theme': theme,
        },
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

  /// Reset preferences to defaults
  Future<Map<String, dynamic>> resetToDefaults() async {
    try {
      final response =
          await _apiClient.post('/preferences/preferences/reset');

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
}
