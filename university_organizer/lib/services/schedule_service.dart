import '../models/schedule.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling schedules
class ScheduleService {
  final ApiClient _apiClient;

  ScheduleService(this._apiClient);

  /// Get all schedules for the current user
  Future<List<Schedule>> getSchedules({String? enrollmentId}) async {
    try {
      final response = await _apiClient.get(
        '/schedules',
        queryParameters: enrollmentId != null
            ? {'enrollment_id': enrollmentId}
            : null,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      return data.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get schedules for a specific day
  Future<List<Schedule>> getSchedulesByDay(int dayOfWeek) async {
    try {
      final response = await _apiClient.get(
        '/schedules',
        queryParameters: {'day_of_week': dayOfWeek},
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      return data.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific schedule by ID
  Future<Schedule> getSchedule(String id) async {
    try {
      final response = await _apiClient.get('/schedules/$id');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Schedule.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new schedule
  Future<Schedule> createSchedule({
    required String enrollmentId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    String? building,
    ScheduleType type = ScheduleType.classType,
    String? color,
    String? notes,
    bool isRecurring = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/schedules',
        data: {
          'enrollment_id': enrollmentId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          if (room != null) 'room': room,
          if (building != null) 'building': building,
          'type': type.name.toUpperCase(),
          if (color != null) 'color': color,
          if (notes != null) 'notes': notes,
          'is_recurring': isRecurring,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Schedule.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a schedule
  Future<Schedule> updateSchedule(
    String id, {
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? building,
    ScheduleType? type,
    String? color,
    String? notes,
    bool? isRecurring,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/schedules/$id',
        data: {
          if (dayOfWeek != null) 'day_of_week': dayOfWeek,
          if (startTime != null) 'start_time': startTime,
          if (endTime != null) 'end_time': endTime,
          if (room != null) 'room': room,
          if (building != null) 'building': building,
          if (type != null) 'type': type.name.toUpperCase(),
          if (color != null) 'color': color,
          if (notes != null) 'notes': notes,
          if (isRecurring != null) 'is_recurring': isRecurring,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Schedule.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _apiClient.delete('/schedules/$id');
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

  /// Check for schedule conflicts
  Future<List<Schedule>> checkConflicts(
    int dayOfWeek,
    String startTime,
    String endTime, {
    String? excludeScheduleId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/schedules/check-conflicts',
        data: {
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          if (excludeScheduleId != null) 'exclude_id': excludeScheduleId,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['conflicts'] ?? [];

      return data.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Export schedule to PDF
  Future<String> exportToPDF() async {
    try {
      final response = await _apiClient.post('/schedules/export/pdf');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return response.data['url'] ?? '';
    } catch (e) {
      rethrow;
    }
  }

  /// Export schedule to Excel
  Future<String> exportToExcel() async {
    try {
      final response = await _apiClient.post('/schedules/export/excel');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return response.data['url'] ?? '';
    } catch (e) {
      rethrow;
    }
  }
}
