import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/csb_field.dart';
import '../../providers/farm_map_provider.dart';

/// Height of the shell's bottom navigation bar, which is drawn over modal
/// sheets. The sheet lifts clear of it so its actions stay tappable.
const double _navBarClearance = 76;

/// Confirmation sheet for claiming a USDA boundary as an owned field.
///
/// Lets the farmer name the field before claiming; the boundary itself comes
/// from USDA data, so there is nothing to draw.
class ClaimFieldSheet extends ConsumerStatefulWidget {
  final CsbField csbField;

  const ClaimFieldSheet({super.key, required this.csbField});

  @override
  ConsumerState<ClaimFieldSheet> createState() => _ClaimFieldSheetState();
}

class _ClaimFieldSheetState extends ConsumerState<ClaimFieldSheet> {
  late final TextEditingController _nameController;
  bool _claiming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    setState(() {
      _claiming = true;
      _error = null;
    });

    final claim = ref.read(claimCsbFieldProvider);
    final error = await claim(
      csbId: widget.csbField.csbId,
      name: _nameController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _claiming = false;
        _error = error;
      });
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final csb = widget.csbField;

    // Keep the sheet clear of the keyboard, the home indicator, and the
    // shell's bottom navigation so the claim action is always reachable.
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        margin: EdgeInsets.fromLTRB(12, 12, 12, 12 + safeBottom + _navBarClearance),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: AppTheme.panelDecoration(emphasized: true),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.skyBlue.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
                    color: AppTheme.skyBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Claim this field',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${csb.acresLabel} • USDA boundary',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'This boundary comes from public USDA field data. Claim it to '
              'add it to your farm — you can rename it and set the crop after.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              enabled: !_claiming,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Field name (optional)',
                hintText: 'e.g. North 80',
              ),
              onSubmitted: (_) => _claiming ? null : _claim(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.panelDecoration(
                  borderColor: AppTheme.dangerRed,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.dangerRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _claiming ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _claiming ? null : _claim,
                    icon: _claiming
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_claiming ? 'Claiming...' : 'Claim Field'),
                  ),
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
