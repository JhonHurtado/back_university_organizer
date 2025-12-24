import 'package:json_annotation/json_annotation.dart';

part 'professor.g.dart';

/// Professor model
@JsonSerializable()
class Professor {
  final String id;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  final String? email;
  final String? phone;
  final String? office;
  final String? department;
  final String? title;
  final String? notes;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Professor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.office,
    this.department,
    this.title,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get full name with title
  String get fullNameWithTitle {
    if (title != null && title!.isNotEmpty) {
      return '$title $firstName $lastName';
    }
    return fullName;
  }

  /// Get initials
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Get display name (title + last name)
  String get displayName {
    if (title != null && title!.isNotEmpty) {
      return '$title $lastName';
    }
    return fullName;
  }

  /// JSON serialization
  factory Professor.fromJson(Map<String, dynamic> json) =>
      _$ProfessorFromJson(json);
  Map<String, dynamic> toJson() => _$ProfessorToJson(this);

  /// Create copy with modifications
  Professor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? office,
    String? department,
    String? title,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Professor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      office: office ?? this.office,
      department: department ?? this.department,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
