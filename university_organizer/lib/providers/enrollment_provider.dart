import 'package:flutter/foundation.dart';
import '../models/enrollment.dart';
import '../services/academic_service.dart';
import '../database/daos/enrollment_dao.dart';
import '../database/app_database.dart';

/// Provider for managing enrollment state with cache-first strategy
class EnrollmentProvider extends ChangeNotifier {
  final AcademicService _academicService;
  final EnrollmentDao _enrollmentDao;

  EnrollmentProvider(this._academicService)
      : _enrollmentDao = EnrollmentDao(AppDatabase.instance);

  List<Enrollment> _enrollments = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCareerId;
  String? _currentPeriodId;
  String? _currentStatus;

  List<Enrollment> get enrollments => _enrollments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get active enrollments
  List<Enrollment> get activeEnrollments =>
      _enrollments.where((e) => e.isActive).toList();

  /// Get completed enrollments
  List<Enrollment> get completedEnrollments =>
      _enrollments.where((e) => e.isCompleted).toList();

  /// Load enrollments for a career with optional filters
  Future<void> loadEnrollmentsByCareer(
    String careerId, {
    String? status,
    String? periodId,
    bool forceRefresh = false,
  }) async {
    if (_isLoading &&
        _currentCareerId == careerId &&
        _currentStatus == status &&
        _currentPeriodId == periodId &&
        !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentCareerId = careerId;
      _currentStatus = status;
      _currentPeriodId = periodId;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        List<Enrollment> cachedEnrollments;
        if (periodId != null) {
          cachedEnrollments = await _enrollmentDao.getByPeriodId(periodId);
        } else {
          cachedEnrollments = await _enrollmentDao.getByCareerId(careerId);
        }

        if (cachedEnrollments.isNotEmpty) {
          _enrollments = _filterEnrollments(cachedEnrollments, status);
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedEnrollments.length} enrollments from cache');

          // Fetch fresh data in background
          _fetchAndCacheEnrollments(careerId, status, periodId);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheEnrollments(careerId, status, periodId);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading enrollments: $e');

      // Try to load expired cache as fallback
      List<Enrollment> expiredCache;
      if (periodId != null) {
        expiredCache = await _enrollmentDao.getByPeriodId(periodId, includeExpired: true);
      } else {
        expiredCache = await _enrollmentDao.getByCareerId(careerId, includeExpired: true);
      }

      if (expiredCache.isNotEmpty) {
        _enrollments = _filterEnrollments(expiredCache, status);
        debugPrint('⚠️  Loaded ${expiredCache.length} enrollments from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch enrollments from API and cache them
  Future<void> _fetchAndCacheEnrollments(
    String careerId,
    String? status,
    String? periodId,
  ) async {
    try {
      final response = await _academicService.getEnrollmentsByCareer(
        careerId: careerId,
        status: status,
        periodId: periodId,
      );

      final enrollments = response.map((json) => Enrollment.fromJson(json)).toList();

      // Cache the enrollments
      await _enrollmentDao.insertOrUpdateBatch(enrollments);

      _enrollments = enrollments;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${enrollments.length} enrollments from API');
    } catch (e) {
      debugPrint('❌ Error fetching enrollments from API: $e');
      rethrow;
    }
  }

  /// Filter enrollments by status
  List<Enrollment> _filterEnrollments(List<Enrollment> enrollments, String? status) {
    if (status == null) return enrollments;

    return enrollments
        .where((e) => e.status.name.toUpperCase() == status.toUpperCase())
        .toList();
  }

  /// Get enrollment by ID with cache-first strategy
  Future<Enrollment?> getEnrollmentById(String enrollmentId) async {
    try {
      // Try cache first
      final cached = await _enrollmentDao.getById(enrollmentId);
      if (cached != null) {
        debugPrint('📦 Loaded enrollment from cache: $enrollmentId');
        return cached;
      }

      // Fetch from API
      final response = await _academicService.getEnrollmentById(enrollmentId);
      final enrollment = Enrollment.fromJson(response);

      // Cache it
      await _enrollmentDao.insertOrUpdate(enrollment);

      debugPrint('🌐 Fetched enrollment from API: $enrollmentId');
      return enrollment;
    } catch (e) {
      debugPrint('❌ Error getting enrollment: $e');
      return null;
    }
  }

  /// Get enrollments by subject
  Future<List<Enrollment>> getEnrollmentsBySubject(String subjectId) async {
    try {
      // Try cache first
      final cached = await _enrollmentDao.getBySubjectId(subjectId);
      if (cached.isNotEmpty) {
        debugPrint('📦 Loaded ${cached.length} enrollments from cache for subject');
        return cached;
      }

      // If not in cache, filter from current enrollments
      return _enrollments.where((e) => e.subjectId == subjectId).toList();
    } catch (e) {
      debugPrint('❌ Error getting enrollments by subject: $e');
      return [];
    }
  }

  /// Load active enrollments
  Future<void> loadActiveEnrollments({bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!forceRefresh) {
        // Try cache first
        final cached = await _enrollmentDao.getActiveEnrollments();
        if (cached.isNotEmpty) {
          _enrollments = cached;
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cached.length} active enrollments from cache');
          return;
        }
      }

      // Need to fetch from API through career
      if (_currentCareerId != null) {
        await loadEnrollmentsByCareer(_currentCareerId!, forceRefresh: true);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading active enrollments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enroll in a subject
  Future<bool> enrollInSubject({
    required String careerId,
    required String subjectId,
    required String periodId,
    String? section,
    String? classroom,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _academicService.enrollInSubject(
        careerId: careerId,
        subjectId: subjectId,
        periodId: periodId,
        section: section,
        classroom: classroom,
      );

      final enrollment = Enrollment.fromJson(response);

      // Cache the new enrollment
      await _enrollmentDao.insertOrUpdate(enrollment);

      // Reload enrollments for this career
      await loadEnrollmentsByCareer(careerId, forceRefresh: true);

      debugPrint('✅ Enrolled in subject: $subjectId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error enrolling in subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an enrollment
  Future<bool> updateEnrollment({
    required String enrollmentId,
    String? section,
    String? classroom,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.updateEnrollment(
        enrollmentId: enrollmentId,
        section: section,
        classroom: classroom,
        status: status,
      );

      // Reload from API to get updated data
      if (_currentCareerId != null) {
        await loadEnrollmentsByCareer(_currentCareerId!, forceRefresh: true);
      }

      debugPrint('✅ Enrollment updated: $enrollmentId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating enrollment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Withdraw from an enrollment
  Future<bool> withdrawFromEnrollment(String enrollmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.withdrawFromEnrollment(enrollmentId);

      // Remove from cache
      await _enrollmentDao.delete(enrollmentId);

      // Update local list
      _enrollments.removeWhere((e) => e.id == enrollmentId);

      debugPrint('✅ Withdrawn from enrollment: $enrollmentId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error withdrawing from enrollment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all cached enrollments
  Future<void> clearCache() async {
    await _enrollmentDao.clearAll();
    _enrollments = [];
    notifyListeners();
    debugPrint('🗑️  Enrollment cache cleared');
  }

  /// Clear cached enrollments for a specific career
  Future<void> clearCacheForCareer(String careerId) async {
    await _enrollmentDao.clearByCareer(careerId);
    if (_currentCareerId == careerId) {
      _enrollments = [];
      notifyListeners();
    }
    debugPrint('🗑️  Enrollment cache cleared for career: $careerId');
  }

  /// Clear cached enrollments for a specific period
  Future<void> clearCacheForPeriod(String periodId) async {
    await _enrollmentDao.clearByPeriod(periodId);
    if (_currentPeriodId == periodId) {
      _enrollments = [];
      notifyListeners();
    }
    debugPrint('🗑️  Enrollment cache cleared for period: $periodId');
  }
}
