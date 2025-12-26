import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'subject.dart';
import 'period.dart';

part 'enrollment.g.dart';

/// Enrollment status enum
enum EnrollmentStatus {
  @JsonValue('ENROLLED')
  enrolled,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('PASSED')
  passed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('WITHDRAWN')
  withdrawn,
}

/// Enrollment model - represents a student enrolled in a subject
@JsonSerializable()
class Enrollment extends Equatable {
  final String id;
  final String careerId;
  final String subjectId;
  final String periodId;
  final String? section;
  final String? classroom;
  final EnrollmentStatus status;
  final double? finalGrade;
  final String? professorId;

  // Nested objects (optional, depend on API include params)
  final Subject? subject;
  final Period? period;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Enrollment({
    required this.id,
    required this.careerId,
    required this.subjectId,
    required this.periodId,
    this.section,
    this.classroom,
    required this.status,
    this.finalGrade,
    this.professorId,
    this.subject,
    this.period,
    this.createdAt,
    this.updatedAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentFromJson(json);

  Map<String, dynamic> toJson() => _$EnrollmentToJson(this);

  Enrollment copyWith({
    String? id,
    String? careerId,
    String? subjectId,
    String? periodId,
    String? section,
    String? classroom,
    EnrollmentStatus? status,
    double? finalGrade,
    String? professorId,
    Subject? subject,
    Period? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Enrollment(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      subjectId: subjectId ?? this.subjectId,
      periodId: periodId ?? this.periodId,
      section: section ?? this.section,
      classroom: classroom ?? this.classroom,
      status: status ?? this.status,
      finalGrade: finalGrade ?? this.finalGrade,
      professorId: professorId ?? this.professorId,
      subject: subject ?? this.subject,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if enrollment is active
  bool get isActive => status == EnrollmentStatus.enrolled ||
                       status == EnrollmentStatus.inProgress;

  /// Check if enrollment is completed
  bool get isCompleted => status == EnrollmentStatus.passed ||
                          status == EnrollmentStatus.failed;

  @override
  List<Object?> get props => [
        id,
        careerId,
        subjectId,
        periodId,
        section,
        classroom,
        status,
        finalGrade,
        professorId,
        subject,
        period,
        createdAt,
        updatedAt,
      ];
}
