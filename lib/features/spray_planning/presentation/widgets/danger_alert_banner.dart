import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DangerAlertBanner extends StatelessWidget {
  final int dangerousFieldCount;
  const DangerAlertBanner({super.key, required this.dangerousFieldCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withOpacity(0.1),
        border: Border.all(color: AppTheme.dangerRed, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.dangerRed, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danger Alert',
                  style: TextStyle(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dangerousFieldCount neighboring field${dangerousFieldCount > 1 ? 's' : ''} '
                  'may be harmed by your selected chemicals. '
                  'Check the map for details.',
                  style: TextStyle(color: AppTheme.dangerRed.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
