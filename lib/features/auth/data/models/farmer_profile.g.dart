// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FarmerProfileImpl _$$FarmerProfileImplFromJson(Map<String, dynamic> json) =>
    _$FarmerProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      farmName: json['farm_name'] as String?,
      farmLatitude: (json['farm_latitude'] as num?)?.toDouble(),
      farmLongitude: (json['farm_longitude'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
      fieldSharingEnabled: json['field_sharing_enabled'] as bool? ?? false,
      gdprConsentAt: json['gdpr_consent_at'] == null
          ? null
          : DateTime.parse(json['gdpr_consent_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$FarmerProfileImplToJson(_$FarmerProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'farm_name': instance.farmName,
      'farm_latitude': instance.farmLatitude,
      'farm_longitude': instance.farmLongitude,
      'avatar_url': instance.avatarUrl,
      'field_sharing_enabled': instance.fieldSharingEnabled,
      'gdpr_consent_at': instance.gdprConsentAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
