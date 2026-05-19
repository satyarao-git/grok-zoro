import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../injection_container.dart';
import '../../providers/next_action_view_providers.dart';
import '../../widgets/next_action_widgets.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class NextActionsScreen extends ConsumerWidget {
  const NextActionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksValue = ref.watch(allNextActionsProvider);
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
    final view = ref.watch(allNextActionsViewProvider);

    return ZoroAppScaffold(
      title: 'Next Actions',
      child: tasksValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SectionCard(
          title: 'Next Actions',
          child: Text(error.toString()),
        ),
        data: (tasks) {
          final today = DateTime.now();
          final todayRange = NextActionDateRange(
            start: today,
            end: today,
            includeOverdue: true,
          );
          final next7DaysRange = NextActionDateRange(
            start: today,
            end: today.add(const Duration(days: 6)),
            includeOverdue: true,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageTitleBand(title: 'Next Actions'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<AllNextActionsView>(
                  selected: {view},
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: AllNextActionsView.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: AllNextActionsView.today,
                      label: Text('Today'),
                    ),
                    ButtonSegment(
                      value: AllNextActionsView.next7Days,
                      label: Text('Next 7 days'),
                    ),
                    ButtonSegment(
                      value: AllNextActionsView.byContext,
                      label: Text('By Context'),
                    ),
                    ButtonSegment(
                      value: AllNextActionsView.byProject,
                      label: Text('By project'),
                    ),
                  ],
                  onSelectionChanged: (selection) {
                    ref.read(allNextActionsViewProvider.notifier).state =
                        selection.single;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (view) {
                  AllNextActionsView.all => _AllActionsView(
                      tasks: tasks,
                      projects: projects,
                    ),
                  AllNextActionsView.today => _DateFilteredActionsView(
                      title: 'Today',
                      tasks: ref.watch(tasksByDateRangeProvider(todayRange)),
                      projects: projects,
                    ),
                  AllNextActionsView.next7Days => _DateFilteredActionsView(
                      title: 'Next 7 days',
                      tasks: ref.watch(
                        tasksByDateRangeProvider(next7DaysRange),
                      ),
                      projects: projects,
                    ),
                  AllNextActionsView.byContext => _ByContextView(
                      tasks: tasks,
                      projects: projects,
                    ),
                  AllNextActionsView.byProject => _ByProjectView(
                      tasks: tasks,
                      projects: projects,
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateFilteredActionsView extends StatelessWidget {
  const _DateFilteredActionsView({
    required this.title,
    required this.tasks,
    required this.projects,
  });

  final String title;
  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return _TaskListPanel(
      title: title,
      tasks: tasks,
      projects: projects,
    );
  }
}

class _ByContextView extends ConsumerWidget {
  const _ByContextView({
    required this.tasks,
    required this.projects,
  });

  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider);
    final selected = ref.watch(selectedAllNextActionsContextProvider);
    final effectiveSelected =
        contexts.any((context) => context.name == selected)
            ? selected
            : contexts.first.name;
    final filteredTasks = ref.watch(nextActionsByContextProvider(
      effectiveSelected,
    ));

    final sidebar = SectionCard(
      title: 'Contexts',
      child: Column(
        children: [
          for (final context in contexts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              selected: effectiveSelected == context.name,
              leading: const Icon(Icons.label_outline),
              title: Text(context.name),
              trailing: Text(
                _countForContext(tasks, context.name).toString(),
              ),
              onTap: () {
                ref
                    .read(
                      selectedAllNextActionsContextProvider.notifier,
                    )
                    .state = context.name;
              },
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              sidebar,
              const SizedBox(height: 16),
              Expanded(
                child: _TaskListPanel(
                  title: effectiveSelected,
                  tasks: filteredTasks,
                  projects: projects,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 238, child: sidebar),
            const SizedBox(width: 18),
            Expanded(
              child: _TaskListPanel(
                title: effectiveSelected,
                tasks: filteredTasks,
                projects: projects,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AllActionsView extends ConsumerWidget {
  const _AllActionsView({
    required this.tasks,
    required this.projects,
  });

  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(allNextActionsSearchProvider).trim().toLowerCase();
    final filteredTasks = tasks.where((task) {
      final projectName = projectNameForTask(task, projects).toLowerCase();
      return query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.context.name.toLowerCase().contains(query) ||
          projectName.contains(query);
    }).toList(growable: false);

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_outlined),
            labelText: 'Search next actions',
          ),
          onChanged: (value) {
            ref.read(allNextActionsSearchProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _TaskListPanel(
            title: 'All',
            tasks: filteredTasks,
            projects: projects,
          ),
        ),
      ],
    );
  }
}

class _ByProjectView extends StatelessWidget {
  const _ByProjectView({
    required this.tasks,
    required this.projects,
  });

  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final projectTasks = tasks.where((task) => task.projectId != null).toList();
    if (projectTasks.isEmpty) {
      return const ZoroEmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No project-linked next actions',
        message: 'Actions linked to active projects will be grouped here.',
      );
    }

    return ListView(
      children: [
        for (final project in projects)
          if (projectTasks.any((task) => task.projectId == project.id))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  project.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                trailing: StatusChip(
                  label:
                      '${projectTasks.where((task) => task.projectId == project.id).length}',
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final task in projectTasks.where(
                    (task) => task.projectId == project.id,
                  )) ...[
                    NextActionTaskCard(task: task, projects: projects),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

class _TaskListPanel extends StatelessWidget {
  const _TaskListPanel({
    required this.title,
    required this.tasks,
    required this.projects,
  });

  final String title;
  final List<Task> tasks;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      trailing: StatusChip(label: '${tasks.length}'),
      expandChild: true,
      child: tasks.isEmpty
          ? const ZoroEmptyState(
              icon: Icons.checklist_outlined,
              title: 'No next actions here',
              message: 'Clarified actions will appear in this view.',
            )
          : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return NextActionTaskCard(
                  task: tasks[index],
                  projects: projects,
                  showDate: true,
                );
              },
            ),
    );
  }
}

int _countForContext(List<Task> tasks, String contextName) {
  return tasks.where((task) => task.context.name == contextName).length;
}
