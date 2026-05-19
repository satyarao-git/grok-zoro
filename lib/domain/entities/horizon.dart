enum HorizonLevel {
  purposeAndPrinciples,
  vision,
  goals,
  areasOfFocus,
  projects,
  nextActions,
}

class Horizon {
  const Horizon({
    required this.level,
    required this.title,
    required this.description,
    this.alignmentScore,
  });

  final HorizonLevel level;
  final String title;
  final String description;
  final double? alignmentScore;
}

class HorizonsOfFocus {
  const HorizonsOfFocus({required this.horizons});

  final List<Horizon> horizons;
}
