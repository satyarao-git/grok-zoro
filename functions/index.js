const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

exports.aiProxy = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: ["OPENAI_API_KEY"],
    invoker: "public",
    cors: true,
  },
  async (request, response) => {
    setCors(response);

    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }

    const route = routeFor(request);

    if (request.method === "GET" && route === "health") {
      response.status(200).json({
        ok: Boolean((process.env.OPENAI_API_KEY || "").trim()),
        provider: "openai",
        model: model(),
      });
      return;
    }

    if (request.method !== "POST" || !["assist", "clarify"].includes(route)) {
      response.status(404).json({ error: "Not found." });
      return;
    }

    try {
      const body =
        request.body && typeof request.body === "object" ? request.body : {};
      const prepared =
        route === "assist"
          ? buildAssistPayload(body)
          : buildLegacyClarifyPayload(body);

      if (prepared.error) {
        response.status(400).json({ error: prepared.error });
        return;
      }

      const rawText = await callOpenAi({
        systemPrompt: prepared.systemPrompt,
        userPayload: prepared.userPayload,
      });
      const suggestion = parseJsonObject(rawText);
      response.status(200).json(prepared.normalize(suggestion));
    } catch (error) {
      logger.error("AI proxy failed", error);
      response.status(500).json({
        error: error instanceof Error ? error.message : "AI proxy failed.",
      });
    }
  },
);

function routeFor(request) {
  const rawPath = (
    request.originalUrl ||
    request.url ||
    request.path ||
    "/"
  ).split("?")[0];
  if (rawPath.includes("/clarify")) return "clarify";
  if (rawPath.includes("/assist")) return "assist";
  if (rawPath.includes("/health")) return "health";
  return "";
}

function model() {
  return (process.env.OPENAI_MODEL || "").trim() || "gpt-5.2";
}

async function callOpenAi({ systemPrompt, userPayload }) {
  const apiKey = (process.env.OPENAI_API_KEY || "").trim();
  if (!apiKey) {
    throw new Error("Set OPENAI_API_KEY as a Firebase Functions secret.");
  }

  const providerResponse = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
      accept: "application/json",
    },
    body: JSON.stringify({
      model: model(),
      input: [
        { role: "system", content: systemPrompt },
        { role: "user", content: JSON.stringify(userPayload) },
      ],
    }),
  });

  const responseBody = await providerResponse.text();
  if (!providerResponse.ok) {
    throw new Error(extractProviderError(responseBody));
  }

  const decoded = JSON.parse(responseBody);
  if (typeof decoded.output_text === "string") {
    return decoded.output_text;
  }

  const chunks = [];
  for (const item of Array.isArray(decoded.output) ? decoded.output : []) {
    for (const content of Array.isArray(item.content) ? item.content : []) {
      if (typeof content.text === "string") {
        chunks.push(content.text);
      }
    }
  }
  return chunks.join("\n");
}

function buildLegacyClarifyPayload(body) {
  const title = cleanString(body.title);
  if (!title) {
    return preparedError("title is required.");
  }

  return {
    systemPrompt:
      "You clarify GTD inbox items for processing. Return only valid JSON. " +
      "Choose nextAction, project, someday, or trash. Prefer concrete next " +
      "physical actions and existing context names.",
    userPayload: {
      inboxItem: {
        title,
        notes: cleanString(body.notes),
      },
      contexts: cleanList(body.contexts),
      today: todayIsoDate(),
      responseSchema: inboxSchemaHint(),
    },
    normalize: (suggestion) => normalizeLegacySuggestion(suggestion, title),
  };
}

function buildAssistPayload(body) {
  const context = cleanString(body.context);
  const payload =
    body.payload && typeof body.payload === "object" ? body.payload : {};

  if (context === "weekly_review") {
    return {
      systemPrompt:
        "You are Zoro, a GTD weekly review assistant. Return only valid JSON " +
        "with priorityActions, stalledProjects, readyToActivateCount, " +
        "horizonsAlignmentTips, and suggestedFocusAreas.",
      userPayload: {
        summary: payload,
        today: todayIsoDate(),
        responseSchema: {
          priorityActions: ["Review Project X"],
          stalledProjects: ["Project A - no progress signal"],
          readyToActivateCount: 0,
          horizonsAlignmentTips: ["Alignment tip"],
          suggestedFocusAreas: ["Clear Inbox"],
        },
      },
      normalize: normalizeWeeklyReview,
    };
  }

  if (context !== "inbox_processing") {
    return preparedError("context must be inbox_processing or weekly_review.");
  }

  const rawText = cleanString(payload.rawText);
  if (!rawText) {
    return preparedError("payload.rawText is required.");
  }

  return {
    systemPrompt:
      "You clarify GTD inbox items for processing. Return only valid JSON. " +
      "Choose nextAction, project, someday, reference, or trash. Prefer " +
      "concrete next physical actions and existing context names.",
    userPayload: {
      inboxItem: {
        title: rawText,
        notes: cleanString(payload.notes),
        currentChoice: cleanString(payload.currentChoice),
      },
      contexts: cleanList(payload.availableContexts),
      today: todayIsoDate(),
      responseSchema: inboxSchemaHint(),
    },
    normalize: (suggestion) => normalizeAssistSuggestion(suggestion, rawText),
  };
}

function inboxSchemaHint() {
  return {
    recommendedChoice:
      "nextAction | project | calendarEvent | someday | reference | waitingFor | trash",
    title: "short clarified title",
    desiredOutcome: "project outcome or null",
    nextActionTitle: "visible next physical action or null",
    context: "one of the provided contexts or null",
    targetDate: "ISO string or null",
    reconsiderDate: "YYYY-MM-DD or null",
    notes: "brief useful notes or null",
    tags: ["short tag"],
    steps: ["future project step"],
  };
}

function normalizeLegacySuggestion(raw, fallbackTitle) {
  return {
    choice: normalizeChoice(raw.choice),
    title: cleanString(raw.title) || fallbackTitle,
    desiredOutcome: cleanOptional(raw.desiredOutcome),
    nextActionTitle: cleanOptional(raw.nextActionTitle),
    contextName: cleanOptional(raw.contextName || raw.context),
    targetDate: cleanDateTime(raw.targetDate),
    reconsiderDate: cleanDate(raw.reconsiderDate),
    notes: cleanOptional(raw.notes),
    tags: cleanList(raw.tags),
    stepTitles: cleanList(raw.stepTitles || raw.steps),
  };
}

function normalizeAssistSuggestion(raw, fallbackTitle) {
  return {
    recommendedChoice: normalizeChoice(raw.recommendedChoice || raw.choice),
    title: cleanString(raw.title) || fallbackTitle,
    desiredOutcome: cleanOptional(raw.desiredOutcome),
    nextActionTitle: cleanOptional(raw.nextActionTitle),
    context: cleanOptional(raw.context || raw.contextName),
    targetDate: cleanDateTime(raw.targetDate),
    reconsiderDate: cleanDate(raw.reconsiderDate),
    notes: cleanOptional(raw.notes),
    tags: cleanList(raw.tags),
    steps: cleanList(raw.steps || raw.stepTitles),
  };
}

function normalizeWeeklyReview(raw) {
  return {
    priorityActions: cleanList(raw.priorityActions),
    stalledProjects: cleanList(raw.stalledProjects),
    readyToActivateCount:
      Number.parseInt(cleanString(raw.readyToActivateCount), 10) || 0,
    horizonsAlignmentTips: cleanList(raw.horizonsAlignmentTips),
    suggestedFocusAreas: cleanList(raw.suggestedFocusAreas),
  };
}

function parseJsonObject(text) {
  const trimmed = String(text || "").trim();
  if (!trimmed) {
    throw new Error("The model returned an empty suggestion.");
  }

  try {
    return JSON.parse(trimmed);
  } catch (_) {
    const match = trimmed.match(/\{[\s\S]*\}/);
    if (!match) {
      throw new Error("The model did not return JSON.");
    }
    return JSON.parse(match[0]);
  }
}

function extractProviderError(body) {
  try {
    const decoded = JSON.parse(body);
    if (typeof decoded.error === "string" && decoded.error.trim()) {
      return decoded.error;
    }
    if (
      decoded.error &&
      typeof decoded.error === "object" &&
      typeof decoded.error.message === "string"
    ) {
      return decoded.error.message;
    }
  } catch (_) {
    // Use fallback below.
  }
  return "OpenAI request failed.";
}

function normalizeChoice(value) {
  const normalized = cleanString(value).replace(/[-_\s]/g, "").toLowerCase();
  if (normalized === "project") return "project";
  if (
    normalized === "calendarevent" ||
    normalized === "calendar" ||
    normalized === "event"
  ) {
    return "calendarEvent";
  }
  if (
    normalized === "someday" ||
    normalized === "somedaymaybe" ||
    normalized === "maybe"
  ) {
    return "someday";
  }
  if (normalized === "reference") return "reference";
  if (
    normalized === "waitingfor" ||
    normalized === "waiting" ||
    normalized === "delegated"
  ) {
    return "waitingFor";
  }
  if (normalized === "trash" || normalized === "delete") return "trash";
  return "nextAction";
}

function cleanList(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.map(cleanString).filter(Boolean);
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
  if (!text) {
    return null;
  }
  const parsed = new Date(text);
  if (Number.isNaN(parsed.getTime())) {
    return cleanDate(value);
  }
  return parsed.toISOString();
}

function cleanString(value) {
  return value == null ? "" : String(value).trim();
}

function todayIsoDate() {
  return new Date().toISOString().slice(0, 10);
}

function preparedError(error) {
  return {
    error,
    systemPrompt: "",
    userPayload: {},
    normalize: (json) => json,
  };
}

function setCors(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  response.set("Access-Control-Allow-Headers", "content-type");
}
