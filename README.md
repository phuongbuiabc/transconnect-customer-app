# VIEGO Customer

Independent Flutter customer application for TransConnect. Android/iOS scaffolds and web preview are included. No sibling source dependency, Git repository initialization, or remote is required.

## Features

Customer registration/login; optional phone; email verification/resend; password recovery/reset; secure persisted sessions; serialized rotating refresh; current identity; logout with server revocation and local cleanup. Vietnamese light UI follows VIEGO crimson/gold grouped surfaces and floating navigation. Home introduces three planned transport services. Orders explicitly states booking is unavailable.

The current backend has no customer trip search, booking, payments or order APIs. This release implements roadmap M5 identity foundation. Google login needs platform OAuth configuration and is deferred. Profile editing and avatar upload are not exposed by current customer APIs.

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

- lib/main.dart: entry point; app/bootstrap.dart owns the app-wide session controller.
- lib/app/: MaterialApp, theme, session controller, verification UI, gate and tab navigation.
- lib/core/: configuration, HTTP transport, errors and secure-storage abstractions.
- lib/features/: auth forms, home, orders and account screens.
- lib/shared/: reusable visual components and form validators.
- test/: HTTP/session regression and small-phone widget checks.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full directory tree, screen locations, dependency boundaries, session safety, sharing strategy and instructions for adding features. Each app remains independently buildable; there are no sibling source imports or new state-management dependencies.

## Validation

Analysis/tests/web build results are recorded in the workspace report .reports/transconnect-frontend/plans/customer-app/00-index.md. Native APK/iOS builds and live backend/email end-to-end flow remain unverified. Secure-storage web dependency currently supports standard JavaScript web builds; Wasm is not a validated target.
