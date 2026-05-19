import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../providers/next_action_view_providers.dart';
import '../../widgets/next_action_widgets.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class Next7DaysScreen extends ConsumerWidget {
  const Next7DaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksValue = ref.watch(allNextActionsProvider);
    final projectsValue = ref.watch(activeProjectsProvider);
    final filter = ref.watch(next7DaysFilterProvider);
    final today = DateTime.now();
    final range = NextActionDateRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day + 6),
    );

    return ZoroAppScaffold(
      title: 'Next 7 Days',
      child: tasksValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Next 7 Days',
          child: Text(error.toString()),
        ),
        data: (_) {
          final projects = projectsValue.valueOrNull ?? const <Project>[];
          final tasks = ref.watch(tasksByDateRangeProvider(range));
          final scheduledProjects =
              ref.watch(projectsByDateRangeProvider(range));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<Next7DaysFilter>(
                selected: {filter},
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: Next7DaysFilter.nextActions,
                    label: Text('Next Actions'),
                  ),
                  ButtonSegment(
                    value: Next7DaysFilter.projects,
                    label: Text('Projects'),
                  ),
                  ButtonSegment(value: Next7DaysFilter.all, label: Text('All')),
                ],
                onSelectionChanged: (selection) {
                  ref.read(next7DaysFilterProvider.notifier).state =
                      selection.single;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _Next7DaysList(
                  filter: filter,
                  tasks: tasks,
                  projects: projects,
                  scheduledProjects: scheduledProjects,
                  range: range,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Next7DaysList extends StatelessWidget {
  const _Next7DaysList({
    required this.filter,
    required this.tasks,
    required this.projects,
    required this.scheduledProjects,
    required this.range,
  });

  final Next7DaysFilter filter;
  final List<Task> tasks;
  final List<Project> projects;
  final List<Project> scheduledProjects;
  final NextActionDateRange range;

  @override
  Widget build(BuildContext context) {
    final hasTasks = filter != Next7DaysFilter.projects && tasks.isNotEmpty;
    final hasProjects =
        filter != Next7DaysFilter.nextActions && scheduledProjects.isNotEmpty;
    if (!hasTasks && !hasProjects) {
      return const ZoroEmptyState(
        icon: Icons.date_range_outlined,
        title: 'Nothing scheduled in the next 7 days',
        message: 'Dated next actions and projects will appear here.',
      );
    }

    final days = [
      for (var index = 0; index < 7; index++)
        range.start.add(Duration(days: index)),
    ];

    return ListView.separated(
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = days[index];
        final dayTasks = filter == Next7DaysFilter.projects
            ? const <Task>[]
            : tasks
                .where((task) => _sameDay(effectiveTaskDate(task), day))
                .toList(growable: false);
        final dayProjects = filter == Next7DaysFilter.nextActions
            ? const <Project>[]
            : scheduledProjects
                .where(
                    (project) => _sameDay(project.targetCompletionDate!, day))
                .toList(growable: false);
        final count = dayTasks.length + dayProjects.length;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return ExpansionTile(
          initiallyExpanded: index <= 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            _dayLabel(day),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          trailing: StatusChip(label: '$count'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final task in dayTasks) ...[
              NextActionTaskCard(
                task: task,
                projects: projects,
                showDate: true,
              ),
              const SizedBox(height: 10),
            ],
            for (final project in dayProjects) ...[
              ScheduledProjectCard(project: project),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  String _dayLabel(DateTime day) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    if (_sameDay(day, today)) {
      return 'Today • ${DateFormat('MMM d').format(day)}';
    }
    if (_sameDay(day, tomorrow)) {
      return 'Tomorrow • ${DateFormat('MMM d').format(day)}';
    }
    return '${DateFormat('EEEE').format(day)} • ${DateFormat('MMM d').format(day)}';
  }
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
