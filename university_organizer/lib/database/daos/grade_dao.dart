import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/grade.dart';
import '../app_database.dart';

/// Data Access Object for Grades
class GradeDao {
  final AppDatabase _db;

  GradeDao(this._db);

  /// Cache TTL duration (15 minutes)
  static const Duration cacheTTL = Duration(minutes: 15);

  /// Insert or update a grade with cache TTL
  Future<void> insertOrUpdate(Grade grade, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'grades',
      {
        'id': grade.id,
        'enrollmentId': grade.enrollmentId,
        'cutNumber': grade.cutNumber,
        'cutName': grade.cutName,
        'weight': grade.weight,
        'grade': grade.grade,
        'maxGrade': grade.maxGrade,
        'weightedGrade': grade.weightedGrade,
        'description': grade.description,
        'notes': grade.notes,
        'gradedAt': grade.gradedAt.toIso8601String(),
        'createdAt': grade.createdAt.toIso8601String(),
        'updatedAt': grade.updatedAt.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Grade cached: Cut ${grade.cutNumber} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple grades
  Future<void> insertOrUpdateBatch(List<Grade> grades, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final grade in grades) {
      batch.insert(
        'grades',
        {
          'id': grade.id,
          'enrollmentId': grade.enrollmentId,
          'cutNumber': grade.cutNumber,
          'cutName': grade.cutName,
          'weight': grade.weight,
          'grade': grade.grade,
          'maxGrade': grade.maxGrade,
          'weightedGrade': grade.weightedGrade,
          'description': grade.description,
          'notes': grade.notes,
          'gradedAt': grade.gradedAt.toIso8601String(),
          'createdAt': grade.createdAt.toIso8601String(),
          'updatedAt': grade.updatedAt.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${grades.length} grades');
  }

  /// Get grade by ID
  Future<Grade?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached grade expired: ${map['id']}');
      return null;
    }

    return _mapToGrade(map);
  }

  /// Get all grades for an enrollment
  Future<List<Grade>> getByEnrollmentId(String enrollmentId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'grades',
      where: includeExpired ? 'enrollmentId = ?' : 'enrollmentId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [enrollmentId] : [enrollmentId, now],
      orderBy: 'cutNumber ASC',
    );

    return maps.map((map) => _mapToGrade(map)).toList();
  }

  /// Get grades by cut number for an enrollment
  Future<Grade?> getByCutNumber(String enrollmentId, int cutNumber) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'grades',
      where: 'enrollmentId = ? AND cutNumber = ? AND expiresAt > ?',
      whereArgs: [enrollmentId, cutNumber, now],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToGrade(maps.first);
  }

  /// Get all grades
  Future<List<Grade>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'grades',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'gradedAt DESC',
    );

    return maps.map((map) => _mapToGrade(map)).toList();
  }

  /// Delete grade by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all grades for an enrollment
  Future<int> clearByEnrollment(String enrollmentId) async {
    final database = await _db.database;
    return await database.delete(
      'grades',
      where: 'enrollmentId = ?',
      whereArgs: [enrollmentId],
    );
  }

  /// Clear all grades
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('grades');
  }

  /// Convert database map to Grade model
  Grade _mapToGrade(Map<String, dynamic> map) {
    return Grade(
      id: map['id'] as String,
      enrollmentId: map['enrollmentId'] as String,
      cutNumber: map['cutNumber'] as int,
      cutName: map['cutName'] as String?,
      weight: map['weight'] as double,
      grade: map['grade'] as double,
      maxGrade: map['maxGrade'] as double,
      weightedGrade: map['weightedGrade'] as double?,
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      gradedAt: DateTime.parse(map['gradedAt'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
