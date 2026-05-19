import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../injection_container.dart';
import '../../widgets/next_action_widgets.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsValue = ref.watch(activeProjectsProvider);

    return ZoroAppScaffold(
      title: 'Projects',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleBand(title: 'Projects'),
          const SizedBox(height: 16),
          Expanded(
            child: projectsValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SectionCard(
                title: 'Projects',
                child: Text(error.toString()),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return const ZoroEmptyState(
                    icon: Icons.folder_open_outlined,
                    title: 'No active projects',
                    message:
                        'Clarify a multi-step outcome to create a project.',
                  );
                }

                return ListView.separated(
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child: const Icon(Icons.folder_open_outlined),
                        ),
                        title: Text(
                          project.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        subtitle: Text(
                          project.desiredOutcome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusChip(
                              label:
                                  '${(project.progress * 100).round()}% complete',
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => context.push('/project/${project.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
