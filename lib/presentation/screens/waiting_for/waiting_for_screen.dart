import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/waiting_for_item.dart';
import '../../../injection_container.dart';
import '../../widgets/item_metadata_widget.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class WaitingForScreen extends ConsumerWidget {
  const WaitingForScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsValue = ref.watch(waitingForProvider);
    final resolvedValue = ref.watch(allWaitingForProvider);
    final dueItems = ref.watch(waitingForDueProvider);
    final selectedView = ref.watch(waitingForViewProvider);

    return ZoroAppScaffold(
      title: 'Waiting for',
      actions: [
        IconButton(
          tooltip: 'Add Waiting For',
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add_outlined),
        ),
      ],
      child: ListView(
        children: [
          const PageTitleBand(title: 'Waiting for'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<WaitingForView>(
              segments: const [
                ButtonSegment(
                  value: WaitingForView.active,
                  icon: Icon(Icons.hourglass_empty_outlined),
                  label: Text('Active'),
                ),
                ButtonSegment(
                  value: WaitingForView.resolved,
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('Resolved'),
                ),
              ],
              selected: {selectedView},
              onSelectionChanged: (value) {
                ref.read(waitingForViewProvider.notifier).state = value.single;
              },
            ),
          ),
          const SizedBox(height: 16),
          if (selectedView == WaitingForView.active)
            itemsValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SectionCard(
                title: 'Delegated work',
                child: Text(error.toString()),
              ),
              data: (items) => _ActiveWaitingForList(
                items: items,
                dueItems: dueItems,
                onResolve: (item) => _resolve(context, ref, item),
                onSnooze: (item) => _pickFollowUpDate(context, ref, item),
                onDelete: (item) => _delete(context, ref, item),
              ),
            )
          else
            resolvedValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SectionCard(
                title: 'Resolved',
                child: Text(error.toString()),
              ),
              data: (items) {
                final resolved = items
                    .where((item) => item.isResolved)
                    .toList(growable: false);
                return _ResolvedWaitingForList(
                  items: resolved,
                  onDelete: (item) => _delete(context, ref, item),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final personController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? followUpDate = DateTime.now().add(const Duration(days: 7));

    final captured = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Waiting For'),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'What are you waiting for?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: personController,
                      decoration: const InputDecoration(
                        labelText: 'Person or team',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            followUpDate == null
                                ? 'No follow-up date'
                                : 'Follow up ${_formatDate(followUpDate!)}',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final selected = await showDatePicker(
                              context: dialogContext,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 1)),
                              lastDate: DateTime(DateTime.now().year + 10),
                              initialDate: followUpDate ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setState(() => followUpDate = selected);
                            }
                          },
                          icon: const Icon(Icons.event_outlined),
                          label: const Text('Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.hourglass_empty_outlined),
                  label: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    final title = titleController.text;
    final person = personController.text;
    final notes = notesController.text;
    titleController.dispose();
    personController.dispose();
    notesController.dispose();

    if (captured != true || !context.mounted) {
      return;
    }

    final success = await ref.read(waitingForProvider.notifier).addItem(
          title: title,
          person: person,
          followUpDate: followUpDate,
          notes: notes,
        );
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Added to Waiting For.' : 'Could not add Waiting For item.',
    );
  }

  Future<void> _pickFollowUpDate(
    BuildContext context,
    WidgetRef ref,
    WaitingForItem item,
  ) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: item.followUpDate ?? DateTime.now(),
    );
    if (selected == null) {
      return;
    }

    final success = await ref
        .read(waitingForProvider.notifier)
        .updateFollowUpDate(item.id, selected);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Follow-up date updated.' : 'Could not update follow-up date.',
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    WaitingForItem item,
  ) async {
    final success =
        await ref.read(waitingForProvider.notifier).markResolved(item.id);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Marked as completed.' : 'Could not resolve item.',
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WaitingForItem item,
  ) async {
    final success =
        await ref.read(waitingForProvider.notifier).deleteItem(item.id);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Deleted "${item.title}".' : 'Could not delete item.',
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActiveWaitingForList extends StatelessWidget {
  const _ActiveWaitingForList({
    required this.items,
    required this.dueItems,
    required this.onResolve,
    required this.onSnooze,
    required this.onDelete,
  });

  final List<WaitingForItem> items;
  final List<WaitingForItem> dueItems;
  final ValueChanged<WaitingForItem> onResolve;
  final ValueChanged<WaitingForItem> onSnooze;
  final ValueChanged<WaitingForItem> onDelete;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByPerson(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${items.length} open delegated item${items.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            StatusChip(label: '${dueItems.length} due'),
          ],
        ),
        const SizedBox(height: 16),
        if (dueItems.isNotEmpty) ...[
          SectionCard(
            title: 'Needs follow-up',
            trailing: StatusChip(label: '${dueItems.length}'),
            child: Column(
              children: [
                for (final item in dueItems)
                  _WaitingForTile(
                    item: item,
                    highlighted: true,
                    onResolve: () => onResolve(item),
                    onSnooze: () => onSnooze(item),
                    onDelete: () => onDelete(item),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SectionCard(
          title: 'By person',
          child: items.isEmpty
              ? const Text('No open Waiting For items yet.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          entry.key,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      for (final item in entry.value)
                        _WaitingForTile(
                          item: item,
                          highlighted:
                              dueItems.any((dueItem) => dueItem.id == item.id),
                          onResolve: () => onResolve(item),
                          onSnooze: () => onSnooze(item),
                          onDelete: () => onDelete(item),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ResolvedWaitingForList extends StatelessWidget {
  const _ResolvedWaitingForList({
    required this.items,
    required this.onDelete,
  });

  final List<WaitingForItem> items;
  final ValueChanged<WaitingForItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Resolved',
      trailing: StatusChip(label: '${items.length}'),
      child: items.isEmpty
          ? const Text('No resolved Waiting For items yet.')
          : Column(
              children: [
                for (final item in items)
                  _WaitingForTile(
                    item: item,
                    highlighted: false,
                    onResolve: null,
                    onSnooze: null,
                    onDelete: () => onDelete(item),
                  ),
              ],
            ),
    );
  }
}

Map<String, List<WaitingForItem>> _groupByPerson(List<WaitingForItem> items) {
  final grouped = <String, List<WaitingForItem>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.person, () => []).add(item);
  }
  return grouped;
}

class _WaitingForTile extends StatelessWidget {
  const _WaitingForTile({
    required this.item,
    required this.highlighted,
    required this.onResolve,
    required this.onSnooze,
    required this.onDelete,
  });

  final WaitingForItem item;
  final bool highlighted;
  final VoidCallback? onResolve;
  final VoidCallback? onSnooze;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        highlighted ? Icons.notification_important_outlined : Icons.person_pin,
        color: highlighted ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(item.title),
      subtitle: Text(_subtitle),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (highlighted) const StatusChip(label: 'Due'),
          if (onSnooze != null)
            OutlinedButton.icon(
              onPressed: onSnooze,
              icon: const Icon(Icons.event_outlined),
              label: const Text('Follow up'),
            ),
          if (onResolve != null)
            FilledButton.icon(
              onPressed: onResolve,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark completed'),
            )
          else
            const StatusChip(label: 'Completed'),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      onLongPress: () => showItemMetadataBottomSheet(
        context,
        entity: item,
        title: item.title,
      ),
    );
  }

  String get _subtitle {
    final date = item.followUpDate == null
        ? 'No follow-up date'
        : 'Follow up ${_formatDate(item.followUpDate!)}';
    if (item.notes == null) {
      return date;
    }
    return '$date - ${item.notes}';
  }
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
