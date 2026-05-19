import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/archive/archive_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/dashboard/main_dashboard_screen.dart';
import '../../presentation/screens/contexts/context_management_screen.dart';
import '../../presentation/screens/horizons/horizons_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/inbox/inbox_screen.dart';
import '../../presentation/screens/next_actions/next_actions_screen.dart';
import '../../presentation/screens/next_7_days/next_7_days_screen.dart';
import '../../presentation/screens/processing/processing_screen.dart';
import '../../presentation/screens/project/project_detail_screen.dart';
import '../../presentation/screens/projects/projects_screen.dart';
import '../../presentation/screens/reference/reference_screen.dart';
import '../../presentation/screens/search/global_search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/someday/someday_maybe_screen.dart';
import '../../presentation/screens/task/task_detail_screen.dart';
import '../../presentation/screens/today/today_screen.dart';
import '../../presentation/screens/waiting_for/waiting_for_screen.dart';
import '../../presentation/screens/weekly_review/weekly_review_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(path: '/inbox', builder: (context, state) => const InboxScreen()),
      GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
      GoRoute(
        path: '/next-7-days',
        builder: (context, state) => const Next7DaysScreen(),
      ),
      GoRoute(
        path: '/processing/:itemId',
        builder: (context, state) {
          return ProcessingScreen(itemId: state.pathParameters['itemId']!);
        },
      ),
      GoRoute(
        path: '/project/:projectId',
        builder: (context, state) {
          return ProjectDetailScreen(
            projectId: state.pathParameters['projectId']!,
          );
        },
      ),
      GoRoute(
        path: '/next-actions',
        builder: (context, state) => const NextActionsScreen(),
      ),
      GoRoute(
        path: '/all-next-actions',
        builder: (context, state) => const NextActionsScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/contexts',
        builder: (context, state) => const ContextManagementScreen(),
      ),
      GoRoute(
        path: '/task/:taskId',
        builder: (context, state) {
          return TaskDetailScreen(taskId: state.pathParameters['taskId']!);
        },
      ),
      GoRoute(
        path: '/someday',
        builder: (context, state) => const SomedayMaybeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/waiting-for',
        builder: (context, state) => const WaitingForScreen(),
      ),
      GoRoute(
        path: '/reference',
        builder: (context, state) => const ReferenceScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/archive',
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/weekly-review',
        builder: (context, state) => const WeeklyReviewScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/horizons',
        builder: (context, state) => const HorizonsScreen(),
      ),
    ],
  );
});
