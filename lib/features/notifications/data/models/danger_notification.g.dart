// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'danger_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DangerNotificationImpl _$$DangerNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$DangerNotificationImpl(
      id: json['id'] as String,
      recipientFarmerId: json['recipient_farmer_id'] as String,
      senderFarmerId: json['sender_farmer_id'] as String,
      sprayPlanId: json['spray_plan_id'] as String,
      affectedFieldId: json['affected_field_id'] as String,
      affectedFieldName: json['affected_field_name'] as String?,
      senderFarmName: json['sender_farm_name'] as String?,
      dangerousChemicalNames:
          (json['dangerous_chemical_names'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      sprayScheduledDate: json['spray_scheduled_date'] == null
          ? null
          : DateTime.parse(json['spray_scheduled_date'] as String),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$DangerNotificationImplToJson(
        _$DangerNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient_farmer_id': instance.recipientFarmerId,
      'sender_farmer_id': instance.senderFarmerId,
      'spray_plan_id': instance.sprayPlanId,
      'affected_field_id': instance.affectedFieldId,
      'affected_field_name': instance.affectedFieldName,
      'sender_farm_name': instance.senderFarmName,
      'dangerous_chemical_names': instance.dangerousChemicalNames,
      'spray_scheduled_date': instance.sprayScheduledDate?.toIso8601String(),
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };
