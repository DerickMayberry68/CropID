import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/chemical.dart';

class ChemicalCard extends StatelessWidget {
  final Chemical chemical;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ChemicalCard({
    super.key,
    required this.chemical,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
  });

  Color get _toxicityColor => switch (chemical.toxicityLevel) {
        ToxicityLevel.low => Colors.green,
        ToxicityLevel.moderate => AppTheme.accentAmber,
        ToxicityLevel.high => Colors.orange,
        ToxicityLevel.extreme => AppTheme.dangerRed,
      };

  String get _toxicityLabel => switch (chemical.toxicityLevel) {
        ToxicityLevel.low => 'Low',
        ToxicityLevel.moderate => 'Moderate',
        ToxicityLevel.high => 'High',
        ToxicityLevel.extreme => 'Extreme',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _toxicityColor.withOpacity(0.15),
          child: Icon(Icons.science_outlined, color: _toxicityColor),
        ),
        title: Text(chemical.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chemical.commonName != null)
              Text(chemical.commonName!,
                  style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Chip(
              label: Text(_toxicityLabel,
                  style: TextStyle(
                      color: _toxicityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              backgroundColor: _toxicityColor.withOpacity(0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red),
                onPressed: onRemove,
              )
            : isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
        isThreeLine: true,
      ),
    );
  }
}
