// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CropImpl _$$CropImplFromJson(Map<String, dynamic> json) => _$CropImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String?,
      iconUrl: json['icon_url'] as String?,
      sensitiveTo: (json['sensitive_to'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$CropImplToJson(_$CropImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'scientific_name': instance.scientificName,
      'icon_url': instance.iconUrl,
      'sensitive_to': instance.sensitiveTo,
      'tags': instance.tags,
    };
