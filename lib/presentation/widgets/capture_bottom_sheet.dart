import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../injection_container.dart';
import '../providers/voice_input_provider.dart';

class CaptureBottomSheet extends ConsumerStatefulWidget {
  const CaptureBottomSheet({super.key});

  @override
  ConsumerState<CaptureBottomSheet> createState() => _CaptureBottomSheetState();
}

class _CaptureBottomSheetState extends ConsumerState<CaptureBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _pulseController;
  bool _syncingFromVoice = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _controller.addListener(_handleTextChanged);
    Future.microtask(() => ref.read(voiceInputProvider.notifier).reset());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (_syncingFromVoice) {
      return;
    }
    ref.read(voiceInputProvider.notifier).updateTranscript(_controller.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(voiceInputProvider);
    final settings = ref.watch(appSettingsProvider);
    final localesValue = ref.watch(voiceLocalesProvider);
    final speechSupported = ref.watch(speechCaptureSupportedProvider);
    final isTextOnlyCapture = !speechSupported;

    ref.listen(voiceInputProvider, (previous, next) {
      if (_controller.text == next.transcript) {
        return;
      }
      _syncingFromVoice = true;
      _controller
        ..text = next.transcript
        ..selection = TextSelection.collapsed(offset: next.transcript.length);
      _syncingFromVoice = false;
    });

    final isCompact = MediaQuery.sizeOf(context).width < 700;

    return FractionallySizedBox(
      heightFactor: isCompact ? 0.96 : 0.78,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture to Inbox',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!isTextOnlyCapture) ...[
                          const SizedBox(height: 4),
                          Text(
                            _localeSummary(
                              localesValue,
                              settings.voiceLocaleId,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (speechSupported)
                    IconButton(
                      tooltip: 'Voice language',
                      onPressed: () => _pickLocale(context),
                      icon: const Icon(Icons.language_outlined),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'What has your attention?',
                    hintText: 'Type what you want to capture...',
                  ),
                ),
              ),
              if (speechSupported) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    _PulsingMicButton(
                      isListening: state.isListening,
                      isInitializing: state.isInitializing,
                      animation: _pulseController,
                      onPressed: () => _toggleListening(state),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isListening
                                ? 'Listening...'
                                : 'Tap microphone to speak',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.status} | Confidence ${(state.confidence * 100).clamp(0, 100).toStringAsFixed(0)}% | Input ${state.soundLevel.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (isTextOnlyCapture) ...[
                Center(
                  child: Text(
                    'Press Win + H to use dictation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _cancel(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : () => _addToInbox(context),
                    icon: const Icon(Icons.inbox_outlined),
                    label: const Text('Add to Inbox'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleListening(VoiceInputState state) async {
    final notifier = ref.read(voiceInputProvider.notifier);
    if (state.isListening) {
      await notifier.pauseListening();
      return;
    }
    await notifier.startListening(initialText: _controller.text);
  }

  Future<void> _cancel(BuildContext context) async {
    await ref.read(voiceInputProvider.notifier).cancelListening();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addToInbox(BuildContext context) async {
    final item = await ref
        .read(voiceInputProvider.notifier)
        .saveTranscript(_controller.text);
    if (!context.mounted || item == null) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Inbox')),
    );
  }

  Future<void> _pickLocale(BuildContext context) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _VoiceLocalePickerLoader(
          selectedLocaleId: ref.read(appSettingsProvider).voiceLocaleId,
        );
      },
    );

    if (!context.mounted || selected == _localePickerCancelled) {
      return;
    }

    await ref.read(appSettingsControllerProvider.notifier).setVoiceLocaleId(
          selected,
        );
    if (ref.read(voiceInputProvider).isListening) {
      await ref.read(voiceInputProvider.notifier).restartListening(
            localeId: selected,
            initialText: _controller.text,
          );
    }
  }

  String _localeSummary(
    AsyncValue<List<LocaleName>> localesValue,
    String? selectedLocaleId,
  ) {
    if (selectedLocaleId == null) {
      return 'Language: Device default';
    }
    final locale = localesValue.valueOrNull
        ?.where((locale) => locale.localeId == selectedLocaleId)
        .firstOrNull;
    return locale == null
        ? 'Language: $selectedLocaleId'
        : 'Language: ${locale.name} (${locale.localeId})';
  }
}

class _PulsingMicButton extends StatelessWidget {
  const _PulsingMicButton({
    required this.isListening,
    required this.isInitializing,
    required this.animation,
    required this.onPressed,
  });

  final bool isListening;
  final bool isInitializing;
  final Animation<double> animation;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = isListening ? 1 + (animation.value * 0.14) : 1.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: isListening ? 0.18 : 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'capture-sheet-mic',
              onPressed: isInitializing ? null : onPressed,
              child: Icon(
                isListening ? Icons.mic_off_outlined : Icons.mic_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}

const _localePickerCancelled = '__cancelled__';

class _VoiceLocalePickerLoader extends ConsumerWidget {
  const _VoiceLocalePickerLoader({required this.selectedLocaleId});

  final String? selectedLocaleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localesValue = ref.watch(voiceLocalesProvider);
    final speechSupported = ref.watch(speechCaptureSupportedProvider);

    if (!speechSupported) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Voice language selection is not available in the Windows tester build. You can type directly, or use Windows dictation with Win+H.',
          ),
        ),
      );
    }

    return localesValue.when(
      loading: () => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading voice languages...'),
            ],
          ),
        ),
      ),
      error: (error, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load voice languages: $error'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(voiceLocalesProvider),
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (locales) => _VoiceLocalePicker(
        locales: locales,
        selectedLocaleId: selectedLocaleId,
      ),
    );
  }
}

class _VoiceLocalePicker extends StatefulWidget {
  const _VoiceLocalePicker({
    required this.locales,
    required this.selectedLocaleId,
  });

  final List<LocaleName> locales;
  final String? selectedLocaleId;

  @override
  State<_VoiceLocalePicker> createState() => _VoiceLocalePickerState();
}

class _VoiceLocalePickerState extends State<_VoiceLocalePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _query.trim().toLowerCase();
    final filtered = widget.locales.where((locale) {
      return query.isEmpty ||
          locale.name.toLowerCase().contains(query) ||
          locale.localeId.toLowerCase().contains(query);
    }).toList(growable: false);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Voice Input Language',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () =>
                        Navigator.of(context).pop(_localePickerCancelled),
                    icon: const Icon(Icons.close_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_outlined),
                  labelText: 'Search languages and accents',
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                        widget.selectedLocaleId == null
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                      ),
                      title: const Text('Device default'),
                      subtitle: const Text('Use browser or device language'),
                      onTap: () => Navigator.of(context).pop(null),
                    ),
                    for (final locale in filtered)
                      ListTile(
                        leading: Icon(
                          widget.selectedLocaleId == locale.localeId
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        title: Text(locale.name),
                        subtitle: Text(locale.localeId),
                        onTap: () => Navigator.of(context).pop(locale.localeId),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
