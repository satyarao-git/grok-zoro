# Zoro Project Summary (Last updated: May 21, 2026)

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
- Android and iOS platform projects are now present for mobile distribution.

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

**May 19-21, 2026 Mobile / Store Handoff**
- Added Flutter Android and iOS scaffolding to the repo.
- Mobile app identity changed to `com.neuralreach.zoro`; use this package name in Google Play Console and the iOS bundle identifier.
- Android display name is `Zoro`; Android app has internet and microphone permissions.
- iOS `Info.plist` includes microphone and speech recognition usage descriptions.
- Native/mobile AI default now points to `https://zoro-windows.web.app` so phones use the Firebase Functions proxy instead of local `127.0.0.1`.
- Upgraded `speech_to_text` to `7.4.0` and moved voice listening to `SpeechListenOptions`.
- Added Android Gradle compatibility handling for older plugin metadata, especially `isar_flutter_libs`.
- Configured Android release signing through `android/key.properties` and `android/upload-keystore.jks`; both are intentionally ignored by Git and must not be committed.
- Google Play Console app was created for `Zoro` with package `com.neuralreach.zoro`; an internal testing release flow was started/uploaded.
- Internal testing release notes must use language tags, for example `<en-US>Initial internal testing release of Zoro.</en-US>`.
- The opt-in link appears only after the internal test release is rolled out.
- Android debug APK was successfully built and installed locally on a Pixel for testing.
- For future Google Play uploads, increment `version` in `pubspec.yaml`; for example `0.1.1+2` after the current `0.1.0+1`.

**Mobile Build Commands**

Android debug APK:

```powershell
& "C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter build apk --debug
```

Android Play Store bundle:

```powershell
& "C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter build appbundle --release
```

Google Play upload artifact:

```text
build\app\outputs\bundle\release\app-release.aab
```

iOS handoff:

```text
Open ios/Runner.xcworkspace in Xcode, not ios/Runner.xcodeproj.
Bundle identifier: com.neuralreach.zoro
```

**Master Specification**
All new code, UI, and behavior must strictly follow the attached master specification document (`grok-zoro.docx`) and the latest `ZORO_IMPLEMENTATION_STATUS.md`.  
The dynamic Inbox Processing screen, GTD correctness, Material 3 design language, and Settings import/export behavior are especially critical.

**Next Priority Items**
- Commit and push the latest Android/iOS/package/signing-config changes before pulling the code on a Mac for Xcode.
- Complete/roll out the Google Play internal testing release and copy the opt-in link for testers.
- Test the Play-distributed Android build thoroughly on Pixel, including persistence, Settings import/export, `.xlsx` upload, voice capture, and AI Assist.
- Build iOS from the latest Git code on macOS using `ios/Runner.xcworkspace`.
- Continue with remaining Phase 2 and Phase 3 features per Master Spec.
- Decide whether JSON import should support merge mode in addition to the current replace/restore mode.
- Decide whether spreadsheet upload should also support CSV in addition to `.xlsx`.

---
This file is the single source of truth for continuing the Zoro project. Always reference it plus the Master Specification when generating new code.
