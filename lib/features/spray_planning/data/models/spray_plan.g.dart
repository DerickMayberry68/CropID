// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spray_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SprayPlanImpl _$$SprayPlanImplFromJson(Map<String, dynamic> json) =>
    _$SprayPlanImpl(
      id: json['id'] as String,
      farmerId: json['farmer_id'] as String,
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String?,
      chemicals: (json['chemicals'] as List<dynamic>?)
              ?.map((e) => Chemical.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      scheduledDate: json['scheduled_date'] == null
          ? null
          : DateTime.parse(json['scheduled_date'] as String),
      status: $enumDecodeNullable(_$SprayPlanStatusEnumMap, json['status']) ??
          SprayPlanStatus.draft,
      dangerousAdjacentFieldIds:
          (json['dangerous_adjacent_field_ids'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SprayPlanImplToJson(_$SprayPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farmer_id': instance.farmerId,
      'field_id': instance.fieldId,
      'field_name': instance.fieldName,
      'chemicals': instance.chemicals.map((e) => e.toJson()).toList(),
      'scheduled_date': instance.scheduledDate?.toIso8601String(),
      'status': _$SprayPlanStatusEnumMap[instance.status]!,
      'dangerous_adjacent_field_ids': instance.dangerousAdjacentFieldIds,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$SprayPlanStatusEnumMap = {
  SprayPlanStatus.draft: 'draft',
  SprayPlanStatus.scheduled: 'scheduled',
  SprayPlanStatus.completed: 'completed',
  SprayPlanStatus.cancelled: 'cancelled',
};
