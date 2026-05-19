import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/horizon.dart';
import 'package:grok_zoro/domain/repositories/horizons_repository.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('horizons load persisted values and save edits', () async {
    final repository = _FakeHorizonsRepository(
      const HorizonsOfFocus(
        horizons: [
          Horizon(
            level: HorizonLevel.vision,
            title: 'Vision (3-5 years)',
            description: 'A calm operating system for work.',
            alignmentScore: 0.8,
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        horizonsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(horizonsProvider);
    await Future<void>.delayed(Duration.zero);

    final vision = container
        .read(horizonsProvider)
        .horizons
        .firstWhere((horizon) => horizon.level == HorizonLevel.vision);
    expect(vision.description, 'A calm operating system for work.');

    container
        .read(horizonsProvider.notifier)
        .updateAlignmentScore(HorizonLevel.vision, 0.9);
    await Future<void>.delayed(Duration.zero);

    final savedVision = repository.saved.horizons
        .firstWhere((horizon) => horizon.level == HorizonLevel.vision);
    expect(savedVision.alignmentScore, 0.9);
  });
}

class _FakeHorizonsRepository implements HorizonsRepository {
  _FakeHorizonsRepository(this.saved);

  HorizonsOfFocus saved;

  @override
  Future<Either<Failure, HorizonsOfFocus>> getHorizons() async {
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> saveHorizons(HorizonsOfFocus horizons) async {
    saved = horizons;
    return right(null);
  }
}
