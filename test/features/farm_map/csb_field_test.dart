import 'package:crop_id/features/farm_map/data/models/csb_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsbField.fromJson', () {
    test('parses an RPC row from csb_fields_near', () {
      final csb = CsbField.fromJson({
        'csb_id': '051522014609386',
        'state': '05',
        'county_fips': '111',
        'boundary_points': [
          {'lat': 35.564931, 'lng': -90.921724},
          {'lat': 35.565931, 'lng': -90.921724},
          {'lat': 35.565931, 'lng': -90.920724},
        ],
        'acres': 2.93,
        'crop_year': 2022,
        'predicted_crop_id': null,
      });

      expect(csb.csbId, '051522014609386');
      expect(csb.state, '05');
      expect(csb.countyFips, '111');
      expect(csb.cropYear, 2022);
      expect(csb.boundaryPoints, hasLength(3));
      expect(csb.latLngBoundary.first.latitude, closeTo(35.564931, 1e-6));
      expect(csb.latLngBoundary.first.longitude, closeTo(-90.921724, 1e-6));
      expect(csb.isRenderable, isTrue);
      expect(csb.acresLabel, '2.9 ac');
    });

    test('tolerates int-valued coordinates and acreage', () {
      final csb = CsbField.fromJson({
        'csb_id': 'whole-numbers',
        'state': '05',
        'boundary_points': [
          {'lat': 35, 'lng': -90},
          {'lat': 36, 'lng': -90},
          {'lat': 36, 'lng': -91},
        ],
        'acres': 3,
      });

      expect(csb.latLngBoundary.first.latitude, 35.0);
      expect(csb.acres, 3.0);
    });

    test('ignores the PostGIS boundary column and malformed points', () {
      final csb = CsbField.fromJson({
        'csb_id': 'mixed',
        'state': '05',
        // The RPC returns `setof csb_fields`, so the raw geography column
        // rides along and must not break decoding.
        'boundary': '0103000020E6100000...',
        'boundary_points': [
          {'lat': 35.1, 'lng': -90.1},
          {'lat': null, 'lng': -90.2},
          'not-a-point',
        ],
      });

      expect(csb.boundaryPoints, hasLength(1));
      expect(csb.isRenderable, isFalse);
      expect(csb.acresLabel, 'Acreage unknown');
    });

    test('defaults to an empty boundary when points are missing', () {
      final csb = CsbField.fromJson({'csb_id': 'empty', 'state': '05'});

      expect(csb.boundaryPoints, isEmpty);
      expect(csb.isRenderable, isFalse);
    });
  });
}
