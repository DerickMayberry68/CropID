import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'field.freezed.dart';
part 'field.g.dart';

/// Visibility level a farmer grants for their field.
enum FieldVisibility {
  @JsonValue('private') private,
  @JsonValue('anonymous') anonymous,   // crop shown, no owner info
  @JsonValue('public') public,         // full info shared
}

@freezed
class Field with _$Field {
  const factory Field({
    required String id,
    required String farmerId,
    required String name,
    /// GeoJSON polygon coordinates stored as a flat list of {lat, lng} maps.
    /// TODO: Phase 1 — store as PostGIS geometry in Supabase, decode here.
    required List<Map<String, double>> boundaryPoints,
    String? currentCropId,
    String? currentCropName,      // denormalized for quick display
    @Default(FieldVisibility.anonymous) FieldVisibility visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Field;

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);
}

extension FieldExt on Field {
  /// Convert boundary points to latlong2 LatLng list for flutter_map polygons.
  List<LatLng> get latLngBoundary => boundaryPoints
      .map((p) => LatLng(p['lat']!, p['lng']!))
      .toList();
}
