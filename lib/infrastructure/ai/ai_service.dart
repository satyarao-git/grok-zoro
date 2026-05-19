import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/app_settings.dart';

abstract class AiAssistService {
  Future<Map<String, dynamic>> suggest({
    required String context,
    required Map<String, Object?> payload,
    required AppSettings settings,
  });
}

class HttpAiAssistService implements AiAssistService {
  const HttpAiAssistService({http.Client? client}) : _client = client;

  final http.Client? _client;

  @override
  Future<Map<String, dynamic>> suggest({
    required String context,
    required Map<String, Object?> payload,
    required AppSettings settings,
  }) async {
    if (!settings.aiEnabled) {
      throw const AiAssistException('Enable AI Assist in Settings first.');
    }

    final baseUri = Uri.tryParse(settings.aiBaseUrl);
    if (baseUri == null || !baseUri.hasScheme) {
      throw const AiAssistException('Set a valid AI base URL in Settings.');
    }

    final client = _client ?? http.Client();
    try {
      final endpoint = _endpointFor(baseUri, settings);
      final response = await client.post(
        endpoint,
        headers: _headersFor(settings),
        body: jsonEncode(_bodyFor(context, payload, settings)),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiAssistException(
          _extractError(response.body) ?? 'AI Assist failed.',
        );
      }

      return _decodeSuggestion(response.body);
    } on http.ClientException catch (error) {
      throw AiAssistException(_connectionMessage(error.message));
    } on FormatException {
      throw const AiAssistException('AI response was not valid JSON.');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  String _connectionMessage(String detail) {
    return 'AI Assist could not reach the configured AI service. Start the '
        'local proxy at http://127.0.0.1:8787, or update Settings > AI '
        'Integration with a reachable endpoint. Details: $detail';
  }

  Uri _endpointFor(Uri baseUri, AppSettings settings) {
    if ((settings.aiApiKey ?? '').trim().isNotEmpty) {
      final path = baseUri.path.toLowerCase();
      if (path.endsWith('/chat/completions')) {
        return baseUri;
      }
      return baseUri.resolve('/v1/chat/completions');
    }
    return baseUri.resolve('/assist');
  }

  Map<String, String> _headersFor(AppSettings settings) {
    final apiKey = (settings.aiApiKey ?? '').trim();
    return {
      'content-type': 'application/json',
      'accept': 'application/json',
      if (apiKey.isNotEmpty) 'authorization': 'Bearer $apiKey',
    };
  }

  Map<String, Object?> _bodyFor(
    String context,
    Map<String, Object?> payload,
    AppSettings settings,
  ) {
    final apiKey = (settings.aiApiKey ?? '').trim();
    if (apiKey.isEmpty) {
      return {
        'context': context,
        'model': settings.aiModel,
        'payload': payload,
      };
    }

    return {
      'model': settings.aiModel,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': _systemPromptFor(context),
        },
        {
          'role': 'user',
          'content': jsonEncode({
            'context': context,
            'payload': payload,
          }),
        },
      ],
    };
  }

  String _systemPromptFor(String context) {
    if (context == 'weekly_review') {
      return 'You are Zoro, a GTD weekly review assistant. Return only JSON '
          'with priorityActions, stalledProjects, readyToActivateCount, '
          'horizonsAlignmentTips, and suggestedFocusAreas.';
    }
    return 'You are Zoro, a GTD inbox clarification assistant. Return only '
        'JSON with recommendedChoice, title, desiredOutcome, steps, context, '
        'targetDate, reconsiderDate, notes, and tags. recommendedChoice may '
        'be nextAction, project, calendarEvent, someday, reference, '
        'waitingFor, or trash.';
  }

  Map<String, dynamic> _decodeSuggestion(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const AiAssistException('AI response was not valid JSON.');
    }

    final choices = decoded['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final message = first['message'];
        if (message is Map) {
          final content = message['content'];
          if (content is String) {
            final parsed = jsonDecode(content);
            if (parsed is Map<String, dynamic>) {
              return parsed;
            }
          }
        }
      }
    }

    final suggestion = decoded['suggestion'];
    if (suggestion is Map<String, dynamic>) {
      return suggestion;
    }
    return decoded;
  }

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class AiAssistException implements Exception {
  const AiAssistException(this.message);

  final String message;

  @override
  String toString() => message;
}
