import 'package:freezed_annotation/freezed_annotation.dart';

part 'crop_duster_service.freezed.dart';
part 'crop_duster_service.g.dart';

@freezed
class CropDusterService with _$CropDusterService {
  const factory CropDusterService({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    String? address,
    String? state,
    /// Approximate service radius in miles
    int? serviceRadiusMiles,
    @Default(true) bool isActive,
  }) = _CropDusterService;

  factory CropDusterService.fromJson(Map<String, dynamic> json) =>
      _$CropDusterServiceFromJson(json);
}
