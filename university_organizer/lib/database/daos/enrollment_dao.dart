import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/enrollment.dart';
import '../app_database.dart';

/// Data Access Object for Enrollments
class EnrollmentDao {
  final AppDatabase _db;

  EnrollmentDao(this._db);

  /// Cache TTL duration (15 minutes)
  static const Duration cacheTTL = Duration(minutes: 15);

  /// Insert or update an enrollment with cache TTL
  Future<void> insertOrUpdate(Enrollment enrollment, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'enrollments',
      {
        'id': enrollment.id,
        'careerId': enrollment.careerId,
        'subjectId': enrollment.subjectId,
        'periodId': enrollment.periodId,
        'section': enrollment.section,
        'classroom': enrollment.classroom,
        'status': enrollment.status.name.toUpperCase(),
        'finalGrade': enrollment.finalGrade,
        'professorId': enrollment.professorId,
        'createdAt': enrollment.createdAt?.toIso8601String(),
        'updatedAt': enrollment.updatedAt?.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Enrollment cached: ${enrollment.id} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple enrollments
  Future<void> insertOrUpdateBatch(List<Enrollment> enrollments, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final enrollment in enrollments) {
      batch.insert(
        'enrollments',
        {
          'id': enrollment.id,
          'careerId': enrollment.careerId,
          'subjectId': enrollment.subjectId,
          'periodId': enrollment.periodId,
          'section': enrollment.section,
          'classroom': enrollment.classroom,
          'status': enrollment.status.name.toUpperCase(),
          'finalGrade': enrollment.finalGrade,
          'professorId': enrollment.professorId,
          'createdAt': enrollment.createdAt?.toIso8601String(),
          'updatedAt': enrollment.updatedAt?.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${enrollments.length} enrollments');
  }

  /// Get enrollment by ID
  Future<Enrollment?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'enrollments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached enrollment expired: ${map['id']}');
      return null;
    }

    return _mapToEnrollment(map);
  }

  /// Get all enrollments for a career
  Future<List<Enrollment>> getByCareerId(String careerId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired ? 'careerId = ?' : 'careerId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [careerId] : [careerId, now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Get all enrollments for a period
  Future<List<Enrollment>> getByPeriodId(String periodId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired ? 'periodId = ?' : 'periodId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [periodId] : [periodId, now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Get all enrollments for a subject
  Future<List<Enrollment>> getBySubjectId(String subjectId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired ? 'subjectId = ?' : 'subjectId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [subjectId] : [subjectId, now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Get active enrollments (ENROLLED or IN_PROGRESS)
  Future<List<Enrollment>> getActiveEnrollments({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired
          ? 'status IN (?, ?)'
          : 'status IN (?, ?) AND expiresAt > ?',
      whereArgs: includeExpired
          ? ['ENROLLED', 'IN_PROGRESS']
          : ['ENROLLED', 'IN_PROGRESS', now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Get completed enrollments (PASSED or FAILED)
  Future<List<Enrollment>> getCompletedEnrollments({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired
          ? 'status IN (?, ?)'
          : 'status IN (?, ?) AND expiresAt > ?',
      whereArgs: includeExpired
          ? ['PASSED', 'FAILED']
          : ['PASSED', 'FAILED', now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Get all enrollments
  Future<List<Enrollment>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'enrollments',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToEnrollment(map)).toList();
  }

  /// Delete enrollment by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'enrollments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all enrollments for a career
  Future<int> clearByCareer(String careerId) async {
    final database = await _db.database;
    return await database.delete(
      'enrollments',
      where: 'careerId = ?',
      whereArgs: [careerId],
    );
  }

  /// Clear all enrollments for a period
  Future<int> clearByPeriod(String periodId) async {
    final database = await _db.database;
    return await database.delete(
      'enrollments',
      where: 'periodId = ?',
      whereArgs: [periodId],
    );
  }

  /// Clear all enrollments
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('enrollments');
  }

  /// Convert database map to Enrollment model
  Enrollment _mapToEnrollment(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'] as String,
      careerId: map['careerId'] as String,
      subjectId: map['subjectId'] as String,
      periodId: map['periodId'] as String,
      section: map['section'] as String?,
      classroom: map['classroom'] as String?,
      status: _parseEnrollmentStatus(map['status'] as String),
      finalGrade: map['finalGrade'] as double?,
      professorId: map['professorId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Parse enrollment status from string
  EnrollmentStatus _parseEnrollmentStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ENROLLED':
        return EnrollmentStatus.enrolled;
      case 'IN_PROGRESS':
        return EnrollmentStatus.inProgress;
      case 'PASSED':
        return EnrollmentStatus.passed;
      case 'FAILED':
        return EnrollmentStatus.failed;
      case 'WITHDRAWN':
        return EnrollmentStatus.withdrawn;
      default:
        return EnrollmentStatus.enrolled;
    }
  }
}
