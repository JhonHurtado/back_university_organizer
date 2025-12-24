import 'package:json_annotation/json_annotation.dart';

part 'grade.g.dart';

/// Grade item type enum
enum GradeItemType {
  @JsonValue('EXAM')
  exam,
  @JsonValue('QUIZ')
  quiz,
  @JsonValue('ASSIGNMENT')
  assignment,
  @JsonValue('PROJECT')
  project,
  @JsonValue('LAB')
  lab,
  @JsonValue('PRESENTATION')
  presentation,
  @JsonValue('PARTICIPATION')
  participation,
  @JsonValue('OTHER')
  other,
}

/// Grade model representing a grade for a cut/period
@JsonSerializable()
class Grade {
  final String id;

  @JsonKey(name: 'enrollment_id')
  final String enrollmentId;

  @JsonKey(name: 'cut_number')
  final int cutNumber;

  @JsonKey(name: 'cut_name')
  final String? cutName;

  final double weight;
  final double grade;

  @JsonKey(name: 'max_grade')
  final double maxGrade;

  @JsonKey(name: 'weighted_grade')
  final double? weightedGrade;

  final String? description;
  final String? notes;

  @JsonKey(name: 'graded_at')
  final DateTime gradedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Grade({
    required this.id,
    required this.enrollmentId,
    required this.cutNumber,
    this.cutName,
    required this.weight,
    required this.grade,
    this.maxGrade = 5.0,
    this.weightedGrade,
    this.description,
    this.notes,
    required this.gradedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get percentage of grade
  double get percentage => (grade / maxGrade) * 100;

  /// Get weighted contribution to final grade
  double get weightedContribution => (grade * weight) / 100;

  /// Check if grade is passing (>= 60%)
  bool get isPassing => percentage >= 60;

  /// Get grade status color
  String get statusColor {
    if (percentage >= 85) return '#10B981'; // Green
    if (percentage >= 70) return '#3B82F6'; // Blue
    if (percentage >= 60) return '#F59E0B'; // Orange
    return '#EF4444'; // Red
  }

  /// Get cut display name
  String get cutDisplayName => cutName ?? 'Cut $cutNumber';

  /// JSON serialization
  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);
  Map<String, dynamic> toJson() => _$GradeToJson(this);

  /// Create copy with modifications
  Grade copyWith({
    String? id,
    String? enrollmentId,
    int? cutNumber,
    String? cutName,
    double? weight,
    double? grade,
    double? maxGrade,
    double? weightedGrade,
    String? description,
    String? notes,
    DateTime? gradedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Grade(
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      cutNumber: cutNumber ?? this.cutNumber,
      cutName: cutName ?? this.cutName,
      weight: weight ?? this.weight,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      weightedGrade: weightedGrade ?? this.weightedGrade,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      gradedAt: gradedAt ?? this.gradedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Grade item model representing individual assessments
@JsonSerializable()
class GradeItem {
  final String id;

  @JsonKey(name: 'grade_id')
  final String gradeId;

  final String name;
  final GradeItemType type;
  final double weight;
  final double grade;

  @JsonKey(name: 'max_grade')
  final double maxGrade;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;

  final String? notes;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  GradeItem({
    required this.id,
    required this.gradeId,
    required this.name,
    required this.type,
    required this.weight,
    required this.grade,
    this.maxGrade = 5.0,
    this.dueDate,
    this.submittedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get percentage of grade
  double get percentage => (grade / maxGrade) * 100;

  /// Check if submitted
  bool get isSubmitted => submittedAt != null;

  /// Check if overdue
  bool get isOverdue {
    if (dueDate == null || isSubmitted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case GradeItemType.exam:
        return 'Exam';
      case GradeItemType.quiz:
        return 'Quiz';
      case GradeItemType.assignment:
        return 'Assignment';
      case GradeItemType.project:
        return 'Project';
      case GradeItemType.lab:
        return 'Lab';
      case GradeItemType.presentation:
        return 'Presentation';
      case GradeItemType.participation:
        return 'Participation';
      case GradeItemType.other:
        return 'Other';
    }
  }

  /// JSON serialization
  factory GradeItem.fromJson(Map<String, dynamic> json) =>
      _$GradeItemFromJson(json);
  Map<String, dynamic> toJson() => _$GradeItemToJson(this);

  /// Create copy with modifications
  GradeItem copyWith({
    String? id,
    String? gradeId,
    String? name,
    GradeItemType? type,
    double? weight,
    double? grade,
    double? maxGrade,
    DateTime? dueDate,
    DateTime? submittedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GradeItem(
      id: id ?? this.id,
      gradeId: gradeId ?? this.gradeId,
      name: name ?? this.name,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      dueDate: dueDate ?? this.dueDate,
      submittedAt: submittedAt ?? this.submittedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
