import 'package:flutter/material.dart';
import '../models/career.dart';
import '../services/career_service.dart';
import '../services/api_exception.dart';

/// Provider for managing careers
class CareerProvider extends ChangeNotifier {
  final CareerService _careerService;

  List<Career> _careers = [];
  Career? _selectedCareer;
  bool _isLoading = false;
  String? _error;

  CareerProvider(this._careerService);

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

  /// Load all careers
  Future<void> loadCareers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _careers = await _careerService.getCareers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _error = e.userMessage;
      } else {
        _error = 'Failed to load careers';
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Load a specific career
  Future<void> loadCareer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCareer = await _careerService.getCareer(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _error = e.userMessage;
      } else {
        _error = 'Failed to load career';
      }
      notifyListeners();
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

      _careers.add(career);
      notifyListeners();
      return career;
    } catch (e) {
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

      final index = _careers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _careers[index] = updatedCareer;
      }

      if (_selectedCareer?.id == id) {
        _selectedCareer = updatedCareer;
      }

      notifyListeners();
      return updatedCareer;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a career
  Future<void> deleteCareer(String id) async {
    try {
      await _careerService.deleteCareer(id);
      _careers.removeWhere((c) => c.id == id);

      if (_selectedCareer?.id == id) {
        _selectedCareer = null;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update career status
  Future<void> updateCareerStatus(String id, CareerStatus status) async {
    try {
      final updatedCareer = await _careerService.updateCareerStatus(id, status);

      final index = _careers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _careers[index] = updatedCareer;
      }

      if (_selectedCareer?.id == id) {
        _selectedCareer = updatedCareer;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update current semester
  Future<void> updateCurrentSemester(String id, int semester) async {
    try {
      final updatedCareer =
          await _careerService.updateCurrentSemester(id, semester);

      final index = _careers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _careers[index] = updatedCareer;
      }

      if (_selectedCareer?.id == id) {
        _selectedCareer = updatedCareer;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Select a career
  void selectCareer(Career? career) {
    _selectedCareer = career;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh careers
  Future<void> refresh() async {
    await loadCareers();
  }
}
