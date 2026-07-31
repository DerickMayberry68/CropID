import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'csb_field.freezed.dart';
part 'csb_field.g.dart';

/// Decodes the `boundary_points` JSONB column into a lat/lng point list.
/// Tolerates both a decoded List and a raw JSON string, and int-valued
/// coordinates (PostgREST may emit whole numbers without a decimal point).
class BoundaryPointsConverter
    implements JsonConverter<List<Map<String, double>>, dynamic> {
  const BoundaryPointsConverter();

  @override
  List<Map<String, double>> fromJson(dynamic json) {
    final raw = json is String ? jsonDecode(json) : json;
    if (raw is! List) return const [];
    final points = <Map<String, double>>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final lat = entry['lat'];
      final lng = entry['lng'];
      if (lat is! num || lng is! num) continue;
      points.add({'lat': lat.toDouble(), 'lng': lng.toDouble()});
    }
    return points;
  }

  @override
  dynamic toJson(List<Map<String, double>> object) => object;
}

/// Decodes a Postgres `numeric` column, which may arrive as a number or a
/// string depending on magnitude and driver.
class NumericConverter implements JsonConverter<double?, dynamic> {
  const NumericConverter();

  @override
  double? fromJson(dynamic json) =>
      json is num ? json.toDouble() : double.tryParse('${json ?? ''}');

  @override
  dynamic toJson(double? object) => object;
}

/// An unclaimed USDA Crop Sequence Boundary — a real field outline imported
/// from public USDA data that a farmer can claim as their own.
///
/// Claiming converts one of these into an owned [Field] via the
/// `claim_csb_field` RPC, so farmers never have to draw boundaries by hand.
@freezed
class CsbField with _$CsbField {
  const factory CsbField({
    required String csbId,
    required String state,
    String? countyFips,
    @BoundaryPointsConverter()
    @Default(<Map<String, double>>[])
    List<Map<String, double>> boundaryPoints,
    @NumericConverter() double? acres,
    int? cropYear,
    String? predictedCropId,
  }) = _CsbField;

  factory CsbField.fromJson(Map<String, dynamic> json) =>
      _$CsbFieldFromJson(json);
}

extension CsbFieldExt on CsbField {
  /// Boundary as latlong2 points for flutter_map polygons.
  List<LatLng> get latLngBoundary =>
      boundaryPoints.map((p) => LatLng(p['lat']!, p['lng']!)).toList();

  /// Whether this boundary has enough points to render as a polygon.
  bool get isRenderable => boundaryPoints.length >= 3;

  /// Short human label, e.g. "12.4 ac".
  String get acresLabel =>
      acres == null ? 'Acreage unknown' : '${acres!.toStringAsFixed(1)} ac';
}
