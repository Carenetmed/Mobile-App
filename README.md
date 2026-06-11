# Carenet

Carenet is a cross-platform Flutter application for healthcare discovery,
appointments, health readings, professional profiles, communities, content,
messaging, reminders, and account management.

## Current Status

The repository currently contains the frontend-ready application surface:

- Shared Flutter code for Android and iOS.
- Named-route navigation and documented user flows.
- Reusable design tokens, buttons, and text fields.
- Local validation and honest local state for frontend-only workflows.
- Disabled or documented controls where real backend contracts are required.
- Widget and flow tests for key user journeys.

The Android debug build is verified during milestone checks. iOS remains a
supported Flutter target but must be built and tested on macOS with Xcode.

Real authentication, account persistence, server-backed health records,
appointments, messaging, notifications, payments, media, and other remote
features are not represented as completed backend behavior.

## Architecture

```text
lib/
  core/       app-wide routing, services, tokens, models, and configuration
  features/   feature-owned presentation, state, data, and domain code
  shared/     reusable widgets
  app.dart    MaterialApp ownership
  main.dart   single application entry point
```

The current implementation uses named routes and feature-local state. Backend
integration should replace local stores through repository boundaries without
rewriting completed screens or route flows.

## Development

Prerequisites:

- Flutter stable with a Dart SDK compatible with `pubspec.yaml`
- Android Studio/Android SDK for Android builds
- macOS and Xcode for iOS builds

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Project Documentation

The durable engineering references are:

- [Architecture rules](docs/ARCHITECTURE_RULES.md)
- [Route inventory](docs/ROUTES.md)
- [User-flow map](docs/FLOW_MAP.md)
- [Product and technical decisions](docs/DECISIONS.md)
- [Deferred backend and product work](docs/DEFERRED_WORK.md)
- [Definition of done](docs/DEFINITION_OF_DONE.md)

## Contribution Workflow

1. Create a focused feature or milestone branch.
2. Complete one documented task at a time.
3. Run relevant tests, analysis, and build checks.
4. Update the companion documentation.
5. Open a pull request into `main` for review.

Do not commit API secrets, signing keys, provider credentials, generated build
output, or local project archives.
