import '../models/career.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling careers
class CareerService {
  final ApiClient _apiClient;

  CareerService(this._apiClient);

  /// Get all careers for the current user
  Future<List<Career>> getCareers() async {
    try {
      final response = await _apiClient.get('/careers');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      return data.map((json) => Career.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific career by ID
  Future<Career> getCareer(String id) async {
    try {
      final response = await _apiClient.get('/careers/$id');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Career.fromJson(response.data);
    } catch (e) {
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
      final response = await _apiClient.post(
        '/careers',
        data: {
          'name': name,
          'university': university,
          'total_credits': totalCredits,
          'total_semesters': totalSemesters,
          'start_date': startDate.toIso8601String(),
          if (code != null) 'code': code,
          if (faculty != null) 'faculty': faculty,
          if (campus != null) 'campus': campus,
          'grade_scale': gradeScale.name.toUpperCase(),
          'min_passing_grade': minPassingGrade,
          'max_grade': maxGrade,
          if (expectedEndDate != null)
            'expected_end_date': expectedEndDate.toIso8601String(),
          if (color != null) 'color': color,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Career.fromJson(response.data);
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
      final response = await _apiClient.patch(
        '/careers/$id',
        data: {
          if (name != null) 'name': name,
          if (code != null) 'code': code,
          if (university != null) 'university': university,
          if (faculty != null) 'faculty': faculty,
          if (campus != null) 'campus': campus,
          if (totalCredits != null) 'total_credits': totalCredits,
          if (totalSemesters != null) 'total_semesters': totalSemesters,
          if (currentSemester != null) 'current_semester': currentSemester,
          if (gradeScale != null)
            'grade_scale': gradeScale.name.toUpperCase(),
          if (minPassingGrade != null) 'min_passing_grade': minPassingGrade,
          if (maxGrade != null) 'max_grade': maxGrade,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (expectedEndDate != null)
            'expected_end_date': expectedEndDate.toIso8601String(),
          if (actualEndDate != null)
            'actual_end_date': actualEndDate.toIso8601String(),
          if (status != null) 'status': status.name.toUpperCase(),
          if (color != null) 'color': color,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Career.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a career
  Future<void> deleteCareer(String id) async {
    try {
      await _apiClient.delete('/careers/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Update career status
  Future<Career> updateCareerStatus(String id, CareerStatus status) async {
    return updateCareer(id, status: status);
  }

  /// Update current semester
  Future<Career> updateCurrentSemester(String id, int semester) async {
    return updateCareer(id, currentSemester: semester);
  }

  /// Get career statistics
  Future<Map<String, dynamic>> getCareerStatistics(String id) async {
    try {
      final response = await _apiClient.get('/careers/$id/statistics');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
