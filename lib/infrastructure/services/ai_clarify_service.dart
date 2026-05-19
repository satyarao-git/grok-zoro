import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/ai_clarification_suggestion.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/context.dart';
import '../../domain/entities/inbox_item.dart';
import '../../domain/entities/processing_choice.dart';

abstract class AiClarifyService {
  Future<AiClarificationSuggestion> clarify({
    required InboxItem item,
    required List<ZoroContext> contexts,
    required AppSettings settings,
  });
}

class HttpAiClarifyService implements AiClarifyService {
  const HttpAiClarifyService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<AiClarificationSuggestion> clarify({
    required InboxItem item,
    required List<ZoroContext> contexts,
    required AppSettings settings,
  }) async {
    if (!settings.aiEnabled) {
      throw const AiClarifyException('Enable AI clarification in Settings.');
    }

    final baseUri = Uri.tryParse(settings.aiBaseUrl);
    if (baseUri == null || !baseUri.hasScheme) {
      throw const AiClarifyException('Set a valid AI proxy URL in Settings.');
    }

    final client = _client ?? http.Client();
    final http.Response response;
    try {
      response = await client.post(
        baseUri.resolve('/clarify'),
        headers: const {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({
          'title': item.title,
          'notes': item.notes,
          'model': settings.aiModel,
          'contexts': contexts.map((context) => context.name).toList(),
        }),
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractError(response.body);
      throw AiClarifyException(message ?? 'AI clarification failed.');
    }

    return aiSuggestionFromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class AiClarifyException implements Exception {
  const AiClarifyException(this.message);

  final String message;

  @override
  String toString() => message;
}

AiClarificationSuggestion aiSuggestionFromJson(Map<String, dynamic> json) {
  final title = _readString(json['title']);
  return AiClarificationSuggestion(
    choice: _choiceFromJson(json['choice']),
    title: title.isEmpty ? 'Clarified item' : title,
    desiredOutcome: _readNullableString(json['desiredOutcome']),
    nextActionTitle: _readNullableString(json['nextActionTitle']),
    contextName: _readNullableString(json['contextName']),
    targetDate: _readDate(json['targetDate']),
    reconsiderDate: _readDate(json['reconsiderDate']),
    notes: _readNullableString(json['notes']),
    tags: _readStringList(json['tags']),
    stepTitles: _readStringList(json['stepTitles']),
  );
}

ProcessingChoice _choiceFromJson(Object? value) {
  final normalized = _readString(value)
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll(' ', '')
      .toLowerCase();
  return switch (normalized) {
    'project' => ProcessingChoice.project,
    'calendarevent' || 'calendar' || 'event' => ProcessingChoice.calendarEvent,
    'someday' || 'somedaymaybe' || 'maybe' => ProcessingChoice.someday,
    'reference' => ProcessingChoice.reference,
    'waitingfor' || 'waiting' || 'delegated' => ProcessingChoice.waitingFor,
    'trash' || 'delete' => ProcessingChoice.trash,
    _ => ProcessingChoice.nextAction,
  };
}

String _readString(Object? value) => value?.toString().trim() ?? '';

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

DateTime? _readDate(Object? value) {
  final text = _readNullableString(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map(_readString)
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

String? _extractError(String body) {
  try {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return _readNullableString(decoded['error']);
  } catch (_) {
    return null;
  }
}
