# CareNet Mobile

CareNet is a Flutter healthcare marketplace application. Its active Phase 1
journey connects patients with verified professionals for appointment booking,
appointment management, messaging, paid consultations, and video or audio
consultations. Professionals manage their public profile, verification
documents, recurring availability, appointment requests, consultation pricing,
and payout information through backend-owned contracts.

## Current Product Boundary

The authenticated application uses role-aware navigation:

- Patients: Home, Find Care, Appointments, Messages.
- Professionals: Home, Schedule, Appointments, Messages.
- Both roles retain Notifications and Account actions in the header.

The active marketplace surfaces use CareNet backend APIs for authentication and
session restoration, onboarding readiness, professional discovery and detail,
requestable appointment times, appointment lifecycle, messaging, transactional
notifications, consultation access, and financial state. The backend remains
authoritative for roles, ownership, eligibility, appointment status, payment
status, consultation access, and verification.

Legacy health-reading, community, creator-content, emergency, and local booking
sources remain recoverable where documented, but they are not active Phase 1
product authority. Deferred routes fail closed or resolve to an approved
compatibility destination; they must not be treated as completed backend
features.

## Readiness Status

Implemented source is not the same as production readiness. The repository has
automated Flutter analysis, tests, Android builds, release-configuration gates,
and staging integration evidence. Production infrastructure ownership, store
governance, final provider operations, physical-device acceptance, and the
separately approved Paystack activation gate remain tracked readiness work.

Android is the first distributable platform. iOS source and environment
configuration are maintained, but final signing and provider acceptance require
Apple credentials, macOS/Xcode, and an iPhone.

See [Codebase status](docs/CODEBASE_STATUS.md) and
[Deferred work](docs/DEFERRED_WORK.md) before making a release-readiness claim.

## Architecture

```text
lib/
  core/       app-wide routing, networking, session, configuration, and tokens
  features/   feature-owned presentation, state, data, and domain code
  shared/     reusable widgets
  app.dart    MaterialApp ownership
  main.dart   single application entry point
```

Named routes and role-aware shells own navigation. Feature repositories and API
clients isolate backend contracts from widgets. Secure session state and
persisted booking/payment intents are account-bound and must never be used to
invent backend authority.

Read [Architecture rules](docs/ARCHITECTURE_RULES.md) before changing code.

## Development

Prerequisites:

- Flutter stable with a Dart SDK compatible with `pubspec.yaml`.
- Android Studio and the Android SDK for Android builds.
- macOS and Xcode for iOS builds.

Common local checks:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

Environment-specific staging or release builds require the documented protected
configuration and signing inputs. Never replace missing provider configuration
with fixture values in a distributable artifact.

## Project Documentation

Engineering references include:

- [Architecture rules](docs/ARCHITECTURE_RULES.md)
- [Route declarations and disposition history](docs/ROUTES.md)
- [User-flow map](docs/FLOW_MAP.md)
- [Product and technical decisions](docs/DECISIONS.md)
- [Codebase status](docs/CODEBASE_STATUS.md)
- [Deferred work](docs/DEFERRED_WORK.md)
- [Android release configuration](docs/ANDROID_RELEASE_CONFIGURATION.md)
- [Android release signing](docs/ANDROID_RELEASE_SIGNING.md)
- [Firebase environments](docs/FIREBASE_ENVIRONMENTS.md)

## Contribution Workflow

1. Create a focused branch from the current integration branch.
2. Preserve unrelated worktrees and archive references.
3. Implement one documented slice with focused regression coverage.
4. Run targeted checks and the complete required verification suite.
5. Reconcile test-count and documentation changes.
6. Open a pull request against `feature/frontend-milestone` and merge only after
   the exact reviewed head and merged result pass CI.

Do not commit API secrets, signing keys, provider credentials, generated build
output, private proof artifacts, or local project archives.
