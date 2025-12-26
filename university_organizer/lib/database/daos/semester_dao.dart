import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/semester.dart';
import '../app_database.dart';

/// Data Access Object for Semesters
class SemesterDao {
  final AppDatabase _db;

  SemesterDao(this._db);

  /// Cache TTL duration (15 minutes)
  static const Duration cacheTTL = Duration(minutes: 15);

  /// Insert or update a semester with cache TTL
  Future<void> insertOrUpdate(Semester semester, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'semesters',
      {
        'id': semester.id,
        'careerId': semester.careerId,
        'number': semester.number,
        'name': semester.name,
        'description': semester.description,
        'createdAt': semester.createdAt?.toIso8601String(),
        'updatedAt': semester.updatedAt?.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Semester cached: ${semester.name} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple semesters
  Future<void> insertOrUpdateBatch(List<Semester> semesters, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final semester in semesters) {
      batch.insert(
        'semesters',
        {
          'id': semester.id,
          'careerId': semester.careerId,
          'number': semester.number,
          'name': semester.name,
          'description': semester.description,
          'createdAt': semester.createdAt?.toIso8601String(),
          'updatedAt': semester.updatedAt?.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${semesters.length} semesters');
  }

  /// Get semester by ID
  Future<Semester?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'semesters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached semester expired: ${map['name']}');
      return null;
    }

    return _mapToSemester(map);
  }

  /// Get all semesters for a career
  Future<List<Semester>> getByCareerId(String careerId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'semesters',
      where: includeExpired ? 'careerId = ?' : 'careerId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [careerId] : [careerId, now],
      orderBy: 'number ASC',
    );

    return maps.map((map) => _mapToSemester(map)).toList();
  }

  /// Get all semesters
  Future<List<Semester>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'semesters',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'number ASC',
    );

    return maps.map((map) => _mapToSemester(map)).toList();
  }

  /// Delete semester by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'semesters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all semesters for a career
  Future<int> clearByCareer(String careerId) async {
    final database = await _db.database;
    return await database.delete(
      'semesters',
      where: 'careerId = ?',
      whereArgs: [careerId],
    );
  }

  /// Clear all semesters
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('semesters');
  }

  /// Convert database map to Semester model
  Semester _mapToSemester(Map<String, dynamic> map) {
    return Semester(
      id: map['id'] as String,
      careerId: map['careerId'] as String,
      number: map['number'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}
