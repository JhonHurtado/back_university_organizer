import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'semester.g.dart';

/// Semester model
@JsonSerializable()
class Semester extends Equatable {
  final String id;
  final String careerId;
  final int number;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Semester({
    required this.id,
    required this.careerId,
    required this.number,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Semester.fromJson(Map<String, dynamic> json) =>
      _$SemesterFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterToJson(this);

  Semester copyWith({
    String? id,
    String? careerId,
    int? number,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Semester(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      number: number ?? this.number,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        careerId,
        number,
        name,
        description,
        createdAt,
        updatedAt,
      ];
}
