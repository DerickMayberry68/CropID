import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/spray_plan_save_state.dart';

class DangerAlertBanner extends StatelessWidget {
  final int dangerousFieldCount;
  final SprayPlanSaveState? saveState;

  const DangerAlertBanner({
    super.key,
    required this.dangerousFieldCount,
    this.saveState,
  });

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
                if (saveState != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    switch (saveState!) {
                      SprayPlanSaveState.saved =>
                        AppConstants.saveStateSavedLabel,
                      SprayPlanSaveState.failed =>
                        AppConstants.saveStateFailedLabel,
                      SprayPlanSaveState.saving =>
                        AppConstants.saveStateSavingLabel,
                      SprayPlanSaveState.idle =>
                        AppConstants.saveStateIdleLabel,
                    },
                    style: TextStyle(
                      color: AppTheme.dangerRed.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
