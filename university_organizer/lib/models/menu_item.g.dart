// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['id'] as String,
  name: json['name'] as String,
  label: json['label'] as String,
  labelKey: json['labelKey'] as String,
  icon: json['icon'] as String,
  path: json['path'] as String,
  externalUrl: json['externalUrl'] as String?,
  target: json['target'] as String,
  parentId: json['parentId'] as String?,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  isPremium: json['isPremium'] as bool,
  badge: json['badge'] as String?,
  badgeColor: json['badgeColor'] as String?,
  state: json['state'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'label': instance.label,
  'labelKey': instance.labelKey,
  'icon': instance.icon,
  'path': instance.path,
  'externalUrl': instance.externalUrl,
  'target': instance.target,
  'parentId': instance.parentId,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'isPremium': instance.isPremium,
  'badge': instance.badge,
  'badgeColor': instance.badgeColor,
  'state': instance.state,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'children': instance.children,
};
