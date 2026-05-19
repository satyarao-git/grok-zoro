# Zoro Project Summary (Last updated: May 17, 2026)

**Project Goal**  
Professional, clean, and faithful implementation of David Allen's Getting Things Done (GTD) methodology in Flutter.

**Tech Stack & Architecture (strictly followed)**
- Clean Architecture + Riverpod 2.x (AsyncNotifier pattern)
- Isar (native) + localStorage web adapter for web/Firebase
- Material 3 minimalist professional design with blue accents
- GoRouter navigation
- `file_picker` + `excel` for Settings-based spreadsheet import

**Current Navigation Sidebar (exact order)**
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

History is available from Settings rather than the main left panel.

**Key Implemented Features**
- Dynamic Inbox Processing screen with left sidebar choices: **Next Action**, **Project**, **Calendar Event**, **Someday/Maybe**, **Reference**, **Waiting For**, and **Trash**.
- Rich Next Action form with full start/end time + all-day support for calendar entries.
- Project processing uses clarified Future Steps; each step can become a linked Next Action, Calendar Event, or Waiting For item.
- Major screens: Dashboard, Inbox, Next Actions, Projects, Calendar (Week/Month/Day), Someday/Maybe, Waiting For, Reference, History, Archive, Settings, Weekly Review, Horizons.
- Voice capture, AI Assist, History logging, Item Metadata widget.
- Firebase Hosting deployment with server-side Firebase Function AI proxy.
- Settings import/export: `Copy JSON`, `Import JSON`, and `Upload Tasks`.

**Settings Import/Export**
- `Copy JSON` exports a Zoro backup snapshot.
- `Import JSON` restores an exported Zoro backup after a confirmation prompt. Current trusted-system data is replaced.
- `Upload Tasks` imports `.xlsx` spreadsheets into Inbox for migration or mind sweep capture.
- Spreadsheet columns: `serial number`, `task`, and optional `category`.
- Imported spreadsheet rows are concatenated into a single Inbox capture, for example `1 - Call bank - Finance`.

**Recent Additions / Refinements**
- Reference added to navigation + processing flow.
- Waiting For action label changed to "Mark completed".
- Calendar integration via `targetDate` / `endDateTime` on Next Actions.
- Weekly Review right-panel add actions for Next Action, Calendar, Project, Waiting For, Reference, and Someday/Maybe.
- Back navigation button on screens reached from another screen.
- Bulk task upload and backup JSON import in Settings.
- Master specification document (`grok-zoro.docx`) updated with the Settings import/restore requirements.

**Master Specification**
All new code, UI, and behavior must strictly follow the attached master specification document (`grok-zoro.docx`) and the latest `ZORO_IMPLEMENTATION_STATUS.md`.  
The dynamic Inbox Processing screen, GTD correctness, Material 3 design language, and Settings import/export behavior are especially critical.

**Next Priority Items**
- Continue with remaining Phase 2 and Phase 3 features per Master Spec.
- Decide whether JSON import should support merge mode in addition to the current replace/restore mode.
- Decide whether spreadsheet upload should also support CSV in addition to `.xlsx`.

---
This file is the single source of truth for continuing the Zoro project. Always reference it plus the Master Specification when generating new code.
