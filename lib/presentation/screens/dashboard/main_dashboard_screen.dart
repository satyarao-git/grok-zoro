import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../injection_container.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount = ref.watch(inboxCountProvider);
    final nextActions = ref.watch(allNextActionsProvider).valueOrNull ?? [];
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? [];
    final readyItems = ref.watch(readyToActivateProvider);
    final waitingFor = ref.watch(waitingForProvider).valueOrNull ?? [];
    final calendarEntries = ref.watch(calendarEntriesProvider);
    final archiveItems = ref.watch(archiveItemsProvider);

    return ZoroAppScaffold(
      title: 'Dashboard',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final cards = [
            _MetricCard(
              label: 'Inbox',
              value: inboxCount.toString(),
              icon: Icons.inbox_outlined,
              onTap: () => context.push('/inbox'),
            ),
            _MetricCard(
              label: 'Next Actions',
              value: nextActions.length.toString(),
              icon: Icons.check_circle_outline,
              onTap: () => context.push('/all-next-actions'),
            ),
            _MetricCard(
              label: 'Active Projects',
              value: projects.length.toString(),
              icon: Icons.folder_copy_outlined,
              onTap: () => context.push('/projects'),
            ),
            _MetricCard(
              label: 'Ready to Activate',
              value: readyItems.length.toString(),
              icon: Icons.bolt_outlined,
              onTap: () => context.push('/someday'),
            ),
            _MetricCard(
              label: 'Waiting For',
              value: waitingFor.length.toString(),
              icon: Icons.hourglass_empty_outlined,
              onTap: () => context.push('/waiting-for'),
            ),
            _MetricCard(
              label: 'Calendar',
              value: calendarEntries.length.toString(),
              icon: Icons.calendar_month_outlined,
              onTap: () => context.push('/calendar'),
            ),
            _MetricCard(
              label: 'Archive',
              value: archiveItems.length.toString(),
              icon: Icons.archive_outlined,
              onTap: () => context.push('/archive'),
            ),
          ];

          return ListView(
            children: [
              const PageTitleBand(
                title: 'A Trusted System',
                subtitle:
                    'Capture what has your attention, clarify the next move, and keep review friction low.',
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.9 : 1.35,
                physics: const NeverScrollableScrollPhysics(),
                children: cards,
              ),
              const SizedBox(height: 24),
              if (projects.isNotEmpty)
                SectionCard(
                  title: 'Current focus',
                  trailing: const StatusChip(label: 'Active'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projects.first.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: projects.first.progress,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(projects.first.desiredOutcome),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
