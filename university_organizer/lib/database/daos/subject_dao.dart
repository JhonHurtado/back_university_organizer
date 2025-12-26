import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/subject.dart';
import '../app_database.dart';

/// Data Access Object for Subjects
class SubjectDao {
  final AppDatabase _db;

  SubjectDao(this._db);

  /// Cache TTL duration (15 minutes)
  static const Duration cacheTTL = Duration(minutes: 15);

  /// Insert or update a subject with cache TTL
  Future<void> insertOrUpdate(Subject subject, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'subjects',
      {
        'id': subject.id,
        'careerId': subject.careerId,
        'semesterId': subject.semesterId,
        'code': subject.code,
        'name': subject.name,
        'description': subject.description,
        'credits': subject.credits,
        'hoursPerWeek': subject.hoursPerWeek,
        'subjectType': subject.subjectType.name.toUpperCase(),
        'area': subject.area,
        'totalCuts': subject.totalCuts,
        'isElective': subject.isElective ? 1 : 0,
        'gradeWeights': subject.gradeWeights != null
            ? jsonEncode(subject.gradeWeights)
            : null,
        'createdAt': subject.createdAt.toIso8601String(),
        'updatedAt': subject.updatedAt.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Subject cached: ${subject.name} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple subjects
  Future<void> insertOrUpdateBatch(List<Subject> subjects, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final subject in subjects) {
      batch.insert(
        'subjects',
        {
          'id': subject.id,
          'careerId': subject.careerId,
          'semesterId': subject.semesterId,
          'code': subject.code,
          'name': subject.name,
          'description': subject.description,
          'credits': subject.credits,
          'hoursPerWeek': subject.hoursPerWeek,
          'subjectType': subject.subjectType.name.toUpperCase(),
          'area': subject.area,
          'totalCuts': subject.totalCuts,
          'isElective': subject.isElective ? 1 : 0,
          'gradeWeights': subject.gradeWeights != null
              ? jsonEncode(subject.gradeWeights)
              : null,
          'createdAt': subject.createdAt.toIso8601String(),
          'updatedAt': subject.updatedAt.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${subjects.length} subjects');
  }

  /// Get subject by ID
  Future<Subject?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached subject expired: ${map['name']}');
      return null;
    }

    return _mapToSubject(map);
  }

  /// Get all subjects for a career
  Future<List<Subject>> getByCareerId(String careerId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'subjects',
      where: includeExpired ? 'careerId = ?' : 'careerId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [careerId] : [careerId, now],
      orderBy: 'code ASC',
    );

    return maps.map((map) => _mapToSubject(map)).toList();
  }

  /// Get all subjects for a semester
  Future<List<Subject>> getBySemesterId(String semesterId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'subjects',
      where: includeExpired ? 'semesterId = ?' : 'semesterId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [semesterId] : [semesterId, now],
      orderBy: 'code ASC',
    );

    return maps.map((map) => _mapToSubject(map)).toList();
  }

  /// Get all subjects
  Future<List<Subject>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'subjects',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'code ASC',
    );

    return maps.map((map) => _mapToSubject(map)).toList();
  }

  /// Delete subject by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all subjects for a career
  Future<int> clearByCareer(String careerId) async {
    final database = await _db.database;
    return await database.delete(
      'subjects',
      where: 'careerId = ?',
      whereArgs: [careerId],
    );
  }

  /// Clear all subjects for a semester
  Future<int> clearBySemester(String semesterId) async {
    final database = await _db.database;
    return await database.delete(
      'subjects',
      where: 'semesterId = ?',
      whereArgs: [semesterId],
    );
  }

  /// Clear all subjects
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('subjects');
  }

  /// Convert database map to Subject model
  Subject _mapToSubject(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      careerId: map['careerId'] as String,
      semesterId: map['semesterId'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      credits: map['credits'] as int,
      hoursPerWeek: map['hoursPerWeek'] as int?,
      subjectType: _parseSubjectType(map['subjectType'] as String?),
      area: map['area'] as String?,
      totalCuts: map['totalCuts'] as int,
      isElective: (map['isElective'] as int) == 1,
      gradeWeights: map['gradeWeights'] != null
          ? jsonDecode(map['gradeWeights'] as String) as Map<String, dynamic>
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Parse subject type from string
  SubjectType _parseSubjectType(String? type) {
    if (type == null) return SubjectType.required;
    switch (type.toUpperCase()) {
      case 'ELECTIVE':
        return SubjectType.elective;
      case 'FREE_ELECTIVE':
        return SubjectType.freeElective;
      case 'COMPLEMENTARY':
        return SubjectType.complementary;
      default:
        return SubjectType.required;
    }
  }
}
