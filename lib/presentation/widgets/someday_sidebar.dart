import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/someday_maybe_item.dart';
import '../providers/someday_filter_providers.dart';
import 'section_card.dart';

class SomedaySidebar extends ConsumerWidget {
  const SomedaySidebar({required this.items, super.key});

  final List<SomedayMaybeItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearFilter = ref.watch(somedayYearFilterProvider);
    final monthFilter = ref.watch(somedayMonthFilterProvider);
    final selectedTags = ref.watch(somedayTagsFilterProvider);
    final years = _yearCounts(items);
    final tags = _tagCounts(items);
    final selectedYear =
        yearFilter is SomedaySpecificYear ? yearFilter.year : null;
    final months = selectedYear == null
        ? const <int, int>{}
        : _monthCounts(
            items,
            selectedYear,
          );

    return SectionCard(
      title: 'Filters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${items.length} Someday/Maybe items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          _SidebarSectionTitle(
            icon: Icons.calendar_today_outlined,
            label: 'Year',
          ),
          const SizedBox(height: 8),
          _FilterListTile(
            label: 'All Years',
            selected: yearFilter is AllSomedayYears,
            onTap: () => ref
                .read(somedayYearFilterProvider.notifier)
                .select(const AllSomedayYears()),
          ),
          for (final entry in years.entries)
            _FilterListTile(
              label: '${entry.key} (${entry.value})',
              selected: yearFilter is SomedaySpecificYear &&
                  yearFilter.year == entry.key,
              onTap: () => ref
                  .read(somedayYearFilterProvider.notifier)
                  .select(SomedaySpecificYear(entry.key)),
            ),
          _FilterListTile(
            label: 'No Date (0)',
            selected: yearFilter is SomedayNoDateYear,
            onTap: () => ref
                .read(somedayYearFilterProvider.notifier)
                .select(const SomedayNoDateYear()),
          ),
          if (selectedYear != null) ...[
            const SizedBox(height: 20),
            _SidebarSectionTitle(
              icon: Icons.date_range_outlined,
              label: 'Month',
            ),
            const SizedBox(height: 8),
            _FilterListTile(
              label: 'All Months',
              selected: monthFilter == null,
              onTap: () =>
                  ref.read(somedayMonthFilterProvider.notifier).select(null),
            ),
            for (final entry in months.entries)
              _FilterListTile(
                label: '${_monthName(entry.key)} (${entry.value})',
                selected: monthFilter == entry.key,
                onTap: () => ref
                    .read(somedayMonthFilterProvider.notifier)
                    .select(entry.key),
              ),
          ],
          const SizedBox(height: 20),
          _SidebarSectionTitle(
            icon: Icons.local_offer_outlined,
            label: 'Tags',
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.clear_all_outlined, size: 18),
              label: const Text('All Tags'),
              onPressed: selectedTags.isEmpty
                  ? null
                  : ref.read(somedayTagsFilterProvider.notifier).clear,
            ),
          ),
          const SizedBox(height: 8),
          if (tags.isEmpty)
            Text(
              'No tags yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in tags.entries)
                  FilterChip(
                    label: Text('${entry.key} (${entry.value})'),
                    selected: selectedTags.contains(entry.key),
                    onSelected: (_) => ref
                        .read(somedayTagsFilterProvider.notifier)
                        .toggle(entry.key),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Map<int, int> _yearCounts(List<SomedayMaybeItem> items) {
    final counts = <int, int>{};
    for (final item in items) {
      counts.update(item.reconsiderDate.year, (count) => count + 1,
          ifAbsent: () => 1);
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<int, int> _monthCounts(List<SomedayMaybeItem> items, int year) {
    final counts = <int, int>{};
    for (final item
        in items.where((item) => item.reconsiderDate.year == year)) {
      counts.update(item.reconsiderDate.month, (count) => count + 1,
          ifAbsent: () => 1);
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, int> _tagCounts(List<SomedayMaybeItem> items) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final tag in item.tags) {
        counts.update(tag, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  String _monthName(int month) => _monthNames[month - 1];
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _FilterListTile extends StatelessWidget {
  const _FilterListTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selected: selected,
      selectedColor: Theme.of(context).colorScheme.primary,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, size: 18) : null,
      onTap: onTap,
    );
  }
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
