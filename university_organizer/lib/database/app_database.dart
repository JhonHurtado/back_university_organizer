import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Application database helper using SQLite
/// Manages local storage for offline mode and caching
class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('university_organizer.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    debugPrint('📁 Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    debugPrint('🗄️  Creating database tables...');

    // Careers table
    await db.execute('''
      CREATE TABLE careers (
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT NOT NULL,
        code TEXT,
        university TEXT NOT NULL,
        faculty TEXT,
        campus TEXT,
        totalCredits INTEGER,
        totalSemesters INTEGER,
        currentSemester INTEGER,
        gradeScale TEXT,
        minPassingGrade REAL,
        maxGrade REAL,
        startDate TEXT,
        expectedEndDate TEXT,
        actualEndDate TEXT,
        color TEXT,
        status TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL
      )
    ''');

    // Semesters table
    await db.execute('''
      CREATE TABLE semesters (
        id TEXT PRIMARY KEY,
        careerId TEXT NOT NULL,
        number INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (careerId) REFERENCES careers (id) ON DELETE CASCADE
      )
    ''');

    // Subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        careerId TEXT NOT NULL,
        semesterId TEXT,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        credits INTEGER NOT NULL,
        hoursPerWeek INTEGER,
        subjectType TEXT,
        area TEXT,
        totalCuts INTEGER,
        isElective INTEGER,
        gradeWeights TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (careerId) REFERENCES careers (id) ON DELETE CASCADE,
        FOREIGN KEY (semesterId) REFERENCES semesters (id) ON DELETE SET NULL
      )
    ''');

    // Periods table
    await db.execute('''
      CREATE TABLE periods (
        id TEXT PRIMARY KEY,
        careerId TEXT NOT NULL,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isCurrent INTEGER,
        createdAt TEXT,
        updatedAt TEXT,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (careerId) REFERENCES careers (id) ON DELETE CASCADE
      )
    ''');

    // Enrollments table
    await db.execute('''
      CREATE TABLE enrollments (
        id TEXT PRIMARY KEY,
        careerId TEXT NOT NULL,
        subjectId TEXT NOT NULL,
        periodId TEXT NOT NULL,
        section TEXT,
        classroom TEXT,
        status TEXT NOT NULL,
        finalGrade REAL,
        professorId TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (careerId) REFERENCES careers (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (periodId) REFERENCES periods (id) ON DELETE CASCADE
      )
    ''');

    // Grades table
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        enrollmentId TEXT NOT NULL,
        cutNumber INTEGER NOT NULL,
        cutName TEXT,
        weight REAL NOT NULL,
        grade REAL NOT NULL,
        maxGrade REAL NOT NULL,
        weightedGrade REAL,
        description TEXT,
        notes TEXT,
        gradedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (enrollmentId) REFERENCES enrollments (id) ON DELETE CASCADE
      )
    ''');

    // Schedules table
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        enrollmentId TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        room TEXT,
        building TEXT,
        type TEXT NOT NULL,
        color TEXT,
        notes TEXT,
        isRecurring INTEGER NOT NULL,
        startDate TEXT,
        endDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (enrollmentId) REFERENCES enrollments (id) ON DELETE CASCADE
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        readAt TEXT,
        actionUrl TEXT,
        actionLabel TEXT,
        metadata TEXT,
        imageUrl TEXT,
        notificationExpiresAt TEXT,
        createdAt TEXT NOT NULL,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_careers_status ON careers(status)');
    await db.execute('CREATE INDEX idx_semesters_career ON semesters(careerId)');
    await db.execute('CREATE INDEX idx_subjects_career ON subjects(careerId)');
    await db.execute('CREATE INDEX idx_subjects_semester ON subjects(semesterId)');
    await db.execute('CREATE INDEX idx_periods_career ON periods(careerId)');
    await db.execute('CREATE INDEX idx_enrollments_career ON enrollments(careerId)');
    await db.execute('CREATE INDEX idx_enrollments_period ON enrollments(periodId)');
    await db.execute('CREATE INDEX idx_grades_enrollment ON grades(enrollmentId)');
    await db.execute('CREATE INDEX idx_schedules_enrollment ON schedules(enrollmentId)');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(userId)');
    await db.execute('CREATE INDEX idx_notifications_isRead ON notifications(isRead)');

    debugPrint('✅ Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from v$oldVersion to v$newVersion');

    // Future migrations will go here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE careers ADD COLUMN newField TEXT');
    // }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('careers');
      await txn.delete('semesters');
      await txn.delete('subjects');
      await txn.delete('periods');
      await txn.delete('enrollments');
      await txn.delete('grades');
      await txn.delete('schedules');
      await txn.delete('notifications');
    });
    debugPrint('🗑️  All cache cleared');
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final tables = [
      'careers',
      'semesters',
      'subjects',
      'periods',
      'enrollments',
      'grades',
      'schedules',
      'notifications',
    ];

    int totalDeleted = 0;
    for (final table in tables) {
      final count = await db.delete(
        table,
        where: 'expiresAt < ?',
        whereArgs: [now],
      );
      totalDeleted += count;
    }

    if (totalDeleted > 0) {
      debugPrint('🗑️  Cleared $totalDeleted expired cache entries');
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('📁 Database closed');
  }
}
