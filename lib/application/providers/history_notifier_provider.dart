import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/history_constants.dart';
import '../../domain/entities/history_entry.dart';
import '../../injection_container.dart';

enum HistoryDateRange { all, today, last7Days }

extension HistoryDateRangeLabel on HistoryDateRange {
  String get label {
    return switch (this) {
      HistoryDateRange.all => 'All',
      HistoryDateRange.today => 'Today',
      HistoryDateRange.last7Days => '7 days',
    };
  }
}

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  HistoryNotifier.new,
);

final historySearchQueryProvider = StateProvider<String>((ref) => '');

final historyActionFilterProvider =
    StateProvider<Set<HistoryAction>>((ref) => <HistoryAction>{});

final historyDateRangeProvider =
    StateProvider<HistoryDateRange>((ref) => HistoryDateRange.all);

final filteredHistoryEntriesProvider = Provider<List<HistoryEntry>>((ref) {
  final entries = ref.watch(historyNotifierProvider).valueOrNull ?? const [];
  final query = ref.watch(historySearchQueryProvider).trim().toLowerCase();
  final actions = ref.watch(historyActionFilterProvider);
  final dateRange = ref.watch(historyDateRangeProvider);
  final now = DateTime.now();

  return entries.where((entry) {
    final matchesQuery = query.isEmpty ||
        entry.description.toLowerCase().contains(query) ||
        entry.entityType.toLowerCase().contains(query) ||
        (entry.details?.toLowerCase().contains(query) ?? false);
    final matchesAction = actions.isEmpty || actions.contains(entry.action);
    final matchesDate = switch (dateRange) {
      HistoryDateRange.all => true,
      HistoryDateRange.today => entry.timestamp.year == now.year &&
          entry.timestamp.month == now.month &&
          entry.timestamp.day == now.day,
      HistoryDateRange.last7Days => !entry.timestamp.isBefore(
          now.subtract(const Duration(days: 7)),
        ),
    };
    return matchesQuery && matchesAction && matchesDate;
  }).toList();
});

class HistoryNotifier extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() async {
    ref.watch(historyRefreshSignalProvider);
    // Master Spec Part 4 & Part 5: keep the audit trail to the last 6 weeks.
    final pruneResult = await ref.read(logHistoryEntryUseCaseProvider).prune();
    final pruneFailure = pruneResult.match((failure) => failure, (_) => null);
    if (pruneFailure != null) {
      throw Exception(pruneFailure.message);
    }

    final since = DateTime.now().subtract(
      const Duration(days: historyRetentionDays),
    );
    final result = await ref.watch(historyRepositoryProvider).getRecent(
          since: since,
        );
    return result.match(
      (failure) => throw Exception(failure.message),
      (entries) => entries,
    );
  }

  Future<void> pruneNow() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
