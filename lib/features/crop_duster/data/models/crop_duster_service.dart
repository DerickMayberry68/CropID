import 'package:freezed_annotation/freezed_annotation.dart';

part 'crop_duster_service.freezed.dart';
part 'crop_duster_service.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum SprayingServiceType {
  drone,
  agAir,
  coOp;

  String get label => switch (this) {
        SprayingServiceType.drone => 'Drone Spraying',
        SprayingServiceType.agAir => 'Ag Air',
        SprayingServiceType.coOp => 'Co-op',
      };

  String get databaseValue => switch (this) {
        SprayingServiceType.drone => 'drone',
        SprayingServiceType.agAir => 'ag_air',
        SprayingServiceType.coOp => 'co_op',
      };
}

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
    @Default(SprayingServiceType.agAir) SprayingServiceType serviceType,

    /// Approximate service radius in miles
    int? serviceRadiusMiles,
    @Default(true) bool isActive,
  }) = _CropDusterService;

  factory CropDusterService.fromJson(Map<String, dynamic> json) =>
      _$CropDusterServiceFromJson(json);
}
