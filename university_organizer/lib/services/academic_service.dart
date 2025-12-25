import '../models/subject.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Service for managing academic entities (semesters, subjects, periods, enrollments)
class AcademicService {
  final ApiClient _apiClient;

  AcademicService(this._apiClient);

  // ==================== SEMESTERS ====================

  /// Create a new semester
  Future<Map<String, dynamic>> createSemester({
    required String careerId,
    required int number,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '/academic/semesters',
        data: {
          'careerId': careerId,
          'number': number,
          'name': name,
          if (description != null) 'description': description,
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

  /// Get semesters by career
  Future<List<Map<String, dynamic>>> getSemestersByCareer(
      String careerId) async {
    try {
      final response =
          await _apiClient.get('/academic/careers/$careerId/semesters');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get semester by ID
  Future<Map<String, dynamic>> getSemesterById(String semesterId) async {
    try {
      final response = await _apiClient.get('/academic/semesters/$semesterId');

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

  /// Update semester
  Future<void> updateSemester({
    required String semesterId,
    String? name,
    String? description,
  }) async {
    try {
      await _apiClient.put(
        '/academic/semesters/$semesterId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete semester
  Future<void> deleteSemester(String semesterId) async {
    try {
      await _apiClient.delete('/academic/semesters/$semesterId');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SUBJECTS ====================

  /// Create a new subject
  Future<Subject> createSubject({
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
      final response = await _apiClient.post(
        '/academic/subjects',
        data: {
          'careerId': careerId,
          'semesterId': semesterId,
          'code': code,
          'name': name,
          if (description != null) 'description': description,
          'credits': credits,
          if (hoursPerWeek != null) 'hoursPerWeek': hoursPerWeek,
          'subjectType': subjectType,
          if (area != null) 'area': area,
          'totalCuts': totalCuts,
          'isElective': isElective,
          if (gradeWeights != null) 'gradeWeights': gradeWeights,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return Subject.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get subjects by career
  Future<List<Subject>> getSubjectsByCareer({
    required String careerId,
    String? semesterId,
    String? subjectType,
    bool? isElective,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (semesterId != null) 'semesterId': semesterId,
        if (subjectType != null) 'subjectType': subjectType,
        if (isElective != null) 'isElective': isElective,
      };

      final response = await _apiClient.get(
        '/academic/careers/$careerId/subjects',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      final List<dynamic> subjects = data is List ? data : [];

      return subjects.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get subject by ID
  Future<Subject> getSubjectById(String subjectId) async {
    try {
      final response = await _apiClient.get('/academic/subjects/$subjectId');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return Subject.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update subject
  Future<void> updateSubject({
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
      await _apiClient.put(
        '/academic/subjects/$subjectId',
        data: {
          if (name != null) 'name': name,
          if (code != null) 'code': code,
          if (description != null) 'description': description,
          if (credits != null) 'credits': credits,
          if (hoursPerWeek != null) 'hoursPerWeek': hoursPerWeek,
          if (subjectType != null) 'subjectType': subjectType,
          if (area != null) 'area': area,
          if (totalCuts != null) 'totalCuts': totalCuts,
          if (isElective != null) 'isElective': isElective,
          if (gradeWeights != null) 'gradeWeights': gradeWeights,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete subject
  Future<void> deleteSubject(String subjectId) async {
    try {
      await _apiClient.delete('/academic/subjects/$subjectId');
    } catch (e) {
      rethrow;
    }
  }

  /// Add prerequisite to subject
  Future<void> addPrerequisite({
    required String subjectId,
    required String prerequisiteId,
    bool isStrict = true,
  }) async {
    try {
      await _apiClient.post(
        '/academic/subjects/$subjectId/prerequisites',
        data: {
          'prerequisiteId': prerequisiteId,
          'isStrict': isStrict,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove prerequisite from subject
  Future<void> removePrerequisite({
    required String subjectId,
    required String prerequisiteId,
  }) async {
    try {
      await _apiClient.delete(
        '/academic/subjects/$subjectId/prerequisites/$prerequisiteId',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== PERIODS ====================

  /// Create academic period
  Future<Map<String, dynamic>> createPeriod({
    required String careerId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/academic/periods',
        data: {
          'careerId': careerId,
          'name': name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
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

  /// Get periods by career
  Future<List<Map<String, dynamic>>> getPeriodsByCareer(
      String careerId) async {
    try {
      final response =
          await _apiClient.get('/academic/careers/$careerId/periods');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current period
  Future<Map<String, dynamic>> getCurrentPeriod(String careerId) async {
    try {
      final response =
          await _apiClient.get('/academic/careers/$careerId/periods/current');

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

  // ==================== ENROLLMENTS ====================

  /// Enroll in a subject
  Future<Map<String, dynamic>> enrollInSubject({
    required String careerId,
    required String subjectId,
    required String periodId,
    String? section,
    String? classroom,
  }) async {
    try {
      final response = await _apiClient.post(
        '/academic/enrollments',
        data: {
          'careerId': careerId,
          'subjectId': subjectId,
          'periodId': periodId,
          if (section != null) 'section': section,
          if (classroom != null) 'classroom': classroom,
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

  /// Get enrollments by career
  Future<List<Map<String, dynamic>>> getEnrollmentsByCareer({
    required String careerId,
    String? status,
    String? periodId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (status != null) 'status': status,
        if (periodId != null) 'periodId': periodId,
      };

      final response = await _apiClient.get(
        '/academic/careers/$careerId/enrollments',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get enrollment by ID
  Future<Map<String, dynamic>> getEnrollmentById(String enrollmentId) async {
    try {
      final response =
          await _apiClient.get('/academic/enrollments/$enrollmentId');

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

  /// Update enrollment
  Future<void> updateEnrollment({
    required String enrollmentId,
    String? section,
    String? classroom,
    String? status,
  }) async {
    try {
      await _apiClient.put(
        '/academic/enrollments/$enrollmentId',
        data: {
          if (section != null) 'section': section,
          if (classroom != null) 'classroom': classroom,
          if (status != null) 'status': status,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Withdraw from enrollment
  Future<void> withdrawFromEnrollment(String enrollmentId) async {
    try {
      await _apiClient.post('/academic/enrollments/$enrollmentId/withdraw');
    } catch (e) {
      rethrow;
    }
  }
}
