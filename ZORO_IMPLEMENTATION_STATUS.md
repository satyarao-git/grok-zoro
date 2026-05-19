# Zoro Implementation Status and Handoff Specification

Last updated: May 17, 2026

This document summarizes what has been implemented so far in the Zoro Flutter app. It is intended as a handoff/status brief for another LLM or collaborator who is brainstorming product direction and needs an accurate picture of the current application.

## Product Summary

Zoro is a professional Getting Things Done (GTD) productivity app built in Flutter. The current implementation focuses on fast capture, inbox clarification, trusted next actions, project organization, calendar visibility, weekly review, history, reference material, and AI-assisted clarification/review.

The app follows:

- Clean Architecture style folder separation.
- Riverpod 2.x for state management.
- Isar as the native persistence layer.
- A localStorage-backed web adapter for Flutter web preview because Isar native cannot compile directly to Flutter web JS/Wasm.
- Material 3 UI with a clean, minimalist, professional design language and blue accents.

## Technology Stack

- Flutter/Dart
- Riverpod 2.x
- GoRouter
- Material 3
- Isar and `isar_flutter_libs`
- Web localStorage adapter for browser preview
- `speech_to_text` for voice capture
- `file_picker` and `excel` for Settings-based `.xlsx` task import
- `http` for AI proxy/API calls
- `intl` for date formatting
- `uuid` for stable entity IDs
- `fpdart` for `Either<Failure, T>` use-case/repository results

## Current App Architecture

Primary folders:

- `lib/domain/entities/`: pure domain models.
- `lib/domain/repositories/`: repository interfaces.
- `lib/domain/usecases/`: application use cases.
- `lib/infrastructure/isar/`: Isar schemas and native database setup.
- `lib/infrastructure/repositories/`: Isar repository implementations.
- `lib/infrastructure/persistence/`: platform-specific repository factories; native uses Isar, web uses localStorage.
- `lib/infrastructure/ai/`: reusable AI Assist service.
- `lib/infrastructure/services/`: legacy AI clarify service and speech-related services.
- `lib/presentation/providers/`: UI-specific Riverpod providers.
- `lib/application/providers/`: app-level providers such as History notifier.
- `lib/application/imports/`: spreadsheet and backup import parsing helpers.
- `lib/presentation/screens/`: screens.
- `lib/presentation/widgets/`: shared UI widgets.
- `lib/core/routes/`: GoRouter setup.
- `lib/core/theme/`: app theme.
- `lib/core/constants/`: constants such as History retention.

The central provider/injection file is:

- `lib/injection_container.dart`

## Routing and Navigation

The app uses GoRouter. Initial route:

- `/dashboard`

Implemented routes:

- `/dashboard` - Dashboard
- `/inbox` - Inbox captures list
- `/today` - Today view
- `/next-7-days` - Next 7 Days view
- `/processing/:itemId` - Inbox Processing screen
- `/project/:projectId` - Project detail
- `/next-actions` - Existing alias for next actions
- `/all-next-actions` - All Next Actions
- `/projects` - Projects
- `/contexts` - Context Management
- `/task/:taskId` - Task/Next Action detail
- `/someday` - Someday/Maybe Review
- `/search` - Global Search
- `/waiting-for` - Waiting For
- `/reference` - Reference
- `/calendar` - Calendar
- `/settings` - Settings
- `/archive` - Archive
- `/weekly-review` - Weekly Review
- `/history` - History
- `/horizons` - Horizons

The left navigation is implemented in `ZoroAppScaffold` and uses a persistent `NavigationRail` on wide layouts and a `NavigationDrawer` on smaller layouts.

Current navigation order:

1. Dashboard
2. Inbox
3. Next Actions
4. Someday/Maybe
5. Projects
6. Calendar
7. Weekly Review
8. Waiting for
9. Reference
10. Contexts
11. Horizons
12. Search
13. Archive
14. Settings

History remains implemented as `/history` and is opened from Settings.

## Domain Entities Implemented

### InboxItem

Fields:

- `id`
- `title`
- `notes`
- `capturedAt`
- `source`: manual, voice, shareSheet, import

### Task

Represents next actions and project steps.

Fields:

- `id`
- `title`
- `description`
- `context`
- `dueDate`
- `targetDate`
- `endDateTime`
- `isNextAction`
- `isCompleted`
- `createdAt`
- `completedAt`
- `projectId`
- `tags`
- `energyLevel`: low, medium, high
- `estimatedMinutes`

### Project

Fields:

- `id`
- `title`
- `desiredOutcome`
- `stepIds`
- `projectSteps`
- `currentNextActionId`
- `targetCompletionDate`
- `isCompleted`
- `createdAt`
- `tags`
- `areaOfFocus`
- `completedStepCount`
- computed `progress`

### SomedayMaybeItem

Fields:

- `id`
- `title`
- `reconsiderDate`
- `createdAt`
- `notes`
- `tags`
- computed `isReadyToActivate`

### WaitingForItem

Fields:

- `id`
- `title`
- `person`
- `projectId`
- `followUpDate`
- `createdAt`
- `notes`
- `isResolved`

### ReferenceItem

Fields:

- `id`
- `title`
- `createdAt`
- `notes`
- `tags`
- `folder`

### HistoryEntry

Fields:

- `id`
- `timestamp`
- `action`
- `entityType`
- `entityId`
- `description`
- `details`

Actions:

- inboxProcessed
- taskCreated
- taskCompleted
- projectCreated
- somedayCreated
- referenceCreated
- waitingForCreated
- somedayActivated
- dataCleared

### Horizons

Implemented as `Horizon` and `HorizonsOfFocus`.

Levels:

- purposeAndPrinciples
- vision
- goals
- areasOfFocus
- projects
- nextActions

### AppSettings

Fields:

- `voiceCaptureEnabled`
- `defaultContextName`
- `weeklyReviewWeekday`
- `aiEnabled`
- `aiBaseUrl`
- `aiModel`
- `aiApiKey`
- `voiceLocaleId`

## Core Use Cases Implemented

- `CreateInboxItemUseCase`
- `ProcessInboxItemUseCase`
- `CreateProjectUseCase`
- `CompleteNextActionUseCase`
- `ActivateSomedayMaybeUseCase`
- `ClearAllDataUseCase`
- `LogHistoryEntryUseCase`
- `AiSuggestUseCase`
- basic `WeeklyReviewUseCase`

## Persistence Implemented

### Native

Native persistence uses Isar schemas and repositories:

- Inbox
- Tasks
- Projects
- Someday/Maybe
- Waiting For
- Reference
- History
- Contexts
- Horizons
- App Settings
- Weekly Review Progress

### Web Preview

Flutter web uses `WebPersistenceStore` in `repository_factories_web.dart`, backed by browser localStorage under key:

- `zoro.persistence.v1`

The web store seeds demo data on first launch.

Important: web preview data is per-browser and local to the tester/device.

## Implemented Screens and Behavior

### Dashboard

Implemented route: `/dashboard`

Current dashboard provides a main overview of the trusted system and entry points into major GTD areas.

### Inbox

Implemented route: `/inbox`

Features:

- Lists unprocessed captures.
- Allows navigating to `/processing/:itemId`.
- Integrated with capture flow from voice/text bottom sheet.

### Inbox Processing

Implemented route: `/processing/:itemId`

Current behavior:

- Two-column layout on wide screens: left clarification sidebar plus dynamic right form.
- Left sidebar choices:
  - Next Action
  - Project
  - Someday/Maybe
  - Reference
  - Trash
- Smart default:
  - Defaults to Project when title suggests multi-step work such as plan, launch, prepare, organize, build.
  - Otherwise defaults to Next Action.
- Dynamic right panel updates immediately when processing choice changes.

Next Action form:

- Title
- Context chips
- Outlook-style target date/time block
- Start date
- Start time
- End time
- All-day toggle
- Notes
- Save button: `Save as Next Action`
- When target date/time is set, the task appears in Calendar via `targetDate` and `endDateTime`.

Project form:

- Project title
- Desired outcome
- Project notes
- Dynamic steps checklist
- Each Future Step can be clarified inline as:
  - Next Action
  - Calendar Event
- Waiting For
- Step 1 displays `Create at least one action`
- Clarified steps are created with the Project and linked through `projectId`
- Save button: `Create Project & Next Action`

Someday/Maybe form:

- Title
- Reason checkboxes
- Reconsider date
- Notes
- Tags

Reference form:

- Title
- Notes
- Tags
- Folder/category
- Save button: `Save to Reference`

Trash:

- Allows discarding the inbox item.

AI:

- Prominent `AI Clarify` button.
- Uses generic `AiSuggestUseCase`.
- Sends raw inbox text and current processing choice.
- Applies AI suggestions to form fields.

Known validation:

- Project processing requires desired outcome.
- Failed validation keeps the inbox item instead of clearing it.

### Voice/Text Capture

Implemented via:

- `VoiceFabWidget`
- `CaptureBottomSheet`
- `VoiceInputNotifier`

Behavior:

- Main screens show a prominent microphone FAB when enabled.
- Tapping opens a unified Capture to Inbox bottom sheet.
- User can type manually or use speech-to-text.
- Live transcription updates an editable text field.
- User can start/stop listening from inside the sheet.
- User can select language/accent in Settings.
- `Add to Inbox` creates an `InboxItem`.
- No auto-navigation to Processing after capture.

### Settings: Voice Input Language

Implemented in Settings.

Features:

- Loads available `speech_to_text` locales.
- Lets user choose preferred speech locale.
- Defaults to device locale if none selected.
- Stores `voiceLocaleId` in settings.

### Today Screen

Implemented route: `/today`

Features:

- Summary: actions due today and overdue.
- Lists active next actions due today or overdue.
- Groups by context.
- Cards show title, context, linked project, energy level, quick complete checkbox.
- Empty state when no due actions.
- Voice FAB available.

### Next 7 Days Screen

Implemented route: `/next-7-days`

Features:

- Filters/tabs: Next Actions, Projects, All.
- Groups dated items over the next seven days by day.
- Expandable/collapsible day sections.
- Cards include title, context/project info, target date badge, quick actions.
- Empty state when no items.

### All Next Actions Screen

Implemented routes:

- `/all-next-actions`
- `/next-actions`

Features:

- Tabs:
  - By Context
  - All Next Actions
  - By Project
- By Context view includes sidebar/context counts.
- By Project groups tasks by project.
- All Next Actions view is searchable.
- Cards show title, context, project, energy level, quick complete.

### Projects

Implemented routes:

- `/projects`
- `/project/:projectId`

Features:

- Active projects list.
- Project detail screen.
- Project progress support via completed step count and step IDs.
- Metadata section in detail screen.

### Task Detail

Implemented route:

- `/task/:taskId`

Features:

- Detail/review of task/next action.
- Metadata section with created date and ID.
- Copy ID support via metadata widget.

### Someday/Maybe Review

Implemented route:

- `/someday`

Features:

- Prominent Ready to Activate section.
- Left-hand `SomedaySidebar`.
- Total item count shown.
- Year filter:
  - All Years
  - No Date
  - dynamically generated years from reconsider dates
  - counts per year
- Month filter:
  - visible only when a specific year is selected
  - includes All Months
  - shows only months with items
- Tags filter:
  - unique tags with counts
  - multi-select support
  - clear/all option
- Main list reacts instantly to filters.
- Activation support via `ActivateSomedayMaybeUseCase`.

### Reference

Implemented route:

- `/reference`

Features:

- Full Reference GTD category support.
- Searchable list of reference items.
- Folder/category filtering.
- Tag filtering.
- Cards show title, notes snippet, tags, folder, open action.
- Empty state.
- Reference items can be created from Inbox Processing.

### Waiting For

Implemented route:

- `/waiting-for`

Features:

- Waiting-for items list.
- Person/follow-up data.
- Due follow-up provider.
- Resolve support.

### Calendar

Implemented route:

- `/calendar`

Features:

- Outlook-style Calendar screen.
- Segmented view selector:
  - Day
  - Week
  - Month
- Default view: Week.
- Period display and date picker.
- Today button.
- Voice FAB.
- Week view:
  - seven-day columns
  - today highlight
  - cards for tasks/projects/waiting-for entries
- Month view:
  - month grid
  - item dots/count indicators
  - day tap behavior
- Day view:
  - untimed/all-day section
  - timed timeline
- Calendar entries include active Tasks and Projects where target/due dates fall in range.
- Next Action target datetime from Inbox Processing appears in Calendar.

### Context Management

Implemented route:

- `/contexts`

Features:

- Context list.
- Add/update/delete contexts.
- Default contexts cannot be deleted or renamed.
- Context usage counts.

Default contexts include:

- @Anywhere
- @Computer
- @Home
- @Errands
- @Calls

### Global Search

Implemented route:

- `/search`

Features:

- Global search across:
  - Inbox
  - Projects
  - Tasks/Next Actions
  - Someday/Maybe
  - Reference
  - Waiting For
  - Archive
  - Horizons
- Results include category labels and routes.

### History

Implemented route:

- `/history`

Features:

- History entries for important actions.
- Chronological Material 3 card list.
- Search/filter UX.
- Top bar indicates last six weeks and count.
- Automatic retention target: 42 days.
- Manual prune action available from Settings.
- Entry properties bottom sheet/dialog shows:
  - timestamp
  - action
  - description
  - entity ID
  - copy ID action
- Main list subtly indicates ID when present.

### Archive

Implemented route:

- `/archive`

Features:

- Aggregated archive-like view of completed tasks and completed projects.
- Uses routes back to detail screens.

### Horizons

Implemented route:

- `/horizons`

Features:

- Horizons of Focus support.
- Alignment summary provider.
- Used by Weekly Review and search.

### Weekly Review

Implemented route:

- `/weekly-review`

Features:

- Checklist-based weekly review progress.
- Steps:
  - Clear Inbox
  - Review Projects
  - Review Next Actions
  - Review Calendar
  - Review Waiting For
  - Review Someday/Maybe
  - Horizons Alignment Check
- Progress stored in persistence.
- Mark review complete.
- Reset review.
- AI Assist Review button.
- AI Review Insights card with:
  - priority actions
  - stalled projects
  - ready-to-activate count
  - horizons alignment tips
  - suggested focus areas
- Quick buttons to open Inbox, Projects, and Someday.

### Settings

Implemented route:

- `/settings`

Sections:

- Capture
- Voice Input Language
- Clarify defaults
- Weekly Review
- AI Integration
- Backup
- Data & Maintenance

Settings features:

- Toggle voice capture FAB.
- Select preferred speech language/accent.
- Choose default next-action context.
- Choose weekly review day.
- Enable/disable AI Assist.
- Configure AI base URL.
- Configure AI model.
- Configure AI API key.
- Copy JSON backup.
- Import JSON backup.
- Upload `.xlsx` tasks to Inbox.
- View History.
- Prune History.
- Clear All Data.

Backup/import behavior:

- `Copy JSON` exports a schema version 1 Zoro snapshot.
- `Import JSON` restores a Zoro snapshot after a confirmation prompt.
- JSON import replaces current Inbox, Tasks, Projects, Someday/Maybe, Reference, Waiting For, settings, contexts, horizons, and weekly review progress.
- JSON import preserves restored entity IDs so task/project links remain intact.
- `Upload Tasks` accepts `.xlsx` files with columns `serial number`, `task`, and optional `category`.
- Spreadsheet rows are imported into Inbox with `CaptureSource.import`.
- Spreadsheet row values are concatenated into one Inbox capture string, for example `1 - Call bank - Finance`.

Clear All Data:

- Protected red-accent action.
- Requires Material 3 confirmation dialog.
- User must type `RESET`.
- Clears Inbox, Tasks, Projects, Someday/Maybe, Reference, Waiting For, History.
- Invalidates major providers.
- Logs action through History system.

### Bulk Capture and Backup Import

Implemented in Settings.

Files:

- `lib/application/imports/bulk_capture_import.dart`
- `lib/domain/usecases/import_backup_use_case.dart`
- `test/bulk_capture_import_test.dart`
- `test/backup_import_snapshot_test.dart`

Behavior:

- Bulk upload reads `.xlsx` spreadsheets through `file_picker` and `excel`.
- Required spreadsheet column: `task`.
- Supported serial columns include `serial number`, `serial no`, `serial`, `number`, `no`, and `#`.
- Optional category columns include `category`, `categories`, `tag`, and `tags`.
- Empty task rows are skipped and reported in the success message.
- Imported spreadsheet rows are added to Inbox as `CaptureSource.import`.
- JSON import restores the same schema version 1 shape emitted by `backupExportProvider`.
- JSON import is replace/restore mode, not merge mode.
- JSON import prompts the user before replacing current trusted-system data.
- Web repositories now preserve supplied IDs on create/add so restored project/task links remain valid.
- Project persistence stores `completedStepCount` in both Isar and web localStorage paths.

## Metadata and IDs

Implemented reusable widget:

- `presentation/widgets/item_metadata_widget.dart`

Behavior:

- Displays item ID with copy button.
- Displays created date formatted as helper text.
- Used inside expandable `Item Metadata` sections on detail/review screens.
- Long-press properties bottom sheets were added for list access where implemented.
- Main list views intentionally avoid always-visible metadata to preserve clean GTD scanning.

## AI Assist Implementation

New generic AI system:

- `lib/infrastructure/ai/ai_service.dart`
- `lib/domain/usecases/ai_suggest_use_case.dart`
- `lib/domain/entities/ai_assist_models.dart`
- `lib/presentation/widgets/ai_assist_button.dart`

Contexts:

- `inbox_processing`
- `weekly_review`

Inbox Processing AI expected output:

```json
{
  "recommendedChoice": "project | nextAction | someday | reference | trash",
  "title": "...",
  "desiredOutcome": "...",
  "steps": ["..."],
  "context": "@Computer",
  "targetDate": "ISO string or null",
  "notes": "...",
  "tags": ["..."]
}
```

Weekly Review AI expected output:

```json
{
  "priorityActions": ["..."],
  "stalledProjects": ["..."],
  "readyToActivateCount": 2,
  "horizonsAlignmentTips": ["..."],
  "suggestedFocusAreas": ["..."]
}
```

AI calling modes:

1. Local proxy mode:
   - App calls configured base URL plus `/assist`.
   - Default base URL: `http://127.0.0.1:8787`.
   - App Settings API key can stay blank.
   - Local proxy reads `.env` and calls OpenAI.

2. OpenAI-compatible direct mode:
   - If API key is configured in app Settings, service can call an OpenAI-compatible chat completions endpoint.
   - This is not recommended for public web deployment because browser-side API keys are not secure.

Local AI proxy:

- `tools/ai_proxy/server.mjs`
- Supports `/health`.
- Supports legacy `/clarify`.
- Supports generic `/assist`.
- Reads `.env` from repo root or `tools/ai_proxy/.env`.
- Calls OpenAI Responses API.

Windows tester AI proxy:

- `tools/ai_proxy_dart/zoro_ai_proxy.dart`
- Compiles to `zoro_ai_proxy.exe`.
- Does not require testers to install Node.js.
- Supports `/health`, `/clarify`, and `/assist`.
- Reads `.env` beside the executable or from the current folder.
- Supports `AI_PROVIDER=openai` and `AI_PROVIDER=anthropic`.
- OpenAI uses `OPENAI_API_KEY` and `OPENAI_MODEL`.
- Anthropic uses `ANTHROPIC_API_KEY` and `ANTHROPIC_MODEL`.

Env file:

- `.env` is gitignored.
- `.env.example` exists.

Expected `.env`:

```text
AI_PROVIDER=openai
PORT=8787
OPENAI_API_KEY=your_real_key_here
OPENAI_MODEL=gpt-5.2

ANTHROPIC_API_KEY=your_anthropic_key_here
ANTHROPIC_MODEL=claude-3-5-sonnet-latest
```

## Local Run Setup

Two services are currently needed for full local testing:

### 1. Flutter web app preview

Script:

```powershell
.\tools\run_web_3200.ps1
```

What it does:

- Builds Flutter web with `--no-wasm-dry-run`.
- Serves `build/web` on `http://127.0.0.1:3200` using `tools/static_web_server.mjs`.

### 2. AI proxy

Script:

```powershell
.\tools\run_ai_proxy.ps1
```

What it does:

- Starts `tools/ai_proxy/server.mjs`.
- Reads `.env`.
- Listens on `http://127.0.0.1:8787`.
- Calls OpenAI using `OPENAI_API_KEY`.

Why two services:

- Browser app runs on port 3200.
- AI proxy runs on port 8787.
- Browser apps cannot safely keep `.env` secrets, so AI calls are proxied through the local Node server.

Mental model:

```text
Browser Zoro app :3200 -> Local AI proxy :8787 -> OpenAI
```

## Firebase Deployment Discussion Status

The user is exploring Option 2: hosted web preview.

Important clarification:

- Firebase App Distribution is for distributing mobile app builds to testers, not hosting a web app.
- Firebase Hosting is the right Firebase product for a Flutter web build.
- Firebase Hosting would only serve static web files.
- The app logic runs in each tester's browser.
- To support AI safely for hosted web testers, a backend proxy is needed.
- On Firebase, the natural backend would be Firebase Cloud Functions.

Potential Firebase architecture:

```text
Tester browser
  -> Firebase Hosting: serves Flutter web build
  -> Firebase Cloud Function: AI proxy
       -> OpenAI
```

Persistence decision:

- Current web app persists data in each tester's browser localStorage.
- Firebase does not store GTD data unless cloud sync/admin review/shared accounts are added later.
- Adding cloud persistence would likely require Firebase Auth and Firestore, which is a separate product decision.

## Test and Verification Status

Recent checks passed:

- `flutter analyze`
- `flutter test`
- `flutter build web`
- `flutter build windows --release`
- `node --check tools/ai_proxy/server.mjs`
- `node --check tools/static_web_server.mjs`
- `dart compile exe tools/ai_proxy_dart/zoro_ai_proxy.dart`

Known web build note:

- Flutter may warn about Wasm incompatibilities because `speech_to_text` uses web APIs and Isar includes native `dart:ffi` internals. The app is intended to use the standard JS web build for preview and localStorage persistence on web.

## Notable Known Constraints and Decisions

- Web preview uses localStorage, not Isar.
- Native persistence uses Isar.
- Hosted web testers will not share data unless a cloud backend is added.
- AI requires a proxy for safe API key handling in web deployments.
- Current local AI proxy uses OpenAI Responses API.
- Windows tester package includes a compiled provider-neutral AI proxy executable.
- App Settings can store an API key, but that is not appropriate for public hosted web distribution.
- Voice input depends on browser/device speech permissions and available locales.
- Static preview server must remain running while testing at `127.0.0.1:3200`.
- AI proxy must remain running while testing AI at `127.0.0.1:8787`.

## Recommended Next Product Decisions

These are not implemented plans; they are pending decisions for future work:

1. Tester distribution target:
   - Firebase Hosting web preview
   - Firebase App Distribution mobile build
   - Desktop build zip/installer

2. AI backend for testers:
   - Local proxy per tester
   - Hosted Firebase Cloud Function proxy
   - Disable AI for first testing round

3. Persistence for testers:
   - Keep browser-local data
   - Add Firebase Auth/Firestore for cloud persistence
   - Add export/import workflows for tester feedback

4. Feedback capture:
   - Manual feedback form
   - In-app feedback capture
   - Firebase/analytics logging

5. Security posture:
   - How to manage OpenAI keys
   - Whether testers use shared key, individual keys, or hosted proxy secret
   - Rate limits/cost controls for AI Assist

## High-Level Current Status

Implemented:

- Core GTD entities and repositories.
- Native Isar persistence.
- Web localStorage persistence.
- Main navigation and routes.
- Dashboard.
- Inbox and processing.
- Next Action, Project, Someday/Maybe, Reference, Trash processing choices.
- Calendar with Day/Week/Month views.
- Today, Next 7 Days, All Next Actions.
- Projects and task detail.
- Someday/Maybe review filters.
- Reference category.
- Waiting For.
- Context management.
- Global search.
- History with retention/prune support.
- Metadata/ID display.
- Settings, backup, clear all data.
- Settings import/export: Copy JSON, Import JSON restore, Upload Tasks from `.xlsx` to Inbox.
- Voice/text Capture to Inbox.
- AI Clarify and AI Assist Review through reusable AI service.
- Local AI proxy with `.env` support.
- Provider-neutral Windows AI proxy with OpenAI/Anthropic support.
- Local static web preview scripts.
- Windows tester package script.
- Firebase Hosting deployment and Firebase Functions AI proxy.
- Firebase web builds use `--pwa-strategy=none` to avoid stale Flutter service-worker caches during tester updates.

Not yet decided/implemented:

- Cloud persistence/sync.
- User accounts/auth.
- Mobile App Distribution packaging.
- Formal tester feedback workflow.
- Merge-mode JSON import.
- CSV import as an alternative to `.xlsx`.
