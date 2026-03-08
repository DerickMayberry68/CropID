import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/models/chemical.dart';
import '../../providers/spray_plan_provider.dart';
import '../widgets/chemical_card.dart';

class ChemicalSelectorScreen extends ConsumerStatefulWidget {
  const ChemicalSelectorScreen({super.key});

  @override
  ConsumerState<ChemicalSelectorScreen> createState() =>
      _ChemicalSelectorScreenState();
}

class _ChemicalSelectorScreenState
    extends ConsumerState<ChemicalSelectorScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(chemicalSearchResultsProvider);
    final selected = ref.watch(selectedChemicalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Chemicals'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search chemicals...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(chemicalSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (val) =>
                  ref.read(chemicalSearchQueryProvider.notifier).state = val,
            ),
          ),
        ),
      ),
      body: results.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (chemicals) => chemicals.isEmpty
            ? const Center(child: Text('No chemicals found'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: chemicals.length,
                itemBuilder: (_, i) {
                  final chem = chemicals[i];
                  final isSelected = selected.any((c) => c.id == chem.id);
                  return ChemicalCard(
                    chemical: chem,
                    isSelected: isSelected,
                    onTap: () => _toggleChemical(chem, selected),
                  );
                },
              ),
      ),
    );
  }

  void _toggleChemical(Chemical chem, List<Chemical> current) {
    final updated = [...current];
    if (updated.any((c) => c.id == chem.id)) {
      updated.removeWhere((c) => c.id == chem.id);
      ref.read(selectedChemicalsProvider.notifier).state = updated;
    } else {
      // Check both directions of incompatibility
      final incompatible = current.where((c) =>
          c.incompatibleWithChemicalIds.contains(chem.id) ||
          chem.incompatibleWithChemicalIds.contains(c.id)).toList();

      if (incompatible.isNotEmpty) {
        _showIncompatibilityWarning(chem, incompatible, updated);
      } else {
        updated.add(chem);
        ref.read(selectedChemicalsProvider.notifier).state = updated;
      }
    }
  }

  Future<void> _showIncompatibilityWarning(
    Chemical chem,
    List<Chemical> incompatible,
    List<Chemical> pending,
  ) async {
    final names = incompatible.map((c) => c.name).join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Expanded(child: Text('Incompatible Chemicals')),
          ],
        ),
        content: Text(
          '${chem.name} is incompatible with:\n\n$names\n\n'
          'Mixing these chemicals may be hazardous. Are you sure you want to add it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      pending.add(chem);
      ref.read(selectedChemicalsProvider.notifier).state = pending;
    }
  }
}
