import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/context.dart';
import '../../../injection_container.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ContextManagementScreen extends ConsumerStatefulWidget {
  const ContextManagementScreen({super.key});

  @override
  ConsumerState<ContextManagementScreen> createState() =>
      _ContextManagementScreenState();
}

class _ContextManagementScreenState
    extends ConsumerState<ContextManagementScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contexts = ref.watch(contextsProvider);
    final usage = ref.watch(contextUsageProvider);

    return ZoroAppScaffold(
      title: 'Context Management',
      child: Column(
        children: [
          const PageTitleBand(
            title: 'Context Management',
            subtitle:
                'Add/remove contexts to organize your next actions by location, tool, or situation help you to act at appropriate time',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
                final editor = _AddContextPanel(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  onAdd: _addContext,
                );
                final list = _ContextList(
                  contexts: contexts,
                  usage: usage,
                  onEdit: _editContext,
                  onDelete: _deleteContext,
                );

                if (!isWide) {
                  return ListView(
                    children: [
                      editor,
                      const SizedBox(height: 16),
                      list,
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 360, child: editor),
                      const SizedBox(width: 20),
                      Expanded(child: list),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addContext() async {
    final added = await ref.read(contextsStateProvider.notifier).addContext(
          name: _nameController.text,
          description: _descriptionController.text,
        );

    if (!mounted) {
      return;
    }

    if (added) {
      _nameController.clear();
      _descriptionController.clear();
      _showMessage('Context added.');
      return;
    }

    _showMessage('Use a unique context name.');
  }

  Future<void> _editContext(ZoroContext contextToEdit) async {
    final updated = await showDialog<ZoroContext>(
      context: context,
      builder: (dialogContext) {
        final nameController = TextEditingController(text: contextToEdit.name);
        final descriptionController = TextEditingController(
          text: contextToEdit.description ?? '',
        );

        return AlertDialog(
          title: const Text('Edit Context'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  ZoroContext(
                    id: contextToEdit.id,
                    name: nameController.text,
                    description: descriptionController.text,
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updated == null || !mounted) {
      return;
    }

    final saved =
        await ref.read(contextsStateProvider.notifier).updateContext(updated);
    if (!mounted) {
      return;
    }
    _showMessage(saved ? 'Context updated.' : 'Could not update context.');
  }

  Future<void> _deleteContext(ZoroContext contextToDelete) async {
    final deleted = await ref
        .read(contextsStateProvider.notifier)
        .deleteContext(contextToDelete.id);
    if (!mounted) {
      return;
    }
    _showMessage(deleted ? 'Context removed.' : 'Default contexts stay put.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AddContextPanel extends StatelessWidget {
  const _AddContextPanel({
    required this.nameController,
    required this.descriptionController,
    required this.onAdd,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Future<void> Function() onAdd;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Add Context',
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Context name',
              hintText: '@Office',
            ),
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_outlined),
              label: const Text('Add Context'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextList extends StatelessWidget {
  const _ContextList({
    required this.contexts,
    required this.usage,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ZoroContext> contexts;
  final Map<String, int> usage;
  final ValueChanged<ZoroContext> onEdit;
  final ValueChanged<ZoroContext> onDelete;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Available Contexts',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: contexts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final zoroContext = contexts[index];
          final actionCount = usage[zoroContext.name] ?? 0;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.label_outline),
            title: Text(zoroContext.name),
            subtitle: Text(
              zoroContext.description?.isNotEmpty == true
                  ? zoroContext.description!
                  : '$actionCount next actions',
            ),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (zoroContext.isDefault)
                  const StatusChip(label: 'Default')
                else
                  StatusChip(label: '$actionCount actions'),
                IconButton(
                  tooltip: 'Edit context',
                  onPressed:
                      zoroContext.isDefault ? null : () => onEdit(zoroContext),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete context',
                  onPressed: zoroContext.isDefault
                      ? null
                      : () => onDelete(zoroContext),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
