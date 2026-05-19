import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.w700),
      side: BorderSide(color: chipColor.withValues(alpha: 0.25)),
      backgroundColor: chipColor.withValues(alpha: 0.08),
    );
  }
}
