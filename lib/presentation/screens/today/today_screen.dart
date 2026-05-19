import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../providers/next_action_view_providers.dart';
import '../../widgets/next_action_widgets.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksValue = ref.watch(allNextActionsProvider);
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
    final today = DateTime.now();
    final range = NextActionDateRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day),
      includeOverdue: true,
    );

    return ZoroAppScaffold(
      title: 'Today',
      child: tasksValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Today',
          child: Text(error.toString()),
        ),
        data: (_) {
          final summary = ref.watch(todayActionSummaryProvider);
          final tasks = ref.watch(tasksByDateRangeProvider(range));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                title: 'Today',
                trailing: StatusChip(
                  label:
                      '${summary.dueToday} actions due today • ${summary.overdue} overdue',
                ),
                child: const Text(
                  'Focus on dated next actions that need attention now.',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: tasks.isEmpty
                    ? const ZoroEmptyState(
                        icon: Icons.today_outlined,
                        title: 'No actions due today — great job!',
                        message:
                            'Anything dated for today or overdue will show up here.',
                      )
                    : _TodayGroupedList(tasks: tasks, projects: projects),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayGroupedList extends StatelessWidget {
  const _TodayGroupedList({
    required this.tasks,
    required this.projects,
  });

  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final contextNames = tasks.map((task) => task.context.name).toSet().toList()
      ..sort();

    return ListView.separated(
      itemCount: contextNames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final contextName = contextNames[index];
        final groupedTasks = tasks
            .where((task) => task.context.name == contextName)
            .toList(growable: false);

        return SectionCard(
          title: contextName,
          trailing: StatusChip(label: '${groupedTasks.length}'),
          child: Column(
            children: [
              for (final task in groupedTasks) ...[
                NextActionTaskCard(
                  task: task,
                  projects: projects,
                  showDate: true,
                ),
                if (task != groupedTasks.last) const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}
