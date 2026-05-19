import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../injection_container.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/zoro_app_scaffold.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);

    return ZoroAppScaffold(
      title: 'Inbox',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleBand(title: 'Captured Items Pending to Clarify'),
          const SizedBox(height: 16),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SectionCard(
                title: 'Captured Items Pending to Clarify',
                child: Text(error.toString()),
              ),
              data: (items) => SectionCard(
                title: 'Captured Items Pending to Clarify',
                expandChild: true,
                child: items.isEmpty
                    ? const Text('Inbox is clear.')
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.radio_button_unchecked),
                            title: Text(item.title),
                            subtitle: Text(
                              'Captured ${item.capturedAt.month}/${item.capturedAt.day}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/processing/${item.id}'),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
