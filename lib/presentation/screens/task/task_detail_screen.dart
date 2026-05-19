import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/context.dart';
import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../widgets/item_metadata_widget.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _minutesController = TextEditingController();

  String? _loadedTaskId;
  String _contextName = '@Anywhere';
  EnergyLevel _energyLevel = EnergyLevel.medium;
  DateTime? _targetDate;
  bool _isNextAction = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskValue = ref.watch(taskDetailProvider(widget.taskId));
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];

    return ZoroAppScaffold(
      title: 'Task',
      child: taskValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Task',
          child: Text(error.toString()),
        ),
        data: (task) {
          _hydrateFromTask(task);
          final project = projects
              .where((project) => project.id == task.projectId)
              .firstOrNull;

          return ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                  StatusChip(
                    label: task.isCompleted
                        ? 'Completed'
                        : task.isCalendarEvent
                            ? 'Calendar Event'
                            : task.isNextAction
                                ? 'Next Action'
                                : 'Project Step',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Action Details',
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 16),
                    _ContextDropdown(
                      value: _contextName,
                      onChanged: (value) =>
                          setState(() => _contextName = value),
                    ),
                    const SizedBox(height: 16),
                    _DateButton(date: _targetDate, onPressed: _pickTargetDate),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<EnergyLevel>(
                            initialValue: _energyLevel,
                            decoration:
                                const InputDecoration(labelText: 'Energy'),
                            items: const [
                              DropdownMenuItem(
                                value: EnergyLevel.low,
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: EnergyLevel.medium,
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: EnergyLevel.high,
                                child: Text('High'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _energyLevel = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Estimated minutes',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isNextAction,
                      title: const Text('Visible in Next Actions'),
                      onChanged: task.isCompleted || task.isCalendarEvent
                          ? null
                          : (value) => setState(() => _isNextAction = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
              if (project != null) ...[
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Project',
                  trailing: const StatusChip(label: 'Linked'),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(project.title),
                    subtitle: Text(project.desiredOutcome),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/project/${project.id}'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ItemMetadataWidget(entity: task),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isSaving ? null : () => _saveTask(task),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : task.isCompleted
                            ? () => _reopenTask(task)
                            : () => _completeTask(task),
                    icon: Icon(
                      task.isCompleted
                          ? Icons.undo_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      task.isCompleted ? 'Mark Not Complete' : 'Mark Complete',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _hydrateFromTask(Task task) {
    if (_loadedTaskId == task.id) {
      return;
    }

    _loadedTaskId = task.id;
    _titleController.text = task.title;
    _notesController.text = task.description ?? '';
    _tagsController.text = task.tags.join(', ');
    _minutesController.text = task.estimatedMinutes?.toString() ?? '';
    _contextName = task.context.name;
    _energyLevel = task.energyLevel;
    _targetDate = task.targetDate;
    _isNextAction = task.isNextAction;
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: _targetDate ?? now,
    );

    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveTask(Task task) async {
    setState(() => _isSaving = true);
    final updated = _copyTask(task);
    final success =
        await ref.read(allNextActionsProvider.notifier).updateTask(updated);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      if (success) {
        _loadedTaskId = null;
      }
    });
    _showResult(success ? 'Task saved.' : 'Could not save task.');
  }

  Future<void> _completeTask(Task task) async {
    setState(() => _isSaving = true);
    final success =
        await ref.read(allNextActionsProvider.notifier).completeTask(task.id);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showResult(success ? 'Task completed.' : 'Could not complete task.');
  }

  Future<void> _reopenTask(Task task) async {
    setState(() => _isSaving = true);
    final success = await ref.read(allNextActionsProvider.notifier).updateTask(
          task.copyWith(
            isCompleted: false,
            clearCompletedAt: true,
          ),
        );
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showResult(success ? 'Task reopened.' : 'Could not reopen task.');
  }

  Task _copyTask(Task task) {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final estimatedMinutes = int.tryParse(_minutesController.text.trim());

    return Task(
      id: task.id,
      title: _titleController.text.trim(),
      context: ZoroContext(
        id: _contextName.replaceAll('@', '').toLowerCase(),
        name: _contextName,
      ),
      createdAt: task.createdAt,
      description: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      dueDate: task.dueDate,
      targetDate: _targetDate,
      endDateTime: task.endDateTime,
      isNextAction: _isNextAction,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
      projectId: task.projectId,
      tags: tags,
      energyLevel: _energyLevel,
      estimatedMinutes: estimatedMinutes,
      isCalendarEvent: task.isCalendarEvent,
      recurrence: task.recurrence,
    );
  }

  void _showResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ContextDropdown extends ConsumerWidget {
  const _ContextDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider);

    return DropdownButtonFormField<String>(
      initialValue:
          contexts.any((context) => context.name == value) ? value : null,
      decoration: const InputDecoration(labelText: 'Context'),
      items: [
        for (final context in contexts)
          DropdownMenuItem(value: context.name, child: Text(context.name)),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.date, required this.onPressed});

  final DateTime? date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'Target Date'
        : 'Target Date: ${date!.month}/${date!.day}/${date!.year}';

    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text(text),
      ),
    );
  }
}
