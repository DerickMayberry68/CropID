import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../farm_map/providers/farm_map_provider.dart';
import '../../data/models/spray_plan.dart';
import '../../providers/spray_plan_provider.dart';
import '../widgets/chemical_card.dart';
import '../widgets/danger_alert_banner.dart';

class SprayPlanScreen extends ConsumerWidget {
  const SprayPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final selectedFieldPlanningReady =
        ref.watch(selectedFieldPlanningReadyProvider);
    final selectedFieldPlanningMessage =
        ref.watch(selectedFieldPlanningMessageProvider);
    final selectedChemicals = ref.watch(selectedChemicalsProvider);
    final dangerousFields = ref.watch(dangerousFieldsProvider);
    final saveState = ref.watch(sprayPlanSaveStateProvider);
    final lastSaveMessage = ref.watch(lastSaveUserMessageProvider);
    final myPlansAsync = ref.watch(mySprayPlansProvider);

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
              subtitle:
                  Text('Crop: ${selectedField.currentCropName ?? 'Unknown'}'),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
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
            DangerAlertBanner(
              dangerousFieldCount: dangerousFields.length,
              saveState: saveState,
            ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.save_outlined),
              title: Text(
                switch (saveState) {
                  SprayPlanSaveState.idle => AppConstants.saveStateIdleLabel,
                  SprayPlanSaveState.saving =>
                    AppConstants.saveStateSavingLabel,
                  SprayPlanSaveState.saved => AppConstants.saveStateSavedLabel,
                  SprayPlanSaveState.failed =>
                    AppConstants.saveStateFailedLabel,
                },
              ),
              subtitle: lastSaveMessage == null ? null : Text(lastSaveMessage),
              trailing: TextButton(
                onPressed: () =>
                    _showSavedPlansBottomSheet(context, myPlansAsync),
                child: const Text('View Saved Plans'),
              ),
            ),
          ),

          const SizedBox(height: 12),

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
                    ref.read(selectedChemicalsProvider.notifier).state =
                        updated;
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
            onPressed: !selectedFieldPlanningReady || selectedChemicals.isEmpty
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
                      chemicalNames:
                          selectedChemicals.map((c) => c.name).toList(),
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
          if (!selectedFieldPlanningReady &&
              selectedFieldPlanningMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                selectedFieldPlanningMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (saveState == SprayPlanSaveState.failed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text(AppConstants.retryActionLabel),
                onPressed: () async {
                  await ref
                      .read(sprayPlanNotifierProvider.notifier)
                      .retryLastSave();
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showSavedPlansBottomSheet(
    BuildContext context,
    AsyncValue<List<SprayPlan>> myPlansAsync,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: myPlansAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Unable to load saved plans: $e'),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No saved plans found yet.'),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: plans.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final plan = plans[index];
                  return ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(plan.fieldName ?? 'Unnamed field'),
                    subtitle: Text(
                      'Chemicals: ${plan.chemicals.length} • Status: ${plan.status.name}',
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
