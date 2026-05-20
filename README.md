# Zoro

Zoro is a Flutter implementation of Getting Things Done (GTD), focused on fast capture, clear processing, trusted next actions, and a calm weekly review.

## Development

The app follows the specification in `grok-zoro.docx`.

Core stack:

- Flutter
- Clean Architecture
- Riverpod 2.x
- Material 3
- Isar

## Import and Backup

Settings includes backup and migration tools:

- `Copy JSON` exports a Zoro backup snapshot.
- `Import JSON` restores a Zoro backup snapshot after confirmation. This replaces the current local trusted-system data.
- `Upload Tasks` imports an `.xlsx` spreadsheet into Inbox for mind sweeps or migration from another tool.

The spreadsheet upload expects these columns:

- `serial number`
- `task`
- `category` (optional)

Each imported row is captured in Inbox as one string, for example:

```text
1 - Call bank - Finance
```

Run a local static build on the agreed port:

```powershell
flutter build web
python -m http.server 3200 --bind 127.0.0.1 --directory build\web
```

## Firebase Hosting

Firebase Hosting serves the static Flutter web output from `build\web`.

Build locally:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build_firebase_hosting.ps1
```

The Firebase build disables Flutter's PWA service worker so testers receive the latest deployed app bundle without stale offline cache behavior.

Before the first deploy, store the OpenAI key as a Firebase Functions secret:

```powershell
firebase.cmd functions:secrets:set OPENAI_API_KEY
```

Deploy with Firebase CLI:

```powershell
firebase.cmd deploy --only functions,hosting
```

Build and deploy together:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\deploy_firebase_hosting.ps1
```

The Firebase project alias is configured in `.firebaserc`. `firebase.json` includes an app-route fallback so deep links like `/calendar` and `/processing/<id>` load the Flutter app correctly. It also routes `/assist`, `/clarify`, and `/health` to the Firebase `aiProxy` function so AI keys stay server-side. On Windows, `firebase.cmd` avoids PowerShell script execution policy blocks.

## Mobile Builds

Android and iOS platform projects are included with the app identity `com.satya.zoro` and display name `Zoro`.

Mobile defaults use the deployed Firebase endpoint:

```text
https://zoro-windows.web.app
```

That endpoint serves `/assist` and `/clarify` through Firebase Functions, so mobile users do not need a local proxy or a client-side AI key.

Android debug build:

```powershell
& "C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter build apk --debug
```

Android release build:

```powershell
& "C:\Users\Satya\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe" flutter build appbundle --release
```

For Play Store release, configure a real Android signing key before uploading the `.aab`.

iOS must be built on macOS with Xcode:

```bash
puro flutter build ipa --release
```

In Xcode, open `ios/Runner.xcworkspace`, select your Apple team, confirm the bundle identifier, then archive for TestFlight or App Store. Existing mobile app data is preserved across updates as long as the app keeps the same bundle/application ID and the user does not uninstall or clear app data.
