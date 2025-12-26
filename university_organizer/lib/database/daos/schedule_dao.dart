import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/schedule.dart';
import '../app_database.dart';

/// Data Access Object for Schedules
class ScheduleDao {
  final AppDatabase _db;

  ScheduleDao(this._db);

  /// Cache TTL duration (30 minutes - schedules change less frequently)
  static const Duration cacheTTL = Duration(minutes: 30);

  /// Insert or update a schedule with cache TTL
  Future<void> insertOrUpdate(Schedule schedule, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'schedules',
      {
        'id': schedule.id,
        'enrollmentId': schedule.enrollmentId,
        'dayOfWeek': schedule.dayOfWeek,
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'room': schedule.room,
        'building': schedule.building,
        'type': schedule.type.name.toUpperCase(),
        'color': schedule.color,
        'notes': schedule.notes,
        'isRecurring': schedule.isRecurring ? 1 : 0,
        'startDate': schedule.startDate?.toIso8601String(),
        'endDate': schedule.endDate?.toIso8601String(),
        'createdAt': schedule.createdAt.toIso8601String(),
        'updatedAt': schedule.updatedAt.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Schedule cached: ${schedule.dayName} ${schedule.startTime} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple schedules
  Future<void> insertOrUpdateBatch(List<Schedule> schedules, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final schedule in schedules) {
      batch.insert(
        'schedules',
        {
          'id': schedule.id,
          'enrollmentId': schedule.enrollmentId,
          'dayOfWeek': schedule.dayOfWeek,
          'startTime': schedule.startTime,
          'endTime': schedule.endTime,
          'room': schedule.room,
          'building': schedule.building,
          'type': schedule.type.name.toUpperCase(),
          'color': schedule.color,
          'notes': schedule.notes,
          'isRecurring': schedule.isRecurring ? 1 : 0,
          'startDate': schedule.startDate?.toIso8601String(),
          'endDate': schedule.endDate?.toIso8601String(),
          'createdAt': schedule.createdAt.toIso8601String(),
          'updatedAt': schedule.updatedAt.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${schedules.length} schedules');
  }

  /// Get schedule by ID
  Future<Schedule?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached schedule expired: ${map['id']}');
      return null;
    }

    return _mapToSchedule(map);
  }

  /// Get all schedules for an enrollment
  Future<List<Schedule>> getByEnrollmentId(String enrollmentId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'schedules',
      where: includeExpired ? 'enrollmentId = ?' : 'enrollmentId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [enrollmentId] : [enrollmentId, now],
      orderBy: 'dayOfWeek ASC, startTime ASC',
    );

    return maps.map((map) => _mapToSchedule(map)).toList();
  }

  /// Get schedules by day of week
  Future<List<Schedule>> getByDayOfWeek(int dayOfWeek, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'schedules',
      where: includeExpired ? 'dayOfWeek = ?' : 'dayOfWeek = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [dayOfWeek] : [dayOfWeek, now],
      orderBy: 'startTime ASC',
    );

    return maps.map((map) => _mapToSchedule(map)).toList();
  }

  /// Get all schedules
  Future<List<Schedule>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'schedules',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'dayOfWeek ASC, startTime ASC',
    );

    return maps.map((map) => _mapToSchedule(map)).toList();
  }

  /// Delete schedule by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all schedules for an enrollment
  Future<int> clearByEnrollment(String enrollmentId) async {
    final database = await _db.database;
    return await database.delete(
      'schedules',
      where: 'enrollmentId = ?',
      whereArgs: [enrollmentId],
    );
  }

  /// Clear all schedules
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('schedules');
  }

  /// Convert database map to Schedule model
  Schedule _mapToSchedule(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      enrollmentId: map['enrollmentId'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      room: map['room'] as String?,
      building: map['building'] as String?,
      type: _parseScheduleType(map['type'] as String),
      color: map['color'] as String?,
      notes: map['notes'] as String?,
      isRecurring: (map['isRecurring'] as int) == 1,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Parse schedule type from string
  ScheduleType _parseScheduleType(String type) {
    switch (type.toUpperCase()) {
      case 'CLASS':
      case 'CLASSTYPE':
        return ScheduleType.classType;
      case 'LAB':
        return ScheduleType.lab;
      case 'TUTORIAL':
        return ScheduleType.tutorial;
      case 'OFFICE_HOURS':
      case 'OFFICEHOURS':
        return ScheduleType.officeHours;
      case 'EXAM':
        return ScheduleType.exam;
      default:
        return ScheduleType.other;
    }
  }
}
