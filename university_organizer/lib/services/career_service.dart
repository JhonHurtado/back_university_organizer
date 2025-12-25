import '../models/career.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling careers
class CareerService {
  final ApiClient _apiClient;

  CareerService(this._apiClient);

  /// Get all careers for the current user
  Future<List<Career>> getCareers({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/careers',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      final List<dynamic> careers = data['careers'] ?? data;

      return careers.map((json) => Career.fromJson(json)).toList();
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

      final data = response.data['data'] ?? response.data;
      return Career.fromJson(data);
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
    int currentSemester = 1,
    GradeScale gradeScale = GradeScale.five,
    double minPassingGrade = 3.0,
    double maxGrade = 5.0,
    DateTime? expectedEndDate,
    String? color,
    String status = 'ACTIVE',
  }) async {
    try {
      final response = await _apiClient.post(
        '/careers',
        data: {
          'name': name,
          'university': university,
          'totalCredits': totalCredits,
          'totalSemesters': totalSemesters,
          'currentSemester': currentSemester,
          'startDate': startDate.toIso8601String(),
          if (code != null) 'code': code,
          if (faculty != null) 'faculty': faculty,
          if (campus != null) 'campus': campus,
          'gradeScale': gradeScale.name.toUpperCase(),
          'minPassingGrade': minPassingGrade,
          'maxGrade': maxGrade,
          if (expectedEndDate != null)
            'expectedEndDate': expectedEndDate.toIso8601String(),
          if (color != null) 'color': color,
          'status': status,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return Career.fromJson(data);
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
      final response = await _apiClient.put(
        '/careers/$id',
        data: {
          if (name != null) 'name': name,
          if (code != null) 'code': code,
          if (university != null) 'university': university,
          if (faculty != null) 'faculty': faculty,
          if (campus != null) 'campus': campus,
          if (totalCredits != null) 'totalCredits': totalCredits,
          if (totalSemesters != null) 'totalSemesters': totalSemesters,
          if (currentSemester != null) 'currentSemester': currentSemester,
          if (gradeScale != null)
            'gradeScale': gradeScale.name.toUpperCase(),
          if (minPassingGrade != null) 'minPassingGrade': minPassingGrade,
          if (maxGrade != null) 'maxGrade': maxGrade,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (expectedEndDate != null)
            'expectedEndDate': expectedEndDate.toIso8601String(),
          if (actualEndDate != null)
            'actualEndDate': actualEndDate.toIso8601String(),
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

      final data = response.data['data'] ?? response.data;
      return Career.fromJson(data);
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
  Future<void> updateCurrentSemester(String id, int semester) async {
    try {
      await _apiClient.put(
        '/careers/$id/semester',
        data: {
          'currentSemester': semester,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restore deleted career
  Future<void> restoreCareer(String id) async {
    try {
      await _apiClient.post('/careers/$id/restore');
    } catch (e) {
      rethrow;
    }
  }

  /// Get career statistics
  Future<Map<String, dynamic>> getCareerStatistics(String id) async {
    try {
      final response = await _apiClient.get('/careers/$id/stats');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
