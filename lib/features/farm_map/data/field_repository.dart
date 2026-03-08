import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/constants/supabase_constants.dart';
import 'models/field.dart';

/// Handles field CRUD and adjacent-field queries.
class FieldRepository {
  final SupabaseClient _client;

  FieldRepository(this._client);

  // ── Farmer's own fields ───────────────────────────────────────────────────

  Future<Either<String, List<Field>>> getMyFields(String farmerId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.fieldsTable)
          .select()
          .eq('farmer_id', farmerId)
          .order('name');
      return Right((data as List).map((e) => Field.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Field>> createField(Field field) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left('Not authenticated');

      // Always stamp with the authenticated user — never trust client-passed farmerId
      final json = field.toJson()..['farmer_id'] = userId;

      // Convert boundary points to PostGIS EWKT so ST_DWithin queries work.
      // boundary_points (JSONB) is kept for client-side rendering roundtrip.
      if (field.boundaryPoints.isNotEmpty) {
        json['boundary'] = _toEwkt(field.boundaryPoints);
      }

      final data = await _client
          .from(SupabaseConstants.fieldsTable)
          .insert(json)
          .select()
          .single();
      return Right(Field.fromJson(data));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Field>> updateField(Field field) async {
    try {
      final json = field.toJson();
      if (field.boundaryPoints.isNotEmpty) {
        json['boundary'] = _toEwkt(field.boundaryPoints);
      }
      final data = await _client
          .from(SupabaseConstants.fieldsTable)
          .update(json)
          .eq('id', field.id)
          .select()
          .single();
      return Right(Field.fromJson(data));
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Converts a list of {lat, lng} boundary points to PostGIS EWKT.
  /// PostGIS WKT uses (longitude latitude) order, and the ring must be closed
  /// (first point repeated at the end).
  String _toEwkt(List<Map<String, double>> points) {
    final coords = points.map((p) => '${p['lng']!} ${p['lat']!}').join(', ');
    final first = points.first;
    return 'SRID=4326;POLYGON(($coords, ${first['lng']!} ${first['lat']!}))';
  }

  Future<Either<String, void>> deleteField(String fieldId) async {
    try {
      await _client
          .from(SupabaseConstants.fieldsTable)
          .delete()
          .eq('id', fieldId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Adjacent fields ───────────────────────────────────────────────────────
  /// Fetch visible fields within [radiusMeters] using PostGIS ST_DWithin.
  /// Calls the `fields_within_radius` RPC defined in schema.sql.
  Future<Either<String, List<Field>>> getAdjacentFields({
    required double lat,
    required double lng,
    double radiusMeters = 500,
    String? excludeFarmerId,
  }) async {
    try {
      // PostGIS RPC — much more accurate than a bounding box
      final data = await _client.rpc(
        'fields_within_radius',
        params: {
          'lat': lat,
          'lng': lng,
          'radius_m': radiusMeters,
        },
      );

      return Right((data as List).map((e) => Field.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Realtime subscription ────────────────────────────────────────────────

  RealtimeChannel subscribeToFieldUpdates(
      void Function(Field field) onUpdate) {
    return _client
        .channel(SupabaseConstants.fieldUpdatesChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.fieldsTable,
          callback: (payload) {
            try {
              final field = Field.fromJson(payload.newRecord);
              onUpdate(field);
            } catch (_) {}
          },
        )
        .subscribe();
  }
}
