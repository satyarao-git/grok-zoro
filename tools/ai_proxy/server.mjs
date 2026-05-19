import http from 'node:http';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

loadEnvFiles();

const port = Number.parseInt(process.env.PORT ?? '8787', 10);
const defaultModel = process.env.OPENAI_MODEL ?? 'gpt-5.2';

const schemaHint = {
  recommendedChoice: 'nextAction | project | calendarEvent | someday | reference | waitingFor | trash',
  choice: 'nextAction | project | calendarEvent | someday | reference | waitingFor | trash',
  title: 'short clarified title',
  desiredOutcome: 'project outcome or null',
  nextActionTitle: 'visible next physical action or null',
  contextName: 'one of the provided contexts or null',
  targetDate: 'YYYY-MM-DD or null',
  reconsiderDate: 'YYYY-MM-DD or null',
  notes: 'brief useful notes or null',
  tags: ['short tag'],
  stepTitles: ['future project step'],
};

const weeklyReviewSchemaHint = {
  priorityActions: ['Review Project X', 'Activate Someday item Y'],
  stalledProjects: ['Project A - no progress signal'],
  readyToActivateCount: 0,
  horizonsAlignmentTips: ['Project Z supports a higher horizon'],
  suggestedFocusAreas: ['Clear remaining Inbox items'],
};

const server = http.createServer(async (request, response) => {
  setCors(response);

  if (request.method === 'OPTIONS') {
    response.writeHead(204);
    response.end();
    return;
  }

  if (request.method === 'GET' && request.url === '/health') {
    sendJson(response, 200, { ok: true, model: defaultModel });
    return;
  }

  if (request.method !== 'POST' || !['/clarify', '/assist'].includes(request.url)) {
    sendJson(response, 404, { error: 'Not found.' });
    return;
  }

  try {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      sendJson(response, 500, { error: 'Set OPENAI_API_KEY before starting the AI proxy.' });
      return;
    }

    const body = await readJson(request);
    const requestPayload =
      request.url === '/assist'
        ? buildAssistPayload(body)
        : buildLegacyClarifyPayload(body);
    if (requestPayload.error) {
      sendJson(response, 400, { error: requestPayload.error });
      return;
    }

    const payload = {
      model: requestPayload.model,
      input: requestPayload.input,
    };

    const aiResponse = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        authorization: `Bearer ${apiKey}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const aiBody = await aiResponse.json();
    if (!aiResponse.ok) {
      sendJson(response, aiResponse.status, {
        error: aiBody?.error?.message ?? 'OpenAI request failed.',
      });
      return;
    }

    const suggestion = parseSuggestion(extractOutputText(aiBody));
    sendJson(response, 200, requestPayload.normalize(suggestion));
  } catch (error) {
    sendJson(response, 500, {
      error: error instanceof Error ? error.message : 'AI proxy failed.',
    });
  }
});

function buildLegacyClarifyPayload(body) {
  const title = cleanString(body.title);
  if (!title) {
    return { error: 'title is required.' };
  }
  return {
    model: cleanString(body.model) || defaultModel,
    input: [
      {
        role: 'system',
        content:
          'You clarify GTD inbox items for processing. Return only valid JSON. Choose nextAction, project, someday, or trash. Prefer concrete next physical actions and existing context names.',
      },
      {
        role: 'user',
        content: JSON.stringify({
          inboxItem: {
            title,
            notes: cleanString(body.notes),
          },
          contexts: Array.isArray(body.contexts) ? body.contexts.map(cleanString).filter(Boolean) : [],
          today: new Date().toISOString().slice(0, 10),
          responseSchema: schemaHint,
        }),
      },
    ],
    normalize: (suggestion) => normalizeSuggestion(suggestion, title),
  };
}

function buildAssistPayload(body) {
  const context = cleanString(body.context);
  const payload = body.payload && typeof body.payload === 'object' ? body.payload : {};
  const model = cleanString(body.model) || defaultModel;
  if (context === 'weekly_review') {
    return {
      model,
      input: [
        {
          role: 'system',
          content:
            'You are Zoro, a GTD weekly review assistant. Return only valid JSON with priorityActions, stalledProjects, readyToActivateCount, horizonsAlignmentTips, and suggestedFocusAreas.',
        },
        {
          role: 'user',
          content: JSON.stringify({
            summary: payload,
            today: new Date().toISOString().slice(0, 10),
            responseSchema: weeklyReviewSchemaHint,
          }),
        },
      ],
      normalize: normalizeWeeklyReview,
    };
  }

  if (context !== 'inbox_processing') {
    return { error: 'context must be inbox_processing or weekly_review.' };
  }

  const rawText = cleanString(payload.rawText);
  if (!rawText) {
    return { error: 'payload.rawText is required.' };
  }

  return {
    model,
    input: [
      {
        role: 'system',
        content:
          'You clarify GTD inbox items for processing. Return only valid JSON. Choose nextAction, project, someday, reference, or trash. Prefer concrete next physical actions and existing context names.',
      },
      {
        role: 'user',
        content: JSON.stringify({
          inboxItem: {
            title: rawText,
            notes: cleanString(payload.notes),
            currentChoice: cleanString(payload.currentChoice),
          },
          contexts: Array.isArray(payload.availableContexts)
            ? payload.availableContexts.map(cleanString).filter(Boolean)
            : [],
          today: new Date().toISOString().slice(0, 10),
          responseSchema: schemaHint,
        }),
      },
    ],
    normalize: (suggestion) => normalizeAssistSuggestion(suggestion, rawText),
  };
}

server.listen(port, '127.0.0.1', () => {
  console.log(`Zoro AI proxy listening on http://127.0.0.1:${port}`);
});

function loadEnvFiles() {
  const proxyDir = dirname(fileURLToPath(import.meta.url));
  const repoRoot = resolve(proxyDir, '..', '..');
  for (const filePath of [join(repoRoot, '.env'), join(proxyDir, '.env')]) {
    if (existsSync(filePath)) {
      loadEnvFile(filePath);
    }
  }
}

function loadEnvFile(filePath) {
  const text = readFileSync(filePath, 'utf8');
  for (const line of text.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }
    const separator = trimmed.indexOf('=');
    if (separator === -1) {
      continue;
    }
    const key = trimmed.slice(0, separator).trim();
    const rawValue = trimmed.slice(separator + 1).trim();
    if (!key || process.env[key] !== undefined) {
      continue;
    }
    process.env[key] = unquoteEnvValue(rawValue);
  }
}

function unquoteEnvValue(value) {
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

function setCors(response) {
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'content-type');
}

function sendJson(response, status, data) {
  response.writeHead(status, { 'content-type': 'application/json' });
  response.end(JSON.stringify(data));
}

async function readJson(request) {
  let body = '';
  for await (const chunk of request) {
    body += chunk;
  }
  return body ? JSON.parse(body) : {};
}

function extractOutputText(aiBody) {
  if (typeof aiBody.output_text === 'string') {
    return aiBody.output_text;
  }

  const chunks = [];
  for (const item of aiBody.output ?? []) {
    for (const content of item.content ?? []) {
      if (typeof content.text === 'string') {
        chunks.push(content.text);
      }
    }
  }
  return chunks.join('\n');
}

function parseSuggestion(text) {
  const trimmed = text.trim();
  if (!trimmed) {
    throw new Error('The model returned an empty suggestion.');
  }

  try {
    return JSON.parse(trimmed);
  } catch {
    const match = trimmed.match(/\{[\s\S]*\}/);
    if (!match) {
      throw new Error('The model did not return JSON.');
    }
    return JSON.parse(match[0]);
  }
}

function normalizeSuggestion(raw, fallbackTitle) {
  return {
    choice: normalizeChoice(raw.choice),
    title: cleanString(raw.title) || fallbackTitle,
    desiredOutcome: cleanOptional(raw.desiredOutcome),
    nextActionTitle: cleanOptional(raw.nextActionTitle),
    contextName: cleanOptional(raw.contextName),
    targetDate: cleanDate(raw.targetDate),
    reconsiderDate: cleanDate(raw.reconsiderDate),
    notes: cleanOptional(raw.notes),
    tags: cleanArray(raw.tags),
    stepTitles: cleanArray(raw.stepTitles),
  };
}

function normalizeAssistSuggestion(raw, fallbackTitle) {
  const legacy = normalizeSuggestion(raw, fallbackTitle);
  return {
    recommendedChoice: normalizeChoice(raw.recommendedChoice ?? raw.choice),
    title: legacy.title,
    desiredOutcome: legacy.desiredOutcome,
    nextActionTitle: legacy.nextActionTitle,
    context: cleanOptional(raw.context ?? raw.contextName),
    targetDate: cleanDateTime(raw.targetDate),
    reconsiderDate: cleanDate(raw.reconsiderDate),
    notes: legacy.notes,
    tags: legacy.tags,
    steps: cleanArray(raw.steps ?? raw.stepTitles),
  };
}

function normalizeWeeklyReview(raw) {
  return {
    priorityActions: cleanArray(raw.priorityActions),
    stalledProjects: cleanArray(raw.stalledProjects),
    readyToActivateCount: Number.isFinite(Number(raw.readyToActivateCount))
      ? Number(raw.readyToActivateCount)
      : 0,
    horizonsAlignmentTips: cleanArray(raw.horizonsAlignmentTips),
    suggestedFocusAreas: cleanArray(raw.suggestedFocusAreas),
  };
}

function normalizeChoice(choice) {
  const normalized = cleanString(choice).replace(/[-_\s]/g, '').toLowerCase();
  if (normalized === 'project') return 'project';
  if (normalized === 'calendarevent' || normalized === 'calendar' || normalized === 'event') return 'calendarEvent';
  if (normalized === 'someday' || normalized === 'somedaymaybe' || normalized === 'maybe') return 'someday';
  if (normalized === 'reference') return 'reference';
  if (normalized === 'waitingfor' || normalized === 'waiting' || normalized === 'delegated') return 'waitingFor';
  if (normalized === 'trash' || normalized === 'delete') return 'trash';
  return 'nextAction';
}

function cleanArray(value) {
  return Array.isArray(value) ? value.map(cleanString).filter(Boolean) : [];
}

function cleanOptional(value) {
  const text = cleanString(value);
  return text || null;
}

function cleanDate(value) {
  const text = cleanString(value);
  return /^\d{4}-\d{2}-\d{2}$/.test(text) ? text : null;
}

function cleanDateTime(value) {
  const text = cleanString(value);
  if (!text) return null;
  const date = new Date(text);
  return Number.isNaN(date.getTime()) ? cleanDate(value) : date.toISOString();
}

function cleanString(value) {
  return value === null || value === undefined ? '' : String(value).trim();
}
