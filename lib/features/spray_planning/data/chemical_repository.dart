import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/services/supabase_service.dart';
import 'models/chemical.dart';
import 'models/spray_plan.dart';

class ChemicalRepository {
  final SupabaseClient _client;
  ChemicalRepository(this._client);

  // ── Chemicals ─────────────────────────────────────────────────────────────

  Future<Either<String, List<Chemical>>> getAllChemicals() async {
    try {
      final data = await _client
          .from(SupabaseConstants.chemicalsTable)
          .select()
          .order('name');
      return Right((data as List).map((e) => Chemical.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Chemical>>> searchChemicals(String query) async {
    try {
      final data = await _client
          .from(SupabaseConstants.chemicalsTable)
          .select()
          .or('name.ilike.%$query%,common_name.ilike.%$query%')
          .order('name')
          .limit(20);
      return Right((data as List).map((e) => Chemical.fromJson(e)).toList());
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Spray plans ───────────────────────────────────────────────────────────

  Future<Either<String, List<SprayPlan>>> getMySprayPlans(
      String farmerId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.sprayPlansTable)
          .select('*, spray_plan_chemicals(*, chemicals(*))')
          .eq('farmer_id', farmerId)
          .order('created_at', ascending: false);
      final plans = (data as List)
          .whereType<Map<String, dynamic>>()
          .map(SprayPlan.fromJson)
          .toList()
          .sortedByCreatedAtDesc(
            createdAt: (plan) => plan.createdAt,
            stableId: (plan) => plan.id,
          );
      return Right(plans);
    } catch (e) {
      return Left(SupabaseService.toUserMessage(e));
    }
  }

  Future<Either<String, SprayPlan>> saveSprayPlan(SprayPlan plan) async {
    try {
      // Strip fields that don't exist as columns in spray_plans:
      //   - 'chemicals' lives in the spray_plan_chemicals junction table
      //   - 'id' when empty lets the DB auto-generate a UUID
      final json = plan.toJson()
        ..remove('chemicals')
        ..remove('current_crop_name');
      if ((json['id'] as String?)?.isEmpty ?? true) json.remove('id');

      final data = await _client
          .from(SupabaseConstants.sprayPlansTable)
          .insert(json)
          .select()
          .single();

      final saved = SprayPlan.fromJson(data);

      // Insert chemicals into junction table if any selected
      if (plan.chemicals.isNotEmpty) {
        final junctionRows = plan.chemicals
            .map((c) => {
                  'spray_plan_id': saved.id,
                  'chemical_id': c.id,
                })
            .toList();
        await _client
            .from(SupabaseConstants.sprayPlanChemicalsTable)
            .insert(junctionRows);
      }

      return Right(saved.copyWith(chemicals: plan.chemicals));
    } catch (e) {
      return Left(SupabaseService.toUserMessage(e));
    }
  }

  // ── Danger check ──────────────────────────────────────────────────────────
  /// Given selected chemicals and a list of adjacent crop IDs,
  /// returns the set of adjacent field IDs that are at risk.
  ///
  /// TODO: Phase 3 — Move this logic to a Supabase Edge Function for
  /// server-side enforcement and to avoid sending full chemical DB to client.
  List<String> computeDangerousFields({
    required List<Chemical> selectedChemicals,
    required Map<String, String> adjacentFieldCropMap, // fieldId → cropId
  }) {
    final dangerous = <String>[];
    for (final entry in adjacentFieldCropMap.entries) {
      final fieldId = entry.key;
      final cropId = entry.value;
      for (final chem in selectedChemicals) {
        if (chem.dangerousToCropIds.contains(cropId)) {
          dangerous.add(fieldId);
          break;
        }
      }
    }
    return dangerous;
  }
}
