import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/someday_maybe_item.dart';
import '../../injection_container.dart';

sealed class SomedayYearFilter {
  const SomedayYearFilter();
}

class AllSomedayYears extends SomedayYearFilter {
  const AllSomedayYears();
}

class SomedayNoDateYear extends SomedayYearFilter {
  const SomedayNoDateYear();
}

class SomedaySpecificYear extends SomedayYearFilter {
  const SomedaySpecificYear(this.year);

  final int year;
}

class SomedayYearFilterNotifier extends Notifier<SomedayYearFilter> {
  @override
  SomedayYearFilter build() => const AllSomedayYears();

  void select(SomedayYearFilter filter) {
    state = filter;
    ref.read(somedayMonthFilterProvider.notifier).clear();
  }
}

class SomedayMonthFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? month) {
    state = month;
  }

  void clear() {
    state = null;
  }
}

class SomedayTagsFilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String tag) {
    state = state.contains(tag)
        ? {...state.where((entry) => entry != tag)}
        : {...state, tag};
  }

  void clear() {
    state = const {};
  }
}

final somedayYearFilterProvider =
    NotifierProvider<SomedayYearFilterNotifier, SomedayYearFilter>(
  SomedayYearFilterNotifier.new,
);

final somedayMonthFilterProvider =
    NotifierProvider<SomedayMonthFilterNotifier, int?>(
  SomedayMonthFilterNotifier.new,
);

final somedayTagsFilterProvider =
    NotifierProvider<SomedayTagsFilterNotifier, Set<String>>(
  SomedayTagsFilterNotifier.new,
);

final filteredSomedayMaybeProvider = Provider<List<SomedayMaybeItem>>((ref) {
  final items = ref.watch(somedayMaybeProvider).valueOrNull ?? const [];
  final yearFilter = ref.watch(somedayYearFilterProvider);
  final monthFilter = ref.watch(somedayMonthFilterProvider);
  final selectedTags = ref.watch(somedayTagsFilterProvider);

  return items.where((item) {
    final matchesYear = switch (yearFilter) {
      AllSomedayYears() => true,
      SomedayNoDateYear() => false,
      SomedaySpecificYear(:final year) => item.reconsiderDate.year == year,
    };
    if (!matchesYear) {
      return false;
    }

    if (monthFilter != null && item.reconsiderDate.month != monthFilter) {
      return false;
    }

    if (selectedTags.isEmpty) {
      return true;
    }

    return selectedTags.every(item.tags.contains);
  }).toList(growable: false);
});
