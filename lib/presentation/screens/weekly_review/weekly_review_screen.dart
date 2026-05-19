import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/ai_assist_models.dart';
import '../../../domain/entities/context.dart';
import '../../../domain/entities/inbox_item.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/project_step.dart';
import '../../../domain/entities/processing_choice.dart';
import '../../../domain/entities/recurrence.dart';
import '../../../injection_container.dart';
import '../../providers/calendar_view_providers.dart';
import '../../widgets/ai_assist_button.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  bool _isAiLoading = false;
  WeeklyReviewAiInsights? _aiInsights;
  String _selectedStepId = 'inbox';
  ProcessingChoice? _creatingChoice;

  static const _stepIds = [
    'inbox',
    'projects',
    'next-actions',
    'calendar',
    'waiting-for',
    'someday',
    'horizons',
  ];

  @override
  Widget build(BuildContext context) {
    final inboxCount = ref.watch(inboxCountProvider);
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
    final nextActions = ref.watch(allNextActionsProvider).valueOrNull ?? [];
    final someday = ref.watch(somedayMaybeProvider).valueOrNull ?? [];
    final ready = ref.watch(readyToActivateProvider);
    final waitingFor = ref.watch(waitingForProvider).valueOrNull ?? [];
    final waitingForDue = ref.watch(waitingForDueProvider);
    final reference = ref.watch(referenceProvider).valueOrNull ?? [];
    final calendarEntries = ref.watch(calendarEntriesProvider);
    final horizonsSummary = ref.watch(horizonsAlignmentProvider);
    final reviewed = ref.watch(weeklyReviewChecklistProvider);
    final completedAt = ref.watch(weeklyReviewCompletedAtProvider);
    final progress = reviewed.length / _stepIds.length;
    final allReviewed = reviewed.length == _stepIds.length;

    final steps = [
      _ReviewStep(
        id: 'inbox',
        title: 'Clear Inbox',
        detail: inboxCount == 0
            ? 'Inbox is clear.'
            : '$inboxCount capture${inboxCount == 1 ? '' : 's'} still need clarification.',
        route: '/inbox',
        actionLabel: 'Open Inbox',
        icon: Icons.inbox_outlined,
        status: inboxCount == 0 ? 'Clear' : '$inboxCount left',
      ),
      _ReviewStep(
        id: 'projects',
        title: 'Review Projects',
        detail:
            '${projects.length} active project${projects.length == 1 ? '' : 's'} need a trusted outcome and current next action.',
        route: projects.isEmpty ? '/inbox' : '/project/${projects.first.id}',
        actionLabel: projects.isEmpty ? 'Create Project' : 'Open Project',
        icon: Icons.folder_copy_outlined,
        status: '${projects.length}',
      ),
      _ReviewStep(
        id: 'next-actions',
        title: 'Review Next Actions',
        detail:
            '${nextActions.length} available next action${nextActions.length == 1 ? '' : 's'} across contexts.',
        route: '/next-actions',
        actionLabel: 'Open Actions',
        icon: Icons.check_circle_outline,
        status: '${nextActions.length}',
      ),
      _ReviewStep(
        id: 'calendar',
        title: 'Review Calendar',
        detail:
            '${calendarEntries.length} dated item${calendarEntries.length == 1 ? '' : 's'} across next actions, projects, and follow-ups.',
        route: '/calendar',
        actionLabel: 'Open Calendar',
        icon: Icons.calendar_month_outlined,
        status: '${calendarEntries.length}',
      ),
      _ReviewStep(
        id: 'waiting-for',
        title: 'Review Waiting For',
        detail:
            '${waitingFor.length} delegated item${waitingFor.length == 1 ? '' : 's'}, ${waitingForDue.length} due for follow-up.',
        route: '/waiting-for',
        actionLabel: 'Open Waiting For',
        icon: Icons.hourglass_empty_outlined,
        status: '${waitingForDue.length} due',
      ),
      _ReviewStep(
        id: 'someday',
        title: 'Review Someday/Maybe',
        detail:
            '${someday.length} total, ${ready.length} ready to activate or snooze.',
        route: '/someday',
        actionLabel: 'Open Someday',
        icon: Icons.event_available_outlined,
        status: '${ready.length} ready',
      ),
      _ReviewStep(
        id: 'horizons',
        title: 'Horizons Alignment Check',
        detail:
            '${horizonsSummary.describedCount}/${horizonsSummary.totalCount} horizons have notes, ${horizonsSummary.alignedCount}/${horizonsSummary.totalCount} are aligned.',
        route: '/horizons',
        actionLabel: 'Open Horizons',
        icon: Icons.flight_takeoff_outlined,
        status: '${horizonsSummary.alignedCount}/${horizonsSummary.totalCount}',
      ),
    ];

    final referenceStep = _ReviewStep(
      id: 'reference',
      title: 'Reference',
      detail:
          '${reference.length} reference item${reference.length == 1 ? '' : 's'} available for support material.',
      route: '/reference',
      actionLabel: 'Open Reference',
      icon: Icons.folder_outlined,
      status: '${reference.length}',
      reviewable: false,
    );
    final allSelectableSteps = [...steps, referenceStep];
    final selectedStep = allSelectableSteps.firstWhere(
      (step) => step.id == _selectedStepId,
      orElse: () => steps.first,
    );

    return ZoroAppScaffold(
      title: 'Weekly Review',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final header = _WeeklyReviewHeader(
            title: _reviewTitle(DateTime.now()),
            subtitle: completedAt == null
                ? 'Adapt your Weekly Review frequency to your activity level: daily when busy, every other day, or weekly minimum to keep your trusted system clear and current'
                : 'Last completed ${completedAt.month}/${completedAt.day}/${completedAt.year}.',
            progressLabel: '${reviewed.length}/${_stepIds.length}',
            isAiLoading: _isAiLoading,
            onAiPressed: () => _assistReview(
              inboxCount: inboxCount,
              projects: projects,
              nextActions: nextActions,
              someday: someday,
              readyToActivateCount: ready.length,
              waitingFor: waitingFor,
              waitingForDueCount: waitingForDue.length,
              calendarEntryCount: calendarEntries.length,
              horizonsAlignedCount: horizonsSummary.alignedCount,
              horizonsTotalCount: horizonsSummary.totalCount,
            ),
          );
          final checklist = _ReviewChecklistPanel(
            steps: steps,
            referenceStep: referenceStep,
            reviewed: reviewed,
            selectedStepId: selectedStep.id,
            allReviewed: allReviewed,
            expand: isWide,
            onStepSelected: (step) {
              setState(() {
                _selectedStepId = step.id;
                _creatingChoice = null;
              });
            },
            onReviewedChanged: (stepId, value) {
              ref
                  .read(weeklyReviewProgressProvider.notifier)
                  .setReviewed(stepId, reviewed: value);
            },
            onMarkComplete: allReviewed
                ? () {
                    ref
                        .read(weeklyReviewProgressProvider.notifier)
                        .markComplete(DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Weekly review marked complete.'),
                      ),
                    );
                  }
                : null,
            onReset: () {
              ref.read(weeklyReviewProgressProvider.notifier).reset();
            },
          );
          final detail = _ReviewStepDetailPanel(
            step: selectedStep,
            reviewed: reviewed.contains(selectedStep.id),
            createChoice: _creatingChoice,
            expand: isWide,
            onReviewedChanged: (value) {
              ref
                  .read(weeklyReviewProgressProvider.notifier)
                  .setReviewed(selectedStep.id, reviewed: value ?? false);
            },
            onStartCreate: (choice) {
              setState(() => _creatingChoice = choice);
            },
            onCancelCreate: () {
              setState(() => _creatingChoice = null);
            },
            onSaved: () {
              setState(() => _creatingChoice = null);
            },
          );

          if (!isWide) {
            return ListView(
              children: [
                header,
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                if (_aiInsights != null) ...[
                  _AiReviewInsightsCard(insights: _aiInsights!),
                  const SizedBox(height: 16),
                ],
                checklist,
                const SizedBox(height: 16),
                detail,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              if (_aiInsights != null) ...[
                _AiReviewInsightsCard(insights: _aiInsights!),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 360, child: checklist),
                    const SizedBox(width: 16),
                    Expanded(child: detail),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assistReview({
    required int inboxCount,
    required List<dynamic> projects,
    required List<dynamic> nextActions,
    required List<dynamic> someday,
    required int readyToActivateCount,
    required List<dynamic> waitingFor,
    required int waitingForDueCount,
    required int calendarEntryCount,
    required int horizonsAlignedCount,
    required int horizonsTotalCount,
  }) async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.aiEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable AI Assist in Settings first.')),
      );
      return;
    }

    setState(() => _isAiLoading = true);
    try {
      final insights =
          await ref.read(aiSuggestUseCaseProvider).suggestWeeklyReview(
                settings: settings,
                summary: AiWeeklyReviewSummary(
                  inboxCount: inboxCount,
                  activeProjects: projects
                      .map((project) => project.title.toString())
                      .toList(growable: false),
                  nextActions: nextActions
                      .map((task) => '${task.title} ${task.context.name}')
                      .toList(growable: false),
                  somedayItems: someday
                      .map((item) => item.title.toString())
                      .toList(growable: false),
                  readyToActivateCount: readyToActivateCount,
                  waitingForItems: waitingFor
                      .map((item) => '${item.title} waiting for ${item.person}')
                      .toList(growable: false),
                  waitingForDueCount: waitingForDueCount,
                  calendarEntryCount: calendarEntryCount,
                  horizonsAlignedCount: horizonsAlignedCount,
                  horizonsTotalCount: horizonsTotalCount,
                ),
              );
      if (!mounted) {
        return;
      }
      setState(() => _aiInsights = insights);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI review insights ready.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isAiLoading = false);
      }
    }
  }

  String _reviewTitle(DateTime date) {
    return 'Weekly Review - ${_weekdayName(date.weekday)}, ${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _WeeklyReviewHeader extends StatelessWidget {
  const _WeeklyReviewHeader({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.isAiLoading,
    required this.onAiPressed,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final bool isAiLoading;
  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) {
    return PageTitleBand(
      title: title,
      subtitle: subtitle,
      trailing: Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AiAssistButton(
            label: 'AI Assist Review',
            isLoading: isAiLoading,
            onPressed: onAiPressed,
          ),
          StatusChip(label: progressLabel),
        ],
      ),
    );
  }
}

class _ReviewChecklistPanel extends StatelessWidget {
  const _ReviewChecklistPanel({
    required this.steps,
    required this.referenceStep,
    required this.reviewed,
    required this.selectedStepId,
    required this.allReviewed,
    required this.expand,
    required this.onStepSelected,
    required this.onReviewedChanged,
    required this.onMarkComplete,
    required this.onReset,
  });

  final List<_ReviewStep> steps;
  final _ReviewStep referenceStep;
  final Set<String> reviewed;
  final String selectedStepId;
  final bool allReviewed;
  final bool expand;
  final ValueChanged<_ReviewStep> onStepSelected;
  final void Function(String stepId, bool reviewed) onReviewedChanged;
  final VoidCallback? onMarkComplete;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps) ...[
          _ReviewStepTile(
            step: step,
            selected: selectedStepId == step.id,
            reviewed: reviewed.contains(step.id),
            onTap: () => onStepSelected(step),
            onReviewedChanged: (value) {
              onReviewedChanged(step.id, value ?? false);
            },
          ),
          const SizedBox(height: 8),
        ],
        const Divider(height: 24),
        Text(
          'Direct capture',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        _ReviewStepTile(
          step: referenceStep,
          selected: selectedStepId == referenceStep.id,
          reviewed: false,
          onTap: () => onStepSelected(referenceStep),
          onReviewedChanged: null,
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onMarkComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark Review Complete'),
            ),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reset Review'),
            ),
          ],
        ),
      ],
    );

    return SectionCard(
      title: 'Review checklist',
      expandChild: expand,
      child: expand ? SingleChildScrollView(child: content) : content,
    );
  }
}

class _ReviewStepTile extends StatelessWidget {
  const _ReviewStepTile({
    required this.step,
    required this.selected,
    required this.reviewed,
    required this.onTap,
    required this.onReviewedChanged,
  });

  final _ReviewStep step;
  final bool selected;
  final bool reviewed;
  final VoidCallback onTap;
  final ValueChanged<bool?>? onReviewedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step.reviewable)
                Checkbox(value: reviewed, onChanged: onReviewedChanged)
              else
                const SizedBox(width: 48, height: 48),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(step.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                        StatusChip(label: step.status),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      step.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStepDetailPanel extends StatelessWidget {
  const _ReviewStepDetailPanel({
    required this.step,
    required this.reviewed,
    required this.createChoice,
    required this.expand,
    required this.onReviewedChanged,
    required this.onStartCreate,
    required this.onCancelCreate,
    required this.onSaved,
  });

  final _ReviewStep step;
  final bool reviewed;
  final ProcessingChoice? createChoice;
  final bool expand;
  final ValueChanged<bool?> onReviewedChanged;
  final ValueChanged<ProcessingChoice> onStartCreate;
  final VoidCallback onCancelCreate;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final choice = _captureChoiceForStep(step.id);
    return SectionCard(
      title: step.title,
      trailing: StatusChip(label: step.status),
      expandChild: expand,
      child: _ReviewDetailContent(
        scrollable: expand,
        children: [
          if (choice != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => onStartCreate(choice),
                icon: const Icon(Icons.add_outlined),
                label: Text('Add new ${_addLabel(choice)}'),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (createChoice != null) ...[
            _WeeklyReviewDirectCaptureForm(
              key: ValueKey(createChoice),
              choice: createChoice!,
              onCancel: onCancelCreate,
              onSaved: onSaved,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (step.reviewable)
                Checkbox(value: reviewed, onChanged: onReviewedChanged)
              else
                const SizedBox(width: 48),
              const SizedBox(width: 8),
              Icon(step.icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.detail),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(step.route),
                      icon: const Icon(Icons.arrow_forward_outlined),
                      label: Text(step.actionLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ProcessingChoice? _captureChoiceForStep(String stepId) {
    return switch (stepId) {
      'next-actions' => ProcessingChoice.nextAction,
      'projects' => ProcessingChoice.project,
      'calendar' => ProcessingChoice.calendarEvent,
      'waiting-for' => ProcessingChoice.waitingFor,
      'reference' => ProcessingChoice.reference,
      'someday' => ProcessingChoice.someday,
      _ => null,
    };
  }

  String _addLabel(ProcessingChoice choice) {
    return switch (choice) {
      ProcessingChoice.nextAction => 'Next Action',
      ProcessingChoice.project => 'Project',
      ProcessingChoice.calendarEvent => 'Calendar Event',
      ProcessingChoice.waitingFor => 'Waiting For',
      ProcessingChoice.someday => 'Someday/Maybe',
      ProcessingChoice.reference => 'Reference',
      _ => choice.label,
    };
  }
}

class _ReviewDetailContent extends StatelessWidget {
  const _ReviewDetailContent({
    required this.scrollable,
    required this.children,
  });

  final bool scrollable;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return ListView(children: children);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _WeeklyReviewDirectCaptureForm extends ConsumerStatefulWidget {
  const _WeeklyReviewDirectCaptureForm({
    required this.choice,
    required this.onCancel,
    required this.onSaved,
    super.key,
  });

  final ProcessingChoice choice;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  @override
  ConsumerState<_WeeklyReviewDirectCaptureForm> createState() =>
      _WeeklyReviewDirectCaptureFormState();
}

class _WeeklyReviewDirectCaptureFormState
    extends ConsumerState<_WeeklyReviewDirectCaptureForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _waitingOnController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _recurrenceIntervalController = TextEditingController(text: '1');
  final _recurrenceCountController = TextEditingController(text: '10');
  final List<_WeeklyReviewProjectStepDraft> _projectSteps = [];
  final Set<String> _somedayReasons = {};
  final Set<int> _recurrenceWeekdays = {};

  DateTime? _targetDate;
  DateTime? _targetEndDate;
  DateTime? _reconsiderDate;
  DateTime? _followUpDate;
  DateTime? _recurrenceUntilDate;
  bool _targetAllDay = false;
  String _referenceFolder = 'Articles';
  String? _waitingForProjectId;
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.none;
  _RecurrenceEndMode _recurrenceEndMode = _RecurrenceEndMode.never;
  bool _isSaving = false;
  bool _isClarifying = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, now.hour + 1);
    _targetDate =
        widget.choice == ProcessingChoice.calendarEvent ? start : null;
    _targetEndDate = _targetDate?.add(const Duration(hours: 1));
    _reconsiderDate = DateTime(now.year + 1, now.month, now.day);
    _followUpDate = now.add(const Duration(days: 7));
    _recurrenceWeekdays.add(now.weekday);
    _projectSteps.add(
      _WeeklyReviewProjectStepDraft(defaultContext: _defaultContext()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _outcomeController.dispose();
    _waitingOnController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _recurrenceIntervalController.dispose();
    _recurrenceCountController.dispose();
    for (final step in _projectSteps) {
      step.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add ${widget.choice.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  AiAssistButton(
                    label: 'AI Clarify',
                    isLoading: _isClarifying,
                    onPressed: _isClarifying ? null : _clarifyWithAi,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Cancel',
                    onPressed: _isSaving ? null : widget.onCancel,
                    icon: const Icon(Icons.close_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ..._fieldsForChoice(),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: Icon(_saveIcon(widget.choice)),
                    label: Text(_isSaving ? 'Saving...' : _saveLabel()),
                  ),
                  OutlinedButton(
                    onPressed: _isSaving ? null : widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fieldsForChoice() {
    final commonTitle = TextFormField(
      controller: _titleController,
      autofocus: true,
      decoration: InputDecoration(labelText: _titleLabel(widget.choice)),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Title is required.' : null,
    );

    return switch (widget.choice) {
      ProcessingChoice.nextAction => [
          commonTitle,
          const SizedBox(height: 14),
          const _WeeklyReviewContextChips(),
          const SizedBox(height: 14),
          _NextActionDateEditor(
            targetDate: _targetDate,
            allDay: _targetAllDay,
            onPickDate: () => _pickDateTime(
              current: _targetDate,
              onPicked: (date) => setState(() => _targetDate = date),
            ),
            onPickTime: () => _pickTime(
              current: _targetDate,
              onPicked: (date) => setState(() => _targetDate = date),
            ),
            onAllDayChanged: (value) {
              setState(() {
                _targetAllDay = value;
                if (value && _targetDate != null) {
                  _targetDate = DateTime(
                    _targetDate!.year,
                    _targetDate!.month,
                    _targetDate!.day,
                  );
                }
              });
            },
          ),
          const SizedBox(height: 14),
          _notesField(),
        ],
      ProcessingChoice.calendarEvent => [
          commonTitle,
          const SizedBox(height: 14),
          const _WeeklyReviewContextChips(),
          const SizedBox(height: 14),
          _DateTimeEditor(
            title: 'Schedule',
            start: _targetDate,
            end: _targetEndDate,
            allDay: _targetAllDay,
            onPickDate: () => _pickDateTime(
              current: _targetDate,
              onPicked: (date) => setState(() {
                _targetDate = date;
                _targetEndDate ??= date.add(const Duration(hours: 1));
              }),
            ),
            onPickStartTime: () => _pickTime(
              current: _targetDate,
              onPicked: (date) => setState(() {
                _targetDate = date;
                if (_targetEndDate == null || !_targetEndDate!.isAfter(date)) {
                  _targetEndDate = date.add(const Duration(hours: 1));
                }
              }),
            ),
            onPickEndTime: () => _pickTime(
              current: _targetEndDate ?? _targetDate,
              onPicked: (date) => setState(() => _targetEndDate = date),
            ),
            onAllDayChanged: (value) {
              setState(() {
                _targetAllDay = value;
                if (value && _targetDate != null) {
                  _targetDate = DateTime(
                    _targetDate!.year,
                    _targetDate!.month,
                    _targetDate!.day,
                  );
                  _targetEndDate = null;
                }
              });
            },
          ),
          const SizedBox(height: 14),
          _RecurrenceEditor(
            frequency: _recurrenceFrequency,
            weekdays: _recurrenceWeekdays,
            endMode: _recurrenceEndMode,
            untilDate: _recurrenceUntilDate,
            intervalController: _recurrenceIntervalController,
            countController: _recurrenceCountController,
            onFrequencyChanged: (frequency) {
              setState(() => _recurrenceFrequency = frequency);
            },
            onWeekdayChanged: (weekday, selected) {
              setState(() {
                if (selected) {
                  _recurrenceWeekdays.add(weekday);
                } else {
                  _recurrenceWeekdays.remove(weekday);
                }
              });
            },
            onEndModeChanged: (mode) {
              setState(() => _recurrenceEndMode = mode);
            },
            onPickUntilDate: () => _pickDateOnly(
              current: _recurrenceUntilDate,
              fallback: DateTime.now().add(const Duration(days: 90)),
              onPicked: (date) => setState(() => _recurrenceUntilDate = date),
            ),
          ),
          const SizedBox(height: 14),
          _notesField(),
          const SizedBox(height: 14),
          _tagsField(),
        ],
      ProcessingChoice.project => [
          commonTitle,
          const SizedBox(height: 14),
          TextFormField(
            controller: _outcomeController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Desired Outcome'),
          ),
          const SizedBox(height: 14),
          _notesField(),
          const SizedBox(height: 14),
          _ProjectStepsEditor(
            steps: _projectSteps,
            onAddStep: _addProjectStep,
            onRemoveStep: _removeProjectStep,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 14),
          _tagsField(),
        ],
      ProcessingChoice.waitingFor => [
          commonTitle,
          const SizedBox(height: 14),
          TextFormField(
            controller: _waitingOnController,
            decoration: const InputDecoration(labelText: 'Person or team'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Person or team is required.'
                : null,
          ),
          const SizedBox(height: 14),
          _ProjectPicker(
            projectId: _waitingForProjectId,
            onChanged: (value) => setState(() => _waitingForProjectId = value),
          ),
          const SizedBox(height: 14),
          _DateButton(
            label: 'Follow-up Date',
            date: _followUpDate,
            icon: Icons.event_outlined,
            onPressed: () => _pickDateOnly(
              current: _followUpDate,
              fallback: DateTime.now().add(const Duration(days: 7)),
              onPicked: (date) => setState(() => _followUpDate = date),
            ),
          ),
          const SizedBox(height: 14),
          _notesField(),
          const SizedBox(height: 14),
          _tagsField(),
        ],
      ProcessingChoice.reference => [
          commonTitle,
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _referenceFolder,
            decoration: const InputDecoration(labelText: 'Folder'),
            items: const [
              DropdownMenuItem(value: 'Articles', child: Text('Articles')),
              DropdownMenuItem(value: 'Notes', child: Text('Notes')),
              DropdownMenuItem(value: 'Ideas', child: Text('Ideas')),
              DropdownMenuItem(value: 'Links', child: Text('Links')),
              DropdownMenuItem(value: 'Documents', child: Text('Documents')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _referenceFolder = value);
              }
            },
          ),
          const SizedBox(height: 14),
          _notesField(minLines: 4),
          const SizedBox(height: 14),
          _tagsField(),
        ],
      ProcessingChoice.someday => [
          commonTitle,
          const SizedBox(height: 14),
          _DateButton(
            label: 'Reconsider Date',
            date: _reconsiderDate,
            icon: Icons.event_available_outlined,
            onPressed: () => _pickDateOnly(
              current: _reconsiderDate,
              fallback: DateTime(DateTime.now().year + 1),
              onPicked: (date) => setState(() => _reconsiderDate = date),
            ),
          ),
          const SizedBox(height: 14),
          _SomedayReasonChips(
            selectedReasons: _somedayReasons,
            onChanged: (reason, selected) {
              setState(() {
                if (selected) {
                  _somedayReasons.add(reason);
                } else {
                  _somedayReasons.remove(reason);
                }
              });
            },
          ),
          const SizedBox(height: 14),
          _notesField(),
          const SizedBox(height: 14),
          _tagsField(),
        ],
      _ => [
          commonTitle,
          const SizedBox(height: 14),
          _notesField(),
        ],
    };
  }

  Widget _notesField({int minLines = 3}) {
    return TextFormField(
      controller: _notesController,
      minLines: minLines,
      maxLines: 6,
      decoration: const InputDecoration(labelText: 'Notes'),
    );
  }

  Widget _tagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(labelText: 'Tags, comma separated'),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final validationError = _validateChoice();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    setState(() => _isSaving = true);
    final title = _titleController.text.trim();
    final notes = _cleanText(_notesController.text);
    final tags = _tags();
    final createdResult = await ref.read(inboxRepositoryProvider).addInboxItem(
          InboxItem(
            id: '',
            title: title,
            notes: notes,
            capturedAt: DateTime.now(),
          ),
        );

    final createdFailure =
        createdResult.match((failure) => failure, (_) => null);
    if (createdFailure != null) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showMessage(createdFailure.message);
      }
      return;
    }
    final created = createdResult.getRight().toNullable()!;

    final result = await ref.read(processInboxItemUseCaseProvider)(
      inboxItemId: created.id,
      choice: widget.choice,
      title: title,
      desiredOutcome: _cleanText(_outcomeController.text),
      context: _selectedContext(),
      targetDate: _targetDate,
      endDateTime: widget.choice == ProcessingChoice.calendarEvent
          ? _targetEndDate
          : null,
      notes: notes,
      reconsiderDate: _reconsiderDate,
      referenceFolder:
          widget.choice == ProcessingChoice.reference ? _referenceFolder : null,
      waitingOn: _waitingOnController.text,
      waitingForProjectId: _waitingForProjectId,
      followUpDate: _followUpDate,
      recurrence: widget.choice == ProcessingChoice.calendarEvent
          ? _buildRecurrence()
          : null,
      tags: tags,
      stepTitles: widget.choice == ProcessingChoice.project
          ? _buildFutureStepTitles()
          : const [],
      projectSteps: widget.choice == ProcessingChoice.project
          ? _buildProjectSteps(tags)
          : const [],
    );

    final failure = result.match((failure) => failure, (_) => null);
    if (failure != null) {
      await ref.read(inboxRepositoryProvider).deleteInboxItem(created.id);
      if (mounted) {
        setState(() => _isSaving = false);
        _showMessage(failure.message);
      }
      return;
    }

    _refreshReviewProviders();
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showMessage('${widget.choice.label} added.');
    widget.onSaved();
  }

  String? _validateChoice() {
    if (widget.choice == ProcessingChoice.calendarEvent &&
        _targetDate == null) {
      return 'Calendar event start is required.';
    }
    if (widget.choice == ProcessingChoice.project) {
      final activeSteps = _projectSteps
          .where((step) => step.titleController.text.trim().isNotEmpty)
          .toList(growable: false);
      if (activeSteps.isEmpty) {
        return 'Create at least one project action.';
      }
      for (final step in activeSteps) {
        if (step.kind == ProjectStepKind.calendarEvent &&
            step.targetDate == null) {
          return 'Calendar project steps need a start date.';
        }
        if (step.kind == ProjectStepKind.waitingFor &&
            step.waitingOnController.text.trim().isEmpty) {
          return 'Waiting For project steps need a person or team.';
        }
      }
    }
    return null;
  }

  Future<void> _clarifyWithAi() async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.aiEnabled) {
      _showMessage('Enable AI clarification in Settings first.');
      return;
    }

    setState(() => _isClarifying = true);
    try {
      final contexts = ref.read(contextsProvider);
      final suggestion =
          await ref.read(aiSuggestUseCaseProvider).suggestInboxProcessing(
                item: InboxItem(
                  id: 'weekly-review-direct-capture',
                  title: _titleController.text.trim().isEmpty
                      ? 'New ${widget.choice.label}'
                      : _titleController.text.trim(),
                  notes: _cleanText(_notesController.text),
                  capturedAt: DateTime.now(),
                ),
                currentChoice: widget.choice,
                contexts: contexts,
                settings: settings,
              );

      if (!mounted) {
        return;
      }

      final matchedContext =
          _matchContextName(contexts, suggestion.contextName);
      if (matchedContext != null) {
        ref.read(selectedContextProvider.notifier).state = matchedContext;
      }

      setState(() {
        _titleController.text = suggestion.title;
        _outcomeController.text =
            suggestion.desiredOutcome ?? _outcomeController.text;
        _notesController.text = suggestion.notes ?? _notesController.text;
        _tagsController.text = suggestion.tags.join(', ');
        _targetDate = suggestion.targetDate ?? _targetDate;
        _targetEndDate = suggestion.targetDate?.add(
              const Duration(minutes: 30),
            ) ??
            _targetEndDate;
        _reconsiderDate = suggestion.reconsiderDate ?? _reconsiderDate;

        if (widget.choice == ProcessingChoice.project &&
            suggestion.steps.isNotEmpty) {
          for (final step in _projectSteps) {
            step.dispose();
          }
          _projectSteps
            ..clear()
            ..addAll(
              suggestion.steps.map(
                (title) => _WeeklyReviewProjectStepDraft(
                  defaultContext: _defaultContext(),
                  title: title,
                ),
              ),
            );
        }
      });

      _showMessage('AI suggestions applied - edit as needed.');
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isClarifying = false);
      }
    }
  }

  void _refreshReviewProviders() {
    ref
      ..invalidate(inboxItemsProvider)
      ..invalidate(allNextActionsProvider)
      ..invalidate(allTasksProvider)
      ..invalidate(activeProjectsProvider)
      ..invalidate(allProjectsProvider)
      ..invalidate(somedayMaybeProvider)
      ..invalidate(readyToActivateProvider)
      ..invalidate(referenceProvider)
      ..invalidate(waitingForProvider)
      ..invalidate(allWaitingForProvider)
      ..invalidate(waitingForDueProvider)
      ..invalidate(calendarEntriesProvider)
      ..invalidate(visibleCalendarEntriesProvider)
      ..invalidate(calendarAgendaEntriesProvider)
      ..invalidate(availableCalendarContextsProvider);
    ref.read(historyRefreshSignalProvider.notifier).state++;
  }

  void _addProjectStep() {
    setState(() {
      _projectSteps.add(
        _WeeklyReviewProjectStepDraft(defaultContext: _defaultContext()),
      );
    });
  }

  void _removeProjectStep(int index) {
    setState(() {
      if (_projectSteps.length == 1) {
        _projectSteps.single.reset(defaultContext: _defaultContext());
        return;
      }
      _projectSteps.removeAt(index).dispose();
    });
  }

  List<ProjectStep> _buildProjectSteps(List<String> tags) {
    final steps = <ProjectStep>[];
    for (var index = 0; index < _projectSteps.length; index++) {
      final draft = _projectSteps[index];
      final title = draft.titleController.text.trim();
      if (title.isEmpty) {
        continue;
      }
      final kind = draft.kind;
      if (kind == null) {
        continue;
      }
      final id = 'weekly-review-step-${index + 1}';
      switch (kind) {
        case ProjectStepKind.nextAction:
          steps.add(
            NextActionProjectStep(
              id: id,
              title: title,
              context: draft.context,
              targetDate: draft.targetDate,
              allDay: draft.allDay,
              notes: _cleanText(draft.notesController.text),
              tags: tags,
            ),
          );
        case ProjectStepKind.calendarEvent:
          steps.add(
            CalendarEventProjectStep(
              id: id,
              title: title,
              context: draft.context,
              targetDate: draft.targetDate!,
              endDateTime: draft.endDateTime,
              allDay: draft.allDay,
              recurrence: draft.buildRecurrence(),
              notes: _cleanText(draft.notesController.text),
              tags: tags,
            ),
          );
        case ProjectStepKind.waitingFor:
          steps.add(
            WaitingForProjectStep(
              id: id,
              title: title,
              person: draft.waitingOnController.text.trim(),
              followUpDate: draft.followUpDate,
              notes: _cleanText(draft.notesController.text),
              tags: tags,
            ),
          );
      }
    }
    return steps;
  }

  List<String> _buildFutureStepTitles() {
    return _projectSteps
        .where((step) =>
            step.kind == null && step.titleController.text.trim().isNotEmpty)
        .map((step) => step.titleController.text.trim())
        .toList(growable: false);
  }

  Recurrence? _buildRecurrence() {
    if (_recurrenceFrequency == RecurrenceFrequency.none) {
      return null;
    }
    return Recurrence(
      frequency: _recurrenceFrequency,
      interval: int.tryParse(_recurrenceIntervalController.text.trim()) ?? 1,
      weekdays: (_recurrenceFrequency == RecurrenceFrequency.weekly ||
              _recurrenceFrequency == RecurrenceFrequency.biweekly)
          ? (_recurrenceWeekdays.toList()..sort())
          : const [],
      count: _recurrenceEndMode == _RecurrenceEndMode.afterCount
          ? int.tryParse(_recurrenceCountController.text.trim())
          : null,
      until: _recurrenceEndMode == _RecurrenceEndMode.onDate
          ? _recurrenceUntilDate
          : null,
    );
  }

  List<String> _tags() {
    final typedTags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty);
    return {
      ...typedTags,
      if (widget.choice == ProcessingChoice.someday)
        ..._somedayReasons.map(_tagFromReason),
    }.toList(growable: false);
  }

  ZoroContext _selectedContext() {
    final name = ref.read(selectedContextProvider);
    return ZoroContext(
      id: name.replaceAll('@', '').toLowerCase(),
      name: name,
    );
  }

  ZoroContext _defaultContext() {
    final name = ref.read(appSettingsProvider).defaultContextName;
    return ZoroContext(
      id: name.replaceAll('@', '').toLowerCase(),
      name: name,
    );
  }

  String? _matchContextName(List<ZoroContext> contexts, String? contextName) {
    if (contextName == null) {
      return null;
    }
    final normalized = contextName.trim().toLowerCase();
    for (final context in contexts) {
      if (context.name.toLowerCase() == normalized) {
        return context.name;
      }
    }
    return null;
  }

  Future<void> _pickDateOnly({
    required DateTime? current,
    required DateTime fallback,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: current ?? fallback,
    );
    if (picked != null) {
      onPicked(DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickDateTime({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final base = current ?? DateTime.now().add(const Duration(hours: 1));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: base,
    );
    if (picked != null) {
      onPicked(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          base.hour,
          base.minute,
        ),
      );
    }
  }

  Future<void> _pickTime({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final base = current ?? DateTime.now().add(const Duration(hours: 1));
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked != null) {
      onPicked(
        DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _titleLabel(ProcessingChoice choice) {
    return switch (choice) {
      ProcessingChoice.nextAction => 'Next Action Title',
      ProcessingChoice.project => 'Project Title',
      ProcessingChoice.calendarEvent => 'Calendar Event Title',
      ProcessingChoice.waitingFor => 'What are you waiting for?',
      ProcessingChoice.reference => 'Reference Title',
      ProcessingChoice.someday => 'Someday/Maybe Title',
      _ => 'Title',
    };
  }

  IconData _saveIcon(ProcessingChoice choice) {
    return switch (choice) {
      ProcessingChoice.nextAction => Icons.save_outlined,
      ProcessingChoice.project => Icons.add_task_outlined,
      ProcessingChoice.calendarEvent => Icons.event_repeat_outlined,
      ProcessingChoice.waitingFor => Icons.hourglass_empty_outlined,
      ProcessingChoice.reference => Icons.folder_outlined,
      ProcessingChoice.someday => Icons.event_available_outlined,
      _ => Icons.add_outlined,
    };
  }

  String _saveLabel() {
    return switch (widget.choice) {
      ProcessingChoice.nextAction => 'Save as Next Action',
      ProcessingChoice.project => 'Create Project & Next Action',
      ProcessingChoice.calendarEvent => 'Save as Calendar Event',
      ProcessingChoice.waitingFor => 'Save Waiting For',
      ProcessingChoice.reference => 'Save Reference',
      ProcessingChoice.someday => 'Save Someday/Maybe',
      _ => 'Save',
    };
  }
}

class _WeeklyReviewContextChips extends ConsumerWidget {
  const _WeeklyReviewContextChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider);
    final selected = ref.watch(selectedContextProvider);
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final context in contexts)
            FilterChip(
              selected: selected == context.name,
              label: Text(context.name),
              onSelected: (_) {
                ref.read(selectedContextProvider.notifier).state = context.name;
              },
            ),
        ],
      ),
    );
  }
}

class _ProjectPicker extends ConsumerWidget {
  const _ProjectPicker({
    required this.projectId,
    required this.onChanged,
  });

  final String? projectId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects =
        ref.watch(activeProjectsProvider).valueOrNull ?? const <Project>[];
    return DropdownButtonFormField<String?>(
      initialValue: projectId,
      decoration: const InputDecoration(labelText: 'Related Project'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No project'),
        ),
        for (final project in projects)
          DropdownMenuItem<String?>(
            value: project.id,
            child: Text(project.title),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateTimeEditor extends StatelessWidget {
  const _DateTimeEditor({
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onAllDayChanged,
  });

  final String title;
  final DateTime? start;
  final DateTime? end;
  final bool allDay;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final ValueChanged<bool> onAllDayChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _DateButton(
                  label: 'Date',
                  date: start,
                  icon: Icons.event_outlined,
                  onPressed: onPickDate,
                ),
                if (!allDay)
                  OutlinedButton.icon(
                    onPressed: onPickStartTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(start == null
                        ? 'Start Time'
                        : _formatTime(TimeOfDay.fromDateTime(start!))),
                  ),
                if (!allDay)
                  OutlinedButton.icon(
                    onPressed: onPickEndTime,
                    icon: const Icon(Icons.timelapse_outlined),
                    label: Text(end == null
                        ? 'End Time'
                        : _formatTime(TimeOfDay.fromDateTime(end!))),
                  ),
                FilterChip(
                  selected: allDay,
                  label: const Text('All day'),
                  onSelected: onAllDayChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextActionDateEditor extends StatelessWidget {
  const _NextActionDateEditor({
    required this.targetDate,
    required this.allDay,
    required this.onPickDate,
    required this.onPickTime,
    required this.onAllDayChanged,
  });

  final DateTime? targetDate;
  final bool allDay;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<bool> onAllDayChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = targetDate;
    final hasTime = date != null &&
        !allDay &&
        (date.hour != 0 || date.minute != 0 || date.second != 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _DateButton(
                  label: 'Target date - optional',
                  date: date,
                  icon: Icons.calendar_today_outlined,
                  onPressed: onPickDate,
                ),
                OutlinedButton.icon(
                  onPressed: allDay ? null : onPickTime,
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(
                    allDay
                        ? '--'
                        : hasTime
                            ? _formatTime(TimeOfDay.fromDateTime(date))
                            : 'Time - optional',
                  ),
                ),
                FilterChip(
                  selected: allDay,
                  label: const Text('All day'),
                  onSelected: onAllDayChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '(Will appear in Calendar view)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(date == null ? label : '$label: ${_formatDate(date!)}'),
    );
  }
}

class _RecurrenceEditor extends StatelessWidget {
  const _RecurrenceEditor({
    required this.frequency,
    required this.weekdays,
    required this.endMode,
    required this.untilDate,
    required this.intervalController,
    required this.countController,
    required this.onFrequencyChanged,
    required this.onWeekdayChanged,
    required this.onEndModeChanged,
    required this.onPickUntilDate,
  });

  final RecurrenceFrequency frequency;
  final Set<int> weekdays;
  final _RecurrenceEndMode endMode;
  final DateTime? untilDate;
  final TextEditingController intervalController;
  final TextEditingController countController;
  final ValueChanged<RecurrenceFrequency> onFrequencyChanged;
  final void Function(int weekday, bool selected) onWeekdayChanged;
  final ValueChanged<_RecurrenceEndMode> onEndModeChanged;
  final VoidCallback onPickUntilDate;

  @override
  Widget build(BuildContext context) {
    final showWeekdays = frequency == RecurrenceFrequency.weekly ||
        frequency == RecurrenceFrequency.biweekly;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.repeat_outlined),
        title: const Text('Recurrence'),
        subtitle: Text(_frequencyLabel(frequency)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          DropdownButtonFormField<RecurrenceFrequency>(
            initialValue: frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: [
              for (final option in RecurrenceFrequency.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(_frequencyLabel(option)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onFrequencyChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: intervalController,
            enabled: frequency != RecurrenceFrequency.none,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Every N',
              prefixText: 'Every ',
            ),
          ),
          if (showWeekdays) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final day in _weekdayLabels.entries)
                    FilterChip(
                      selected: weekdays.contains(day.key),
                      label: Text(day.value),
                      onSelected: (selected) =>
                          onWeekdayChanged(day.key, selected),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SegmentedButton<_RecurrenceEndMode>(
            segments: const [
              ButtonSegment(
                value: _RecurrenceEndMode.never,
                label: Text('Never'),
              ),
              ButtonSegment(
                value: _RecurrenceEndMode.afterCount,
                label: Text('After N'),
              ),
              ButtonSegment(
                value: _RecurrenceEndMode.onDate,
                label: Text('On date'),
              ),
            ],
            selected: {endMode},
            showSelectedIcon: false,
            onSelectionChanged: frequency == RecurrenceFrequency.none
                ? null
                : (selection) => onEndModeChanged(selection.single),
          ),
          if (endMode == _RecurrenceEndMode.afterCount) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Occurrences'),
            ),
          ],
          if (endMode == _RecurrenceEndMode.onDate) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _DateButton(
                label: 'Ends On',
                date: untilDate,
                icon: Icons.event_outlined,
                onPressed: onPickUntilDate,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _frequencyLabel(RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.none => 'None',
      RecurrenceFrequency.daily => 'Daily',
      RecurrenceFrequency.weekly => 'Weekly',
      RecurrenceFrequency.biweekly => 'Bi-weekly',
      RecurrenceFrequency.monthly => 'Monthly',
      RecurrenceFrequency.yearly => 'Yearly',
    };
  }
}

class _ProjectStepsEditor extends StatelessWidget {
  const _ProjectStepsEditor({
    required this.steps,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.onChanged,
  });

  final List<_WeeklyReviewProjectStepDraft> steps;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Future Steps',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddStep,
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('Add step'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < steps.length; index++) ...[
              _ProjectStepEditor(
                index: index,
                draft: steps[index],
                onRemove: () => onRemoveStep(index),
                onChanged: onChanged,
              ),
              if (index < steps.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectStepEditor extends ConsumerWidget {
  const _ProjectStepEditor({
    required this.index,
    required this.draft,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _WeeklyReviewProjectStepDraft draft;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text('Step ${index + 1}'),
        trailing: IconButton(
          tooltip: 'Remove step',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          TextFormField(
            controller: draft.titleController,
            decoration: const InputDecoration(labelText: 'Step Title'),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: draft.kind?.name ?? 'future',
            decoration: const InputDecoration(labelText: 'Step Type'),
            items: const [
              DropdownMenuItem(
                value: 'future',
                child: Text('Future Step'),
              ),
              DropdownMenuItem(
                value: 'nextAction',
                child: Text('Next Action'),
              ),
              DropdownMenuItem(
                value: 'calendarEvent',
                child: Text('Calendar Event'),
              ),
              DropdownMenuItem(
                value: 'waitingFor',
                child: Text('Waiting For'),
              ),
            ],
            onChanged: (value) {
              draft.kind = switch (value) {
                'nextAction' => ProjectStepKind.nextAction,
                'calendarEvent' => ProjectStepKind.calendarEvent,
                'waitingFor' => ProjectStepKind.waitingFor,
                _ => null,
              };
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          if (draft.kind == ProjectStepKind.nextAction ||
              draft.kind == ProjectStepKind.calendarEvent) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final context in contexts)
                    FilterChip(
                      selected: draft.context.name == context.name,
                      label: Text(context.name),
                      onSelected: (_) {
                        draft.context = context;
                        onChanged();
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DateTimeEditor(
              title: draft.kind == ProjectStepKind.calendarEvent
                  ? 'Schedule'
                  : 'Target Date',
              start: draft.targetDate,
              end: draft.endDateTime,
              allDay: draft.allDay,
              onPickDate: () async {
                final picked = await _pickDateForProjectStep(
                  context,
                  draft.targetDate,
                );
                if (picked != null) {
                  draft.targetDate = picked;
                  draft.endDateTime ??= picked.add(const Duration(hours: 1));
                  onChanged();
                }
              },
              onPickStartTime: () async {
                final picked = await _pickTimeForProjectStep(
                  context,
                  draft.targetDate,
                );
                if (picked != null) {
                  draft.targetDate = picked;
                  if (draft.endDateTime == null ||
                      !draft.endDateTime!.isAfter(picked)) {
                    draft.endDateTime = picked.add(const Duration(hours: 1));
                  }
                  onChanged();
                }
              },
              onPickEndTime: () async {
                final picked = await _pickTimeForProjectStep(
                  context,
                  draft.endDateTime ?? draft.targetDate,
                );
                if (picked != null) {
                  draft.endDateTime = picked;
                  onChanged();
                }
              },
              onAllDayChanged: (value) {
                draft.allDay = value;
                if (value && draft.targetDate != null) {
                  draft.targetDate = DateTime(
                    draft.targetDate!.year,
                    draft.targetDate!.month,
                    draft.targetDate!.day,
                  );
                  draft.endDateTime = null;
                }
                onChanged();
              },
            ),
          ],
          if (draft.kind == ProjectStepKind.calendarEvent) ...[
            const SizedBox(height: 12),
            _RecurrenceEditor(
              frequency: draft.frequency,
              weekdays: draft.weekdays,
              endMode: draft.endMode,
              untilDate: draft.untilDate,
              intervalController: draft.intervalController,
              countController: draft.countController,
              onFrequencyChanged: (frequency) {
                draft.frequency = frequency;
                onChanged();
              },
              onWeekdayChanged: (weekday, selected) {
                if (selected) {
                  draft.weekdays.add(weekday);
                } else {
                  draft.weekdays.remove(weekday);
                }
                onChanged();
              },
              onEndModeChanged: (mode) {
                draft.endMode = mode;
                onChanged();
              },
              onPickUntilDate: () async {
                final picked = await _pickDateForProjectStep(
                  context,
                  draft.untilDate ??
                      DateTime.now().add(
                        const Duration(days: 90),
                      ),
                );
                if (picked != null) {
                  draft.untilDate = picked;
                  onChanged();
                }
              },
            ),
          ],
          if (draft.kind == ProjectStepKind.waitingFor) ...[
            TextFormField(
              controller: draft.waitingOnController,
              decoration: const InputDecoration(labelText: 'Person or team'),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _DateButton(
                label: 'Follow-up Date',
                date: draft.followUpDate,
                icon: Icons.event_outlined,
                onPressed: () async {
                  final picked = await _pickDateForProjectStep(
                    context,
                    draft.followUpDate ??
                        DateTime.now().add(
                          const Duration(days: 7),
                        ),
                  );
                  if (picked != null) {
                    draft.followUpDate = picked;
                    onChanged();
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: draft.notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateForProjectStep(
    BuildContext context,
    DateTime? current,
  ) async {
    final base = current ?? DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: base,
    );
    if (picked == null) {
      return null;
    }
    return DateTime(
      picked.year,
      picked.month,
      picked.day,
      base.hour,
      base.minute,
    );
  }

  Future<DateTime?> _pickTimeForProjectStep(
    BuildContext context,
    DateTime? current,
  ) async {
    final base = current ?? DateTime.now().add(const Duration(hours: 1));
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null) {
      return null;
    }
    return DateTime(
      base.year,
      base.month,
      base.day,
      picked.hour,
      picked.minute,
    );
  }
}

class _SomedayReasonChips extends StatelessWidget {
  const _SomedayReasonChips({
    required this.selectedReasons,
    required this.onChanged,
  });

  final Set<String> selectedReasons;
  final void Function(String reason, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    const reasons = [
      'Not now',
      'Maybe later',
      'Needs more clarity',
      'Waiting for capacity',
    ];
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final reason in reasons)
            FilterChip(
              selected: selectedReasons.contains(reason),
              label: Text(reason),
              onSelected: (selected) => onChanged(reason, selected),
            ),
        ],
      ),
    );
  }
}

class _WeeklyReviewProjectStepDraft {
  _WeeklyReviewProjectStepDraft({
    required ZoroContext defaultContext,
    String? title,
  })  : context = defaultContext,
        titleController = TextEditingController(text: title),
        weekdays = {DateTime.now().weekday};

  final TextEditingController titleController;
  final TextEditingController waitingOnController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController intervalController =
      TextEditingController(text: '1');
  final TextEditingController countController =
      TextEditingController(text: '10');
  final Set<int> weekdays;

  ProjectStepKind? kind;
  ZoroContext context;
  DateTime? targetDate;
  DateTime? endDateTime;
  DateTime? followUpDate;
  DateTime? untilDate;
  bool allDay = false;
  RecurrenceFrequency frequency = RecurrenceFrequency.none;
  _RecurrenceEndMode endMode = _RecurrenceEndMode.never;

  void reset({required ZoroContext defaultContext}) {
    titleController.clear();
    waitingOnController.clear();
    notesController.clear();
    intervalController.text = '1';
    countController.text = '10';
    weekdays
      ..clear()
      ..add(DateTime.now().weekday);
    kind = null;
    context = defaultContext;
    targetDate = null;
    endDateTime = null;
    followUpDate = null;
    untilDate = null;
    allDay = false;
    frequency = RecurrenceFrequency.none;
    endMode = _RecurrenceEndMode.never;
  }

  Recurrence? buildRecurrence() {
    if (frequency == RecurrenceFrequency.none) {
      return null;
    }
    return Recurrence(
      frequency: frequency,
      interval: int.tryParse(intervalController.text.trim()) ?? 1,
      weekdays: (frequency == RecurrenceFrequency.weekly ||
              frequency == RecurrenceFrequency.biweekly)
          ? (weekdays.toList()..sort())
          : const [],
      count: endMode == _RecurrenceEndMode.afterCount
          ? int.tryParse(countController.text.trim())
          : null,
      until: endMode == _RecurrenceEndMode.onDate ? untilDate : null,
    );
  }

  void dispose() {
    titleController.dispose();
    waitingOnController.dispose();
    notesController.dispose();
    intervalController.dispose();
    countController.dispose();
  }
}

enum _RecurrenceEndMode { never, afterCount, onDate }

const _weekdayLabels = {
  DateTime.monday: 'Mon',
  DateTime.tuesday: 'Tue',
  DateTime.wednesday: 'Wed',
  DateTime.thursday: 'Thu',
  DateTime.friday: 'Fri',
  DateTime.saturday: 'Sat',
  DateTime.sunday: 'Sun',
};

class _AiReviewInsightsCard extends StatelessWidget {
  const _AiReviewInsightsCard({required this.insights});

  final WeeklyReviewAiInsights insights;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'AI Review Insights',
      trailing: StatusChip(label: '${insights.readyToActivateCount} ready'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightSection(
            title: 'Priority actions',
            items: insights.priorityActions,
          ),
          _InsightSection(
            title: 'Stalled projects',
            items: insights.stalledProjects,
          ),
          _InsightSection(
            title: 'Horizons alignment',
            items: insights.horizonsAlignmentTips,
          ),
          _InsightSection(
            title: 'Suggested focus areas',
            items: insights.suggestedFocusAreas,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/inbox'),
                icon: const Icon(Icons.inbox_outlined),
                label: const Text('Open Inbox'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/projects'),
                icon: const Icon(Icons.folder_copy_outlined),
                label: const Text('Open Projects'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/someday'),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Open Someday'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewStep {
  const _ReviewStep({
    required this.id,
    required this.title,
    required this.detail,
    required this.route,
    required this.actionLabel,
    required this.icon,
    required this.status,
    this.reviewable = true,
  });

  final String id;
  final String title;
  final String detail;
  final String route;
  final String actionLabel;
  final IconData icon;
  final String status;
  final bool reviewable;
}

String? _cleanText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _tagFromReason(String reason) {
  return reason
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
