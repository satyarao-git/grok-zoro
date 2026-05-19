import 'package:flutter/material.dart';

import 'capture_bottom_sheet.dart';

class VoiceFabWidget extends StatelessWidget {
  const VoiceFabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      tooltip: 'Capture to Inbox',
      heroTag: 'voice-input-fab',
      onPressed: () => _showCaptureSheet(context),
      icon: const Icon(Icons.edit_note_outlined),
      label: const Text("What's on your mind?"),
    );
  }

  Future<void> _showCaptureSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const CaptureBottomSheet(),
    );
  }
}
