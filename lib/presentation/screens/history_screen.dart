import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers/history_notifier_provider.dart';
import '../../domain/entities/history_entry.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/zoro_app_scaffold.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);
    final filteredEntries = ref.watch(filteredHistoryEntriesProvider);
    final totalEntries = historyState.valueOrNull?.length ?? 0;

    return ZoroAppScaffold(
      title: 'History',
      actions: [
        IconButton(
          tooltip: 'Refresh history',
          onPressed: () => ref.invalidate(historyNotifierProvider),
          icon: const Icon(Icons.refresh_outlined),
        ),
      ],
      child: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _HistoryError(message: error.toString()),
        data: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: 'Last 6 weeks',
              trailing: StatusChip(label: '$totalEntries entries'),
              child: _HistoryFilters(totalEntries: filteredEntries.length),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredEntries.isEmpty
                  ? const _HistoryEmptyState()
                  : ListView.separated(
                      itemCount: filteredEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _HistoryCard(entry: filteredEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryFilters extends ConsumerWidget {
  const _HistoryFilters({required this.totalEntries});

  final int totalEntries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionFilters = ref.watch(historyActionFilterProvider);
    final dateRange = ref.watch(historyDateRangeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_outlined),
            labelText: 'Search history',
          ),
          onChanged: (value) {
            ref.read(historySearchQueryProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '$totalEntries shown',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            for (final range in HistoryDateRange.values)
              FilterChip(
                selected: dateRange == range,
                label: Text(range.label),
                onSelected: (_) {
                  ref.read(historyDateRangeProvider.notifier).state = range;
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.clear_all_outlined, size: 18),
              label: const Text('All actions'),
              onPressed: () {
                ref.read(historyActionFilterProvider.notifier).state =
                    <HistoryAction>{};
              },
            ),
            for (final action in HistoryAction.values)
              FilterChip(
                selected: actionFilters.contains(action),
                label: Text(action.label),
                onSelected: (selected) {
                  final next = {...actionFilters};
                  selected ? next.add(action) : next.remove(action);
                  ref.read(historyActionFilterProvider.notifier).state = next;
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat('MMM d, y - h:mm a').format(entry.timestamp);

    return Card(
      child: ListTile(
        isThreeLine: entry.details != null,
        onTap: () => _showHistoryProperties(context, entry),
        onLongPress: () => _showHistoryProperties(context, entry),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Icon(_iconFor(entry.action), size: 20),
        ),
        title: Text(
          entry.description,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$time - ${entry.action.label}'),
              if (entry.details != null) ...[
                const SizedBox(height: 4),
                Text(entry.details!),
              ],
            ],
          ),
        ),
        trailing: _HistoryTrailing(entry: entry),
      ),
    );
  }

  IconData _iconFor(HistoryAction action) {
    return switch (action) {
      HistoryAction.inboxProcessed => Icons.inbox_outlined,
      HistoryAction.taskCreated => Icons.add_task_outlined,
      HistoryAction.taskCompleted => Icons.task_alt_outlined,
      HistoryAction.calendarEventCreated => Icons.event_repeat_outlined,
      HistoryAction.projectCreated => Icons.folder_copy_outlined,
      HistoryAction.somedayCreated => Icons.event_available_outlined,
      HistoryAction.referenceCreated => Icons.folder_open_outlined,
      HistoryAction.waitingForCreated => Icons.hourglass_empty_outlined,
      HistoryAction.waitingForResolved => Icons.check_circle_outline,
      HistoryAction.somedayActivated => Icons.play_arrow_outlined,
      HistoryAction.inboxTrashed => Icons.delete_outline,
      HistoryAction.dataCleared => Icons.delete_forever_outlined,
    };
  }
}

class _HistoryTrailing extends StatelessWidget {
  const _HistoryTrailing({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final entityId = entry.entityId;
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 104),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CompactHistoryBadge(label: entry.entityType),
          if (entityId != null) ...[
            const SizedBox(height: 2),
            Text(
              _shortId(entityId),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactHistoryBadge extends StatelessWidget {
  const _CompactHistoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _showHistoryProperties(
  BuildContext context,
  HistoryEntry entry,
) async {
  final timestamp = DateFormat('MMMM d, y - h:mm a').format(entry.timestamp);
  final entityId = entry.entityId;

  // Master Spec debugging enhancement: expose internal IDs only on demand.
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History Properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              _PropertyText(label: 'Timestamp', value: timestamp),
              _PropertyText(label: 'Action', value: entry.action.label),
              _PropertyText(label: 'Description', value: entry.description),
              Row(
                children: [
                  Expanded(
                    child: _PropertyText(
                      label: 'Entity ID',
                      value: entityId ?? '-',
                      singleLine: true,
                    ),
                  ),
                  if (entityId != null)
                    IconButton(
                      tooltip: 'Copy entity ID',
                      onPressed: () => _copyEntityId(context, entityId),
                      icon: const Icon(Icons.copy_outlined),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PropertyText extends StatelessWidget {
  const _PropertyText({
    required this.label,
    required this.value,
    this.singleLine = false,
  });

  final String label;
  final String value;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        maxLines: singleLine ? 1 : null,
        overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.clip,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

Future<void> _copyEntityId(BuildContext context, String entityId) async {
  await Clipboard.setData(ClipboardData(text: entityId));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Entity ID copied.')),
  );
}

String _shortId(String id) {
  if (id.length <= 8) {
    return 'ID $id';
  }
  return 'ID ${id.substring(0, 8)}...';
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            size: 72,
            color: theme.colorScheme.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As you process and complete work, Zoro will keep the last six weeks here.',
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

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SectionCard(
        title: 'History could not load',
        child: Text(message),
      ),
    );
  }
}
