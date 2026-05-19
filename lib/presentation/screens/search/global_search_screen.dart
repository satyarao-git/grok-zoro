import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../injection_container.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class GlobalSearchScreen extends ConsumerWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(globalSearchResultsProvider);
    final grouped = _groupResults(results);

    return ZoroAppScaffold(
      title: 'Search',
      child: ListView(
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search Zoro',
              prefixIcon: Icon(Icons.search_outlined),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 16),
          if (query.trim().isEmpty)
            const SectionCard(
              title: 'Search everything',
              child: Text(
                'Find inbox captures, projects, next actions, Reference, Waiting For, Someday/Maybe items, and horizons.',
              ),
            )
          else if (results.isEmpty)
            SectionCard(
              title: 'No results',
              child: Text('No trusted-system items match "$query".'),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final entry in grouped.entries) ...[
              SectionCard(
                title: entry.key,
                trailing: StatusChip(label: '${entry.value.length}'),
                child: Column(
                  children: [
                    for (final result in entry.value)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(result.title),
                        subtitle: Text(
                          result.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(result.route),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Map<String, List<SearchResult>> _groupResults(List<SearchResult> results) {
    final grouped = <String, List<SearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.category, () => []).add(result);
    }
    return grouped;
  }
}
