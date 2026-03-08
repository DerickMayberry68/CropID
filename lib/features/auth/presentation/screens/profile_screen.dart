import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_overlay.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(farmerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const CircularProgressIndicator(),
                            errorWidget: (_, __, ___) => Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (profile.farmName != null)
                Center(
                  child: Text(
                    profile.farmName!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),

              const SizedBox(height: 32),

              // ── Info tiles ──────────────────────────────────────────
              const Divider(),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profile.phoneNumber ?? 'Not set',
              ),
              _InfoTile(
                icon: Icons.agriculture_outlined,
                label: 'Farm',
                value: profile.farmName ?? 'Not set',
              ),
              const Divider(),

              // ── Privacy ─────────────────────────────────────────────
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Share field data with neighbors'),
                subtitle: const Text(
                  'Allows neighboring farmers to see your crop info',
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

              // ── Edit button ─────────────────────────────────────────
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
