import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../models/period.dart';
import '../app_database.dart';

/// Data Access Object for Periods
class PeriodDao {
  final AppDatabase _db;

  PeriodDao(this._db);

  /// Cache TTL duration (15 minutes)
  static const Duration cacheTTL = Duration(minutes: 15);

  /// Insert or update a period with cache TTL
  Future<void> insertOrUpdate(Period period, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    await database.insert(
      'periods',
      {
        'id': period.id,
        'careerId': period.careerId,
        'name': period.name,
        'startDate': period.startDate.toIso8601String(),
        'endDate': period.endDate.toIso8601String(),
        'isCurrent': period.isCurrent == true ? 1 : 0,
        'createdAt': period.createdAt?.toIso8601String(),
        'updatedAt': period.updatedAt?.toIso8601String(),
        'cachedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('✅ Period cached: ${period.name} (expires: $expiresAt)');
  }

  /// Batch insert or update multiple periods
  Future<void> insertOrUpdateBatch(List<Period> periods, {Duration? ttl}) async {
    final database = await _db.database;
    final now = DateTime.now();
    final expiresAt = now.add(ttl ?? cacheTTL);

    final batch = database.batch();
    for (final period in periods) {
      batch.insert(
        'periods',
        {
          'id': period.id,
          'careerId': period.careerId,
          'name': period.name,
          'startDate': period.startDate.toIso8601String(),
          'endDate': period.endDate.toIso8601String(),
          'isCurrent': period.isCurrent == true ? 1 : 0,
          'createdAt': period.createdAt?.toIso8601String(),
          'updatedAt': period.updatedAt?.toIso8601String(),
          'cachedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Batch cached ${periods.length} periods');
  }

  /// Get period by ID
  Future<Period?> getById(String id) async {
    final database = await _db.database;
    final maps = await database.query(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;

    // Check if cache is expired
    final expiresAt = DateTime.parse(map['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('⚠️  Cached period expired: ${map['name']}');
      return null;
    }

    return _mapToPeriod(map);
  }

  /// Get all periods for a career
  Future<List<Period>> getByCareerId(String careerId, {bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'periods',
      where: includeExpired ? 'careerId = ?' : 'careerId = ? AND expiresAt > ?',
      whereArgs: includeExpired ? [careerId] : [careerId, now],
      orderBy: 'startDate DESC',
    );

    return maps.map((map) => _mapToPeriod(map)).toList();
  }

  /// Get current period for a career
  Future<Period?> getCurrentPeriod(String careerId) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'periods',
      where: 'careerId = ? AND isCurrent = 1 AND expiresAt > ?',
      whereArgs: [careerId, now],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToPeriod(maps.first);
  }

  /// Get all periods
  Future<List<Period>> getAll({bool includeExpired = false}) async {
    final database = await _db.database;
    final now = DateTime.now().toIso8601String();

    final maps = await database.query(
      'periods',
      where: includeExpired ? null : 'expiresAt > ?',
      whereArgs: includeExpired ? null : [now],
      orderBy: 'startDate DESC',
    );

    return maps.map((map) => _mapToPeriod(map)).toList();
  }

  /// Delete period by ID
  Future<int> delete(String id) async {
    final database = await _db.database;
    return await database.delete(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all periods for a career
  Future<int> clearByCareer(String careerId) async {
    final database = await _db.database;
    return await database.delete(
      'periods',
      where: 'careerId = ?',
      whereArgs: [careerId],
    );
  }

  /// Clear all periods
  Future<int> clearAll() async {
    final database = await _db.database;
    return await database.delete('periods');
  }

  /// Convert database map to Period model
  Period _mapToPeriod(Map<String, dynamic> map) {
    return Period(
      id: map['id'] as String,
      careerId: map['careerId'] as String,
      name: map['name'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isCurrent: (map['isCurrent'] as int?) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}
