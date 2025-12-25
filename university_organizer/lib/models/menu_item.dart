import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

/// Menu item model from backend
@JsonSerializable()
class MenuItem {
  final String id;
  final String name;
  final String label;
  final String labelKey;
  final String icon;
  final String path;
  final String? externalUrl;
  final String target;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String? badge;
  final String? badgeColor;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuItem>? children;

  MenuItem({
    required this.id,
    required this.name,
    required this.label,
    required this.labelKey,
    required this.icon,
    required this.path,
    this.externalUrl,
    required this.target,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.isPremium,
    this.badge,
    this.badgeColor,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
