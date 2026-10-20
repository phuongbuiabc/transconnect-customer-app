# VIEGO Customer

Independent Flutter customer application for TransConnect. Android/iOS scaffolds and web preview are included. No sibling source dependency, Git repository initialization, or remote is required.

## Features

Customer registration/login; optional phone; email verification/resend; password recovery/reset; secure persisted sessions; serialized rotating refresh; current identity; logout with server revocation and local cleanup. Vietnamese light UI follows VIEGO crimson/gold grouped surfaces and floating navigation. Home introduces three planned transport services. Orders explicitly states booking is unavailable.

The backend has no customer trip search, booking, payments or order APIs. Google UI needs platform OAuth configuration and remains deferred. Updated 20/10: Account → edit name/phone, change current password and select an avatar using image_picker 1.2.2; upload goes through the authenticated backend to Cloudinary. Changing password clears the local session after BE revokes refresh tokens; a wrong current password displays a field error and retains the session.

The backend needs Cloudinary local credentials; no cloud secret is embedded in the app. PNG/JPEG/WebP up to 5 MiB are accepted by the server. iOS includes the gallery usage description; native gallery/device behavior needs live acceptance. Reference: [image_picker](https://pub.dev/packages/image_picker/versions/1.2.2). Test steps/results are in [current test](../../TransConnect-Backend/docs/current-test.md) and [tracker](../../TransConnect-Docs/00-project/progress-tracker.md#closure-implementation-20-10).

## Run

Flutter 3.35.2 / Dart 3.9 or compatible newer SDK:

    flutter pub get
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5267

Android emulator reaches the host through 10.0.2.2. For web/iOS simulator use localhost where appropriate. Physical devices require a reachable LAN host/backend binding. Confirm backend port in launchSettings.json.

    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5267
    flutter analyze
    flutter test
    flutter build web --dart-define=API_BASE_URL=https://your-api.example

No secrets belong in dart-define. Use HTTPS in production. Android HTTP is enabled only in debug/profile manifests; iOS local HTTP requires debug ATS configuration or trusted HTTPS. Web secure storage requires HTTPS or localhost; allow the preview origin in backend CORS. App bundle identifiers are starter com.transconnect values; configure owned IDs/signing before distribution. Native iOS builds require macOS/Xcode. Android release signing is the generated debug placeholder and must be replaced before publishing. Generated launcher assets are placeholders.

## Layout

See [ARCHITECTURE.md](ARCHITECTURE.md) for the current feature structure and coding rules, and [AGENTS.md](AGENTS.md) for contributor instructions.

- `app`: bootstrap, navigation and controller composition.
- `core`: transport, typed decoding, session lifecycle and secure storage.
- `features`: typed models, repositories, controllers and presentation.
- `shared`: theme, reusable widgets and validation.
- `scripts/Check.ps1`: format check, analyze and tests; optional `-NoRestore`.

Local API defaults: Android native/emulator `http://10.0.2.2:5267`; web/desktop/iOS simulator `http://localhost:5267`. Override with `--dart-define=API_BASE_URL=...` for a real device or deployment. Both apps use the same backend; their account groups and storage keys remain separate.

## Validation

Foundation verification (18/10/2026): static analysis and 17 tests passed using a writable copy of the installed SDK. Native builds and live backend/email E2E were not performed.

Run all checks: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Check.ps1`.
