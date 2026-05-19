import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../application/imports/bulk_capture_import.dart';
import '../../../application/providers/history_notifier_provider.dart';
import '../../../domain/entities/inbox_item.dart';
import '../../../injection_container.dart';
import '../../providers/voice_input_provider.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zoro_app_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final contexts = ref.watch(contextsProvider);
    final selectedContext = contexts.any(
      (context) => context.name == settings.defaultContextName,
    )
        ? settings.defaultContextName
        : contexts.first.name;

    return ZoroAppScaffold(
      title: 'Settings',
      child: ListView(
        children: [
          SectionCard(
            title: 'Capture',
            trailing: StatusChip(
              label: settings.voiceCaptureEnabled ? 'On' : 'Off',
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Voice capture button'),
              subtitle:
                  const Text('Show the microphone action on main screens.'),
              value: settings.voiceCaptureEnabled,
              onChanged: (value) {
                ref
                    .read(appSettingsControllerProvider.notifier)
                    .setVoiceCaptureEnabled(enabled: value);
              },
            ),
          ),
          const SizedBox(height: 16),
          const _VoiceLanguageSection(),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Clarify defaults',
            child: DropdownButtonFormField<String>(
              key: ValueKey('default-context-$selectedContext'),
              initialValue: selectedContext,
              decoration: const InputDecoration(
                labelText: 'Default next action context',
              ),
              items: [
                for (final context in contexts)
                  DropdownMenuItem(
                    value: context.name,
                    child: Text(context.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(appSettingsControllerProvider.notifier)
                      .setDefaultContextName(value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Weekly Review',
            child: DropdownButtonFormField<int>(
              key: ValueKey('weekly-review-${settings.weeklyReviewWeekday}'),
              initialValue: settings.weeklyReviewWeekday,
              decoration: const InputDecoration(
                labelText: 'Preferred review day',
              ),
              items: [
                for (var index = 0; index < _weekdays.length; index++)
                  DropdownMenuItem(
                    value: index + 1,
                    child: Text(_weekdays[index]),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(appSettingsControllerProvider.notifier)
                      .setWeeklyReviewDay(value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'AI Integration',
            trailing: StatusChip(label: settings.aiEnabled ? 'On' : 'Off'),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('AI Assist'),
                  subtitle: const Text(
                    'Use AI for inbox clarification and weekly review insights.',
                  ),
                  value: settings.aiEnabled,
                  onChanged: (value) {
                    ref
                        .read(appSettingsControllerProvider.notifier)
                        .setAiEnabled(enabled: value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('ai-base-url-${settings.aiBaseUrl}'),
                  initialValue: settings.aiBaseUrl,
                  decoration: const InputDecoration(
                    labelText: 'AI base URL',
                    helperText:
                        'Local proxy: http://127.0.0.1:8787 or OpenAI-compatible endpoint.',
                  ),
                  keyboardType: TextInputType.url,
                  onFieldSubmitted: (value) {
                    ref
                        .read(appSettingsControllerProvider.notifier)
                        .setAiBaseUrl(value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey(
                    'ai-api-key-${settings.aiApiKey?.isNotEmpty == true}',
                  ),
                  initialValue: settings.aiApiKey,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API key',
                    helperText: 'Leave blank when using a trusted local proxy.',
                  ),
                  onFieldSubmitted: (value) {
                    ref
                        .read(appSettingsControllerProvider.notifier)
                        .setAiApiKey(value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('ai-model-${settings.aiModel}'),
                  initialValue: settings.aiModel,
                  decoration: const InputDecoration(
                    labelText: 'AI model',
                  ),
                  onFieldSubmitted: (value) {
                    ref
                        .read(appSettingsControllerProvider.notifier)
                        .setAiModel(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Backup',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copy a JSON snapshot for safekeeping, restore a Zoro backup, or bulk-load captured tasks into Inbox.',
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _importSpreadsheet(context, ref),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Upload Tasks'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _importBackupJson(context, ref),
                        icon: const Icon(Icons.restore_page_outlined),
                        label: const Text('Import JSON'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _copyBackup(context, ref),
                        icon: const Icon(Icons.content_copy_outlined),
                        label: const Text('Copy JSON'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Data & Maintenance',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Maintenance tools for reviewing and resetting local GTD data.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push('/history'),
                      icon: const Icon(Icons.history_outlined),
                      label: const Text('View History'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(historyNotifierProvider.notifier)
                            .pruneNow();
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('History retention refreshed.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_delete_outlined),
                      label: const Text('Prune History'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () => _confirmClearAllData(context, ref),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Clear All Data'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyBackup(BuildContext context, WidgetRef ref) async {
    await Clipboard.setData(
      ClipboardData(text: await ref.read(backupExportProvider.future)),
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup JSON copied.')),
    );
  }

  Future<void> _importSpreadsheet(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await _pickFileBytes(const ['xlsx']);
      if (bytes == null) {
        return;
      }

      final parsed = parseBulkCaptureSpreadsheet(bytes);
      var importedCount = 0;
      for (final title in parsed.titles) {
        final result = await ref.read(createInboxItemUseCaseProvider)(
          title: title,
          source: CaptureSource.import,
        );
        final failure = result.match((failure) => failure, (_) => null);
        if (failure != null) {
          throw Exception(failure.message);
        }
        importedCount++;
      }

      _refreshImportedData(ref);
      if (!context.mounted) {
        return;
      }
      final skipped = parsed.skippedRows == 0
          ? ''
          : ' ${parsed.skippedRows} empty rows skipped.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $importedCount captures to Inbox.$skipped'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanImportError(error))),
      );
    }
  }

  Future<void> _importBackupJson(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await _pickFileBytes(const ['json']);
      if (bytes == null) {
        return;
      }

      final backupText = utf8.decode(bytes);
      if (!context.mounted) {
        return;
      }
      final confirmed = await _confirmImportBackup(context);
      if (confirmed != true || !context.mounted) {
        return;
      }

      final result = await ref.read(importBackupUseCaseProvider)(
        backupText,
      );
      final failure = result.match((failure) => failure, (_) => null);
      if (failure != null) {
        throw Exception(failure.message);
      }

      _refreshImportedData(ref);
      if (!context.mounted) {
        return;
      }
      final importResult = result.getRight().toNullable();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported backup JSON with ${importResult?.totalImported ?? 0} trusted-system items.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanImportError(error))),
      );
    }
  }

  Future<Uint8List?> _pickFileBytes(List<String> allowedExtensions) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return null;
    }
    return file.bytes ?? await file.xFile.readAsBytes();
  }

  Future<bool?> _confirmImportBackup(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.restore_page_outlined),
          title: const Text('Import Backup JSON?'),
          content: const Text(
            'This will replace your current Inbox, Next Actions, Projects, Someday/Maybe, Reference, Waiting For, settings, contexts, horizons, and weekly review progress with the selected backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Import Backup'),
            ),
          ],
        );
      },
    );
  }

  void _refreshImportedData(WidgetRef ref) {
    ref
      ..invalidate(appSettingsControllerProvider)
      ..invalidate(contextsStateProvider)
      ..invalidate(selectedContextProvider)
      ..invalidate(inboxItemsProvider)
      ..invalidate(allNextActionsProvider)
      ..invalidate(allTasksProvider)
      ..invalidate(activeProjectsProvider)
      ..invalidate(allProjectsProvider)
      ..invalidate(somedayMaybeProvider)
      ..invalidate(referenceProvider)
      ..invalidate(waitingForProvider)
      ..invalidate(allWaitingForProvider)
      ..invalidate(readyToActivateProvider)
      ..invalidate(waitingForDueProvider)
      ..invalidate(calendarEntriesProvider)
      ..invalidate(visibleCalendarEntriesProvider)
      ..invalidate(archiveItemsProvider)
      ..invalidate(globalSearchResultsProvider)
      ..invalidate(horizonsProvider)
      ..invalidate(weeklyReviewProgressProvider)
      ..invalidate(backupExportProvider);
  }

  String _cleanImportError(Object error) {
    final message = error is FormatException
        ? error.message
        : error.toString().replaceFirst('Exception: ', '');
    return 'Import failed: $message';
  }

  Future<void> _confirmClearAllData(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var isClearing = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              icon: Icon(
                Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Clear All Data?'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This will permanently delete ALL Inbox items, Next Actions, Projects, Someday/Maybe items, Reference items, Waiting For items, and History. This cannot be undone.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      enabled: !isClearing,
                      decoration: const InputDecoration(
                        labelText: 'Type RESET to confirm',
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isClearing
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: controller.text == 'RESET' && !isClearing
                      ? () async {
                          setDialogState(() => isClearing = true);
                          final result =
                              await ref.read(clearAllDataUseCaseProvider)();
                          if (!dialogContext.mounted) {
                            return;
                          }
                          Navigator.of(dialogContext).pop(result.isRight());
                          result.match(
                            (failure) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            ),
                            (_) {},
                          );
                        }
                      : null,
                  child: Text(isClearing ? 'Clearing...' : 'Clear Everything'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();

    if (confirmed != true || !context.mounted) {
      return;
    }

    ref
      ..invalidate(inboxItemsProvider)
      ..invalidate(allNextActionsProvider)
      ..invalidate(allTasksProvider)
      ..invalidate(activeProjectsProvider)
      ..invalidate(allProjectsProvider)
      ..invalidate(somedayMaybeProvider)
      ..invalidate(referenceProvider)
      ..invalidate(waitingForProvider)
      ..invalidate(readyToActivateProvider)
      ..invalidate(waitingForDueProvider)
      ..invalidate(calendarEntriesProvider)
      ..invalidate(visibleCalendarEntriesProvider)
      ..invalidate(archiveItemsProvider)
      ..invalidate(globalSearchResultsProvider)
      ..invalidate(historyNotifierProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared.')),
    );
  }
}

const _deviceDefaultLocale = '__device_default__';

class _VoiceLanguageSection extends ConsumerWidget {
  const _VoiceLanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final localesValue = ref.watch(voiceLocalesProvider);
    final selected = settings.voiceLocaleId ?? _deviceDefaultLocale;

    return SectionCard(
      title: 'Voice Input Language',
      child: localesValue.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text(
          'Voice locales are unavailable: $error',
        ),
        data: (locales) {
          final hasSelected = selected == _deviceDefaultLocale ||
              locales.any((locale) => locale.localeId == selected);
          return DropdownButtonFormField<String>(
            key: ValueKey('voice-locale-$selected-${locales.length}'),
            initialValue: hasSelected ? selected : _deviceDefaultLocale,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Preferred speech language',
              helperText:
                  'Device default is used when no language is selected.',
            ),
            items: [
              const DropdownMenuItem(
                value: _deviceDefaultLocale,
                child: Text('Device default'),
              ),
              for (final locale in locales)
                DropdownMenuItem(
                  value: locale.localeId,
                  child: Text('${locale.name} (${locale.localeId})'),
                ),
            ],
            onChanged: (value) {
              ref.read(appSettingsControllerProvider.notifier).setVoiceLocaleId(
                    value == _deviceDefaultLocale ? null : value,
                  );
            },
          );
        },
      ),
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
