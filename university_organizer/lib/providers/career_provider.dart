import 'package:flutter/material.dart';
import '../models/career.dart';
import '../services/career_service.dart';
import '../services/api_exception.dart';
import '../database/daos/career_dao.dart';
import '../database/app_database.dart';

/// Provider for managing careers with cache-first strategy
class CareerProvider extends ChangeNotifier {
  final CareerService _careerService;
  final CareerDao _careerDao;

  List<Career> _careers = [];
  Career? _selectedCareer;
  bool _isLoading = false;
  String? _error;

  CareerProvider(this._careerService)
      : _careerDao = CareerDao(AppDatabase.instance);

  // Getters
  List<Career> get careers => _careers;
  Career? get selectedCareer => _selectedCareer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCareers => _careers.isNotEmpty;

  /// Get active careers
  List<Career> get activeCareers =>
      _careers.where((c) => c.status == CareerStatus.active).toList();

  /// Get completed careers
  List<Career> get completedCareers =>
      _careers.where((c) => c.isCompleted).toList();

  /// Get total active careers count
  int get activeCareersCount => activeCareers.length;

  /// Load all careers with cache-first strategy
  Future<void> loadCareers({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        final cachedCareers = await _careerDao.getAll();
        if (cachedCareers.isNotEmpty) {
          _careers = cachedCareers;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedCareers.length} careers from cache');

          // Fetch fresh data in background
          _fetchAndCacheCareers();
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheCareers();
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _error = e.userMessage;
      } else {
        _error = 'Failed to load careers';
      }
      debugPrint('❌ Error loading careers: $e');

      // Try to load expired cache as fallback
      final expiredCache = await _careerDao.getAll(includeExpired: true);
      if (expiredCache.isNotEmpty) {
        _careers = expiredCache;
        debugPrint('⚠️  Loaded ${expiredCache.length} careers from expired cache');
      }

      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch careers from API and cache them
  Future<void> _fetchAndCacheCareers() async {
    try {
      final careers = await _careerService.getCareers();

      // Cache the careers
      await _careerDao.insertOrUpdateBatch(careers);

      _careers = careers;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${careers.length} careers from API');
    } catch (e) {
      debugPrint('❌ Error fetching careers from API: $e');
      rethrow;
    }
  }

  /// Load a specific career with cache-first strategy
  Future<void> loadCareer(String id, {bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!forceRefresh) {
        // Try cache first
        final cached = await _careerDao.getById(id);
        if (cached != null) {
          _selectedCareer = cached;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded career from cache: ${cached.name}');

          // Fetch fresh data in background
          _fetchAndCacheCareer(id);
          return;
        }
      }

      // Fetch from API
      await _fetchAndCacheCareer(id);
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _error = e.userMessage;
      } else {
        _error = 'Failed to load career';
      }
      debugPrint('❌ Error loading career: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch career from API and cache it
  Future<void> _fetchAndCacheCareer(String id) async {
    try {
      final career = await _careerService.getCareer(id);

      // Cache it
      await _careerDao.insertOrUpdate(career);

      _selectedCareer = career;
      _isLoading = false;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched career from API: ${career.name}');
    } catch (e) {
      debugPrint('❌ Error fetching career from API: $e');
      rethrow;
    }
  }

  /// Create a new career
  Future<Career> createCareer({
    required String name,
    required String university,
    required int totalCredits,
    required int totalSemesters,
    required DateTime startDate,
    String? code,
    String? faculty,
    String? campus,
    GradeScale gradeScale = GradeScale.five,
    double minPassingGrade = 3.0,
    double maxGrade = 5.0,
    DateTime? expectedEndDate,
    String? color,
  }) async {
    try {
      final career = await _careerService.createCareer(
        name: name,
        university: university,
        totalCredits: totalCredits,
        totalSemesters: totalSemesters,
        startDate: startDate,
        code: code,
        faculty: faculty,
        campus: campus,
        gradeScale: gradeScale,
        minPassingGrade: minPassingGrade,
        maxGrade: maxGrade,
        expectedEndDate: expectedEndDate,
        color: color,
      );

      // Cache the new career
      await _careerDao.insertOrUpdate(career);

      _careers.add(career);
      notifyListeners();

      debugPrint('✅ Career created: ${career.name}');
      return career;
    } catch (e) {
      debugPrint('❌ Error creating career: $e');
      rethrow;
    }
  }

  /// Update a career
  Future<Career> updateCareer(
    String id, {
    String? name,
    String? code,
    String? university,
    String? faculty,
    String? campus,
    int? totalCredits,
    int? totalSemesters,
    int? currentSemester,
    GradeScale? gradeScale,
    double? minPassingGrade,
    double? maxGrade,
    DateTime? startDate,
    DateTime? expectedEndDate,
    DateTime? actualEndDate,
    CareerStatus? status,
    String? color,
  }) async {
    try {
      final updatedCareer = await _careerService.updateCareer(
        id,
        name: name,
        code: code,
        university: university,
        faculty: faculty,
        campus: campus,
        totalCredits: totalCredits,
        totalSemesters: totalSemesters,
        currentSemester: currentSemester,
        gradeScale: gradeScale,
        minPassingGrade: minPassingGrade,
        maxGrade: maxGrade,
        startDate: startDate,
        expectedEndDate: expectedEndDate,
        actualEndDate: actualEndDate,
        status: status,
        color: color,
      );

      // Update cache
      await _careerDao.insertOrUpdate(updatedCareer);

      final index = _careers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _careers[index] = updatedCareer;
      }

      if (_selectedCareer?.id == id) {
        _selectedCareer = updatedCareer;
      }

      notifyListeners();
      debugPrint('✅ Career updated: ${updatedCareer.name}');
      return updatedCareer;
    } catch (e) {
      debugPrint('❌ Error updating career: $e');
      rethrow;
    }
  }

  /// Delete a career
  Future<void> deleteCareer(String id) async {
    try {
      await _careerService.deleteCareer(id);

      // Remove from cache
      await _careerDao.delete(id);

      _careers.removeWhere((c) => c.id == id);

      if (_selectedCareer?.id == id) {
        _selectedCareer = null;
      }

      notifyListeners();
      debugPrint('✅ Career deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting career: $e');
      rethrow;
    }
  }

  /// Update career status
  Future<void> updateCareerStatus(String id, CareerStatus status) async {
    try {
      final updatedCareer = await _careerService.updateCareerStatus(id, status);

      // Update cache
      await _careerDao.insertOrUpdate(updatedCareer);

      final index = _careers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _careers[index] = updatedCareer;
      }

      if (_selectedCareer?.id == id) {
        _selectedCareer = updatedCareer;
      }

      notifyListeners();
      debugPrint('✅ Career status updated: $status');
    } catch (e) {
      debugPrint('❌ Error updating career status: $e');
      rethrow;
    }
  }

  /// Select a career
  void selectCareer(Career career) {
    _selectedCareer = career;
    notifyListeners();
  }

  /// Clear selected career
  void clearSelectedCareer() {
    _selectedCareer = null;
    notifyListeners();
  }

  /// Refresh careers (force reload from API)
  Future<void> refresh() async {
    await loadCareers(forceRefresh: true);
  }

  /// Clear all cached careers
  Future<void> clearCache() async {
    await _careerDao.clearAll();
    _careers = [];
    notifyListeners();
    debugPrint('🗑️  Career cache cleared');
  }
}
