// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csb_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CsbFieldImpl _$$CsbFieldImplFromJson(Map<String, dynamic> json) =>
    _$CsbFieldImpl(
      csbId: json['csb_id'] as String,
      state: json['state'] as String,
      countyFips: json['county_fips'] as String?,
      boundaryPoints: json['boundary_points'] == null
          ? const <Map<String, double>>[]
          : const BoundaryPointsConverter().fromJson(json['boundary_points']),
      acres: const NumericConverter().fromJson(json['acres']),
      cropYear: (json['crop_year'] as num?)?.toInt(),
      predictedCropId: json['predicted_crop_id'] as String?,
    );

Map<String, dynamic> _$$CsbFieldImplToJson(_$CsbFieldImpl instance) =>
    <String, dynamic>{
      'csb_id': instance.csbId,
      'state': instance.state,
      'county_fips': instance.countyFips,
      'boundary_points':
          const BoundaryPointsConverter().toJson(instance.boundaryPoints),
      'acres': const NumericConverter().toJson(instance.acres),
      'crop_year': instance.cropYear,
      'predicted_crop_id': instance.predictedCropId,
    };
