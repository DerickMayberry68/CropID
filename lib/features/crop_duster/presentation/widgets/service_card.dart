import 'package:flutter/material.dart';

import '../../data/models/crop_duster_service.dart';

class ServiceCard extends StatelessWidget {
  final CropDusterService service;
  final VoidCallback onContact;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, size: 28, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(service.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            if (service.address != null) ...[
              const SizedBox(height: 4),
              Text(service.address!,
                  style: const TextStyle(color: Colors.grey)),
            ],
            if (service.serviceRadiusMiles != null)
              Text('Serves up to ${service.serviceRadiusMiles} miles',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Call'),
                    onPressed: onContact,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Send Info'),
                    onPressed: onContact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
