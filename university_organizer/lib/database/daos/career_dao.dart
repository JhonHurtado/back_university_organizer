import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/career.dart';
import '../app_database.dart';

/// Data Access Object for Careers
class CareerDao {
  final AppDatabase _db;

  CareerDao(this._db);

  /// Cache TTL duration (30 minutes - careers change less frequently)
  static const Duration cacheTTL = Duration(minutes: 30);

  /// Insert or update a career with cache TTL
  Future<void> insertOrUpdate(Career career, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'careers',
      {
        'id': career.id,
        'userId': career.userId,
        'name': career.name,
        'code': career.code,
        'university': career.university,
        'faculty': career.faculty,
        'campus': career.campus,
        'totalCredits': career.totalCredits,
        'totalSemesters': career.totalSemesters,
        'currentSemester': career.currentSemester,
        'gradeScale': career.gradeScale?.name.toUpperCase(),
        'minPassingGrade': career.minPassingGrade,
        'maxGrade': career.maxGrade,
        'startDate': career.startDate?.toIso8601String(),
        'expectedEndDate': career.expectedEndDate?.toIso8601String(),
        'actualEndDate': career.actualEndDate?.toIso8601String(),
        'color': career.color,
        'status': career.status?.name.toUpperCase(),
        'createdAt': career.createdAt?.toIso8601String(),
        'updatedAt': career.updatedAt?.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Career cached: ${career.name} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple careers
  Future<void> insertOrUpdateBatch(List<Career> careers, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final career in careers) {
      batch.insert(
        'careers',
        {
          'id': career.id,
          'userId': career.userId,
          'name': career.name,
          'code': career.code,
          'university': career.university,
          'faculty': career.faculty,
          'campus': career.campus,
          'totalCredits': career.totalCredits,
          'totalSemesters': career.totalSemesters,
          'currentSemester': career.currentSemester,
          'gradeScale': career.gradeScale?.name.toUpperCase(),
          'minPassingGrade': career.minPassingGrade,
          'maxGrade': career.maxGrade,
          'startDate': career.startDate?.toIso8601String(),
          'expectedEndDate': career.expectedEndDate?.toIso8601String(),
          'actualEndDate': career.actualEndDate?.toIso8601String(),
          'color': career.color,
          'status': career.status?.name.toUpperCase(),
          'createdAt': career.createdAt?.toIso8601String(),
          'updatedAt': career.updatedAt?.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${careers.length} careers');
  }

  /// Get career by ID
  Future<Career?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'careers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached career expired: ${map['name']}');
      return null;
    }

    return _mapToCareer(map);
  }

  /// Get all careers for a user
  Future<List<Career>> getByUserId(String userId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'careers',
      where: includeExpired ? 'userId = ?' : 'userId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [userId] : [userId, now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToCareer(map)).toList();
  }

  /// Get all careers
  Future<List<Career>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'careers',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToCareer(map)).toList();
  }

  /// Get active careers
  Future<List<Career>> getActiveCareers({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'careers',
      where: includeExpired
          ? 'status = ?'
          : 'status = ? AND expiresAt > ?',
      whereArgs: includeExpired ? ['ACTIVE'] : ['ACTIVE', now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToCareer(map)).toList();
  }

  /// Delete career by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'careers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all careers
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('careers');
  }

  /// Convert database map to Career model
  Career _mapToCareer(Map<String, dynamic> map) {
    return Career(
      id: map['id'] as String,
      userId: map['userId'] as String?,
      name: map['name'] as String,
      code: map['code'] as String?,
      university: map['university'] as String,
      faculty: map['faculty'] as String?,
      campus: map['campus'] as String?,
      totalCredits: map['totalCredits'] as int?,
      totalSemesters: map['totalSemesters'] as int?,
      currentSemester: map['currentSemester'] as int?,
      gradeScale: _parseGradeScale(map['gradeScale'] as String?),
      minPassingGrade: map['minPassingGrade'] as double?,
      maxGrade: map['maxGrade'] as double?,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      expectedEndDate: map['expectedEndDate'] != null
          ? DateTime.parse(map['expectedEndDate'] as String)
          : null,
      actualEndDate: map['actualEndDate'] != null
          ? DateTime.parse(map['actualEndDate'] as String)
          : null,
      color: map['color'] as String?,
      status: _parseCareerStatus(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Parse grade scale from string
  GradeScale? _parseGradeScale(String? scale) {
    if (scale == null) return null;
    switch (scale.toUpperCase()) {
      case 'FIVE':
        return GradeScale.five;
      case 'TEN':
        return GradeScale.ten;
      case 'HUNDRED':
        return GradeScale.hundred;
      case 'FOUR_GPA':
      case 'FOURGPA':
        return GradeScale.fourGPA;
      case 'SEVEN':
        return GradeScale.seven;
      default:
        return null;
    }
  }

  /// Parse career status from string
  CareerStatus? _parseCareerStatus(String? status) {
    if (status == null) return null;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return CareerStatus.active;
      case 'COMPLETED':
        return CareerStatus.completed;
      case 'PAUSED':
        return CareerStatus.paused;
      case 'CANCELLED':
        return CareerStatus.cancelled;
      case 'GRADUATED':
        return CareerStatus.graduated;
      default:
        return CareerStatus.active;
    }
  }
}
