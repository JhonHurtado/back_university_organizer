import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

/// Subject type enum
enum SubjectType {
  @JsonValue('REQUIRED')
  required,
  @JsonValue('ELECTIVE')
  elective,
  @JsonValue('FREE_ELECTIVE')
  freeElective,
  @JsonValue('COMPLEMENTARY')
  complementary,
}

/// Subject model representing a course/subject
@JsonSerializable()
class Subject {
  final String id;

  @JsonKey(name: 'career_id')
  final String careerId;

  @JsonKey(name: 'semester_id')
  final String semesterId;

  final String code;
  final String name;
  final String? description;
  final int credits;

  @JsonKey(name: 'hours_per_week')
  final int? hoursPerWeek;

  @JsonKey(name: 'subject_type')
  final SubjectType subjectType;

  final String? area;

  @JsonKey(name: 'grade_weights')
  final Map<String, dynamic>? gradeWeights;

  @JsonKey(name: 'total_cuts')
  final int totalCuts;

  @JsonKey(name: 'is_elective')
  final bool isElective;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  Subject({
    required this.id,
    required this.careerId,
    required this.semesterId,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    this.hoursPerWeek,
    this.subjectType = SubjectType.required,
    this.area,
    this.gradeWeights,
    this.totalCuts = 3,
    this.isElective = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Get subject type display name
  String get subjectTypeDisplayName {
    switch (subjectType) {
      case SubjectType.required:
        return 'Required';
      case SubjectType.elective:
        return 'Elective';
      case SubjectType.freeElective:
        return 'Free Elective';
      case SubjectType.complementary:
        return 'Complementary';
    }
  }

  /// Get abbreviated code
  String get abbreviatedCode {
    if (code.length <= 8) return code;
    return '${code.substring(0, 8)}...';
  }

  /// JSON serialization
  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  /// Create copy with modifications
  Subject copyWith({
    String? id,
    String? careerId,
    String? semesterId,
    String? code,
    String? name,
    String? description,
    int? credits,
    int? hoursPerWeek,
    SubjectType? subjectType,
    String? area,
    Map<String, dynamic>? gradeWeights,
    int? totalCuts,
    bool? isElective,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      semesterId: semesterId ?? this.semesterId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      subjectType: subjectType ?? this.subjectType,
      area: area ?? this.area,
      gradeWeights: gradeWeights ?? this.gradeWeights,
      totalCuts: totalCuts ?? this.totalCuts,
      isElective: isElective ?? this.isElective,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
