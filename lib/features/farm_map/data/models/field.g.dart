// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FieldImpl _$$FieldImplFromJson(Map<String, dynamic> json) => _$FieldImpl(
      id: json['id'] as String,
      farmerId: json['farmer_id'] as String,
      name: json['name'] as String,
      boundaryPoints: (json['boundary_points'] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ))
          .toList(),
      currentCropId: json['current_crop_id'] as String?,
      currentCropName: json['current_crop_name'] as String?,
      visibility:
          $enumDecodeNullable(_$FieldVisibilityEnumMap, json['visibility']) ??
              FieldVisibility.anonymous,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FieldImplToJson(_$FieldImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farmer_id': instance.farmerId,
      'name': instance.name,
      'boundary_points': instance.boundaryPoints,
      'current_crop_id': instance.currentCropId,
      'current_crop_name': instance.currentCropName,
      'visibility': _$FieldVisibilityEnumMap[instance.visibility]!,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$FieldVisibilityEnumMap = {
  FieldVisibility.private: 'private',
  FieldVisibility.anonymous: 'anonymous',
  FieldVisibility.public: 'public',
};
