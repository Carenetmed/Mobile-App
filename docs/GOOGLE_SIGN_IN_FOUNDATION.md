# Google sign-in foundation

Owner task: `52.19`

Status: Accepted foundation

Purpose: replace placeholder mobile app identifiers before creating or wiring
Google OAuth credentials.

This slice does not wire Google sign-in UI and does not enable backend Google
auth by itself.

## Decision

Use `com.carenet.app` as the staging/production mobile app identifier baseline
for Google sign-in setup.

| Platform | Identifier |
| --- | --- |
| Android namespace | `com.carenet.app` |
| Android application ID | `com.carenet.app` |
| iOS bundle ID | `com.carenet.app` |
| iOS test bundle ID | `com.carenet.app.RunnerTests` |

## Why this comes before Google wiring

Google OAuth credentials should not be created against placeholder identifiers:

- old Android application ID: `com.example.app_t`
- old iOS bundle ID: `com.example.appt`

Using placeholder IDs would create avoidable rework and could leave stale OAuth
clients or package fingerprints in the project.

## Still required before Google UI can be enabled

Future Google setup still needs:

- Google OAuth client creation for the real Android package ID
- Android signing certificate SHA fingerprints for the intended build variants
- Google OAuth client creation for the real iOS bundle ID
- frontend Google ID-token acquisition package/config decision
- backend `GOOGLE_OAUTH_CLIENT_ID` staging configuration
- readiness check showing `googleAuth: ok`
- focused frontend tests for enabled/disabled Google states

## Non-claims

This slice does not claim:

- Google sign-in works
- backend Google auth is enabled
- `google-services.json` or `GoogleService-Info.plist` exists
- production OAuth setup is complete
- app store / play store release readiness
