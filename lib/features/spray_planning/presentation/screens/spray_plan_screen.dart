import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../farm_map/providers/farm_map_provider.dart';
import '../../providers/spray_plan_provider.dart';
import '../widgets/chemical_card.dart';
import '../widgets/danger_alert_banner.dart';

class SprayPlanScreen extends ConsumerWidget {
  const SprayPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final selectedChemicals = ref.watch(selectedChemicalsProvider);
    final dangerousFields = ref.watch(dangerousFieldsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Spray Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Selected field info ────────────────────────────────────────
          if (selectedField != null) ...[
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(selectedField.name),
              subtitle: Text(
                  'Crop: ${selectedField.currentCropName ?? 'Unknown'}'),
              tileColor:
                  Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ] else
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const ListTile(
                leading: Icon(Icons.warning_amber_outlined),
                title: Text('No field selected'),
                subtitle: Text('Go to My Farm and tap a field first'),
              ),
            ),

          const SizedBox(height: 20),

          // ── Danger alert ───────────────────────────────────────────────
          if (dangerousFields.isNotEmpty)
            DangerAlertBanner(dangerousFieldCount: dangerousFields.length),

          const SizedBox(height: 20),

          // ── Selected chemicals ─────────────────────────────────────────
          Text('Selected Chemicals (${selectedChemicals.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          if (selectedChemicals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No chemicals selected yet.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...selectedChemicals.map((c) => ChemicalCard(
                  chemical: c,
                  onRemove: () {
                    final updated = [...selectedChemicals]..remove(c);
                    ref
                        .read(selectedChemicalsProvider.notifier)
                        .state = updated;
                  },
                )),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Chemical'),
            onPressed: () => context.push(AppRoutes.chemicalSelector),
          ),

          const SizedBox(height: 32),

          // ── Save and contact ───────────────────────────────────────────
          PrimaryButton(
            label: 'Save Plan & Find Spray Service',
            isLoading: ref.watch(sprayPlanNotifierProvider).isLoading,
            onPressed: selectedField == null || selectedChemicals.isEmpty
                ? null
                : () async {
                    final notifier =
                        ref.read(sprayPlanNotifierProvider.notifier);

                    // Initialize the plan for the selected field before saving.
                    // initForField was never called elsewhere — plan stayed null
                    // causing save() to silently no-op.
                    notifier.initForField(
                        selectedField!.id, selectedField.name);

                    await notifier.save(
                      dangerousFieldIds: dangerousFields,
                      chemicalNames: selectedChemicals
                          .map((c) => c.name)
                          .toList(),
                    );

                    if (!context.mounted) return;

                    final planState = ref.read(sprayPlanNotifierProvider);
                    planState.whenOrNull(
                      error: (err, _) =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving plan: $err')),
                      ),
                      data: (plan) {
                        if (plan != null) context.go(AppRoutes.cropDusters);
                      },
                    );
                  },
          ),
        ],
      ),
    );
  }
}
