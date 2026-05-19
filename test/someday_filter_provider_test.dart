import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/someday_maybe_item.dart';
import 'package:grok_zoro/injection_container.dart';
import 'package:grok_zoro/presentation/providers/someday_filter_providers.dart';

void main() {
  test('someday filters combine year, month, and selected tags', () async {
    final container = ProviderContainer(
      overrides: [
        somedayMaybeProvider.overrideWith(() => _SomedayStub()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(somedayMaybeProvider.future);

    expect(container.read(filteredSomedayMaybeProvider), hasLength(4));

    container
        .read(somedayYearFilterProvider.notifier)
        .select(const SomedaySpecificYear(2027));
    expect(
      container.read(filteredSomedayMaybeProvider).map((item) => item.title),
      ['Renew passport', 'Research conference'],
    );

    container.read(somedayMonthFilterProvider.notifier).select(3);
    expect(
      container.read(filteredSomedayMaybeProvider).map((item) => item.title),
      ['Research conference'],
    );

    container.read(somedayTagsFilterProvider.notifier).toggle('travel');
    expect(container.read(filteredSomedayMaybeProvider), isEmpty);

    container.read(somedayTagsFilterProvider.notifier).clear();
    container.read(somedayTagsFilterProvider.notifier).toggle('career');
    expect(
      container.read(filteredSomedayMaybeProvider).map((item) => item.title),
      ['Research conference'],
    );
  });
}

class _SomedayStub extends SomedayMaybeNotifier {
  @override
  Future<List<SomedayMaybeItem>> build() async {
    return [
      SomedayMaybeItem(
        id: 'someday-1',
        title: 'Plan cabin trip',
        reconsiderDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026, 1, 1),
        tags: const ['travel'],
      ),
      SomedayMaybeItem(
        id: 'someday-2',
        title: 'Buy synthesizer',
        reconsiderDate: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 1, 1),
        tags: const ['music'],
      ),
      SomedayMaybeItem(
        id: 'someday-3',
        title: 'Renew passport',
        reconsiderDate: DateTime(2027, 2, 1),
        createdAt: DateTime(2026, 1, 1),
        tags: const ['travel'],
      ),
      SomedayMaybeItem(
        id: 'someday-4',
        title: 'Research conference',
        reconsiderDate: DateTime(2027, 3, 12),
        createdAt: DateTime(2026, 1, 1),
        tags: const ['career'],
      ),
    ];
  }
}
