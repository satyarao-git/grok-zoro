import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/context.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/project_step.dart';
import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../widgets/item_metadata_widget.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _titleController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _loadedProjectId;
  DateTime? _targetCompletionDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _outcomeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsValue = ref.watch(allProjectsProvider);

    return ZoroAppScaffold(
      title: 'Project',
      child: projectsValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Project',
          child: Text(error.toString()),
        ),
        data: (projects) {
          final project = projects
              .where((entry) => entry.id == widget.projectId)
              .firstOrNull;
          if (project == null) {
            return const SectionCard(
              title: 'Project',
              child: Text('Project was completed or could not be found.'),
            );
          }

          final projectTasksValue = ref.watch(projectTasksProvider(project.id));

          return projectTasksValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => SectionCard(
              title: 'Project tasks',
              child: Text(error.toString()),
            ),
            data: (projectTasks) {
              _hydrateFromProject(project);
              final progress = projectTasks.isEmpty
                  ? project.progress
                  : projectTasks.where((task) => task.isCompleted).length /
                      projectTasks.length;

              return ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      StatusChip(
                        label: project.isCompleted ? 'Completed' : 'Active',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 24),
                  SectionCard(
                    title: 'Project Basics',
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration:
                              const InputDecoration(labelText: 'Project Title'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _outcomeController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                              labelText: 'Desired Outcome'),
                        ),
                        const SizedBox(height: 16),
                        _DateButton(
                          date: _targetCompletionDate,
                          onPressed: _pickTargetDate,
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
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Steps',
                    trailing: TextButton.icon(
                      onPressed: _isSaving ? null : () => _addStep(project),
                      icon: const Icon(Icons.add_outlined),
                      label: const Text('Add Step'),
                    ),
                    child: projectTasks.isEmpty
                        ? const Text('No steps have been added yet.')
                        : Column(
                            children: [
                              for (var index = 0;
                                  index < projectTasks.length;
                                  index++) ...[
                                _ProjectStepTile(
                                  task: projectTasks[index],
                                  onCompletionChanged: (isCompleted) =>
                                      _setTaskCompleted(
                                    projectTasks[index],
                                    isCompleted,
                                  ),
                                  onActiveChanged: (isActive) => _setTaskActive(
                                    projectTasks[index],
                                    isActive,
                                  ),
                                ),
                                if (index < projectTasks.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  ItemMetadataWidget(entity: project),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed:
                            _isSaving ? null : () => _saveProject(project),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                      ),
                      if (!project.isCompleted) ...[
                        OutlinedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () => _completeProject(project),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark Project Complete'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () => _moveProjectToSomeday(project),
                          icon: const Icon(Icons.schedule_outlined),
                          label: const Text('Move to Someday/Maybe'),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _hydrateFromProject(Project project) {
    if (_loadedProjectId == project.id) {
      return;
    }

    _loadedProjectId = project.id;
    _titleController.text = project.title;
    _outcomeController.text = project.desiredOutcome;
    _tagsController.text = project.tags.join(', ');
    _targetCompletionDate = project.targetCompletionDate;
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: _targetCompletionDate ?? now,
    );

    if (picked != null) {
      setState(() => _targetCompletionDate = picked);
    }
  }

  Future<void> _saveProject(Project project) async {
    setState(() => _isSaving = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);

    final updated = Project(
      id: project.id,
      title: _titleController.text.trim(),
      desiredOutcome: _outcomeController.text.trim(),
      createdAt: project.createdAt,
      stepIds: project.stepIds,
      projectSteps: project.projectSteps,
      currentNextActionId: project.currentNextActionId,
      targetCompletionDate: _targetCompletionDate,
      isCompleted: project.isCompleted,
      tags: tags,
      areaOfFocus: project.areaOfFocus,
      completedStepCount: project.completedStepCount,
    );

    final success =
        await ref.read(activeProjectsProvider.notifier).updateProject(updated);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      if (success) {
        _loadedProjectId = null;
      }
    });
    _showResult(success ? 'Project saved.' : 'Could not save project.');
  }

  Future<void> _completeProject(Project project) async {
    setState(() => _isSaving = true);
    final success = await ref
        .read(activeProjectsProvider.notifier)
        .completeProject(project.id);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showResult(success ? 'Project completed.' : 'Could not complete project.');
    if (success) {
      context.go('/dashboard');
    }
  }

  Future<void> _moveProjectToSomeday(Project project) async {
    setState(() => _isSaving = true);
    final success = await ref
        .read(activeProjectsProvider.notifier)
        .moveProjectToSomeday(project);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showResult(
      success
          ? 'Moved "${project.title}" to Someday/Maybe.'
          : 'Could not move project.',
    );
    if (success) {
      context.go('/someday');
    }
  }

  Future<void> _setTaskCompleted(Task task, bool isCompleted) async {
    final updated = task.copyWith(
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
      clearCompletedAt: !isCompleted,
    );
    final success =
        await ref.read(allNextActionsProvider.notifier).updateTask(updated);
    if (!mounted) {
      return;
    }

    _showResult(
      success
          ? isCompleted
              ? 'Completed "${task.title}".'
              : 'Reopened "${task.title}".'
          : isCompleted
              ? 'Could not complete task.'
              : 'Could not reopen task.',
    );
  }

  Future<void> _setTaskActive(Task task, bool isActive) async {
    final success = await ref.read(allNextActionsProvider.notifier).updateTask(
          task.copyWith(isNextAction: isActive),
        );
    if (!mounted) {
      return;
    }

    _showResult(
      success
          ? isActive
              ? 'Marked "${task.title}" active.'
              : 'Marked "${task.title}" not active.'
          : 'Could not update step status.',
    );
  }

  Future<void> _addStep(Project project) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final contexts = ref.read(contextsProvider);
    var selectedContext = contexts.firstOrNull ??
        const ZoroContext(id: 'anywhere', name: '@Anywhere');
    var errorText = '';

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Step'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Step Title',
                        errorText: errorText.isEmpty ? null : errorText,
                      ),
                      onSubmitted: (_) {
                        if (titleController.text.trim().isEmpty) {
                          setDialogState(
                            () => errorText = 'Step title is required.',
                          );
                          return;
                        }
                        Navigator.of(dialogContext).pop(true);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ZoroContext>(
                      initialValue: selectedContext,
                      decoration: const InputDecoration(labelText: 'Context'),
                      items: [
                        for (final context in contexts)
                          DropdownMenuItem(
                            value: context,
                            child: Text(context.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedContext = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Notes (optional)'),
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
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      setDialogState(
                        () => errorText = 'Step title is required.',
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('Add Step'),
                ),
              ],
            );
          },
        );
      },
    );

    final title = titleController.text.trim();
    final notes = _cleanText(notesController.text);
    titleController.dispose();
    notesController.dispose();

    if (shouldCreate != true || title.isEmpty || !mounted) {
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final taskResult = await ref.read(taskRepositoryProvider).createTask(
          Task(
            id: '',
            title: title,
            description: notes,
            context: selectedContext,
            createdAt: now,
            projectId: project.id,
            tags: project.tags,
            isNextAction: false,
          ),
        );
    final taskFailure = taskResult.match((failure) => failure, (_) => null);
    if (taskFailure != null) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showResult(taskFailure.message);
      return;
    }

    final task = taskResult.match((_) => null, (task) => task)!;
    final updatedProject = project.copyWith(
      stepIds: [...project.stepIds, task.id],
      projectSteps: [
        ...project.projectSteps,
        NextActionProjectStep(
          id: task.id,
          title: task.title,
          context: task.context,
          createdEntityId: task.id,
          notes: task.description,
          tags: task.tags,
        ),
      ],
    );
    final success =
        await ref.read(activeProjectsProvider.notifier).updateProject(
              updatedProject,
            );
    if (!mounted) {
      return;
    }

    ref
      ..invalidate(projectTasksProvider(project.id))
      ..invalidate(allTasksProvider)
      ..invalidate(allNextActionsProvider);
    setState(() => _isSaving = false);
    _showResult(success ? 'Step added.' : 'Could not add step.');
  }

  String? _cleanText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProjectStepTile extends StatelessWidget {
  const _ProjectStepTile({
    required this.task,
    required this.onCompletionChanged,
    required this.onActiveChanged,
  });

  final Task task;
  final ValueChanged<bool> onCompletionChanged;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final statusColor = task.isCompleted
        ? Theme.of(context).colorScheme.tertiary
        : task.isNextAction || task.isCalendarEvent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => onCompletionChanged(value ?? false),
      ),
      title: Text(task.title),
      subtitle: Text('${task.context.name} - ${_stepKindLabel(task)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepStatusControl(
            task: task,
            color: statusColor,
            label: _stepStatusLabel(task),
            onActiveChanged: onActiveChanged,
          ),
          IconButton(
            tooltip: 'View details',
            onPressed: () => context.push('/task/${task.id}'),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      onTap: () => context.push('/task/${task.id}'),
      onLongPress: () => showItemMetadataBottomSheet(
        context,
        entity: task,
        title: task.title,
      ),
    );
  }

  String _stepKindLabel(Task task) {
    if (task.isCalendarEvent) {
      return 'calendar event';
    }
    if (task.isNextAction) {
      return 'next action';
    }
    return 'future step';
  }

  String _stepStatusLabel(Task task) {
    if (task.isCompleted) {
      return 'Completed';
    }
    if (task.isNextAction || task.isCalendarEvent) {
      return 'Active';
    }
    return 'Not active';
  }
}

class _StepStatusControl extends StatelessWidget {
  const _StepStatusControl({
    required this.task,
    required this.color,
    required this.label,
    required this.onActiveChanged,
  });

  final Task task;
  final Color color;
  final String label;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    if (task.isCompleted || task.isCalendarEvent) {
      return StatusChip(label: label, color: color);
    }

    return ActionChip(
      tooltip: task.isNextAction ? 'Mark not active' : 'Mark active',
      avatar: Icon(
        task.isNextAction
            ? Icons.toggle_on_outlined
            : Icons.toggle_off_outlined,
        size: 18,
        color: color,
      ),
      label: Text(label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      backgroundColor: color.withValues(alpha: 0.08),
      onPressed: () => onActiveChanged(!task.isNextAction),
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
        ? 'Target Completion Date'
        : 'Target Completion Date: ${date!.month}/${date!.day}/${date!.year}';

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
