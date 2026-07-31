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
      final planData = await _client
          .from(SupabaseConstants.sprayPlansTable)
          .select()
          .eq('farmer_id', farmerId)
          .order('created_at', ascending: false);

      final plans = (planData as List)
          .whereType<Map<String, dynamic>>()
          .map(SprayPlan.fromJson)
          .toList()
          .sortedByCreatedAtDesc(
            createdAt: (plan) => plan.createdAt,
            stableId: (plan) => plan.id,
          );

      if (plans.isEmpty) return Right(plans);

      final planIds =
          plans.map((p) => p.id).where((id) => id.isNotEmpty).toList();
      if (planIds.isEmpty) return Right(plans);

      final junctionData = await _client
          .from(SupabaseConstants.sprayPlanChemicalsTable)
          .select('spray_plan_id, chemical_id')
          .inFilter('spray_plan_id', planIds);

      final junctionRows =
          (junctionData as List).whereType<Map<String, dynamic>>();
      final chemicalsByPlanId = <String, List<String>>{};
      for (final row in junctionRows) {
        final planId = row['spray_plan_id'] as String?;
        final chemicalId = row['chemical_id'] as String?;
        if (planId == null || chemicalId == null) continue;
        chemicalsByPlanId.putIfAbsent(planId, () => []).add(chemicalId);
      }

      final allChemicalIds =
          chemicalsByPlanId.values.expand((ids) => ids).toSet().toList();

      if (allChemicalIds.isEmpty) return Right(plans);

      final chemicalData = await _client
          .from(SupabaseConstants.chemicalsTable)
          .select()
          .inFilter('id', allChemicalIds);

      final chemicalsById = {
        for (final row
            in (chemicalData as List).whereType<Map<String, dynamic>>())
          (row['id'] as String): Chemical.fromJson(row),
      };

      final hydratedPlans = plans.map((plan) {
        final chemicalIds = chemicalsByPlanId[plan.id] ?? const <String>[];
        final hydratedChemicals = chemicalIds
            .map((id) => chemicalsById[id])
            .whereType<Chemical>()
            .toList();
        return plan.copyWith(chemicals: hydratedChemicals);
      }).toList();

      return Right(hydratedPlans);
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
        ..remove('current_crop_name')
        ..remove('created_at');
      if ((json['id'] as String?)?.isEmpty ?? true) json.remove('id');

      final data = await _client
          .from(SupabaseConstants.sprayPlansTable)
          .insert(json)
          .select()
          .single();

      final saved = SprayPlan.fromJson(data);

      // Insert chemicals into junction table if any selected
      final uniqueChemicals = <String, Chemical>{
        for (final chemical in plan.chemicals) chemical.id: chemical,
      }.values.toList();

      if (uniqueChemicals.isNotEmpty) {
        final junctionRows = uniqueChemicals
            .map((c) => {
                  'spray_plan_id': saved.id,
                  'chemical_id': c.id,
                })
            .toList();
        await _client
            .from(SupabaseConstants.sprayPlanChemicalsTable)
            .insert(junctionRows);
      }

      return Right(saved.copyWith(chemicals: uniqueChemicals));
    } catch (e) {
      return Left(SupabaseService.toUserMessage(e));
    }
  }

  Future<Either<String, SprayPlan>> updateSprayPlan(SprayPlan plan) async {
    try {
      final json = plan.toJson()
        ..remove('chemicals')
        ..remove('current_crop_name')
        ..remove('created_at');

      final data = await _client
          .from(SupabaseConstants.sprayPlansTable)
          .update(json)
          .eq('id', plan.id)
          .select()
          .single();

      await _client
          .from(SupabaseConstants.sprayPlanChemicalsTable)
          .delete()
          .eq('spray_plan_id', plan.id);

      final uniqueChemicals = <String, Chemical>{
        for (final chemical in plan.chemicals) chemical.id: chemical,
      }.values.toList();

      if (uniqueChemicals.isNotEmpty) {
        final junctionRows = uniqueChemicals
            .map((c) => {
                  'spray_plan_id': plan.id,
                  'chemical_id': c.id,
                })
            .toList();
        await _client
            .from(SupabaseConstants.sprayPlanChemicalsTable)
            .insert(junctionRows);
      }

      final updated = SprayPlan.fromJson(data);
      return Right(updated.copyWith(chemicals: uniqueChemicals));
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
