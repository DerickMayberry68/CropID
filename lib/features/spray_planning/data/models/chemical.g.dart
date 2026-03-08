// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chemical.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChemicalImpl _$$ChemicalImplFromJson(Map<String, dynamic> json) =>
    _$ChemicalImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      commonName: json['common_name'] as String?,
      manufacturer: json['manufacturer'] as String?,
      toxicityLevel:
          $enumDecodeNullable(_$ToxicityLevelEnumMap, json['toxicity_level']) ??
              ToxicityLevel.moderate,
      dangerousToCropIds: (json['dangerous_to_crop_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dangerousToCropNames: (json['dangerous_to_crop_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      incompatibleWithChemicalIds:
          (json['incompatible_with_chemical_ids'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      withdrawalPeriodDays: json['withdrawal_period_days'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ChemicalImplToJson(_$ChemicalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'common_name': instance.commonName,
      'manufacturer': instance.manufacturer,
      'toxicity_level': _$ToxicityLevelEnumMap[instance.toxicityLevel]!,
      'dangerous_to_crop_ids': instance.dangerousToCropIds,
      'dangerous_to_crop_names': instance.dangerousToCropNames,
      'incompatible_with_chemical_ids': instance.incompatibleWithChemicalIds,
      'withdrawal_period_days': instance.withdrawalPeriodDays,
      'notes': instance.notes,
    };

const _$ToxicityLevelEnumMap = {
  ToxicityLevel.low: 'low',
  ToxicityLevel.moderate: 'moderate',
  ToxicityLevel.high: 'high',
  ToxicityLevel.extreme: 'extreme',
};
