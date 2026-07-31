import 'package:flutter/material.dart';

import '../../data/models/crop_duster_service.dart';

class ServiceCard extends StatelessWidget {
  final CropDusterService service;
  final VoidCallback onContact;
  final String? contextSummary;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onContact,
    this.contextSummary,
  });

  IconData get _serviceIcon => switch (service.serviceType) {
        SprayingServiceType.drone => Icons.smart_toy_outlined,
        SprayingServiceType.agAir => Icons.flight_takeoff,
        SprayingServiceType.coOp => Icons.storefront_outlined,
      };

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
                Icon(_serviceIcon, size: 28, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.serviceType.label,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
            if (contextSummary != null) ...[
              const SizedBox(height: 6),
              Text(
                contextSummary!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
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
