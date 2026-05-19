import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/someday_maybe_item.dart';
import '../../../injection_container.dart';
import '../../providers/someday_filter_providers.dart';
import '../../widgets/item_metadata_widget.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/someday_sidebar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class SomedayMaybeScreen extends ConsumerWidget {
  const SomedayMaybeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsValue = ref.watch(somedayMaybeProvider);
    final ready = ref.watch(readyToActivateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ZoroAppScaffold(
      title: 'Someday/Maybe',
      child: itemsValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'All Someday/Maybe',
          child: Text(error.toString()),
        ),
        data: (items) {
          final filteredItems = ref.watch(filteredSomedayMaybeProvider);

          return ListView(
            children: [
              const PageTitleBand(title: 'Someday/Maybe'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${items.length} total items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to Activate (${ready.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (ready.isEmpty)
                        const Text('Nothing is due for reconsideration today.'),
                      for (final item in ready)
                        _SomedayTile(
                          item: item,
                          isReady: true,
                          onActivate: () => _activate(context, ref, item),
                          onSnooze: () => _snooze(context, ref, item),
                          onDelete: () => _delete(context, ref, item),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final list = _SomedayListSection(
                    items: filteredItems,
                    onActivate: (item) => _activate(context, ref, item),
                    onSnooze: (item) => _snooze(context, ref, item),
                    onDelete: (item) => _delete(context, ref, item),
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SomedaySidebar(items: items),
                        const SizedBox(height: 16),
                        list,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 220, child: SomedaySidebar(items: items)),
                      const SizedBox(width: 20),
                      Expanded(child: list),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _activate(
    BuildContext context,
    WidgetRef ref,
    SomedayMaybeItem item,
  ) async {
    final projectId =
        await ref.read(somedayMaybeProvider.notifier).activateAsProject(item);
    if (!context.mounted) {
      return;
    }

    if (projectId == null) {
      _showMessage(context, 'Could not activate "${item.title}".');
      return;
    }

    _showMessage(context, 'Activated "${item.title}" as a project.');
    context.push('/project/$projectId');
  }

  Future<void> _snooze(
    BuildContext context,
    WidgetRef ref,
    SomedayMaybeItem item,
  ) async {
    final nextQuarter = _addMonths(DateTime.now(), 3);
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: nextQuarter,
    );
    if (date == null) {
      return;
    }

    final success =
        await ref.read(somedayMaybeProvider.notifier).snoozeItem(item.id, date);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Snoozed "${item.title}".' : 'Could not snooze item.',
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SomedayMaybeItem item,
  ) async {
    final success =
        await ref.read(somedayMaybeProvider.notifier).deleteItem(item.id);
    if (!context.mounted) {
      return;
    }

    _showMessage(
      context,
      success ? 'Deleted "${item.title}".' : 'Could not delete item.',
    );
  }

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SomedayListSection extends StatelessWidget {
  const _SomedayListSection({
    required this.items,
    required this.onActivate,
    required this.onSnooze,
    required this.onDelete,
  });

  final List<SomedayMaybeItem> items;
  final ValueChanged<SomedayMaybeItem> onActivate;
  final ValueChanged<SomedayMaybeItem> onSnooze;
  final ValueChanged<SomedayMaybeItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'All Someday/Maybe (${items.length})',
      child: items.isEmpty
          ? const Text('No Someday/Maybe items match these filters.')
          : Column(
              children: [
                for (final item in items)
                  _SomedayTile(
                    item: item,
                    isReady: item.isReadyToActivate,
                    onActivate: () => onActivate(item),
                    onSnooze: () => onSnooze(item),
                    onDelete: () => onDelete(item),
                  ),
              ],
            ),
    );
  }
}

class _SomedayTile extends StatelessWidget {
  const _SomedayTile({
    required this.item,
    required this.isReady,
    required this.onActivate,
    required this.onSnooze,
    required this.onDelete,
  });

  final SomedayMaybeItem item;
  final bool isReady;
  final VoidCallback onActivate;
  final VoidCallback onSnooze;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.title),
      subtitle: Text(
        'Reconsider ${item.reconsiderDate.month}/${item.reconsiderDate.day}/${item.reconsiderDate.year}',
      ),
      leading: Icon(
        isReady ? Icons.bolt_outlined : Icons.event_available_outlined,
      ),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (item.tags.isNotEmpty) StatusChip(label: item.tags.first),
          FilledButton(
            onPressed: onActivate,
            child: const Text('Activate'),
          ),
          OutlinedButton(
            onPressed: onSnooze,
            child: const Text('Snooze'),
          ),
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
}
