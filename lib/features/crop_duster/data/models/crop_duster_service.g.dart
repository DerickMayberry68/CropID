// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_duster_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CropDusterServiceImpl _$$CropDusterServiceImplFromJson(
        Map<String, dynamic> json) =>
    _$CropDusterServiceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      state: json['state'] as String?,
      serviceRadiusMiles: (json['service_radius_miles'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$CropDusterServiceImplToJson(
        _$CropDusterServiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'state': instance.state,
      'service_radius_miles': instance.serviceRadiusMiles,
      'is_active': instance.isActive,
    };
