import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/models/crop_duster_service.dart';
import '../../providers/crop_duster_provider.dart';
import '../widgets/service_card.dart';

class CropDusterScreen extends ConsumerStatefulWidget {
  const CropDusterScreen({super.key});

  @override
  ConsumerState<CropDusterScreen> createState() => _CropDusterScreenState();
}

class _CropDusterScreenState extends ConsumerState<CropDusterScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(cropDusterSearchResultsProvider);
    final payload = ref.watch(contactPayloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spraying Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name or state...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) =>
                  ref.read(cropDusterSearchQueryProvider.notifier).state = val,
            ),
          ),
        ),
      ),
      body: results.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (services) => services.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No services found nearby',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: services.length,
                itemBuilder: (_, i) => ServiceCard(
                  service: services[i],
                  contextSummary: payload == null
                      ? 'Save an Application Plan to prefill contact details.'
                      : '${payload.fieldName} • ${payload.chemicalNames.length} chemicals • ${payload.dangerCount} risks',
                  onContact: () => _openContactFlow(
                    context: context,
                    service: services[i],
                    payload: payload,
                  ),
                ),
              ),
      ),
    );
  }

  void _openContactFlow({
    required BuildContext context,
    required CropDusterService service,
    required CropDusterContactPayload? payload,
  }) {
    final hasAnyChannel =
        service.phone.trim().isNotEmpty || (service.email ?? '').trim().isNotEmpty;
    if (!hasAnyChannel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.contactStateUnavailableLabel)),
      );
      return;
    }
    if (payload == null || !payload.hasRequiredContext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save an Application Plan before contacting services.'),
        ),
      );
      return;
    }

    ref.read(selectedServiceProvider.notifier).state = service;
    context.push(AppRoutes.cropDusterContact);
  }
}
