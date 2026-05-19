class WaitingForItem {
  const WaitingForItem({
    required this.id,
    required this.title,
    required this.person,
    required this.createdAt,
    this.projectId,
    this.followUpDate,
    this.notes,
    this.tags = const [],
    this.isResolved = false,
  });

  final String id;
  final String title;
  final String person;
  final String? projectId;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final String? notes;
  final List<String> tags;
  final bool isResolved;
}
