import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = _loadEnv();
  final port = int.tryParse(env['PORT'] ?? '') ?? 8787;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Zoro AI proxy listening on http://127.0.0.1:$port');
  stdout.writeln('Provider: ${_provider(env)}');

  await for (final request in server) {
    _setCors(request.response);
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    if (request.method == 'GET' && request.uri.path == '/health') {
      await _sendJson(request.response, HttpStatus.ok, {
        'ok': true,
        'provider': _provider(env),
        'model': _model(env),
      });
      continue;
    }

    if (request.method != 'POST' ||
        (request.uri.path != '/assist' && request.uri.path != '/clarify')) {
      await _sendJson(
        request.response,
        HttpStatus.notFound,
        {'error': 'Not found.'},
      );
      continue;
    }

    try {
      final body = await _readJson(request);
      final prepared = request.uri.path == '/assist'
          ? _buildAssistPayload(body, env)
          : _buildLegacyClarifyPayload(body, env);

      if (prepared.error != null) {
        await _sendJson(
          request.response,
          HttpStatus.badRequest,
          {'error': prepared.error},
        );
        continue;
      }

      final rawText = await _callProvider(
        env: env,
        systemPrompt: prepared.systemPrompt,
        userPayload: prepared.userPayload,
      );
      final suggestion = _parseJsonObject(rawText);
      await _sendJson(
        request.response,
        HttpStatus.ok,
        prepared.normalize(suggestion),
      );
    } catch (error) {
      await _sendJson(
        request.response,
        HttpStatus.internalServerError,
        {'error': error.toString()},
      );
    }
  }
}

Map<String, String> _loadEnv() {
  final values = <String, String>{...Platform.environment};
  final candidates = <File>[
    File('.env'),
    File(
        '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}.env'),
  ];

  for (final file in candidates) {
    if (!file.existsSync()) {
      continue;
    }
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      final separator = trimmed.indexOf('=');
      if (separator == -1) {
        continue;
      }
      final key = trimmed.substring(0, separator).trim();
      final value = _unquote(trimmed.substring(separator + 1).trim());
      values.putIfAbsent(key, () => value);
    }
  }
  return values;
}

String _provider(Map<String, String> env) {
  final explicit = (env['AI_PROVIDER'] ?? '').trim().toLowerCase();
  if (explicit == 'anthropic' || explicit == 'openai') {
    return explicit;
  }
  if ((env['ANTHROPIC_API_KEY'] ?? '').trim().isNotEmpty &&
      (env['OPENAI_API_KEY'] ?? '').trim().isEmpty) {
    return 'anthropic';
  }
  return 'openai';
}

String _model(Map<String, String> env) {
  if (_provider(env) == 'anthropic') {
    return (env['ANTHROPIC_MODEL'] ?? '').trim().isEmpty
        ? 'claude-3-5-sonnet-latest'
        : env['ANTHROPIC_MODEL']!.trim();
  }
  return (env['OPENAI_MODEL'] ?? '').trim().isEmpty
      ? 'gpt-5.2'
      : env['OPENAI_MODEL']!.trim();
}

Future<String> _callProvider({
  required Map<String, String> env,
  required String systemPrompt,
  required Map<String, Object?> userPayload,
}) {
  return switch (_provider(env)) {
    'anthropic' => _callAnthropic(env, systemPrompt, userPayload),
    _ => _callOpenAi(env, systemPrompt, userPayload),
  };
}

Future<String> _callOpenAi(
  Map<String, String> env,
  String systemPrompt,
  Map<String, Object?> userPayload,
) async {
  final apiKey = (env['OPENAI_API_KEY'] ?? '').trim();
  if (apiKey.isEmpty) {
    throw const FormatException('Set OPENAI_API_KEY in .env.');
  }

  final response = await _postJson(
    Uri.parse('https://api.openai.com/v1/responses'),
    headers: {'authorization': 'Bearer $apiKey'},
    body: {
      'model': _model(env),
      'input': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': jsonEncode(userPayload)},
      ],
    },
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw FormatException(_extractProviderError(response.body, 'OpenAI'));
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  if (decoded['output_text'] is String) {
    return decoded['output_text'] as String;
  }

  final chunks = <String>[];
  for (final item in decoded['output'] as List? ?? const []) {
    if (item is! Map) {
      continue;
    }
    for (final content in item['content'] as List? ?? const []) {
      if (content is Map && content['text'] is String) {
        chunks.add(content['text'] as String);
      }
    }
  }
  return chunks.join('\n');
}

Future<String> _callAnthropic(
  Map<String, String> env,
  String systemPrompt,
  Map<String, Object?> userPayload,
) async {
  final apiKey = (env['ANTHROPIC_API_KEY'] ?? '').trim();
  if (apiKey.isEmpty) {
    throw const FormatException('Set ANTHROPIC_API_KEY in .env.');
  }

  final response = await _postJson(
    Uri.parse('https://api.anthropic.com/v1/messages'),
    headers: {
      'x-api-key': apiKey,
      'anthropic-version': env['ANTHROPIC_VERSION'] ?? '2023-06-01',
    },
    body: {
      'model': _model(env),
      'max_tokens': int.tryParse(env['AI_MAX_TOKENS'] ?? '') ?? 1200,
      'system': systemPrompt,
      'messages': [
        {'role': 'user', 'content': jsonEncode(userPayload)},
      ],
    },
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw FormatException(_extractProviderError(response.body, 'Anthropic'));
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final chunks = <String>[];
  for (final content in decoded['content'] as List? ?? const []) {
    if (content is Map && content['text'] is String) {
      chunks.add(content['text'] as String);
    }
  }
  return chunks.join('\n');
}

Future<_ProviderResponse> _postJson(
  Uri uri, {
  required Map<String, String> headers,
  required Map<String, Object?> body,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    return _ProviderResponse(response.statusCode, responseBody);
  } finally {
    client.close(force: true);
  }
}

_PreparedRequest _buildLegacyClarifyPayload(
  Map<String, dynamic> body,
  Map<String, String> env,
) {
  final title = _cleanString(body['title']);
  if (title.isEmpty) {
    return _PreparedRequest.error('title is required.');
  }
  return _PreparedRequest(
    systemPrompt:
        'You clarify GTD inbox items for processing. Return only valid JSON. '
        'Choose nextAction, project, someday, or trash. Prefer concrete next '
        'physical actions and existing context names.',
    userPayload: {
      'inboxItem': {
        'title': title,
        'notes': _cleanString(body['notes']),
      },
      'contexts': _cleanList(body['contexts']),
      'today': DateTime.now().toIso8601String().substring(0, 10),
      'responseSchema': _inboxSchemaHint(),
    },
    normalize: (suggestion) => _normalizeLegacySuggestion(suggestion, title),
  );
}

_PreparedRequest _buildAssistPayload(
  Map<String, dynamic> body,
  Map<String, String> env,
) {
  final context = _cleanString(body['context']);
  final payload = body['payload'] is Map
      ? Map<String, dynamic>.from(body['payload'] as Map)
      : <String, dynamic>{};

  if (context == 'weekly_review') {
    return _PreparedRequest(
      systemPrompt:
          'You are Zoro, a GTD weekly review assistant. Return only valid JSON '
          'with priorityActions, stalledProjects, readyToActivateCount, '
          'horizonsAlignmentTips, and suggestedFocusAreas.',
      userPayload: {
        'summary': payload,
        'today': DateTime.now().toIso8601String().substring(0, 10),
        'responseSchema': {
          'priorityActions': ['Review Project X'],
          'stalledProjects': ['Project A - no progress signal'],
          'readyToActivateCount': 0,
          'horizonsAlignmentTips': ['Alignment tip'],
          'suggestedFocusAreas': ['Clear Inbox'],
        },
      },
      normalize: _normalizeWeeklyReview,
    );
  }

  if (context != 'inbox_processing') {
    return _PreparedRequest.error(
      'context must be inbox_processing or weekly_review.',
    );
  }

  final rawText = _cleanString(payload['rawText']);
  if (rawText.isEmpty) {
    return _PreparedRequest.error('payload.rawText is required.');
  }

  return _PreparedRequest(
    systemPrompt:
        'You clarify GTD inbox items for processing. Return only valid JSON. '
        'Choose nextAction, project, someday, reference, or trash. Prefer '
        'concrete next physical actions and existing context names.',
    userPayload: {
      'inboxItem': {
        'title': rawText,
        'notes': _cleanString(payload['notes']),
        'currentChoice': _cleanString(payload['currentChoice']),
      },
      'contexts': _cleanList(payload['availableContexts']),
      'today': DateTime.now().toIso8601String().substring(0, 10),
      'responseSchema': _inboxSchemaHint(),
    },
    normalize: (suggestion) => _normalizeAssistSuggestion(suggestion, rawText),
  );
}

Map<String, Object?> _inboxSchemaHint() {
  return {
    'recommendedChoice':
        'nextAction | project | calendarEvent | someday | reference | waitingFor | trash',
    'title': 'short clarified title',
    'desiredOutcome': 'project outcome or null',
    'nextActionTitle': 'visible next physical action or null',
    'context': 'one of the provided contexts or null',
    'targetDate': 'ISO string or null',
    'reconsiderDate': 'YYYY-MM-DD or null',
    'notes': 'brief useful notes or null',
    'tags': ['short tag'],
    'steps': ['future project step'],
  };
}

Map<String, Object?> _normalizeLegacySuggestion(
  Map<String, dynamic> raw,
  String fallbackTitle,
) {
  return {
    'choice': _normalizeChoice(raw['choice']),
    'title': _cleanString(raw['title']).isEmpty
        ? fallbackTitle
        : _cleanString(raw['title']),
    'desiredOutcome': _cleanOptional(raw['desiredOutcome']),
    'nextActionTitle': _cleanOptional(raw['nextActionTitle']),
    'contextName': _cleanOptional(raw['contextName'] ?? raw['context']),
    'targetDate': _cleanDateTime(raw['targetDate']),
    'reconsiderDate': _cleanDate(raw['reconsiderDate']),
    'notes': _cleanOptional(raw['notes']),
    'tags': _cleanList(raw['tags']),
    'stepTitles': _cleanList(raw['stepTitles'] ?? raw['steps']),
  };
}

Map<String, Object?> _normalizeAssistSuggestion(
  Map<String, dynamic> raw,
  String fallbackTitle,
) {
  return {
    'recommendedChoice': _normalizeChoice(
      raw['recommendedChoice'] ?? raw['choice'],
    ),
    'title': _cleanString(raw['title']).isEmpty
        ? fallbackTitle
        : _cleanString(raw['title']),
    'desiredOutcome': _cleanOptional(raw['desiredOutcome']),
    'nextActionTitle': _cleanOptional(raw['nextActionTitle']),
    'context': _cleanOptional(raw['context'] ?? raw['contextName']),
    'targetDate': _cleanDateTime(raw['targetDate']),
    'reconsiderDate': _cleanDate(raw['reconsiderDate']),
    'notes': _cleanOptional(raw['notes']),
    'tags': _cleanList(raw['tags']),
    'steps': _cleanList(raw['steps'] ?? raw['stepTitles']),
  };
}

Map<String, Object?> _normalizeWeeklyReview(Map<String, dynamic> raw) {
  return {
    'priorityActions': _cleanList(raw['priorityActions']),
    'stalledProjects': _cleanList(raw['stalledProjects']),
    'readyToActivateCount': int.tryParse(
          _cleanString(raw['readyToActivateCount']),
        ) ??
        0,
    'horizonsAlignmentTips': _cleanList(raw['horizonsAlignmentTips']),
    'suggestedFocusAreas': _cleanList(raw['suggestedFocusAreas']),
  };
}

Map<String, dynamic> _parseJsonObject(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('The model returned an empty suggestion.');
  }
  try {
    return jsonDecode(trimmed) as Map<String, dynamic>;
  } catch (_) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(trimmed);
    if (match == null) {
      throw const FormatException('The model did not return JSON.');
    }
    return jsonDecode(match.group(0)!) as Map<String, dynamic>;
  }
}

Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
  final body = await utf8.decodeStream(request);
  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }
  return jsonDecode(body) as Map<String, dynamic>;
}

Future<void> _sendJson(
  HttpResponse response,
  int statusCode,
  Map<String, Object?> body,
) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}

void _setCors(HttpResponse response) {
  response.headers.set('access-control-allow-origin', '*');
  response.headers.set('access-control-allow-methods', 'GET,POST,OPTIONS');
  response.headers.set('access-control-allow-headers', 'content-type');
}

String _extractProviderError(String body, String provider) {
  try {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final error = decoded['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
  } catch (_) {
    // Use fallback below.
  }
  return '$provider request failed.';
}

String _normalizeChoice(Object? value) {
  final normalized =
      _cleanString(value).replaceAll(RegExp(r'[-_\s]'), '').toLowerCase();
  if (normalized == 'project') return 'project';
  if (normalized == 'calendarevent' ||
      normalized == 'calendar' ||
      normalized == 'event') {
    return 'calendarEvent';
  }
  if (normalized == 'someday' ||
      normalized == 'somedaymaybe' ||
      normalized == 'maybe') {
    return 'someday';
  }
  if (normalized == 'reference') return 'reference';
  if (normalized == 'waitingfor' ||
      normalized == 'waiting' ||
      normalized == 'delegated') {
    return 'waitingFor';
  }
  if (normalized == 'trash' || normalized == 'delete') return 'trash';
  return 'nextAction';
}

List<String> _cleanList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_cleanString).where((entry) => entry.isNotEmpty).toList();
}

String? _cleanOptional(Object? value) {
  final text = _cleanString(value);
  return text.isEmpty ? null : text;
}

String? _cleanDate(Object? value) {
  final text = _cleanString(value);
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ? text : null;
}

String? _cleanDateTime(Object? value) {
  final text = _cleanString(value);
  if (text.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(text);
  return parsed?.toIso8601String() ?? _cleanDate(value);
}

String _cleanString(Object? value) {
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

String _unquote(String value) {
  if ((value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

typedef _Normalizer = Map<String, Object?> Function(Map<String, dynamic>);

class _PreparedRequest {
  const _PreparedRequest({
    required this.systemPrompt,
    required this.userPayload,
    required this.normalize,
    this.error,
  });

  factory _PreparedRequest.error(String error) {
    return _PreparedRequest(
      systemPrompt: '',
      userPayload: const {},
      normalize: (json) => json,
      error: error,
    );
  }

  final String systemPrompt;
  final Map<String, Object?> userPayload;
  final _Normalizer normalize;
  final String? error;
}

class _ProviderResponse {
  const _ProviderResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}
