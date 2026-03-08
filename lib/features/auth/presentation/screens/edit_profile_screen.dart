import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/models/farmer_profile.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _initialized = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _farmNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(FarmerProfile profile) {
    if (_initialized) return;
    _nameCtrl.text = profile.fullName;
    _farmNameCtrl.text = profile.farmName ?? '';
    _phoneCtrl.text = profile.phoneNumber ?? '';
    _initialized = true;
  }

  Future<void> _pickAndUploadAvatar(FarmerProfile profile) async {
    final repo = ref.read(authRepositoryProvider);
    final xFile = await repo.avatarService.pickImage();
    if (xFile == null) return; // user cancelled

    setState(() => _isUploadingAvatar = true);

    final result = await repo.avatarService.uploadAvatar(
      userId: profile.id,
      image: xFile,
    );

    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);

    result.fold(
      (err) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $err'))),
      (_) {
        ref.invalidate(farmerProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated')),
        );
      },
    );
  }

  Future<void> _save(FarmerProfile current) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      fullName: _nameCtrl.text.trim(),
      farmName: _farmNameCtrl.text.trim().isEmpty
          ? null
          : _farmNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim(),
    );

    final result = await ref
        .read(authRepositoryProvider)
        .updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (err) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $err'))),
      (_) {
        // Invalidate the profile cache so ProfileScreen refreshes
        ref.invalidate(farmerProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(farmerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          _initFromProfile(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Avatar ─────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _isUploadingAvatar
                          ? null
                          : () => _pickAndUploadAvatar(profile),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            child: _isUploadingAvatar
                                ? const CircularProgressIndicator()
                                : profile.avatarUrl != null
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: profile.avatarUrl!,
                                          width: 104,
                                          height: 104,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (_, __, ___) => Text(
                                            profile.fullName.isNotEmpty
                                                ? profile.fullName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                fontSize: 36),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        profile.fullName.isNotEmpty
                                            ? profile.fullName[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 36,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap to change photo',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Personal info ──────────────────────────────────
                  Text('Personal Info',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        Validators.required(v, fieldName: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.phone,
                  ),

                  const SizedBox(height: 28),

                  // ── Farm info ──────────────────────────────────────
                  Text('Farm Info',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _farmNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name (optional)',
                      prefixIcon: Icon(Icons.agriculture_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Farm location info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color:
                                Theme.of(context).colorScheme.primary,
                            size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Farm location is set automatically from your fields on the map.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Privacy ────────────────────────────────────────
                  Text('Privacy',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Share my field data'),
                    subtitle: const Text(
                      'Allow neighboring farmers to see your crop info. '
                      'You can set visibility per-field on the map.',
                    ),
                    value: profile.fieldSharingEnabled,
                    onChanged: (val) async {
                      final updated =
                          profile.copyWith(fieldSharingEnabled: val);
                      await ref
                          .read(authRepositoryProvider)
                          .updateProfile(updated);
                      ref.invalidate(farmerProfileProvider);
                    },
                  ),

                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'Save Changes',
                    isLoading: _isSaving,
                    onPressed: () => _save(profile),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
