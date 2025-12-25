import '../models/schedule.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling schedules
class ScheduleService {
  final ApiClient _apiClient;

  ScheduleService(this._apiClient);

  /// Get all schedules for the current user
  Future<List<Schedule>> getSchedules({String? enrollmentId, int? dayOfWeek}) async {
    try {
      final queryParameters = <String, dynamic>{
        if (enrollmentId != null) 'enrollmentId': enrollmentId,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      };

      final response = await _apiClient.get(
        '/schedules/schedules',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      final List<dynamic> schedules = data is List ? data : [];

      return schedules.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific schedule by ID
  Future<Schedule> getSchedule(String id) async {
    try {
      final response = await _apiClient.get('/schedules/schedules/$id');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return Schedule.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new schedule
  Future<Map<String, dynamic>> createSchedule({
    required String enrollmentId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? location,
    String? scheduleType,
    bool isRecurring = true,
  }) async {
    try {
      final response = await _apiClient.post(
        '/schedules/schedules',
        data: {
          'enrollmentId': enrollmentId,
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          if (location != null) 'location': location,
          if (scheduleType != null) 'scheduleType': scheduleType,
          'isRecurring': isRecurring,
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

  /// Update a schedule
  Future<void> updateSchedule(
    String id, {
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? scheduleType,
    bool? isRecurring,
  }) async {
    try {
      await _apiClient.put(
        '/schedules/schedules/$id',
        data: {
          if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
          if (startTime != null) 'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
          if (location != null) 'location': location,
          if (scheduleType != null) 'scheduleType': scheduleType,
          if (isRecurring != null) 'isRecurring': isRecurring,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _apiClient.delete('/schedules/schedules/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get weekly schedule
  Future<Map<int, List<Schedule>>> getWeeklySchedule() async {
    try {
      final schedules = await getSchedules();

      // Group schedules by day of week
      final Map<int, List<Schedule>> weeklySchedule = {};

      for (var schedule in schedules) {
        if (!weeklySchedule.containsKey(schedule.dayOfWeek)) {
          weeklySchedule[schedule.dayOfWeek] = [];
        }
        weeklySchedule[schedule.dayOfWeek]!.add(schedule);
      }

      // Sort schedules within each day by start time
      for (var day in weeklySchedule.keys) {
        weeklySchedule[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      return weeklySchedule;
    } catch (e) {
      rethrow;
    }
  }
}
