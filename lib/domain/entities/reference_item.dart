class ReferenceItem {
  const ReferenceItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.notes,
    this.tags = const [],
    this.folder,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String? notes;
  final List<String> tags;
  final String? folder;
}
