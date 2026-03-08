import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Instruction banner shown at the top of the field drawing screen.
class DrawFieldToolbar extends StatelessWidget {
  final int pointCount;
  final bool canClose;
  final bool isSaving;
  final VoidCallback? onDone;

  const DrawFieldToolbar({
    super.key,
    required this.pointCount,
    required this.canClose,
    required this.isSaving,
    this.onDone,
  });

  String get _instruction {
    if (pointCount == 0) return 'Tap the map to place your first point';
    if (pointCount == 1) return 'Keep tapping to add more points';
    if (pointCount == 2) return 'Add at least one more point';
    return 'Tap the first point (yellow) or press Done to close';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            pointCount == 0
                ? Icons.touch_app_outlined
                : Icons.location_on_outlined,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_instruction,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (pointCount > 0)
                  Text('$pointCount point${pointCount == 1 ? '' : 's'} placed',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (canClose)
            isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(64, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Done'),
                  ),
        ],
      ),
    );
  }
}
