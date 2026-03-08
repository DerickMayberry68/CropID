import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/field.dart';
import '../../providers/farm_map_provider.dart';

class EditFieldScreen extends ConsumerStatefulWidget {
  final Field field;
  const EditFieldScreen({super.key, required this.field});

  @override
  ConsumerState<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends ConsumerState<EditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late FieldVisibility _visibility;
  bool _isSaving = false;
  bool _isDeleting = false;

  // TODO: Phase 3 — populate from crops table via provider
  static const _mockCrops = [
    ('corn', 'Corn'),
    ('soybeans', 'Soybeans'),
    ('wheat', 'Wheat'),
    ('cotton', 'Cotton'),
    ('canola', 'Canola'),
    ('sunflower', 'Sunflower'),
    ('sorghum', 'Sorghum'),
    ('alfalfa', 'Alfalfa'),
    ('potato', 'Potato'),
    ('sugar_beet', 'Sugar Beet'),
  ];

  String? _selectedCropId;
  String? _selectedCropName;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.field.name);
    _visibility = widget.field.visibility;
    _selectedCropId = widget.field.currentCropId;
    _selectedCropName = widget.field.currentCropName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = widget.field.copyWith(
      name: _nameCtrl.text.trim(),
      visibility: _visibility,
      currentCropId: _selectedCropId,
      currentCropName: _selectedCropName,
    );

    final result =
        await ref.read(fieldRepositoryProvider).updateField(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (err) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $err'))),
      (_) {
        ref.invalidate(myFieldsProvider);
        ref.read(selectedFieldProvider.notifier).state = updated;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field updated')),
        );
      },
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Field?'),
        content: Text(
          'Are you sure you want to delete "${widget.field.name}"? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final result = await ref
        .read(fieldRepositoryProvider)
        .deleteField(widget.field.id);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    result.fold(
      (err) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $err'))),
      (_) {
        ref.invalidate(myFieldsProvider);
        ref.read(selectedFieldProvider.notifier).state = null;
        // Pop back to map (pop twice — edit screen + bottom sheet)
        Navigator.of(context)
          ..pop()
          ..pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('"${widget.field.name}" deleted')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Field'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.dangerRed),
            tooltip: 'Delete field',
            onPressed: _isDeleting ? null : _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Field name ───────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  prefixIcon: Icon(Icons.landscape_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Field name is required'
                    : null,
              ),

              const SizedBox(height: 24),

              // ── Current crop ─────────────────────────────────────
              Text('Current Crop',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCropId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.grass_outlined),
                ),
                hint: const Text('Select a crop'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None / Fallow'),
                  ),
                  ..._mockCrops.map((c) => DropdownMenuItem(
                        value: c.$1,
                        child: Text(c.$2),
                      )),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedCropId = val;
                    _selectedCropName = val == null
                        ? null
                        : _mockCrops
                            .firstWhere((c) => c.$1 == val)
                            .$2;
                  });
                },
              ),

              const SizedBox(height: 24),

              // ── Visibility ───────────────────────────────────────
              Text('Data Sharing',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...FieldVisibility.values.map(
                (v) => RadioListTile<FieldVisibility>(
                  contentPadding: EdgeInsets.zero,
                  value: v,
                  groupValue: _visibility,
                  title: Text(_visibilityLabel(v)),
                  subtitle: Text(_visibilityDesc(v),
                      style: const TextStyle(fontSize: 12)),
                  onChanged: (val) =>
                      setState(() => _visibility = val!),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _visibilityLabel(FieldVisibility v) => switch (v) {
        FieldVisibility.private => 'Private',
        FieldVisibility.anonymous => 'Anonymous',
        FieldVisibility.public => 'Public',
      };

  String _visibilityDesc(FieldVisibility v) => switch (v) {
        FieldVisibility.private =>
          'Only you can see this field',
        FieldVisibility.anonymous =>
          'Crop type visible to neighbors, your name is hidden',
        FieldVisibility.public =>
          'Full field info visible to neighboring farmers',
      };
}
