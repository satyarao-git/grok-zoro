import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/date_format_extensions.dart';
import '../../../injection_container.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksValue = ref.watch(allTasksProvider);
    final projectsValue = ref.watch(allProjectsProvider);
    final items = ref.watch(archiveItemsProvider);
    final completedTasks =
        items.where((item) => item.type == ArchiveItemType.task).length;
    final completedProjects =
        items.where((item) => item.type == ArchiveItemType.project).length;

    final isLoading = tasksValue.isLoading || projectsValue.isLoading;
    final error = tasksValue.error ?? projectsValue.error;

    return ZoroAppScaffold(
      title: 'Archive',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? SectionCard(title: 'Archive', child: Text(error.toString()))
              : ListView(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        StatusChip(label: '$completedTasks tasks'),
                        StatusChip(label: '$completedProjects projects'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Completed work',
                      trailing: StatusChip(label: '${items.length}'),
                      child: items.isEmpty
                          ? const Text(
                              'Completed next actions and projects will appear here.',
                            )
                          : Column(
                              children: [
                                for (final item in items)
                                  _ArchiveTile(item: item),
                              ],
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _ArchiveTile extends StatelessWidget {
  const _ArchiveTile({required this.item});

  final ArchiveItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
      title: Text(item.title),
      subtitle: Text('${item.archivedAt.compactLabel} - ${item.subtitle}'),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StatusChip(label: _label),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.push(item.route),
    );
  }

  IconData get _icon {
    return switch (item.type) {
      ArchiveItemType.task => Icons.check_circle_outline,
      ArchiveItemType.project => Icons.folder_copy_outlined,
    };
  }

  String get _label {
    return switch (item.type) {
      ArchiveItemType.task => 'Task',
      ArchiveItemType.project => 'Project',
    };
  }
}
