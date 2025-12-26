import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../database/daos/schedule_dao.dart';
import '../database/app_database.dart';

/// Provider for managing schedule state with cache-first strategy
class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _scheduleService;
  final ScheduleDao _scheduleDao;

  ScheduleProvider(this._scheduleService)
      : _scheduleDao = ScheduleDao(AppDatabase.instance);

  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;
  String? _currentEnrollmentId;
  int? _currentDayOfWeek;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get schedules grouped by day
  Map<int, List<Schedule>> get schedulesByDay {
    final grouped = <int, List<Schedule>>{};
    for (var schedule in _schedules) {
      grouped.putIfAbsent(schedule.dayOfWeek, () => []).add(schedule);
    }
    return grouped;
  }

  /// Load schedules with cache-first strategy
  Future<void> loadSchedules({
    String? enrollmentId,
    int? dayOfWeek,
    bool forceRefresh = false,
  }) async {
    if (_isLoading &&
        _currentEnrollmentId == enrollmentId &&
        _currentDayOfWeek == dayOfWeek &&
        !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentEnrollmentId = enrollmentId;
      _currentDayOfWeek = dayOfWeek;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        List<Schedule> cachedSchedules;
        if (enrollmentId != null) {
          cachedSchedules = await _scheduleDao.getByEnrollmentId(enrollmentId);
        } else if (dayOfWeek != null) {
          cachedSchedules = await _scheduleDao.getByDayOfWeek(dayOfWeek);
        } else {
          cachedSchedules = await _scheduleDao.getAll();
        }

        if (cachedSchedules.isNotEmpty) {
          _schedules = cachedSchedules;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedSchedules.length} schedules from cache');

          // Fetch fresh data in background
          _fetchAndCacheSchedules(enrollmentId, dayOfWeek);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheSchedules(enrollmentId, dayOfWeek);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading schedules: $e');

      // Try to load expired cache as fallback
      List<Schedule> expiredCache;
      if (enrollmentId != null) {
        expiredCache = await _scheduleDao.getByEnrollmentId(enrollmentId, includeExpired: true);
      } else if (dayOfWeek != null) {
        expiredCache = await _scheduleDao.getByDayOfWeek(dayOfWeek, includeExpired: true);
      } else {
        expiredCache = await _scheduleDao.getAll(includeExpired: true);
      }

      if (expiredCache.isNotEmpty) {
        _schedules = expiredCache;
        debugPrint('⚠️  Loaded ${expiredCache.length} schedules from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch schedules from API and cache them
  Future<void> _fetchAndCacheSchedules(String? enrollmentId, int? dayOfWeek) async {
    try {
      final schedules = await _scheduleService.getSchedules(
        enrollmentId: enrollmentId,
        dayOfWeek: dayOfWeek,
      );

      // Cache the schedules
      await _scheduleDao.insertOrUpdateBatch(schedules);

      _schedules = schedules;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${schedules.length} schedules from API');
    } catch (e) {
      debugPrint('❌ Error fetching schedules from API: $e');
      rethrow;
    }
  }

  /// Get schedule by ID with cache-first strategy
  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      // Try cache first
      final cached = await _scheduleDao.getById(scheduleId);
      if (cached != null) {
        debugPrint('📦 Loaded schedule from cache: $scheduleId');
        return cached;
      }

      // Fetch from API
      final schedule = await _scheduleService.getSchedule(scheduleId);

      // Cache it
      await _scheduleDao.insertOrUpdate(schedule);

      debugPrint('🌐 Fetched schedule from API: $scheduleId');
      return schedule;
    } catch (e) {
      debugPrint('❌ Error getting schedule: $e');
      return null;
    }
  }

  /// Get schedules for a specific day
  List<Schedule> getSchedulesForDay(int dayOfWeek) {
    return _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();
  }

  /// Get today's schedules
  List<Schedule> getTodaySchedules() {
    final today = DateTime.now().weekday;
    return getSchedulesForDay(today);
  }

  /// Get next schedule
  Schedule? getNextSchedule() {
    final now = DateTime.now();
    final today = now.weekday;
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Get schedules for today that haven't started yet
    final todaySchedules = getSchedulesForDay(today)
        .where((s) => s.startTime.compareTo(currentTime) > 0)
        .toList();

    if (todaySchedules.isNotEmpty) {
      todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      return todaySchedules.first;
    }

    // No more schedules today, find next day's first schedule
    for (var day = today + 1; day <= 7; day++) {
      final daySchedules = getSchedulesForDay(day);
      if (daySchedules.isNotEmpty) {
        daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
        return daySchedules.first;
      }
    }

    // Wrap around to beginning of week
    for (var day = 1; day < today; day++) {
      final daySchedules = getSchedulesForDay(day);
      if (daySchedules.isNotEmpty) {
        daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
        return daySchedules.first;
      }
    }

    return null;
  }

  /// Create a new schedule
  Future<bool> createSchedule({
    required String enrollmentId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? location,
    String? scheduleType,
    bool isRecurring = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _scheduleService.createSchedule(
        enrollmentId: enrollmentId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        location: location,
        scheduleType: scheduleType,
        isRecurring: isRecurring,
      );

      // Reload schedules
      await loadSchedules(forceRefresh: true);

      debugPrint('✅ Schedule created');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a schedule
  Future<bool> updateSchedule(
    String scheduleId, {
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? scheduleType,
    bool? isRecurring,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _scheduleService.updateSchedule(
        scheduleId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        location: location,
        scheduleType: scheduleType,
        isRecurring: isRecurring,
      );

      // Reload schedules
      await loadSchedules(forceRefresh: true);

      debugPrint('✅ Schedule updated: $scheduleId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _scheduleService.deleteSchedule(scheduleId);

      // Remove from cache
      await _scheduleDao.delete(scheduleId);

      // Update local list
      _schedules.removeWhere((s) => s.id == scheduleId);

      debugPrint('✅ Schedule deleted: $scheduleId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error deleting schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all cached schedules
  Future<void> clearCache() async {
    await _scheduleDao.clearAll();
    _schedules = [];
    notifyListeners();
    debugPrint('🗑️  Schedule cache cleared');
  }

  /// Clear cached schedules for a specific enrollment
  Future<void> clearCacheForEnrollment(String enrollmentId) async {
    await _scheduleDao.clearByEnrollment(enrollmentId);
    if (_currentEnrollmentId == enrollmentId) {
      _schedules = [];
      notifyListeners();
    }
    debugPrint('🗑️  Schedule cache cleared for enrollment: $enrollmentId');
  }
}
