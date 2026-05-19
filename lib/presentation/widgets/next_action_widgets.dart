import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../injection_container.dart';
import '../providers/next_action_view_providers.dart';
import 'item_metadata_widget.dart';
import 'status_chip.dart';

class NextActionTaskCard extends ConsumerWidget {
  const NextActionTaskCard({
    required this.task,
    required this.projects,
    this.showDate = false,
    super.key,
  });

  final Task task;
  final List<Project> projects;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectName = projectNameForTask(task, projects);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/task/${task.id}'),
        onLongPress: () => showItemMetadataBottomSheet(
          context,
          entity: task,
          title: task.title,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: false,
                onChanged: (_) => _complete(context, ref),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SoftChip(
                          label: task.context.name,
                          icon: Icons.alternate_email_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        _SoftChip(
                          label: _energyLabel(task.energyLevel),
                          icon: Icons.battery_charging_full_outlined,
                          color: _energyColor(task.energyLevel),
                        ),
                        if (projectName.isNotEmpty)
                          _SoftChip(
                            label: projectName,
                            icon: Icons.folder_open_outlined,
                            color: theme.colorScheme.secondary,
                          ),
                        if (showDate)
                          _SoftChip(
                            label: DateFormat('MMM d')
                                .format(effectiveTaskDate(task)),
                            icon: Icons.event_outlined,
                            color: theme.colorScheme.tertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View',
                onPressed: () => context.push('/task/${task.id}'),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(allNextActionsProvider.notifier).completeTask(task.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Completed "${task.title}".' : 'Could not complete task.',
        ),
        action: success
            ? SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  await ref.read(allNextActionsProvider.notifier).updateTask(
                        task.copyWith(
                          isCompleted: false,
                          clearCompletedAt: true,
                        ),
                      );
                },
              )
            : null,
      ),
    );
  }
}

class ScheduledProjectCard extends StatelessWidget {
  const ScheduledProjectCard({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = project.targetCompletionDate;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          child: const Icon(Icons.folder_open_outlined),
        ),
        title: Text(
          project.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          project.desiredOutcome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (date != null)
              StatusChip(label: DateFormat('MMM d').format(date)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/project/${project.id}'),
      ),
    );
  }
}

class ZoroEmptyState extends StatelessWidget {
  const ZoroEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 74,
            color: theme.colorScheme.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

String _energyLabel(EnergyLevel energyLevel) {
  return switch (energyLevel) {
    EnergyLevel.low => 'Low',
    EnergyLevel.medium => 'Medium',
    EnergyLevel.high => 'High',
  };
}

Color _energyColor(EnergyLevel energyLevel) {
  return switch (energyLevel) {
    EnergyLevel.low => Colors.green.shade700,
    EnergyLevel.medium => Colors.orange.shade800,
    EnergyLevel.high => Colors.red.shade700,
  };
}
