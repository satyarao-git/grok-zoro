# Zoro Windows Tester Instructions

Thank you for testing Zoro.

## What is in this folder

- `Zoro\grok_zoro.exe` - the Zoro Windows app.
- `zoro_ai_proxy.exe` - local AI helper. It supports OpenAI and Anthropic.
- `.env.example` - template for your AI key.
- `zoro.bat` - starts the Zoro app.
- `run_ai_proxy.bat` - starts the local AI helper.

## Start Zoro without AI

Open:

```text
zoro.bat
```

Most GTD features work without AI.

## Voice capture on Windows

The Windows tester build supports typing directly into the Capture to Inbox
box. Built-in microphone capture is disabled in this early Windows package
because the current speech plugin does not provide Windows desktop dictation.

You can still use Windows dictation:

1. Click inside the large Capture to Inbox text box.
2. Press `Win+H`.
3. Dictate into the text field.
4. Click `Add to Inbox`.

## Enable AI Clarify / AI Assist Review

1. Copy `.env.example` to `.env` in this same folder.
2. Edit `.env`.
3. Choose a provider:

For OpenAI:

```text
AI_PROVIDER=openai
OPENAI_API_KEY=your_openai_key
OPENAI_MODEL=gpt-5.2
```

For Anthropic:

```text
AI_PROVIDER=anthropic
ANTHROPIC_API_KEY=your_anthropic_key
ANTHROPIC_MODEL=claude-3-5-sonnet-latest
```

4. Double-click:

```text
run_ai_proxy.bat
```

Keep that window open while using AI features.

5. In Zoro, go to Settings > AI Integration:

```text
AI Assist: On
AI base URL: http://127.0.0.1:8787
API key: blank
```

The key stays in your local `.env` file and is not entered into the app.

## Troubleshooting

If AI does not work:

- Make sure `run_ai_proxy.bat` is still open.
- Open `http://127.0.0.1:8787/health` in a browser. It should show `ok: true`.
- Check that `.env` is in the same folder as `zoro_ai_proxy.exe`.
- Check that only one provider is selected in `AI_PROVIDER`.

If Windows blocks the app:

- Click More info.
- Click Run anyway.

This build is for early testing and is not code-signed yet.
