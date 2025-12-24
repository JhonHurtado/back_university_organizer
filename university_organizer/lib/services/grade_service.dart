import '../models/grade.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for handling grades
class GradeService {
  final ApiClient _apiClient;

  GradeService(this._apiClient);

  /// Get all grades for a specific enrollment
  Future<List<Grade>> getGrades(String enrollmentId) async {
    try {
      final response = await _apiClient.get(
        '/grades',
        queryParameters: {'enrollment_id': enrollmentId},
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      return data.map((json) => Grade.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific grade by ID
  Future<Grade> getGrade(String id) async {
    try {
      final response = await _apiClient.get('/grades/$id');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Grade.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new grade
  Future<Grade> createGrade({
    required String enrollmentId,
    required int cutNumber,
    required double weight,
    required double grade,
    String? cutName,
    double maxGrade = 5.0,
    String? description,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/grades',
        data: {
          'enrollment_id': enrollmentId,
          'cut_number': cutNumber,
          'weight': weight,
          'grade': grade,
          if (cutName != null) 'cut_name': cutName,
          'max_grade': maxGrade,
          if (description != null) 'description': description,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Grade.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a grade
  Future<Grade> updateGrade(
    String id, {
    int? cutNumber,
    String? cutName,
    double? weight,
    double? grade,
    double? maxGrade,
    String? description,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/grades/$id',
        data: {
          if (cutNumber != null) 'cut_number': cutNumber,
          if (cutName != null) 'cut_name': cutName,
          if (weight != null) 'weight': weight,
          if (grade != null) 'grade': grade,
          if (maxGrade != null) 'max_grade': maxGrade,
          if (description != null) 'description': description,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return Grade.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a grade
  Future<void> deleteGrade(String id) async {
    try {
      await _apiClient.delete('/grades/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get grade items for a specific grade
  Future<List<GradeItem>> getGradeItems(String gradeId) async {
    try {
      final response = await _apiClient.get('/grades/$gradeId/items');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];

      return data.map((json) => GradeItem.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a grade item
  Future<GradeItem> createGradeItem({
    required String gradeId,
    required String name,
    required GradeItemType type,
    required double weight,
    required double grade,
    double maxGrade = 5.0,
    DateTime? dueDate,
    DateTime? submittedAt,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/grades/$gradeId/items',
        data: {
          'name': name,
          'type': type.name.toUpperCase(),
          'weight': weight,
          'grade': grade,
          'max_grade': maxGrade,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          if (submittedAt != null)
            'submitted_at': submittedAt.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return GradeItem.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a grade item
  Future<GradeItem> updateGradeItem(
    String id, {
    String? name,
    GradeItemType? type,
    double? weight,
    double? grade,
    double? maxGrade,
    DateTime? dueDate,
    DateTime? submittedAt,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/grade-items/$id',
        data: {
          if (name != null) 'name': name,
          if (type != null) 'type': type.name.toUpperCase(),
          if (weight != null) 'weight': weight,
          if (grade != null) 'grade': grade,
          if (maxGrade != null) 'max_grade': maxGrade,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          if (submittedAt != null)
            'submitted_at': submittedAt.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return GradeItem.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a grade item
  Future<void> deleteGradeItem(String id) async {
    try {
      await _apiClient.delete('/grade-items/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate final grade for an enrollment
  Future<Map<String, dynamic>> calculateFinalGrade(String enrollmentId) async {
    try {
      final response = await _apiClient.get(
        '/grades/calculate-final',
        queryParameters: {'enrollment_id': enrollmentId},
      );

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

  /// Get grade statistics for a career
  Future<Map<String, dynamic>> getGradeStatistics(String careerId) async {
    try {
      final response = await _apiClient.get(
        '/grades/statistics',
        queryParameters: {'career_id': careerId},
      );

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
