import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../injection_container.dart';
import 'voice_fab_widget.dart';

class ZoroAppScaffold extends ConsumerWidget {
  const ZoroAppScaffold({
    required this.title,
    required this.child,
    this.actions,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  static const _destinations = [
    _NavDestination('Dashboard', Icons.grid_view_outlined, '/dashboard'),
    _NavDestination('Inbox', Icons.inbox_outlined, '/inbox'),
    _NavDestination(
      'Next Actions',
      Icons.checklist_outlined,
      '/all-next-actions',
      aliases: ['/next-actions'],
    ),
    _NavDestination('Someday/Maybe', Icons.bookmark_border, '/someday'),
    _NavDestination('Projects', Icons.folder_open_outlined, '/projects'),
    _NavDestination('Calendar', Icons.calendar_month_outlined, '/calendar'),
    _NavDestination(
      'Weekly Review',
      Icons.fact_check_outlined,
      '/weekly-review',
    ),
    _NavDestination(
      'Waiting for',
      Icons.hourglass_empty_outlined,
      '/waiting-for',
    ),
    _NavDestination('Reference', Icons.folder_open_outlined, '/reference'),
    _NavDestination('Contexts', Icons.label_outline, '/contexts'),
    _NavDestination('Horizons', Icons.flight_takeoff_outlined, '/horizons'),
    _NavDestination('Search', Icons.search_outlined, '/search'),
    _NavDestination('Archive', Icons.archive_outlined, '/archive'),
    _NavDestination('Settings', Icons.settings_outlined, '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final settings = ref.watch(appSettingsProvider);
    final canGoBack = Navigator.of(context).canPop();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 1100;
        return Scaffold(
          appBar: useRail
              ? null
              : AppBar(
                  title: Text(title),
                  actions: [
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => context.push('/search'),
                      icon: const Icon(Icons.search_outlined),
                    ),
                    ...?actions,
                  ],
                ),
          drawer: useRail ? null : _NavigationDrawer(location: location),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (useRail) _NavigationSideRail(location: location),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          useRail ? 28 : 24,
                          24,
                          24,
                        ),
                        child: canGoBack
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => context.pop(),
                                    icon: const Icon(Icons.arrow_back_outlined),
                                    label: const Text('Back'),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(child: child),
                                ],
                              )
                            : child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              settings.voiceCaptureEnabled ? const VoiceFabWidget() : null,
        );
      },
    );
  }
}

class _NavDestination {
  const _NavDestination(
    this.label,
    this.icon,
    this.path, {
    this.aliases = const [],
  });

  final String label;
  final IconData icon;
  final String path;
  final List<String> aliases;
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _selectedIndex(location),
      onDestinationSelected: (index) {
        Navigator.of(context).pop();
        context.go(ZoroAppScaffold._destinations[index].path);
      },
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 16, 16),
          child: Text(
            'Zoro',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        for (final destination in ZoroAppScaffold._destinations)
          NavigationDrawerDestination(
            icon: Icon(destination.icon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}

class _NavigationSideRail extends StatelessWidget {
  const _NavigationSideRail({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: NavigationRail(
        extended: true,
        scrollable: true,
        minExtendedWidth: 224,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
          size: 23,
        ),
        unselectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 22,
        ),
        selectedLabelTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: Theme.of(context).colorScheme.primary.withValues(
              alpha: 0.1,
            ),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (index) {
          context.go(ZoroAppScaffold._destinations[index].path);
        },
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: Text(
            'Zoro',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        destinations: [
          for (final destination in ZoroAppScaffold._destinations)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}

int _selectedIndex(String location) {
  final index = ZoroAppScaffold._destinations.indexWhere((item) {
    if (item.path == '/dashboard') {
      return location == item.path;
    }
    return location.startsWith(item.path) ||
        item.aliases.any((alias) => location.startsWith(alias));
  });

  return index < 0 ? 0 : index;
}
