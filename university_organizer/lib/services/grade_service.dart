import '../models/grade.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling grades
class GradeService {
  final ApiClient _apiClient;

  GradeService(this._apiClient);

  /// Get all grades for a specific enrollment
  Future<Map<String, dynamic>> getGradesByEnrollment(
      String enrollmentId) async {
    try {
      final response =
          await _apiClient.get('/grades/enrollments/$enrollmentId/grades');

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

  /// Get a specific grade by ID
  Future<Grade> getGrade(String id) async {
    try {
      final response = await _apiClient.get('/grades/grades/$id');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return Grade.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new grade
  Future<Map<String, dynamic>> createGrade({
    required String enrollmentId,
    required int cutNumber,
    required double value,
    required double weight,
    DateTime? gradeDate,
    String? observations,
  }) async {
    try {
      final response = await _apiClient.post(
        '/grades/grades',
        data: {
          'enrollmentId': enrollmentId,
          'cutNumber': cutNumber,
          'value': value,
          'weight': weight,
          if (gradeDate != null) 'gradeDate': gradeDate.toIso8601String(),
          if (observations != null) 'observations': observations,
        },
      );

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

  /// Update a grade
  Future<void> updateGrade(
    String id, {
    double? value,
    double? weight,
    DateTime? gradeDate,
    String? observations,
  }) async {
    try {
      await _apiClient.put(
        '/grades/grades/$id',
        data: {
          if (value != null) 'value': value,
          if (weight != null) 'weight': weight,
          if (gradeDate != null) 'gradeDate': gradeDate.toIso8601String(),
          if (observations != null) 'observations': observations,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a grade
  Future<void> deleteGrade(String id) async {
    try {
      await _apiClient.delete('/grades/grades/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Create a grade item
  Future<Map<String, dynamic>> createGradeItem({
    required String gradeId,
    required String name,
    required double value,
    required double weight,
    required double maxValue,
    DateTime? gradeDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/grades/grade-items',
        data: {
          'gradeId': gradeId,
          'name': name,
          'value': value,
          'weight': weight,
          'maxValue': maxValue,
          if (gradeDate != null) 'gradeDate': gradeDate.toIso8601String(),
        },
      );

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

  /// Update a grade item
  Future<void> updateGradeItem(
    String id, {
    String? name,
    double? value,
    double? weight,
    double? maxValue,
    DateTime? gradeDate,
  }) async {
    try {
      await _apiClient.put(
        '/grades/grade-items/$id',
        data: {
          if (name != null) 'name': name,
          if (value != null) 'value': value,
          if (weight != null) 'weight': weight,
          if (maxValue != null) 'maxValue': maxValue,
          if (gradeDate != null) 'gradeDate': gradeDate.toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a grade item
  Future<void> deleteGradeItem(String id) async {
    try {
      await _apiClient.delete('/grades/grade-items/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get career GPA
  Future<Map<String, dynamic>> getCareerGPA(String careerId) async {
    try {
      final response = await _apiClient.get('/grades/careers/$careerId/gpa');

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
