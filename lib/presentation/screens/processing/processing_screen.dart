import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/context.dart';
import '../../../domain/entities/inbox_item.dart';
import '../../../domain/entities/project_step.dart';
import '../../../domain/entities/processing_choice.dart';
import '../../../domain/entities/recurrence.dart';
import '../../../injection_container.dart';
import '../../providers/calendar_view_providers.dart';
import '../../providers/next_action_view_providers.dart';
import '../../providers/processing_form_provider.dart';
import '../../widgets/ai_assist_button.dart';
import '../../widgets/section_card.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final _titleController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _nextActionController = TextEditingController();
  final _waitingOnController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  final List<_ProjectStepDraft> _projectStepDrafts = [];

  DateTime? _targetDate;
  DateTime? _targetEndDate;
  DateTime? _reconsiderDate;
  DateTime? _followUpDate;
  DateTime? _recurrenceUntilDate;
  bool _targetAllDay = false;
  bool _nextActionTimeSet = false;
  String _referenceFolder = 'Articles';
  String? _waitingForProjectId;
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.none;
  final Set<int> _recurrenceWeekdays = {};
  final _recurrenceIntervalController = TextEditingController(text: '1');
  final _recurrenceCountController = TextEditingController(text: '10');
  _RecurrenceEndMode _recurrenceEndMode = _RecurrenceEndMode.never;
  String? _loadedItemId;
  bool _isSaving = false;
  bool _isClarifying = false;
  final Set<String> _somedayReasons = {};
  final Set<int> _expandedProjectNextActions = {};

  @override
  void dispose() {
    _titleController.dispose();
    _outcomeController.dispose();
    _nextActionController.dispose();
    _waitingOnController.dispose();
    _recurrenceIntervalController.dispose();
    _recurrenceCountController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    for (final draft in _projectStepDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsValue = ref.watch(inboxItemsProvider);

    return itemsValue.when(
      loading: () => const ZoroAppScaffold(
        title: 'Processing',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ZoroAppScaffold(
        title: 'Processing',
        child: SectionCard(title: 'Inbox item', child: Text(error.toString())),
      ),
      data: (items) {
        final item =
            items.where((entry) => entry.id == widget.itemId).firstOrNull;
        if (item == null) {
          return const ZoroAppScaffold(
            title: 'Processing',
            child: SectionCard(
              title: 'Inbox item',
              child: Text('This inbox item has already been processed.'),
            ),
          );
        }

        _hydrateFromItem(item);
        final choice = ref.watch(currentProcessingChoiceProvider);

        return ZoroAppScaffold(
          title: 'Processing: ${item.title}',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AiAssistButton(
                label: 'AI Clarify',
                isLoading: _isClarifying,
                onPressed: _isClarifying ? null : () => _clarifyWithAi(item),
              ),
            ),
          ],
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final picker = _ProcessingChoiceRail(choice: choice);
              final content = _ProcessingContent(
                choice: choice,
                titleController: _titleController,
                outcomeController: _outcomeController,
                waitingOnController: _waitingOnController,
                notesController: _notesController,
                tagsController: _tagsController,
                stepControllers: _stepControllers,
                projectStepDrafts: _projectStepDrafts,
                targetDate: _targetDate,
                targetEndDate: _targetEndDate,
                targetAllDay: _targetAllDay,
                reconsiderDate: _reconsiderDate,
                followUpDate: _followUpDate,
                recurrenceFrequency: _recurrenceFrequency,
                recurrenceWeekdays: _recurrenceWeekdays,
                recurrenceEndMode: _recurrenceEndMode,
                recurrenceUntilDate: _recurrenceUntilDate,
                recurrenceIntervalController: _recurrenceIntervalController,
                recurrenceCountController: _recurrenceCountController,
                somedayReasons: _somedayReasons,
                isSaving: _isSaving,
                onReasonChanged: _toggleSomedayReason,
                onAddStep: _addStep,
                onRemoveStep: _confirmRemoveStep,
                expandedProjectNextActions: _expandedProjectNextActions,
                onToggleProjectNextAction: _toggleProjectNextAction,
                onProjectStepChanged: () => setState(() {}),
                onPickTargetDate: _pickTargetDateTime,
                onPickTargetStartDate: _pickTargetStartDate,
                onPickTargetStartTime: _pickTargetStartTime,
                onPickTargetEndTime: _pickTargetEndTime,
                onTargetAllDayChanged: _setTargetAllDay,
                onPickNextActionDate: _pickNextActionTargetDate,
                onPickNextActionTime: _pickNextActionTime,
                onNextActionAllDayChanged: _setNextActionAllDay,
                onRecurrenceFrequencyChanged: _setRecurrenceFrequency,
                onRecurrenceWeekdayChanged: _setRecurrenceWeekday,
                onRecurrenceEndModeChanged: (mode) {
                  setState(() => _recurrenceEndMode = mode);
                },
                onPickRecurrenceUntilDate: () => _pickDate(
                  current: _recurrenceUntilDate,
                  initialFallback: DateTime.now().add(
                    const Duration(days: 90),
                  ),
                  onPicked: (date) =>
                      setState(() => _recurrenceUntilDate = date),
                ),
                onPickReconsiderDate: () => _pickDate(
                  current: _reconsiderDate,
                  initialFallback: DateTime(DateTime.now().year + 1),
                  onPicked: (date) => setState(() => _reconsiderDate = date),
                ),
                referenceFolder: _referenceFolder,
                onReferenceFolderChanged: (folder) {
                  setState(() => _referenceFolder = folder);
                },
                waitingForProjectId: _waitingForProjectId,
                onWaitingForProjectChanged: (projectId) {
                  setState(() => _waitingForProjectId = projectId);
                },
                onPickFollowUpDate: () => _pickDate(
                  current: _followUpDate,
                  initialFallback: DateTime.now().add(const Duration(days: 7)),
                  onPicked: (date) => setState(() => _followUpDate = date),
                ),
                onSubmit: () => _submit(choice),
              );

              if (!isWide) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      picker,
                      const SizedBox(height: 16),
                      Expanded(child: content),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: constraints.maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 248, child: picker),
                    const SizedBox(width: 24),
                    Expanded(child: content),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _hydrateFromItem(InboxItem item) {
    if (_loadedItemId == item.id) {
      return;
    }

    _loadedItemId = item.id;
    _titleController.text = item.title;
    _outcomeController.text = item.notes ?? '';
    _nextActionController.text = item.title;
    _waitingOnController.clear();
    _notesController.text = item.notes ?? '';
    _tagsController.clear();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    for (final draft in _projectStepDrafts) {
      draft.dispose();
    }
    _stepControllers
      ..clear()
      ..add(TextEditingController());
    _projectStepDrafts
      ..clear()
      ..add(_ProjectStepDraft(defaultContext: _defaultContextName()));
    _targetDate = null;
    _targetEndDate = null;
    _targetAllDay = false;
    _nextActionTimeSet = false;
    _reconsiderDate = DateTime(DateTime.now().year + 1);
    _followUpDate = DateTime.now().add(const Duration(days: 7));
    _recurrenceUntilDate = null;
    _recurrenceFrequency = RecurrenceFrequency.none;
    _recurrenceWeekdays
      ..clear()
      ..add(DateTime.now().weekday);
    _recurrenceIntervalController.text = '1';
    _recurrenceCountController.text = '10';
    _recurrenceEndMode = _RecurrenceEndMode.never;
    _referenceFolder = 'Articles';
    _waitingForProjectId = null;
    _somedayReasons.clear();
    _expandedProjectNextActions.clear();
    final initialChoice = _initialChoiceFor(item);
    final defaultContext = ref.read(appSettingsProvider).defaultContextName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadedItemId != item.id) {
        return;
      }
      ref.read(currentProcessingChoiceProvider.notifier).state = initialChoice;
      ref.read(selectedContextProvider.notifier).state = defaultContext;
    });
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _projectStepDrafts
          .add(_ProjectStepDraft(defaultContext: _defaultContextName()));
    });
  }

  void _removeStep(int index) {
    setState(() {
      if (_stepControllers.length == 1) {
        _stepControllers.single.clear();
        _projectStepDrafts.single.reset(defaultContext: _defaultContextName());
        _expandedProjectNextActions.clear();
        return;
      }

      _stepControllers.removeAt(index).dispose();
      _projectStepDrafts.removeAt(index).dispose();
      final shifted = _expandedProjectNextActions
          .where((stepIndex) => stepIndex != index)
          .map((stepIndex) => stepIndex > index ? stepIndex - 1 : stepIndex)
          .where((stepIndex) => stepIndex < _stepControllers.length);
      _expandedProjectNextActions
        ..clear()
        ..addAll(shifted);
    });
  }

  Future<void> _confirmRemoveStep(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete step?'),
        content: const Text(
          'This removes the step from the project being created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _removeStep(index);
    }
  }

  void _toggleProjectNextAction(int index) {
    setState(() {
      if (!_expandedProjectNextActions.add(index)) {
        _expandedProjectNextActions.remove(index);
      }
    });
  }

  String _defaultContextName() {
    return ref.read(appSettingsProvider).defaultContextName;
  }

  void _toggleSomedayReason(String reason, bool selected) {
    setState(() {
      if (selected) {
        _somedayReasons.add(reason);
        return;
      }
      _somedayReasons.remove(reason);
    });
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    DateTime? initialFallback,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: current ?? initialFallback ?? now,
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _pickTargetDateTime() async {
    final now = DateTime.now();
    final current = _targetDate;
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: current ?? now,
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final startTime = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.fromDateTime(now)
          : TimeOfDay.fromDateTime(current),
    );
    if (startTime == null || !mounted) {
      return;
    }

    final startDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _targetEndDate ?? startDateTime.add(const Duration(minutes: 30)),
      ),
    );
    if (endTime == null || !mounted) {
      return;
    }

    setState(() {
      _targetAllDay = false;
      _targetDate = startDateTime;
      _targetEndDate = _endFor(startDateTime, endTime);
      _recurrenceWeekdays
        ..clear()
        ..add(startDateTime.weekday);
    });
  }

  Future<void> _pickTargetStartDate() async {
    final now = DateTime.now();
    final current = _targetDate ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: current,
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      if (_targetAllDay) {
        _targetDate = DateTime(picked.year, picked.month, picked.day);
        _targetEndDate =
            DateTime(picked.year, picked.month, picked.day, 23, 59);
        _recurrenceWeekdays
          ..clear()
          ..add(picked.weekday);
        return;
      }
      final existingStart = _targetDate ?? now;
      final existingEnd =
          _targetEndDate ?? existingStart.add(const Duration(minutes: 30));
      _targetDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        existingStart.hour,
        existingStart.minute,
      );
      _targetEndDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        existingEnd.hour,
        existingEnd.minute,
      );
      _recurrenceWeekdays
        ..clear()
        ..add(picked.weekday);
    });
  }

  Future<void> _pickTargetStartTime() async {
    final current = _targetDate ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _targetAllDay = false;
      _targetDate = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
      final end =
          _targetEndDate ?? _targetDate!.add(const Duration(minutes: 30));
      if (!end.isAfter(_targetDate!)) {
        _targetEndDate = _targetDate!.add(const Duration(minutes: 30));
      }
    });
  }

  Future<void> _pickTargetEndTime() async {
    final start = _targetDate ?? DateTime.now();
    final currentEnd = _targetEndDate ?? start.add(const Duration(minutes: 30));
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentEnd),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _targetAllDay = false;
      _targetEndDate = _endFor(start, picked);
    });
  }

  void _setTargetAllDay(bool value) {
    final current = _targetDate ?? DateTime.now();
    setState(() {
      _targetAllDay = value;
      if (value) {
        _targetDate = DateTime(current.year, current.month, current.day);
        _targetEndDate =
            DateTime(current.year, current.month, current.day, 23, 59);
        return;
      }
      _targetDate = DateTime(current.year, current.month, current.day, 9);
      _targetEndDate = _targetDate!.add(const Duration(minutes: 30));
    });
  }

  Future<void> _pickNextActionTargetDate() async {
    final now = DateTime.now();
    final current = _targetDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: current,
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      if (_nextActionTimeSet && !_targetAllDay) {
        final existing = _targetDate ?? now;
        _targetDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          existing.hour,
          existing.minute,
        );
        return;
      }
      _targetDate = DateTime(picked.year, picked.month, picked.day);
      _targetEndDate = null;
      _nextActionTimeSet = false;
    });
  }

  Future<void> _pickNextActionTime() async {
    final now = DateTime.now();
    final current = _targetDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showTimePicker(
      context: context,
      initialTime: _nextActionTimeSet
          ? TimeOfDay.fromDateTime(current)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _targetAllDay = false;
      _nextActionTimeSet = true;
      _targetDate = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
      _targetEndDate = null;
    });
  }

  void _setNextActionAllDay(bool value) {
    final now = DateTime.now();
    final current = _targetDate ?? DateTime(now.year, now.month, now.day);
    setState(() {
      _targetAllDay = value;
      if (value) {
        _targetDate = DateTime(current.year, current.month, current.day);
        _targetEndDate = null;
        _nextActionTimeSet = false;
      }
    });
  }

  void _setRecurrenceFrequency(RecurrenceFrequency frequency) {
    setState(() {
      _recurrenceFrequency = frequency;
      if (frequency == RecurrenceFrequency.none) {
        _recurrenceEndMode = _RecurrenceEndMode.never;
      }
      if ((frequency == RecurrenceFrequency.weekly ||
              frequency == RecurrenceFrequency.biweekly) &&
          _recurrenceWeekdays.isEmpty) {
        _recurrenceWeekdays.add((_targetDate ?? DateTime.now()).weekday);
      }
    });
  }

  void _setRecurrenceWeekday(int weekday, bool selected) {
    setState(() {
      if (selected) {
        _recurrenceWeekdays.add(weekday);
        return;
      }
      if (_recurrenceWeekdays.length > 1) {
        _recurrenceWeekdays.remove(weekday);
      }
    });
  }

  DateTime _endFor(DateTime start, TimeOfDay time) {
    var end =
        DateTime(start.year, start.month, start.day, time.hour, time.minute);
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  Future<void> _submit(ProcessingChoice choice) async {
    setState(() => _isSaving = true);
    final selectedContextName = ref.read(selectedContextProvider);
    final typedTags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final tags = {
      ...typedTags,
      if (choice == ProcessingChoice.someday)
        ..._somedayReasons.map(_tagFromReason),
    }.toList(growable: false);

    final success = await ref.read(inboxItemsProvider.notifier).processItem(
          itemId: widget.itemId,
          request: ProcessingRequest(
            choice: choice,
            title: _titleController.text,
            desiredOutcome: _outcomeController.text,
            context: ZoroContext(
              id: selectedContextName.replaceAll('@', '').toLowerCase(),
              name: selectedContextName,
            ),
            targetDate: _targetDate,
            endDateTime:
                choice == ProcessingChoice.nextAction ? null : _targetEndDate,
            notes: _notesController.text,
            nextActionTitle: choice == ProcessingChoice.project
                ? null
                : _nextActionController.text,
            reconsiderDate: _reconsiderDate,
            referenceFolder:
                choice == ProcessingChoice.reference ? _referenceFolder : null,
            waitingOn: _waitingOnController.text,
            waitingForProjectId: _waitingForProjectId,
            followUpDate: _followUpDate,
            recurrence: choice == ProcessingChoice.calendarEvent
                ? _buildRecurrence()
                : null,
            tags: tags,
            stepTitles: choice == ProcessingChoice.project
                ? _buildFutureStepTitles()
                : const [],
            projectSteps: choice == ProcessingChoice.project
                ? _buildProjectSteps(tags)
                : const [],
          ),
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    if (success) {
      // Refresh calendar-facing derived providers immediately after processing
      // so a newly scheduled Next Action is visible without reopening the app.
      ref
        ..invalidate(calendarAgendaEntriesProvider)
        ..invalidate(calendarEntriesProvider)
        ..invalidate(availableCalendarContextsProvider)
        ..invalidate(tasksByDateRangeProvider)
        ..invalidate(waitingForProvider)
        ..invalidate(allWaitingForProvider);
      context.go('/inbox');
      return;
    }

    final message = ref.read(inboxActionErrorProvider) ?? 'Could not save.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  List<ProjectStep> _buildProjectSteps(List<String> tags) {
    final steps = <ProjectStep>[];
    for (var index = 0; index < _stepControllers.length; index++) {
      final title = _stepControllers[index].text.trim();
      if (title.isEmpty) {
        continue;
      }
      final draft = _projectStepDrafts[index];
      final kind = draft.kind;
      if (kind == null) {
        continue;
      }
      final id = 'project-step-${index + 1}';
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
          final targetDate = draft.targetDate;
          if (targetDate == null) {
            continue;
          }
          steps.add(
            CalendarEventProjectStep(
              id: id,
              title: title,
              context: draft.context,
              targetDate: targetDate,
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
    final titles = <String>[];
    for (var index = 0; index < _stepControllers.length; index++) {
      final title = _stepControllers[index].text.trim();
      if (title.isNotEmpty && _projectStepDrafts[index].kind == null) {
        titles.add(title);
      }
    }
    return titles;
  }

  String? _cleanText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _clarifyWithAi(InboxItem item) async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.aiEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable AI clarification in Settings first.'),
        ),
      );
      return;
    }

    setState(() => _isClarifying = true);
    try {
      final contexts = ref.read(contextsProvider);
      final currentChoice = ref.read(currentProcessingChoiceProvider);
      final suggestion =
          await ref.read(aiSuggestUseCaseProvider).suggestInboxProcessing(
                item: item,
                currentChoice: currentChoice,
                contexts: contexts,
                settings: settings,
              );

      if (!mounted) {
        return;
      }

      ref.read(currentProcessingChoiceProvider.notifier).state =
          suggestion.recommendedChoice;
      final matchedContext = _matchContextName(
        contexts,
        suggestion.contextName,
      );
      if (matchedContext != null) {
        ref.read(selectedContextProvider.notifier).state = matchedContext;
      }

      setState(() {
        _titleController.text = suggestion.title;
        _outcomeController.text =
            suggestion.desiredOutcome ?? _outcomeController.text;
        _nextActionController.text =
            suggestion.nextActionTitle ?? suggestion.title;
        _notesController.text = suggestion.notes ?? _notesController.text;
        _tagsController.text = suggestion.tags.join(', ');
        _targetDate = suggestion.targetDate;
        _targetEndDate = suggestion.targetDate?.add(
          const Duration(minutes: 30),
        );
        _reconsiderDate = suggestion.reconsiderDate ?? _reconsiderDate;

        if (suggestion.steps.isNotEmpty) {
          for (final controller in _stepControllers) {
            controller.dispose();
          }
          _stepControllers
            ..clear()
            ..addAll(
              suggestion.steps.map(
                (title) => TextEditingController(text: title),
              ),
            );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI suggestions applied - edit as needed'),
        ),
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
        setState(() => _isClarifying = false);
      }
    }
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

  ProcessingChoice _initialChoiceFor(InboxItem item) {
    final text = '${item.title} ${item.notes ?? ''}'.toLowerCase();
    final looksLikeRecurringCalendar = RegExp(
          r'\b(every|weekly|recurring|repeat|daily|monthly|yearly|bi-?weekly)\b',
        ).hasMatch(text) &&
        RegExp(r'\b(\d{1,2}(:\d{2})?\s?(am|pm)?|morning|afternoon|evening|night)\b')
            .hasMatch(text);
    if (looksLikeRecurringCalendar) {
      return ProcessingChoice.calendarEvent;
    }
    final projectSignals = [
      'plan ',
      'organize ',
      'build ',
      'launch ',
      'prepare ',
    ];
    final looksLikeProject = projectSignals.any(text.contains);
    return looksLikeProject
        ? ProcessingChoice.project
        : ProcessingChoice.nextAction;
  }

  String _tagFromReason(String reason) {
    return reason
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

class _ProcessingChoiceRail extends ConsumerWidget {
  const _ProcessingChoiceRail({required this.choice});

  final ProcessingChoice choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Clarify as',
      child: RadioGroup<ProcessingChoice>(
        groupValue: choice,
        onChanged: (value) {
          if (value != null) {
            ref.read(currentProcessingChoiceProvider.notifier).state = value;
          }
        },
        child: Column(
          children: [
            _choiceTile(
              context,
              ProcessingChoice.nextAction,
              'Next Action',
              Icons.check_circle_outline,
            ),
            _choiceTile(
              context,
              ProcessingChoice.project,
              'Project',
              Icons.account_tree_outlined,
            ),
            _choiceTile(
              context,
              ProcessingChoice.calendarEvent,
              'Calendar Event',
              Icons.event_repeat_outlined,
            ),
            _choiceTile(
              context,
              ProcessingChoice.someday,
              'Someday/Maybe',
              Icons.event_available_outlined,
            ),
            _choiceTile(
              context,
              ProcessingChoice.reference,
              'Reference',
              Icons.folder_open_outlined,
            ),
            _choiceTile(
              context,
              ProcessingChoice.waitingFor,
              'Waiting For',
              Icons.hourglass_empty_outlined,
            ),
            _choiceTile(
              context,
              ProcessingChoice.trash,
              'Trash',
              Icons.delete_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceTile(
    BuildContext context,
    ProcessingChoice value,
    String label,
    IconData icon,
  ) {
    final selected = choice == value;

    return RadioListTile<ProcessingChoice>(
      value: value,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selected: selected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      title: Text(label),
      secondary: Icon(icon),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  const _ProcessingContent({
    required this.choice,
    required this.titleController,
    required this.outcomeController,
    required this.waitingOnController,
    required this.notesController,
    required this.tagsController,
    required this.stepControllers,
    required this.projectStepDrafts,
    required this.targetDate,
    required this.targetEndDate,
    required this.targetAllDay,
    required this.reconsiderDate,
    required this.followUpDate,
    required this.recurrenceFrequency,
    required this.recurrenceWeekdays,
    required this.recurrenceEndMode,
    required this.recurrenceUntilDate,
    required this.recurrenceIntervalController,
    required this.recurrenceCountController,
    required this.somedayReasons,
    required this.isSaving,
    required this.onReasonChanged,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.expandedProjectNextActions,
    required this.onToggleProjectNextAction,
    required this.onProjectStepChanged,
    required this.onPickTargetDate,
    required this.onPickTargetStartDate,
    required this.onPickTargetStartTime,
    required this.onPickTargetEndTime,
    required this.onTargetAllDayChanged,
    required this.onPickNextActionDate,
    required this.onPickNextActionTime,
    required this.onNextActionAllDayChanged,
    required this.onRecurrenceFrequencyChanged,
    required this.onRecurrenceWeekdayChanged,
    required this.onRecurrenceEndModeChanged,
    required this.onPickRecurrenceUntilDate,
    required this.onPickReconsiderDate,
    required this.referenceFolder,
    required this.onReferenceFolderChanged,
    required this.waitingForProjectId,
    required this.onWaitingForProjectChanged,
    required this.onPickFollowUpDate,
    required this.onSubmit,
  });

  final ProcessingChoice choice;
  final TextEditingController titleController;
  final TextEditingController outcomeController;
  final TextEditingController waitingOnController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final List<TextEditingController> stepControllers;
  final List<_ProjectStepDraft> projectStepDrafts;
  final DateTime? targetDate;
  final DateTime? targetEndDate;
  final bool targetAllDay;
  final DateTime? reconsiderDate;
  final DateTime? followUpDate;
  final RecurrenceFrequency recurrenceFrequency;
  final Set<int> recurrenceWeekdays;
  final _RecurrenceEndMode recurrenceEndMode;
  final DateTime? recurrenceUntilDate;
  final TextEditingController recurrenceIntervalController;
  final TextEditingController recurrenceCountController;
  final Set<String> somedayReasons;
  final bool isSaving;
  final void Function(String reason, bool selected) onReasonChanged;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;
  final Set<int> expandedProjectNextActions;
  final ValueChanged<int> onToggleProjectNextAction;
  final VoidCallback onProjectStepChanged;
  final VoidCallback onPickTargetDate;
  final VoidCallback onPickTargetStartDate;
  final VoidCallback onPickTargetStartTime;
  final VoidCallback onPickTargetEndTime;
  final ValueChanged<bool> onTargetAllDayChanged;
  final VoidCallback onPickNextActionDate;
  final VoidCallback onPickNextActionTime;
  final ValueChanged<bool> onNextActionAllDayChanged;
  final ValueChanged<RecurrenceFrequency> onRecurrenceFrequencyChanged;
  final void Function(int weekday, bool selected) onRecurrenceWeekdayChanged;
  final ValueChanged<_RecurrenceEndMode> onRecurrenceEndModeChanged;
  final VoidCallback onPickRecurrenceUntilDate;
  final VoidCallback onPickReconsiderDate;
  final String referenceFolder;
  final ValueChanged<String> onReferenceFolderChanged;
  final String? waitingForProjectId;
  final ValueChanged<String?> onWaitingForProjectChanged;
  final VoidCallback onPickFollowUpDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return switch (choice) {
      ProcessingChoice.nextAction => _NextActionForm(
          titleController: titleController,
          notesController: notesController,
          targetDate: targetDate,
          targetAllDay: targetAllDay,
          isSaving: isSaving,
          onPickDate: onPickNextActionDate,
          onPickTime: onPickNextActionTime,
          onAllDayChanged: onNextActionAllDayChanged,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.project => _ProjectForm(
          titleController: titleController,
          outcomeController: outcomeController,
          notesController: notesController,
          tagsController: tagsController,
          stepControllers: stepControllers,
          projectStepDrafts: projectStepDrafts,
          isSaving: isSaving,
          onAddStep: onAddStep,
          onRemoveStep: onRemoveStep,
          expandedNextActions: expandedProjectNextActions,
          onToggleNextAction: onToggleProjectNextAction,
          onStepChanged: onProjectStepChanged,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.calendarEvent => _CalendarEventForm(
          titleController: titleController,
          notesController: notesController,
          tagsController: tagsController,
          targetDate: targetDate,
          targetEndDate: targetEndDate,
          targetAllDay: targetAllDay,
          recurrenceFrequency: recurrenceFrequency,
          recurrenceWeekdays: recurrenceWeekdays,
          recurrenceEndMode: recurrenceEndMode,
          recurrenceUntilDate: recurrenceUntilDate,
          recurrenceIntervalController: recurrenceIntervalController,
          recurrenceCountController: recurrenceCountController,
          isSaving: isSaving,
          onPickTargetDate: onPickTargetDate,
          onPickStartDate: onPickTargetStartDate,
          onPickStartTime: onPickTargetStartTime,
          onPickEndTime: onPickTargetEndTime,
          onAllDayChanged: onTargetAllDayChanged,
          onRecurrenceFrequencyChanged: onRecurrenceFrequencyChanged,
          onRecurrenceWeekdayChanged: onRecurrenceWeekdayChanged,
          onRecurrenceEndModeChanged: onRecurrenceEndModeChanged,
          onPickRecurrenceUntilDate: onPickRecurrenceUntilDate,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.someday => _SomedayForm(
          titleController: titleController,
          notesController: notesController,
          tagsController: tagsController,
          reconsiderDate: reconsiderDate,
          selectedReasons: somedayReasons,
          isSaving: isSaving,
          onReasonChanged: onReasonChanged,
          onPickReconsiderDate: onPickReconsiderDate,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.reference => _ReferenceForm(
          titleController: titleController,
          notesController: notesController,
          tagsController: tagsController,
          folder: referenceFolder,
          isSaving: isSaving,
          onFolderChanged: onReferenceFolderChanged,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.waitingFor => _WaitingForForm(
          titleController: titleController,
          waitingOnController: waitingOnController,
          notesController: notesController,
          tagsController: tagsController,
          followUpDate: followUpDate,
          projectId: waitingForProjectId,
          isSaving: isSaving,
          onProjectChanged: onWaitingForProjectChanged,
          onPickFollowUpDate: onPickFollowUpDate,
          onSubmit: onSubmit,
        ),
      ProcessingChoice.trash => _TrashPanel(
          isSaving: isSaving,
          onSubmit: onSubmit,
        ),
    };
  }
}

class _CalendarEventForm extends StatelessWidget {
  const _CalendarEventForm({
    required this.titleController,
    required this.notesController,
    required this.tagsController,
    required this.targetDate,
    required this.targetEndDate,
    required this.targetAllDay,
    required this.recurrenceFrequency,
    required this.recurrenceWeekdays,
    required this.recurrenceEndMode,
    required this.recurrenceUntilDate,
    required this.recurrenceIntervalController,
    required this.recurrenceCountController,
    required this.isSaving,
    required this.onPickTargetDate,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onAllDayChanged,
    required this.onRecurrenceFrequencyChanged,
    required this.onRecurrenceWeekdayChanged,
    required this.onRecurrenceEndModeChanged,
    required this.onPickRecurrenceUntilDate,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final DateTime? targetDate;
  final DateTime? targetEndDate;
  final bool targetAllDay;
  final RecurrenceFrequency recurrenceFrequency;
  final Set<int> recurrenceWeekdays;
  final _RecurrenceEndMode recurrenceEndMode;
  final DateTime? recurrenceUntilDate;
  final TextEditingController recurrenceIntervalController;
  final TextEditingController recurrenceCountController;
  final bool isSaving;
  final VoidCallback onPickTargetDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final ValueChanged<bool> onAllDayChanged;
  final ValueChanged<RecurrenceFrequency> onRecurrenceFrequencyChanged;
  final void Function(int weekday, bool selected) onRecurrenceWeekdayChanged;
  final ValueChanged<_RecurrenceEndMode> onRecurrenceEndModeChanged;
  final VoidCallback onPickRecurrenceUntilDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Save as Calendar Event',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          const _ContextChips(),
          const SizedBox(height: 16),
          _OutlookTargetDateFieldRich(
            targetDate: targetDate,
            endDateTime: targetEndDate,
            allDay: targetAllDay,
            onInitialPick: onPickTargetDate,
            onPickStartDate: onPickStartDate,
            onPickStartTime: onPickStartTime,
            onPickEndTime: onPickEndTime,
            onAllDayChanged: onAllDayChanged,
          ),
          const SizedBox(height: 16),
          _RecurrenceSection(
            frequency: recurrenceFrequency,
            weekdays: recurrenceWeekdays,
            endMode: recurrenceEndMode,
            untilDate: recurrenceUntilDate,
            intervalController: recurrenceIntervalController,
            countController: recurrenceCountController,
            onFrequencyChanged: onRecurrenceFrequencyChanged,
            onWeekdayChanged: onRecurrenceWeekdayChanged,
            onEndModeChanged: onRecurrenceEndModeChanged,
            onPickUntilDate: onPickRecurrenceUntilDate,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration:
                const InputDecoration(labelText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.event_repeat_outlined),
            label: Text(isSaving ? 'Saving...' : 'Save as Calendar Event'),
          ),
        ],
      ),
    );
  }
}

enum _RecurrenceEndMode { never, afterCount, onDate }

class _RecurrenceSection extends StatelessWidget {
  const _RecurrenceSection({
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
          TextField(
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
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Occurrences'),
            ),
          ],
          if (endMode == _RecurrenceEndMode.onDate) ...[
            const SizedBox(height: 12),
            _DateButton(
              label: 'Ends On',
              date: untilDate,
              onPressed: onPickUntilDate,
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

const _weekdayLabels = {
  DateTime.monday: 'Mon',
  DateTime.tuesday: 'Tue',
  DateTime.wednesday: 'Wed',
  DateTime.thursday: 'Thu',
  DateTime.friday: 'Fri',
  DateTime.saturday: 'Sat',
  DateTime.sunday: 'Sun',
};

class _ProjectForm extends StatelessWidget {
  const _ProjectForm({
    required this.titleController,
    required this.outcomeController,
    required this.notesController,
    required this.tagsController,
    required this.stepControllers,
    required this.projectStepDrafts,
    required this.isSaving,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.expandedNextActions,
    required this.onToggleNextAction,
    required this.onStepChanged,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController outcomeController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final List<TextEditingController> stepControllers;
  final List<_ProjectStepDraft> projectStepDrafts;
  final bool isSaving;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;
  final Set<int> expandedNextActions;
  final ValueChanged<int> onToggleNextAction;
  final VoidCallback onStepChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Create Project',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Project Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: outcomeController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Desired Outcome'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 16),
          _ProjectStepsEditor(
            controllers: stepControllers,
            drafts: projectStepDrafts,
            onAddStep: onAddStep,
            onRemoveStep: onRemoveStep,
            expandedNextActions: expandedNextActions,
            onToggleNextAction: onToggleNextAction,
            onStepChanged: onStepChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration:
                const InputDecoration(labelText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.add_task_outlined),
            label:
                Text(isSaving ? 'Saving...' : 'Create Project & Next Action'),
          ),
        ],
      ),
    );
  }
}

class _NextActionForm extends StatelessWidget {
  const _NextActionForm({
    required this.titleController,
    required this.notesController,
    required this.targetDate,
    required this.targetAllDay,
    required this.isSaving,
    required this.onPickDate,
    required this.onPickTime,
    required this.onAllDayChanged,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController notesController;
  final DateTime? targetDate;
  final bool targetAllDay;
  final bool isSaving;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<bool> onAllDayChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Save as Next Action',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Next Action Title'),
          ),
          const SizedBox(height: 16),
          const _ContextChips(),
          const SizedBox(height: 16),
          _NextActionTargetDateField(
            targetDate: targetDate,
            allDay: targetAllDay,
            onPickDate: onPickDate,
            onPickTime: onPickTime,
            onAllDayChanged: onAllDayChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save as Next Action'),
          ),
        ],
      ),
    );
  }
}

class _NextActionTargetDateField extends StatelessWidget {
  const _NextActionTargetDateField({
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
    final hasDate = date != null;
    final hasTime = targetDate != null &&
        !allDay &&
        (targetDate!.hour != 0 || targetDate!.minute != 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _OutlookPickerBox(
                      label: 'Target date - optional',
                      value: hasDate
                          ? DateFormat('M/d/y').format(date)
                          : 'Select date',
                      icon: Icons.calendar_today_outlined,
                      onTap: onPickDate,
                    ),
                    _OutlookPickerBox(
                      label: 'Time - optional',
                      value: allDay
                          ? '--'
                          : hasTime
                              ? DateFormat('h:mm a').format(targetDate!)
                              : 'Select time',
                      icon: Icons.schedule_outlined,
                      onTap: allDay ? null : onPickTime,
                    ),
                    _OutlookAllDayToggle(
                      value: allDay,
                      onChanged: onAllDayChanged,
                    ),
                  ],
                ),
              ),
            ],
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

class _ProjectStepDraft {
  _ProjectStepDraft({required String defaultContext})
      : context = ZoroContext(
          id: defaultContext.replaceAll('@', '').toLowerCase(),
          name: defaultContext,
        );

  ProjectStepKind? kind;
  ZoroContext context;
  DateTime? targetDate;
  DateTime? endDateTime;
  DateTime? followUpDate;
  bool allDay = false;
  RecurrenceFrequency frequency = RecurrenceFrequency.none;
  final Set<int> weekdays = {};
  final intervalController = TextEditingController(text: '1');
  final notesController = TextEditingController();
  final waitingOnController = TextEditingController();

  void reset({required String defaultContext}) {
    kind = null;
    context = ZoroContext(
      id: defaultContext.replaceAll('@', '').toLowerCase(),
      name: defaultContext,
    );
    targetDate = null;
    endDateTime = null;
    followUpDate = null;
    allDay = false;
    frequency = RecurrenceFrequency.none;
    weekdays.clear();
    intervalController.text = '1';
    notesController.clear();
    waitingOnController.clear();
  }

  void dispose() {
    intervalController.dispose();
    notesController.dispose();
    waitingOnController.dispose();
  }

  Future<void> pickDate(BuildContext context, VoidCallback onChanged) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: targetDate ?? now,
    );
    if (picked == null) {
      return;
    }

    final existing = targetDate;
    targetDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      existing?.hour ?? 0,
      existing?.minute ?? 0,
    );
    if (endDateTime != null) {
      endDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        endDateTime!.hour,
        endDateTime!.minute,
      );
    }
    onChanged();
  }

  Future<void> pickTime(BuildContext context, VoidCallback onChanged) async {
    final now = DateTime.now();
    final current = targetDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) {
      return;
    }

    allDay = false;
    targetDate = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
    endDateTime ??= targetDate!.add(const Duration(minutes: 30));
    onChanged();
  }

  Future<void> pickEndTime(BuildContext context, VoidCallback onChanged) async {
    final start = targetDate ?? DateTime.now();
    final current = endDateTime ?? start.add(const Duration(minutes: 30));
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) {
      return;
    }

    var end = DateTime(
      start.year,
      start.month,
      start.day,
      picked.hour,
      picked.minute,
    );
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    endDateTime = end;
    onChanged();
  }

  Future<void> pickDateTimeRange(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    await pickDate(context, onChanged);
  }

  Future<void> pickFollowUpDate(
    BuildContext context,
    VoidCallback onChanged,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: followUpDate ?? now.add(const Duration(days: 7)),
    );
    if (picked != null) {
      followUpDate = picked;
      onChanged();
    }
  }

  void setAllDay(bool value, VoidCallback onChanged) {
    allDay = value;
    if (value) {
      final now = DateTime.now();
      final current = targetDate ?? DateTime(now.year, now.month, now.day);
      targetDate = DateTime(current.year, current.month, current.day);
      endDateTime = null;
    }
    onChanged();
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
    );
  }
}

class _ProjectStepsEditor extends StatelessWidget {
  const _ProjectStepsEditor({
    required this.controllers,
    required this.drafts,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.expandedNextActions,
    required this.onToggleNextAction,
    required this.onStepChanged,
  });

  final List<TextEditingController> controllers;
  final List<_ProjectStepDraft> drafts;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;
  final Set<int> expandedNextActions;
  final ValueChanged<int> onToggleNextAction;
  final VoidCallback onStepChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Future Steps',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < controllers.length; index++) ...[
          _ProjectStepRow(
            index: index,
            controller: controllers[index],
            draft: drafts[index],
            isExpanded: expandedNextActions.contains(index),
            onTypeSelected: (kind) {
              drafts[index].kind = kind;
              if (kind != null && !expandedNextActions.contains(index)) {
                onToggleNextAction(index);
              } else if (kind == null && expandedNextActions.contains(index)) {
                onToggleNextAction(index);
              }
              onStepChanged();
            },
            onToggleExpanded: () => onToggleNextAction(index),
            onDelete: () => onRemoveStep(index),
            onChanged: onStepChanged,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: onAddStep,
          icon: const Icon(Icons.add_outlined),
          label: const Text('Add Step'),
        ),
      ],
    );
  }
}

class _ProjectStepRow extends StatelessWidget {
  const _ProjectStepRow({
    required this.index,
    required this.controller,
    required this.draft,
    required this.isExpanded,
    required this.onTypeSelected,
    required this.onToggleExpanded,
    required this.onDelete,
    required this.onChanged,
  });

  final int index;
  final TextEditingController controller;
  final _ProjectStepDraft draft;
  final bool isExpanded;
  final void Function(ProjectStepKind? kind) onTypeSelected;
  final VoidCallback onToggleExpanded;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = draft.kind;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kind == ProjectStepKind.nextAction
            ? theme.colorScheme.primary.withValues(alpha: 0.04)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kind == ProjectStepKind.nextAction
              ? theme.colorScheme.primary.withValues(alpha: 0.28)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index == 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Create at least one action',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Icon(_stepIcon(kind), color: _stepColor(theme, kind)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: _titleLabel(index, kind),
                    suffixIcon: Tooltip(
                      message: _stepLabel(kind),
                      child: Icon(_stepIcon(kind)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StepKindPill(
                label: 'Future Step',
                icon: Icons.notes_outlined,
                selected: kind == null,
                onPressed: () => onTypeSelected(null),
              ),
              _StepKindPill(
                label: 'Next Action',
                icon: Icons.check_circle_outline,
                selected: kind == ProjectStepKind.nextAction,
                onPressed: () => onTypeSelected(ProjectStepKind.nextAction),
              ),
              _StepKindPill(
                label: 'Calendar Event',
                icon: Icons.calendar_month_outlined,
                selected: kind == ProjectStepKind.calendarEvent,
                onPressed: () => onTypeSelected(ProjectStepKind.calendarEvent),
              ),
              _StepKindPill(
                label: 'Waiting For',
                icon: Icons.person_outline,
                selected: kind == ProjectStepKind.waitingFor,
                onPressed: () => onTypeSelected(ProjectStepKind.waitingFor),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onDelete();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
              IconButton(
                tooltip: isExpanded ? 'Collapse details' : 'Expand details',
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onToggleExpanded();
                },
                icon: Icon(
                  isExpanded
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined,
                ),
              ),
            ],
          ),
          if (isExpanded && kind != null) ...[
            const SizedBox(height: 12),
            _ProjectStepDetails(
              kind: kind,
              draft: draft,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }

  static String _titleLabel(int index, ProjectStepKind? kind) {
    final suffix = switch (kind) {
      null => 'Future Step Title',
      ProjectStepKind.nextAction => 'Next Action Title',
      ProjectStepKind.calendarEvent => 'Calendar Event Title',
      ProjectStepKind.waitingFor => 'Waiting For Title',
    };
    return 'Step ${index + 1} - $suffix';
  }
}

class _StepKindPill extends StatelessWidget {
  const _StepKindPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    void handlePressed() {
      FocusManager.instance.primaryFocus?.unfocus();
      onPressed();
    }

    if (selected) {
      return FilledButton.tonalIcon(
        onPressed: handlePressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: handlePressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _ProjectStepDetails extends StatelessWidget {
  const _ProjectStepDetails({
    required this.kind,
    required this.draft,
    required this.onChanged,
  });

  final ProjectStepKind kind;
  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: switch (kind) {
        ProjectStepKind.nextAction => _ProjectStepNextActionForm(
            draft: draft,
            onChanged: onChanged,
          ),
        ProjectStepKind.calendarEvent => _ProjectStepCalendarEventForm(
            draft: draft,
            onChanged: onChanged,
          ),
        ProjectStepKind.waitingFor => _ProjectStepWaitingForForm(
            draft: draft,
            onChanged: onChanged,
          ),
      },
    );
  }
}

class _ProjectStepNextActionForm extends StatelessWidget {
  const _ProjectStepNextActionForm({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProjectStepContextChips(draft: draft, onChanged: onChanged),
        const SizedBox(height: 12),
        _NextActionTargetDateField(
          targetDate: draft.targetDate,
          allDay: draft.allDay,
          onPickDate: () => draft.pickDate(context, onChanged),
          onPickTime: () => draft.pickTime(context, onChanged),
          onAllDayChanged: (value) => draft.setAllDay(value, onChanged),
        ),
        const SizedBox(height: 12),
        _ProjectStepNotesField(draft: draft, onChanged: onChanged),
      ],
    );
  }
}

class _ProjectStepCalendarEventForm extends StatelessWidget {
  const _ProjectStepCalendarEventForm({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProjectStepContextChips(draft: draft, onChanged: onChanged),
        const SizedBox(height: 12),
        _OutlookTargetDateFieldRich(
          targetDate: draft.targetDate,
          endDateTime: draft.endDateTime,
          allDay: draft.allDay,
          onInitialPick: () => draft.pickDateTimeRange(context, onChanged),
          onPickStartDate: () => draft.pickDate(context, onChanged),
          onPickStartTime: () => draft.pickTime(context, onChanged),
          onPickEndTime: () => draft.pickEndTime(context, onChanged),
          onAllDayChanged: (value) => draft.setAllDay(value, onChanged),
        ),
        const SizedBox(height: 12),
        _ProjectStepRecurrenceSection(draft: draft, onChanged: onChanged),
        const SizedBox(height: 12),
        _ProjectStepNotesField(draft: draft, onChanged: onChanged),
      ],
    );
  }
}

class _ProjectStepWaitingForForm extends StatelessWidget {
  const _ProjectStepWaitingForForm({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: draft.waitingOnController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Waiting on',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        _DateButton(
          label: 'Follow-up Date',
          date: draft.followUpDate,
          onPressed: () => draft.pickFollowUpDate(context, onChanged),
        ),
        const SizedBox(height: 12),
        _ProjectStepNotesField(draft: draft, onChanged: onChanged),
      ],
    );
  }
}

class _ProjectStepNotesField extends StatelessWidget {
  const _ProjectStepNotesField({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: draft.notesController,
      onChanged: (_) => onChanged(),
      minLines: 2,
      maxLines: 4,
      decoration: const InputDecoration(labelText: 'Notes (optional)'),
    );
  }
}

class _ProjectStepContextChips extends ConsumerWidget {
  const _ProjectStepContextChips({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider);

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final context in contexts)
            ChoiceChip(
              label: Text(context.name),
              selected: draft.context.name == context.name,
              onSelected: (_) {
                draft.context = context;
                onChanged();
              },
            ),
        ],
      ),
    );
  }
}

class _ProjectStepRecurrenceSection extends StatelessWidget {
  const _ProjectStepRecurrenceSection({
    required this.draft,
    required this.onChanged,
  });

  final _ProjectStepDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.repeat_outlined),
        title: const Text('Recurrence'),
        subtitle: Text(_RecurrenceSection._frequencyLabel(draft.frequency)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          DropdownButtonFormField<RecurrenceFrequency>(
            initialValue: draft.frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: [
              for (final option in RecurrenceFrequency.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(_RecurrenceSection._frequencyLabel(option)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                draft.frequency = value;
                if ((value == RecurrenceFrequency.weekly ||
                        value == RecurrenceFrequency.biweekly) &&
                    draft.weekdays.isEmpty) {
                  draft.weekdays.add(
                    (draft.targetDate ?? DateTime.now()).weekday,
                  );
                }
                onChanged();
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: draft.intervalController,
            enabled: draft.frequency != RecurrenceFrequency.none,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Every N',
              prefixText: 'Every ',
            ),
            onChanged: (_) => onChanged(),
          ),
          if (draft.frequency == RecurrenceFrequency.weekly ||
              draft.frequency == RecurrenceFrequency.biweekly) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final day in _weekdayLabels.entries)
                    FilterChip(
                      selected: draft.weekdays.contains(day.key),
                      label: Text(day.value),
                      onSelected: (selected) {
                        if (selected) {
                          draft.weekdays.add(day.key);
                        } else if (draft.weekdays.length > 1) {
                          draft.weekdays.remove(day.key);
                        }
                        onChanged();
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

IconData _stepIcon(ProjectStepKind? kind) {
  return switch (kind) {
    null => Icons.notes_outlined,
    ProjectStepKind.nextAction => Icons.check_circle_outline,
    ProjectStepKind.calendarEvent => Icons.calendar_month_outlined,
    ProjectStepKind.waitingFor => Icons.person_outline,
  };
}

String _stepLabel(ProjectStepKind? kind) {
  return switch (kind) {
    null => 'Future Step',
    ProjectStepKind.nextAction => 'Next Action',
    ProjectStepKind.calendarEvent => 'Calendar Event',
    ProjectStepKind.waitingFor => 'Waiting For',
  };
}

Color _stepColor(ThemeData theme, ProjectStepKind? kind) {
  return switch (kind) {
    null => theme.colorScheme.outline,
    ProjectStepKind.nextAction => theme.colorScheme.primary,
    ProjectStepKind.calendarEvent => theme.colorScheme.tertiary,
    ProjectStepKind.waitingFor => theme.colorScheme.secondary,
  };
}

const _somedayReasonOptions = [
  'Budget constraints',
  'Wrong season',
  'Low priority',
  'Needs more information',
];

class _SomedayForm extends StatelessWidget {
  const _SomedayForm({
    required this.titleController,
    required this.notesController,
    required this.tagsController,
    required this.reconsiderDate,
    required this.selectedReasons,
    required this.isSaving,
    required this.onReasonChanged,
    required this.onPickReconsiderDate,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final DateTime? reconsiderDate;
  final Set<String> selectedReasons;
  final bool isSaving;
  final void Function(String reason, bool selected) onReasonChanged;
  final VoidCallback onPickReconsiderDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Move to Someday/Maybe',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          Text(
            'Reason',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          for (final reason in _somedayReasonOptions)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(reason),
              value: selectedReasons.contains(reason),
              onChanged: (value) => onReasonChanged(reason, value ?? false),
            ),
          const SizedBox(height: 16),
          _DateButton(
            label: 'Reconsider Date',
            date: reconsiderDate,
            onPressed: onPickReconsiderDate,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Rich Notes'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration:
                const InputDecoration(labelText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.event_available_outlined),
            label: Text(isSaving ? 'Saving...' : 'Move to Someday/Maybe'),
          ),
        ],
      ),
    );
  }
}

const _referenceFolders = [
  'Articles',
  'Receipts',
  'Manuals',
  'Legal',
  'Ideas',
  'Notes',
];

class _ReferenceForm extends StatelessWidget {
  const _ReferenceForm({
    required this.titleController,
    required this.notesController,
    required this.tagsController,
    required this.folder,
    required this.isSaving,
    required this.onFolderChanged,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final String folder;
  final bool isSaving;
  final ValueChanged<String> onFolderChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Save to Reference',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration:
                const InputDecoration(labelText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 16),
          Text(
            'Reference Folder',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _referenceFolders)
                  ChoiceChip(
                    label: Text(option),
                    selected: folder == option,
                    onSelected: (_) => onFolderChanged(option),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.description_outlined),
            label: Text(isSaving ? 'Saving...' : 'Save to Reference'),
          ),
        ],
      ),
    );
  }
}

class _WaitingForForm extends ConsumerWidget {
  const _WaitingForForm({
    required this.titleController,
    required this.waitingOnController,
    required this.notesController,
    required this.tagsController,
    required this.followUpDate,
    required this.projectId,
    required this.isSaving,
    required this.onProjectChanged,
    required this.onPickFollowUpDate,
    required this.onSubmit,
  });

  final TextEditingController titleController;
  final TextEditingController waitingOnController;
  final TextEditingController notesController;
  final TextEditingController tagsController;
  final DateTime? followUpDate;
  final String? projectId;
  final bool isSaving;
  final ValueChanged<String?> onProjectChanged;
  final VoidCallback onPickFollowUpDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];

    return SectionCard(
      title: 'Save as Waiting For',
      expandChild: true,
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: waitingOnController,
            decoration: const InputDecoration(
              labelText: 'Waiting on',
              hintText: 'Accountant, John, vendor, team...',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: projectId,
            decoration: const InputDecoration(
              labelText: 'Link to Project (optional)',
              prefixIcon: Icon(Icons.folder_open_outlined),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No linked project'),
              ),
              for (final project in projects)
                DropdownMenuItem<String?>(
                  value: project.id,
                  child: Text(project.title),
                ),
            ],
            onChanged: onProjectChanged,
          ),
          const SizedBox(height: 16),
          _DateButton(
            label: 'Follow-up Date',
            date: followUpDate,
            onPressed: onPickFollowUpDate,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tagsController,
            decoration:
                const InputDecoration(labelText: 'Tags, comma separated'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : onSubmit,
            icon: const Icon(Icons.hourglass_empty_outlined),
            label: Text(isSaving ? 'Saving...' : 'Save as Waiting For'),
          ),
        ],
      ),
    );
  }
}

class _TrashPanel extends StatelessWidget {
  const _TrashPanel({required this.isSaving, required this.onSubmit});

  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Trash Item',
      child: FilledButton.icon(
        onPressed: isSaving ? null : onSubmit,
        icon: const Icon(Icons.delete_outline),
        label: Text(isSaving ? 'Deleting...' : 'Delete Inbox Item'),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onPressed,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? label
        : '$label: ${date!.month}/${date!.day}/${date!.year}';

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

class _OutlookTargetDateFieldRich extends StatelessWidget {
  const _OutlookTargetDateFieldRich({
    required this.targetDate,
    required this.endDateTime,
    required this.allDay,
    required this.onInitialPick,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onAllDayChanged,
  });

  final DateTime? targetDate;
  final DateTime? endDateTime;
  final bool allDay;
  final VoidCallback onInitialPick;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final ValueChanged<bool> onAllDayChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = targetDate;
    final end = endDateTime ?? start?.add(const Duration(minutes: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: InkWell(
            onTap: start == null ? onInitialPick : null,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          start == null
                              ? 'Set Target Date'
                              : _summary(start, end, allDay),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: start == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        start == null
                            ? Icons.add_outlined
                            : Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                Container(height: 2, color: theme.colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _OutlookPickerBox(
                        label: 'Start date',
                        value: start == null
                            ? 'Select date'
                            : DateFormat('M/d/y').format(start),
                        icon: Icons.calendar_today_outlined,
                        onTap: onPickStartDate,
                      ),
                      _OutlookPickerBox(
                        label: 'Start time',
                        value: start == null || allDay
                            ? '--'
                            : DateFormat('h:mm a').format(start),
                        icon: Icons.keyboard_arrow_down_outlined,
                        onTap: allDay ? null : onPickStartTime,
                      ),
                      _OutlookPickerBox(
                        label: 'End time',
                        value: end == null || allDay
                            ? '--'
                            : DateFormat('h:mm a').format(end),
                        icon: Icons.keyboard_arrow_down_outlined,
                        onTap: allDay ? null : onPickEndTime,
                      ),
                      _OutlookAllDayToggle(
                        value: allDay,
                        onChanged: onAllDayChanged,
                      ),
                    ],
                  ),
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

  String _summary(DateTime start, DateTime? end, bool allDay) {
    if (allDay) {
      return '${DateFormat('EEE M/d/y').format(start)} All day';
    }
    final resolvedEnd = end ?? start.add(const Duration(minutes: 30));
    return '${DateFormat('EEE M/d/y h:mm a').format(start)} - '
        '${DateFormat('h:mm a').format(resolvedEnd)}';
  }
}

class _OutlookPickerBox extends StatelessWidget {
  const _OutlookPickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return SizedBox(
      width: 136,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: enabled ? 1 : 0.56,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      size: 18,
                      color: label == 'Start date'
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: enabled
                      ? theme.colorScheme.outlineVariant
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlookAllDayToggle extends StatelessWidget {
  const _OutlookAllDayToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Checkbox(
            value: value,
            onChanged: (selected) => onChanged(selected ?? false),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Text(
            'All day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextChips extends ConsumerWidget {
  const _ContextChips();

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
            ChoiceChip(
              label: Text(context.name),
              selected: selected == context.name,
              onSelected: (_) {
                ref.read(selectedContextProvider.notifier).state = context.name;
              },
            ),
        ],
      ),
    );
  }
}
