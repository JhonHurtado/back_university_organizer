import 'package:json_annotation/json_annotation.dart';

part 'career.g.dart';

/// Career status enum
enum CareerStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('GRADUATED')
  graduated,
}

/// Grade scale enum
enum GradeScale {
  @JsonValue('FIVE')
  five, // 0-5 (Colombia, México)
  @JsonValue('TEN')
  ten, // 0-10 (Argentina, España)
  @JsonValue('HUNDRED')
  hundred, // 0-100 (USA porcentaje)
  @JsonValue('FOUR_GPA')
  fourGPA, // 0-4 GPA (USA)
  @JsonValue('SEVEN')
  seven, // 1-7 (Chile)
}

/// Career model representing a university career/program
@JsonSerializable()
class Career {
  final String id;

  @JsonKey(name: 'user_id')
  final String? userId;

  final String name;
  final String? code;
  final String university;
  final String? faculty;
  final String? campus;

  @JsonKey(name: 'total_credits')
  final int? totalCredits;

  @JsonKey(name: 'total_semesters')
  final int? totalSemesters;

  @JsonKey(name: 'current_semester')
  final int? currentSemester;

  @JsonKey(name: 'grade_scale')
  final GradeScale? gradeScale;

  @JsonKey(name: 'min_passing_grade')
  final double? minPassingGrade;

  @JsonKey(name: 'max_grade')
  final double? maxGrade;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'expected_end_date')
  final DateTime? expectedEndDate;

  @JsonKey(name: 'actual_end_date')
  final DateTime? actualEndDate;

  // Backend might send 'state' or 'status'
  @JsonKey(name: 'status', unknownEnumValue: CareerStatus.active)
  final CareerStatus? status;

  final String? color;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  // Additional field that might come from backend as 'state'
  final String? state;

  Career({
    required this.id,
    this.userId,
    required this.name,
    this.code,
    required this.university,
    this.faculty,
    this.campus,
    this.totalCredits,
    this.totalSemesters,
    this.currentSemester,
    this.gradeScale,
    this.minPassingGrade,
    this.maxGrade,
    this.startDate,
    this.expectedEndDate,
    this.actualEndDate,
    this.status,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.state,
  });

  /// Get progress percentage
  double get progressPercentage {
    if (totalSemesters == null || totalSemesters == 0) return 0;
    if (currentSemester == null) return 0;
    return (currentSemester! / totalSemesters!) * 100;
  }

  /// Check if career is active
  bool get isActive => status == CareerStatus.active;

  /// Check if career is completed
  bool get isCompleted => status == CareerStatus.completed || status == CareerStatus.graduated;

  /// Get status display name
  String get statusDisplayName {
    if (status == null) return 'Active';
    switch (status!) {
      case CareerStatus.active:
        return 'Active';
      case CareerStatus.completed:
        return 'Completed';
      case CareerStatus.paused:
        return 'Paused';
      case CareerStatus.cancelled:
        return 'Cancelled';
      case CareerStatus.graduated:
        return 'Graduated';
    }
  }

  /// Get grade scale display name
  String get gradeScaleDisplayName {
    if (gradeScale == null) return '0-5';
    switch (gradeScale!) {
      case GradeScale.five:
        return '0-5';
      case GradeScale.ten:
        return '0-10';
      case GradeScale.hundred:
        return '0-100';
      case GradeScale.fourGPA:
        return '0-4 GPA';
      case GradeScale.seven:
        return '1-7';
    }
  }

  /// JSON serialization
  factory Career.fromJson(Map<String, dynamic> json) => _$CareerFromJson(json);
  Map<String, dynamic> toJson() => _$CareerToJson(this);

  /// Create copy with modifications
  Career copyWith({
    String? id,
    String? userId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Career(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      code: code ?? this.code,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      campus: campus ?? this.campus,
      totalCredits: totalCredits ?? this.totalCredits,
      totalSemesters: totalSemesters ?? this.totalSemesters,
      currentSemester: currentSemester ?? this.currentSemester,
      gradeScale: gradeScale ?? this.gradeScale,
      minPassingGrade: minPassingGrade ?? this.minPassingGrade,
      maxGrade: maxGrade ?? this.maxGrade,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      status: status ?? this.status,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
