import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../providers/calendar_view_providers.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(selectedCalendarModeProvider);
    final selectedDate = ref.watch(selectedCalendarDateProvider);
    final range = CalendarDateRange.from(selectedDate, mode);
    final entries = ref.watch(calendarAgendaEntriesProvider(range));

    return ZoroAppScaffold(
      title: 'Calendar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalendarToolbar(
            mode: mode,
            selectedDate: selectedDate,
            range: range,
          ),
          const SizedBox(height: 14),
          _ContextFilters(range: range),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (mode) {
                CalendarViewMode.day => _DayView(
                    key: ValueKey('day-${selectedDate.toIso8601String()}'),
                    selectedDate: selectedDate,
                    entries: entries,
                  ),
                CalendarViewMode.week => _WeekView(
                    key: ValueKey('week-${range.start.toIso8601String()}'),
                    range: range,
                    entries: entries,
                  ),
                CalendarViewMode.month => _MonthView(
                    key: ValueKey('month-${range.start.toIso8601String()}'),
                    selectedDate: selectedDate,
                    range: range,
                    entries: entries,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarToolbar extends ConsumerWidget {
  const _CalendarToolbar({
    required this.mode,
    required this.selectedDate,
    required this.range,
  });

  final CalendarViewMode mode;
  final DateTime selectedDate;
  final CalendarDateRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(value: CalendarViewMode.day, label: Text('Day')),
              ButtonSegment(value: CalendarViewMode.week, label: Text('Week')),
              ButtonSegment(
                value: CalendarViewMode.month,
                label: Text('Month'),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              ref.read(selectedCalendarModeProvider.notifier).state =
                  selection.single;
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            final selectedDateController =
                ref.read(selectedCalendarDateProvider.notifier);
            _pickDate(
              context,
              selectedDate,
              (date) => selectedDateController.state = date,
            );
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(_periodLabel(range, mode)),
        ),
        OutlinedButton.icon(
          onPressed: () {
            final now = DateTime.now();
            ref.read(selectedCalendarDateProvider.notifier).state =
                DateTime(now.year, now.month, now.day);
          },
          icon: const Icon(Icons.today_outlined),
          label: const Text('Today'),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime selectedDate,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 10),
      initialDate: selectedDate,
    );
    if (!context.mounted || picked == null) {
      return;
    }
    onPicked(DateTime(picked.year, picked.month, picked.day));
  }

  String _periodLabel(CalendarDateRange range, CalendarViewMode mode) {
    return switch (mode) {
      CalendarViewMode.day => DateFormat('MMMM d, y').format(range.start),
      CalendarViewMode.week =>
        '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d, y').format(range.end)}',
      CalendarViewMode.month => DateFormat('MMMM y').format(range.start),
    };
  }
}

class _ContextFilters extends ConsumerWidget {
  const _ContextFilters({required this.range});

  final CalendarDateRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(availableCalendarContextsProvider);
    final selected = ref.watch(calendarContextFilterProvider);
    final count = ref.watch(calendarAgendaEntriesProvider(range)).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: StatusChip(label: '$count scheduled'),
          ),
          FilterChip(
            selected: selected == null,
            label: const Text('All Contexts'),
            onSelected: (_) {
              ref.read(calendarContextFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          for (final contextName in contexts) ...[
            FilterChip(
              selected: selected == contextName,
              label: Text(contextName),
              onSelected: (_) {
                ref.read(calendarContextFilterProvider.notifier).state =
                    selected == contextName ? null : contextName;
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _WeekView extends StatefulWidget {
  const _WeekView({
    required this.range,
    required this.entries,
    super.key,
  });

  final CalendarDateRange range;
  final List<CalendarAgendaEntry> entries;

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var index = 0; index < 7; index++)
        widget.range.start.add(Duration(days: index)),
    ];

    if (widget.entries.isEmpty) {
      return const _CalendarEmptyState(
        title: 'No actions this week',
        message: 'Dated next actions and projects will appear here.',
      );
    }

    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final day in days)
              SizedBox(
                width: 230,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _WeekDayColumn(
                    day: day,
                    entries: widget.entries.where((entry) {
                      return _sameDay(entry.date, day);
                    }).toList(growable: false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayColumn extends StatelessWidget {
  const _WeekDayColumn({
    required this.day,
    required this.entries,
  });

  final DateTime day;
  final List<CalendarAgendaEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _isToday(day);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: today
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE d').format(day),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: today
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No actions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _AgendaCard(entry: entries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthView extends ConsumerWidget {
  const _MonthView({
    required this.selectedDate,
    required this.range,
    required this.entries,
    super.key,
  });

  final DateTime selectedDate;
  final CalendarDateRange range;
  final List<CalendarAgendaEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthStart = DateTime(selectedDate.year, selectedDate.month);
    final gridStart =
        monthStart.subtract(Duration(days: monthStart.weekday % 7));
    final days = [
      for (var index = 0; index < 42; index++)
        gridStart.add(Duration(days: index)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                for (final label in const [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                ])
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final dayEntries = entries.where((entry) {
                    return _sameDay(entry.date, day);
                  }).toList(growable: false);
                  return _MonthDayCell(
                    day: day,
                    inMonth: day.month == selectedDate.month,
                    entries: dayEntries,
                    onTap: () {
                      ref.read(selectedCalendarDateProvider.notifier).state =
                          day;
                      ref.read(selectedCalendarModeProvider.notifier).state =
                          CalendarViewMode.day;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.inMonth,
    required this.entries,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final List<CalendarAgendaEntry> entries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _isToday(day);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: today
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: inMonth ? 1 : 0.35,
                ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: today
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d').format(day),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: today ? FontWeight.w800 : FontWeight.w600,
                color: inMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (entries.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight,
                child: entries.length == 1
                    ? Icon(
                        Icons.circle,
                        size: 9,
                        color: theme.colorScheme.primary,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${entries.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({
    required this.selectedDate,
    required this.entries,
    super.key,
  });

  final DateTime selectedDate;
  final List<CalendarAgendaEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _CalendarEmptyState(
        title: 'No actions today',
        message: 'Choose another date or add target dates to your actions.',
      );
    }

    final untimed = entries.where((entry) => !_hasTime(entry.date)).toList();
    final timed = entries.where((entry) => _hasTime(entry.date)).toList();
    final visibleHours = _visibleTimelineHours(timed);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'All Day / Untimed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                if (untimed.isEmpty)
                  const Text('No untimed actions.')
                else
                  for (final entry in untimed) ...[
                    _AgendaCard(entry: entry),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final hour in visibleHours)
          _TimelineHourRow(
            hour: hour,
            entries: timed.where((entry) => entry.date.hour == hour).toList(),
          ),
      ],
    );
  }
}

class _TimelineHourRow extends StatelessWidget {
  const _TimelineHourRow({
    required this.hour,
    required this.entries,
  });

  final int hour;
  final List<CalendarAgendaEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat('h a').format(DateTime(2026, 1, 1, hour));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: entries.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        for (final entry in entries) ...[
                          _AgendaCard(entry: entry),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.entry});

  final CalendarAgendaEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProject = entry.type == CalendarAgendaEntryType.project;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(entry.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    entry.isRecurring
                        ? Icons.repeat_outlined
                        : isProject
                            ? Icons.folder_copy_outlined
                            : Icons.check_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.desiredOutcome != null) ...[
                const SizedBox(height: 6),
                Text(
                  entry.desiredOutcome!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _SoftChip(
                    label: entry.contextName,
                    icon: isProject
                        ? Icons.folder_outlined
                        : Icons.alternate_email_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  _SoftChip(
                    label: isProject
                        ? entry.badge
                        : entry.isRecurring
                            ? 'Repeats'
                            : _energyLabel(entry.energyLevel),
                    icon: isProject
                        ? Icons.flag_outlined
                        : entry.isRecurring
                            ? Icons.repeat_outlined
                            : Icons.battery_charging_full_outlined,
                    color: _energyColor(theme, entry.energyLevel, isProject),
                  ),
                  if (!isProject && _hasTime(entry.date))
                    _SoftChip(
                      label: _entryTimeRange(entry),
                      icon: Icons.schedule_outlined,
                      color: theme.colorScheme.tertiary,
                    ),
                  TextButton.icon(
                    onPressed: () => context.push(entry.route),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEmptyState extends StatelessWidget {
  const _CalendarEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 74,
            color: theme.colorScheme.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
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

String _energyLabel(EnergyLevel energyLevel) {
  return switch (energyLevel) {
    EnergyLevel.low => 'Low',
    EnergyLevel.medium => 'Medium',
    EnergyLevel.high => 'High',
  };
}

Color _energyColor(ThemeData theme, EnergyLevel energyLevel, bool isProject) {
  if (isProject) {
    return theme.colorScheme.secondary;
  }
  return switch (energyLevel) {
    EnergyLevel.low => Colors.green.shade700,
    EnergyLevel.medium => Colors.orange.shade800,
    EnergyLevel.high => Colors.red.shade700,
  };
}

bool _hasTime(DateTime date) {
  return date.hour != 0 || date.minute != 0 || date.second != 0;
}

List<int> _visibleTimelineHours(List<CalendarAgendaEntry> entries) {
  final hours = <int>{
    for (var hour = 7; hour <= 19; hour++) hour,
    for (final entry in entries) entry.date.hour,
  }.toList()
    ..sort();
  return hours;
}

String _entryTimeRange(CalendarAgendaEntry entry) {
  final start = DateFormat('h:mm a').format(entry.date);
  final end = entry.endDateTime == null
      ? null
      : DateFormat('h:mm a').format(entry.endDateTime!);
  return end == null ? start : '$start - $end';
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool _isToday(DateTime date) {
  return _sameDay(date, DateTime.now());
}
