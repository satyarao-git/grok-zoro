import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/horizon.dart';
import '../../../injection_container.dart';
import '../../widgets/page_title_band.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class HorizonsScreen extends ConsumerWidget {
  const HorizonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizons = ref.watch(horizonsProvider).horizons;
    final summary = ref.watch(horizonsAlignmentProvider);

    return ZoroAppScaffold(
      title: 'Horizons of Focus',
      child: ListView(
        children: [
          PageTitleBand(
            title: 'Horizons of Focus',
            subtitle:
                'Review your Horizons of Focus to keep every daily action, project, and goal aligned with your long-term "purpose and vision."',
            trailing: StatusChip(
              label: '${summary.alignedCount}/${summary.totalCount} aligned',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.describedCount}/${summary.totalCount} horizons have notes.',
          ),
          const SizedBox(height: 24),
          for (final horizon in horizons) ...[
            _HorizonCard(horizon: horizon),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _HorizonCard extends ConsumerWidget {
  const _HorizonCard({required this.horizon});

  final Horizon horizon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = horizon.alignmentScore ?? 0.5;

    return SectionCard(
      title: '${_altitudeLabel(horizon.level)} - ${horizon.title}',
      trailing: StatusChip(label: _scoreLabel(score)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: ValueKey('${horizon.level.name}-notes'),
            initialValue: horizon.description,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Notes and alignment checks',
            ),
            onChanged: (value) {
              ref
                  .read(horizonsProvider.notifier)
                  .updateDescription(horizon.level, value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Alignment'),
              Expanded(
                child: Slider(
                  value: score,
                  divisions: 10,
                  label: '${(score * 100).round()}%',
                  onChanged: (value) {
                    ref
                        .read(horizonsProvider.notifier)
                        .updateAlignmentScore(horizon.level, value);
                  },
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${(score * 100).round()}%',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _altitudeLabel(HorizonLevel level) {
    return switch (level) {
      HorizonLevel.purposeAndPrinciples => '50,000 ft',
      HorizonLevel.vision => '40,000 ft',
      HorizonLevel.goals => '30,000 ft',
      HorizonLevel.areasOfFocus => '20,000 ft',
      HorizonLevel.projects => '10,000 ft',
      HorizonLevel.nextActions => 'Ground',
    };
  }

  String _scoreLabel(double score) {
    if (score >= 0.8) {
      return 'Aligned';
    }
    if (score >= 0.5) {
      return 'Needs review';
    }
    return 'Misaligned';
  }
}
