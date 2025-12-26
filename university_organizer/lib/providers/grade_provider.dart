import 'package:flutter/foundation.dart';
import '../models/grade.dart';
import '../services/grade_service.dart';
import '../database/daos/grade_dao.dart';
import '../database/app_database.dart';

/// Provider for managing grade state with cache-first strategy
class GradeProvider extends ChangeNotifier {
  final GradeService _gradeService;
  final GradeDao _gradeDao;

  GradeProvider(this._gradeService)
      : _gradeDao = GradeDao(AppDatabase.instance);

  List<Grade> _grades = [];
  Map<String, dynamic>? _gpaData;
  bool _isLoading = false;
  String? _error;
  String? _currentEnrollmentId;

  List<Grade> get grades => _grades;
  Map<String, dynamic>? get gpaData => _gpaData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Calculate average grade
  double get averageGrade {
    if (_grades.isEmpty) return 0.0;
    final total = _grades.fold<double>(0.0, (sum, g) => sum + g.grade);
    return total / _grades.length;
  }

  /// Calculate weighted average
  double get weightedAverage {
    if (_grades.isEmpty) return 0.0;
    final totalWeighted = _grades.fold<double>(
        0.0, (sum, g) => sum + g.weightedContribution);
    return totalWeighted;
  }

  /// Load grades for an enrollment with cache-first strategy
  Future<void> loadGradesByEnrollment(String enrollmentId, {bool forceRefresh = false}) async {
    if (_isLoading && _currentEnrollmentId == enrollmentId && !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentEnrollmentId = enrollmentId;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        final cachedGrades = await _gradeDao.getByEnrollmentId(enrollmentId);
        if (cachedGrades.isNotEmpty) {
          _grades = cachedGrades;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedGrades.length} grades from cache');

          // Fetch fresh data in background
          _fetchAndCacheGrades(enrollmentId);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheGrades(enrollmentId);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading grades: $e');

      // Try to load expired cache as fallback
      final expiredCache = await _gradeDao.getByEnrollmentId(enrollmentId, includeExpired: true);
      if (expiredCache.isNotEmpty) {
        _grades = expiredCache;
        debugPrint('⚠️  Loaded ${expiredCache.length} grades from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch grades from API and cache them
  Future<void> _fetchAndCacheGrades(String enrollmentId) async {
    try {
      final response = await _gradeService.getGradesByEnrollment(enrollmentId);

      // Extract grades from response
      final List<dynamic> gradesData = response['grades'] ?? [];
      final grades = gradesData.map((json) => Grade.fromJson(json)).toList();

      // Cache the grades
      await _gradeDao.insertOrUpdateBatch(grades);

      _grades = grades;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${grades.length} grades from API');
    } catch (e) {
      debugPrint('❌ Error fetching grades from API: $e');
      rethrow;
    }
  }

  /// Get grade by ID with cache-first strategy
  Future<Grade?> getGradeById(String gradeId) async {
    try {
      // Try cache first
      final cached = await _gradeDao.getById(gradeId);
      if (cached != null) {
        debugPrint('📦 Loaded grade from cache: $gradeId');
        return cached;
      }

      // Fetch from API
      final grade = await _gradeService.getGrade(gradeId);

      // Cache it
      await _gradeDao.insertOrUpdate(grade);

      debugPrint('🌐 Fetched grade from API: $gradeId');
      return grade;
    } catch (e) {
      debugPrint('❌ Error getting grade: $e');
      return null;
    }
  }

  /// Get grade by cut number
  Future<Grade?> getGradeByCutNumber(String enrollmentId, int cutNumber) async {
    try {
      // Try cache first
      final cached = await _gradeDao.getByCutNumber(enrollmentId, cutNumber);
      if (cached != null) {
        debugPrint('📦 Loaded grade from cache: Cut $cutNumber');
        return cached;
      }

      // Try to find in current loaded grades
      try {
        return _grades.firstWhere((g) => g.cutNumber == cutNumber);
      } catch (e) {
        debugPrint('Grade not found for cut $cutNumber');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting grade by cut: $e');
      return null;
    }
  }

  /// Load career GPA
  Future<void> loadCareerGPA(String careerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _gpaData = await _gradeService.getCareerGPA(careerId);

      debugPrint('✅ Loaded career GPA: ${_gpaData?['gpa']}');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading career GPA: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new grade
  Future<bool> createGrade({
    required String enrollmentId,
    required int cutNumber,
    required double value,
    required double weight,
    DateTime? gradeDate,
    String? observations,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _gradeService.createGrade(
        enrollmentId: enrollmentId,
        cutNumber: cutNumber,
        value: value,
        weight: weight,
        gradeDate: gradeDate,
        observations: observations,
      );

      // Reload grades for this enrollment
      await loadGradesByEnrollment(enrollmentId, forceRefresh: true);

      debugPrint('✅ Grade created for cut $cutNumber');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating grade: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a grade
  Future<bool> updateGrade(
    String gradeId, {
    double? value,
    double? weight,
    DateTime? gradeDate,
    String? observations,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _gradeService.updateGrade(
        gradeId,
        value: value,
        weight: weight,
        gradeDate: gradeDate,
        observations: observations,
      );

      // Reload grades
      if (_currentEnrollmentId != null) {
        await loadGradesByEnrollment(_currentEnrollmentId!, forceRefresh: true);
      }

      debugPrint('✅ Grade updated: $gradeId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating grade: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a grade
  Future<bool> deleteGrade(String gradeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _gradeService.deleteGrade(gradeId);

      // Remove from cache
      await _gradeDao.delete(gradeId);

      // Update local list
      _grades.removeWhere((g) => g.id == gradeId);

      debugPrint('✅ Grade deleted: $gradeId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error deleting grade: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get passing grades
  List<Grade> getPassingGrades() {
    return _grades.where((g) => g.isPassing).toList();
  }

  /// Get failing grades
  List<Grade> getFailingGrades() {
    return _grades.where((g) => !g.isPassing).toList();
  }

  /// Clear all cached grades
  Future<void> clearCache() async {
    await _gradeDao.clearAll();
    _grades = [];
    notifyListeners();
    debugPrint('🗑️  Grade cache cleared');
  }

  /// Clear cached grades for a specific enrollment
  Future<void> clearCacheForEnrollment(String enrollmentId) async {
    await _gradeDao.clearByEnrollment(enrollmentId);
    if (_currentEnrollmentId == enrollmentId) {
      _grades = [];
      notifyListeners();
    }
    debugPrint('🗑️  Grade cache cleared for enrollment: $enrollmentId');
  }
}
