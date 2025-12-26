import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../services/academic_service.dart';
import '../database/daos/subject_dao.dart';
import '../database/app_database.dart';

/// Provider for managing subject state with cache-first strategy
class SubjectProvider extends ChangeNotifier {
  final AcademicService _academicService;
  final SubjectDao _subjectDao;

  SubjectProvider(this._academicService)
      : _subjectDao = SubjectDao(AppDatabase.instance);

  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCareerId;
  String? _currentSemesterId;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load subjects for a career with optional filters
  Future<void> loadSubjectsByCareer(
    String careerId, {
    String? semesterId,
    String? subjectType,
    bool? isElective,
    bool forceRefresh = false,
  }) async {
    if (_isLoading &&
        _currentCareerId == careerId &&
        _currentSemesterId == semesterId &&
        !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      _currentCareerId = careerId;
      _currentSemesterId = semesterId;
      notifyListeners();

      if (!forceRefresh) {
        // Try to load from cache first
        List<Subject> cachedSubjects;
        if (semesterId != null) {
          cachedSubjects = await _subjectDao.getBySemesterId(semesterId);
        } else {
          cachedSubjects = await _subjectDao.getByCareerId(careerId);
        }

        if (cachedSubjects.isNotEmpty) {
          _subjects = _filterSubjects(cachedSubjects, subjectType, isElective);
          _isLoading = false;
          notifyListeners();
          debugPrint('📦 Loaded ${cachedSubjects.length} subjects from cache');

          // Fetch fresh data in background
          _fetchAndCacheSubjects(careerId, semesterId, subjectType, isElective);
          return;
        }
      }

      // No cache or force refresh - fetch from API
      await _fetchAndCacheSubjects(careerId, semesterId, subjectType, isElective);
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading subjects: $e');

      // Try to load expired cache as fallback
      List<Subject> expiredCache;
      if (semesterId != null) {
        expiredCache = await _subjectDao.getBySemesterId(semesterId, includeExpired: true);
      } else {
        expiredCache = await _subjectDao.getByCareerId(careerId, includeExpired: true);
      }

      if (expiredCache.isNotEmpty) {
        _subjects = _filterSubjects(expiredCache, subjectType, isElective);
        debugPrint('⚠️  Loaded ${expiredCache.length} subjects from expired cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch subjects from API and cache them
  Future<void> _fetchAndCacheSubjects(
    String careerId,
    String? semesterId,
    String? subjectType,
    bool? isElective,
  ) async {
    try {
      final subjects = await _academicService.getSubjectsByCareer(
        careerId: careerId,
        semesterId: semesterId,
        subjectType: subjectType,
        isElective: isElective,
      );

      // Cache the subjects
      await _subjectDao.insertOrUpdateBatch(subjects);

      _subjects = subjects;
      _error = null;
      notifyListeners();

      debugPrint('🌐 Fetched and cached ${subjects.length} subjects from API');
    } catch (e) {
      debugPrint('❌ Error fetching subjects from API: $e');
      rethrow;
    }
  }

  /// Filter subjects by type and elective status
  List<Subject> _filterSubjects(
    List<Subject> subjects,
    String? subjectType,
    bool? isElective,
  ) {
    var filtered = subjects;

    if (subjectType != null) {
      filtered = filtered
          .where((s) => s.subjectType.name.toLowerCase() == subjectType.toLowerCase())
          .toList();
    }

    if (isElective != null) {
      filtered = filtered.where((s) => s.isElective == isElective).toList();
    }

    return filtered;
  }

  /// Get subject by ID with cache-first strategy
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      // Try cache first
      final cached = await _subjectDao.getById(subjectId);
      if (cached != null) {
        debugPrint('📦 Loaded subject from cache: ${cached.name}');
        return cached;
      }

      // Fetch from API
      final subject = await _academicService.getSubjectById(subjectId);

      // Cache it
      await _subjectDao.insertOrUpdate(subject);

      debugPrint('🌐 Fetched subject from API: ${subject.name}');
      return subject;
    } catch (e) {
      debugPrint('❌ Error getting subject: $e');
      return null;
    }
  }

  /// Create a new subject
  Future<bool> createSubject({
    required String careerId,
    required String semesterId,
    required String code,
    required String name,
    String? description,
    required int credits,
    int? hoursPerWeek,
    required String subjectType,
    String? area,
    int totalCuts = 3,
    bool isElective = false,
    Map<String, double>? gradeWeights,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subject = await _academicService.createSubject(
        careerId: careerId,
        semesterId: semesterId,
        code: code,
        name: name,
        description: description,
        credits: credits,
        hoursPerWeek: hoursPerWeek,
        subjectType: subjectType,
        area: area,
        totalCuts: totalCuts,
        isElective: isElective,
        gradeWeights: gradeWeights,
      );

      // Cache the new subject
      await _subjectDao.insertOrUpdate(subject);

      // Reload subjects for this career
      await loadSubjectsByCareer(careerId, forceRefresh: true);

      debugPrint('✅ Subject created: ${subject.name}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a subject
  Future<bool> updateSubject({
    required String subjectId,
    String? name,
    String? code,
    String? description,
    int? credits,
    int? hoursPerWeek,
    String? subjectType,
    String? area,
    int? totalCuts,
    bool? isElective,
    Map<String, double>? gradeWeights,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.updateSubject(
        subjectId: subjectId,
        name: name,
        code: code,
        description: description,
        credits: credits,
        hoursPerWeek: hoursPerWeek,
        subjectType: subjectType,
        area: area,
        totalCuts: totalCuts,
        isElective: isElective,
        gradeWeights: gradeWeights,
      );

      // Reload from API to get updated data
      if (_currentCareerId != null) {
        await loadSubjectsByCareer(_currentCareerId!, forceRefresh: true);
      }

      debugPrint('✅ Subject updated: $subjectId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a subject
  Future<bool> deleteSubject(String subjectId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _academicService.deleteSubject(subjectId);

      // Remove from cache
      await _subjectDao.delete(subjectId);

      // Update local list
      _subjects.removeWhere((s) => s.id == subjectId);

      debugPrint('✅ Subject deleted: $subjectId');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error deleting subject: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all cached subjects
  Future<void> clearCache() async {
    await _subjectDao.clearAll();
    _subjects = [];
    notifyListeners();
    debugPrint('🗑️  Subject cache cleared');
  }

  /// Clear cached subjects for a specific career
  Future<void> clearCacheForCareer(String careerId) async {
    await _subjectDao.clearByCareer(careerId);
    if (_currentCareerId == careerId) {
      _subjects = [];
      notifyListeners();
    }
    debugPrint('🗑️  Subject cache cleared for career: $careerId');
  }

  /// Clear cached subjects for a specific semester
  Future<void> clearCacheForSemester(String semesterId) async {
    await _subjectDao.clearBySemester(semesterId);
    if (_currentSemesterId == semesterId) {
      _subjects = [];
      notifyListeners();
    }
    debugPrint('🗑️  Subject cache cleared for semester: $semesterId');
  }
}
