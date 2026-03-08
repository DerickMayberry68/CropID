import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../farm_map/data/models/field.dart';
import '../../../farm_map/providers/farm_map_provider.dart';
import '../../../spray_planning/providers/spray_plan_provider.dart';
import '../../providers/crop_duster_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  bool _isSendingSms = false;
  bool _isSendingEmail = false;

  String _buildMessage({
    required String fieldName,
    required List<String> chemicals,
    required int dangerCount,
    required double? lat,
    required double? lng,
  }) {
    final chemList = chemicals.isEmpty ? 'TBD' : chemicals.join(', ');
    final coords = (lat != null && lng != null)
        ? 'https://maps.google.com/?q=$lat,$lng'
        : 'coordinates not available';
    final dangerNote = dangerCount > 0
        ? '\nWARNING: $dangerCount neighboring field(s) may be at risk.'
        : '';

    return 'Hello,\n\n'
        'I need a spraying service for my field "$fieldName".\n\n'
        'Location: $coords\n'
        'Chemicals: $chemList$dangerNote\n\n'
        'Please contact me to schedule. Thank you.';
  }

  Future<void> _sendMessage({
    required bool sendSms,
    required bool sendEmail,
  }) async {
    final service = ref.read(selectedServiceProvider);
    final user = ref.read(currentUserProvider);
    final selectedField = ref.read(selectedFieldProvider);
    final chemicals = ref.read(selectedChemicalsProvider);
    final dangerousFields = ref.read(dangerousFieldsProvider);

    if (service == null || user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing service or user context')),
      );
      return;
    }

    final lat = selectedField?.latLngBoundary.isNotEmpty == true
        ? selectedField?.latLngBoundary.first.latitude
        : null;
    final lng = selectedField?.latLngBoundary.isNotEmpty == true
        ? selectedField?.latLngBoundary.first.longitude
        : null;
    final message = _buildMessage(
      fieldName: selectedField?.name ?? 'My Field',
      chemicals: chemicals.map((c) => c.name).toList(),
      dangerCount: dangerousFields.length,
      lat: lat,
      lng: lng,
    );

    setState(() {
      if (sendSms) _isSendingSms = true;
      if (sendEmail) _isSendingEmail = true;
    });

    final result = await ref.read(cropDusterRepositoryProvider).contactService(
          serviceId: service.id,
          farmerId: user.id,
          fieldName: selectedField?.name ?? 'My Field',
          chemicalNames: chemicals.map((c) => c.name).toList(),
          dangerCount: dangerousFields.length,
          message: message,
          lat: lat,
          lng: lng,
          sendSms: sendSms,
          sendEmail: sendEmail,
        );

    if (!mounted) return;

    setState(() {
      if (sendSms) _isSendingSms = false;
      if (sendEmail) _isSendingEmail = false;
    });

    result.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $err')),
      ),
      (data) {
        final smsStatus = data['sms'];
        final emailStatus = data['email'];
        final serviceName = data['service_name'] ?? service.name;
        final statusParts = <String>[];

        if (sendSms) statusParts.add('SMS: ${smsStatus ?? 'unknown'}');
        if (sendEmail) statusParts.add('Email: ${emailStatus ?? 'unknown'}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sent to $serviceName. ${statusParts.join(' | ')}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(selectedServiceProvider);
    final selectedField = ref.watch(selectedFieldProvider);
    final chemicals = ref.watch(selectedChemicalsProvider);
    final dangerousFields = ref.watch(dangerousFieldsProvider);
    final profileAsync = ref.watch(farmerProfileProvider);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contact')),
        body: const Center(child: Text('No service selected')),
      );
    }

    final message = _buildMessage(
      fieldName: selectedField?.name ?? 'My Field',
      chemicals: chemicals.map((c) => c.name).toList(),
      dangerCount: dangerousFields.length,
      lat: selectedField?.latLngBoundary.isNotEmpty == true
          ? selectedField?.latLngBoundary.first.latitude
          : null,
      lng: selectedField?.latLngBoundary.isNotEmpty == true
          ? selectedField?.latLngBoundary.first.longitude
          : null,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Contact ${service.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (service.address != null) ...[
                    const SizedBox(height: 4),
                    Text(service.address!,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                  if (service.serviceRadiusMiles != null)
                    Text('Service radius: ${service.serviceRadiusMiles} miles',
                        style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  profileAsync.when(
                    loading: () =>
                        const Text('Loading your contact details...'),
                    error: (_, __) => const Text(
                      'Unable to load your profile details for reply-to metadata.',
                      style: TextStyle(color: AppTheme.dangerRed),
                    ),
                    data: (profile) {
                      final hasReplyContact = profile != null &&
                          ((profile.phoneNumber?.isNotEmpty ?? false) ||
                              profile.email.isNotEmpty);
                      return Text(
                        hasReplyContact
                            ? 'CropID will send this request using your saved profile details.'
                            : 'Add a phone number or email in your profile so services can reply.',
                        style: TextStyle(
                          color: hasReplyContact
                              ? Colors.grey.shade700
                              : AppTheme.dangerRed,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Message Preview',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              message,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Call ${service.name}',
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: service.phone);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.email_outlined),
            label: Text(
                _isSendingEmail ? 'Sending Email...' : 'Send Email via CropID'),
            onPressed: _isSendingEmail
                ? null
                : () => _sendMessage(sendSms: false, sendEmail: true),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.sms_outlined),
            label:
                Text(_isSendingSms ? 'Sending SMS...' : 'Send SMS via CropID'),
            onPressed: _isSendingSms
                ? null
                : () => _sendMessage(sendSms: true, sendEmail: false),
          ),
        ],
      ),
    );
  }
}
