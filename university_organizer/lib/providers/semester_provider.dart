import 'package:flutter/foundation.dart';
import '../models/semester.dart';
import '../services/academic_service.dart';
import '../database/daos/semester_dao.dart';
import '../database/app_database.dart';

/// Provider for managing semester state with cache-first strategy
class SemesterProvider extends ChangeNotifier {
  final AcademicService _academicService;
  final SemesterDao _semesterDao;

  SemesterProvider(this._academicService)
      : _semesterDao = SemesterDao(AppDatabase.instance);

  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCareerId;

  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load semesters for a career with cache-first strategy
  Future<void> loadSemestersByCareer(String careerId, {bool forceRefresh = false}) async {
    if (_isLoading && _currentCareerId == careerId && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      _currentCareerId = careerId;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        final cachedSemesters = await _semesterDao.getByCareerId(careerId);
        if (cachedSemesters.isNotEmpty) {
          _semesters = cachedSemesters;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedSemesters.length} semesters from cache');

          // Fetch fresh data in background
          _fetchAndCacheSemesters(careerId);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheSemesters(careerId);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading semesters: $e');

      // Try to load expired cache as fallback
      final expiredCache = await _semesterDao.getByCareerId(careerId, includeExpired: true);
      if (expiredCache.isNotEmpty) {
        _semesters = expiredCache;
        debugPrint('⚠️  Loaded ${expiredCache.length} semesters from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch semesters from API and cache them
  Future<void> _fetchAndCacheSemesters(String careerId) async {
    try {
      final response = await _academicService.getSemestersByCareer(careerId);
      final semesters = response.map((json) => Semester.fromJson(json)).toList();

      // Cache the semesters
      await _semesterDao.insertOrUpdateBatch(semesters);

      _semesters = semesters;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${semesters.length} semesters from API');
    } catch (e) {
      debugPrint('❌ Error fetching semesters from API: $e');
      rethrow;
    }
  }

  /// Get semester by ID with cache-first strategy
  Future<Semester?> getSemesterById(String semesterId) async {
    try {
      // Try cache first
      final cached = await _semesterDao.getById(semesterId);
      if (cached != null) {
        debugPrint('📦 Loaded semester from cache: ${cached.name}');
        return cached;
      }

      // Fetch from API
      final response = await _academicService.getSemesterById(semesterId);
      final semester = Semester.fromJson(response);

      // Cache it
      await _semesterDao.insertOrUpdate(semester);

      debugPrint('🌐 Fetched semester from API: ${semester.name}');
      return semester;
    } catch (e) {
      debugPrint('❌ Error getting semester: $e');
      return null;
    }
  }

  /// Create a new semester
  Future<bool> createSemester({
    required String careerId,
    required int number,
    required String name,
    String? description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _academicService.createSemester(
        careerId: careerId,
        number: number,
        name: name,
        description: description,
      );

      final semester = Semester.fromJson(response);

      // Cache the new semester
      await _semesterDao.insertOrUpdate(semester);

      // Reload semesters for this career
      await loadSemestersByCareer(careerId, forceRefresh: true);

      debugPrint('✅ Semester created: ${semester.name}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating semester: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a semester
  Future<bool> updateSemester({
    required String semesterId,
    String? name,
    String? description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.updateSemester(
        semesterId: semesterId,
        name: name,
        description: description,
      );

      // Reload from API to get updated data
      if (_currentCareerId != null) {
        await loadSemestersByCareer(_currentCareerId!, forceRefresh: true);
      }

      debugPrint('✅ Semester updated: $semesterId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating semester: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a semester
  Future<bool> deleteSemester(String semesterId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.deleteSemester(semesterId);

      // Remove from cache
      await _semesterDao.delete(semesterId);

      // Update local list
      _semesters.removeWhere((s) => s.id == semesterId);

      debugPrint('✅ Semester deleted: $semesterId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error deleting semester: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all cached semesters
  Future<void> clearCache() async {
    await _semesterDao.clearAll();
    _semesters = [];
    notifyListeners();
    debugPrint('🗑️  Semester cache cleared');
  }

  /// Clear cached semesters for a specific career
  Future<void> clearCacheForCareer(String careerId) async {
    await _semesterDao.clearByCareer(careerId);
    if (_currentCareerId == careerId) {
      _semesters = [];
      notifyListeners();
    }
    debugPrint('🗑️  Semester cache cleared for career: $careerId');
  }
}
