class SomedayMaybeItem {
  const SomedayMaybeItem({
    required this.id,
    required this.title,
    required this.reconsiderDate,
    required this.createdAt,
    this.notes,
    this.tags = const [],
  });

  final String id;
  final String title;
  final DateTime reconsiderDate;
  final DateTime createdAt;
  final String? notes;
  final List<String> tags;

  bool get isReadyToActivate {
    return !reconsiderDate.isAfter(DateTime.now());
  }
}
