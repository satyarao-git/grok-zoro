import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/reference_item.dart';
import '../../../injection_container.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ReferenceScreen extends ConsumerWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsValue = ref.watch(referenceProvider);

    return ZoroAppScaffold(
      title: 'Reference',
      child: itemsValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Reference',
          child: Text(error.toString()),
        ),
        data: (items) {
          final filtered = ref.watch(filteredReferenceProvider);
          final folders = ref.watch(referenceFoldersProvider);
          final tags = ref.watch(referenceTagsProvider);
          final selectedFolder = ref.watch(referenceFolderFilterProvider);
          final selectedTag = ref.watch(referenceTagFilterProvider);

          return ListView(
            children: [
              const PageTitleBand(title: 'Reference'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined),
                  labelText: 'Search reference',
                ),
                onChanged: (value) {
                  ref.read(referenceSearchProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(label: '${items.length} filed'),
                  FilterChip(
                    selected: selectedFolder == null,
                    label: const Text('All folders'),
                    onSelected: (_) {
                      ref.read(referenceFolderFilterProvider.notifier).state =
                          null;
                    },
                  ),
                  for (final folder in folders)
                    FilterChip(
                      selected: selectedFolder == folder,
                      label: Text(folder),
                      onSelected: (_) {
                        ref.read(referenceFolderFilterProvider.notifier).state =
                            selectedFolder == folder ? null : folder;
                      },
                    ),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      selected: selectedTag == null,
                      label: const Text('All tags'),
                      onSelected: (_) {
                        ref.read(referenceTagFilterProvider.notifier).state =
                            null;
                      },
                    ),
                    for (final tag in tags)
                      FilterChip(
                        selected: selectedTag == tag,
                        label: Text(tag),
                        onSelected: (_) {
                          ref.read(referenceTagFilterProvider.notifier).state =
                              selectedTag == tag ? null : tag;
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (items.isEmpty)
                const _ReferenceEmptyState()
              else if (filtered.isEmpty)
                const SectionCard(
                  title: 'No matches',
                  child: Text('Try a different search, folder, or tag.'),
                )
              else
                SectionCard(
                  title: 'Filed reference',
                  child: Column(
                    children: [
                      for (final item in filtered)
                        _ReferenceTile(
                          item: item,
                          onDelete: () async {
                            final success = await ref
                                .read(referenceProvider.notifier)
                                .deleteItem(item.id);
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Reference deleted.'
                                    : 'Could not delete reference.'),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({
    required this.item,
    required this.onDelete,
  });

  final ReferenceItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = item.notes?.trim();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notes != null && notes.isNotEmpty)
                Text(
                  notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (item.folder != null) StatusChip(label: item.folder!),
                  StatusChip(
                    label: DateFormat('MMM d, y').format(item.createdAt),
                  ),
                  for (final tag in item.tags) StatusChip(label: tag),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Reference actions',
          onSelected: (value) {
            if (value == 'open') {
              _showReferenceDetails(context, item);
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'open', child: Text('Open')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showReferenceDetails(context, item),
      ),
    );
  }
}

class _ReferenceEmptyState extends StatelessWidget {
  const _ReferenceEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Nothing filed yet',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 72,
                color: theme.colorScheme.primary.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 14),
              Text(
                'Nothing filed yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Reference material saved from Inbox will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showReferenceDetails(BuildContext context, ReferenceItem item) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            if (item.folder != null) StatusChip(label: item.folder!),
            if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(item.notes!),
            ],
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final tag in item.tags) StatusChip(label: tag)],
              ),
            ],
          ],
        ),
      );
    },
  );
}
