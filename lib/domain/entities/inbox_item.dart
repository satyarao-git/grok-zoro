enum CaptureSource { manual, voice, shareSheet, import }

class InboxItem {
  const InboxItem({
    required this.id,
    required this.title,
    required this.capturedAt,
    this.notes,
    this.source = CaptureSource.manual,
  });

  final String id;
  final String title;
  final String? notes;
  final DateTime capturedAt;
  final CaptureSource source;
}
