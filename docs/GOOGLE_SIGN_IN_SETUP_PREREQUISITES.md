# Google sign-in setup prerequisites

Owner task: `52.20`

Status: Accepted prerequisites; staging backend readiness enabled in task
`52.21`; Flutter sign-in provider wiring completed in task `52.22`

Purpose: collect the exact Google OAuth prerequisites for `com.carenet.app`
before enabling Google sign-in UI.

This setup record distinguishes provider readiness from production readiness.

## Current staging status

Developer-private staging is reachable through the local Cloud Run Proxy, but
readiness still reports Google disabled:

```json
{
  "providers": {
    "email": "ok",
    "googleAuth": "disabled",
    "verificationStorage": "disabled"
  }
}
```

Secret Manager currently contains:

```text
database-url
jwt-access-secret
jwt-refresh-secret
public-app-base-url
resend-api-key
```

Task `52.21` added the first Google OAuth client ID to backend staging as
`GOOGLE_OAUTH_CLIENT_ID` through Secret Manager and redeployed Cloud Run.
Task `52.22` then corrected the staging backend and Flutter app to use the Web
OAuth client ID required by `google_sign_in` server-client ID configuration.
Readiness reports `googleAuth: ok`.

Latest verified readiness excerpt:

```json
{
  "providers": {
    "email": "ok",
    "googleAuth": "ok",
    "verificationStorage": "disabled"
  }
}
```

## App identifiers

| Platform | Value |
| --- | --- |
| Android package name | `com.carenet.app` |
| iOS bundle ID | `com.carenet.app` |

## Android debug fingerprint

Debug keystore:

```text
C:\Users\asd\.android\debug.keystore
```

Debug certificate fingerprints:

```text
SHA-1:   79:DC:39:4B:88:BF:0B:C5:3F:C9:A1:DC:08:1F:F7:09:E4:6D:95:53
SHA-256: 5A:04:92:52:01:0F:84:C8:5C:0D:31:6C:D2:63:7B:58:5D:6B:D8:85:AE:04:1F:67:29:7D:22:CA:0F:D9:22:5F
```

This is suitable only for local/debug OAuth setup.

## Release fingerprint status

An existing release keystore file is present:

```text
C:\Users\asd\.android\release-key.jks
```

Its alias listing shows:

```text
puredetoxkey
```

The release SHA fingerprints were not collected because reading them requires
the keystore password. Do not guess or record the password in docs, PR bodies,
or chat logs. Collect release fingerprints only through an intentional release
signing slice.

## OAuth clients needed

Minimum staging/client setup:

1. Android OAuth client for package `com.carenet.app` with the debug SHA-1
   above.
2. iOS OAuth client for bundle ID `com.carenet.app`.
3. A backend-accepted Web OAuth client ID configured as
   `GOOGLE_OAUTH_CLIENT_ID` in staging. Updated in task `52.22`.
4. Flutter frontend provider config that can obtain a Google ID token for the
   same accepted audience.

Backend verification currently checks the ID token `aud` against a single
`GOOGLE_OAUTH_CLIENT_ID` value. If Android and iOS use different OAuth client
IDs, the backend must either support an approved audience list or the next
implementation must deliberately choose which platform/client is enabled first.

## CLI limitation found

Google Cloud CLI is installed and authenticated for project:

```text
carenet-staging-20260712
```

But the installed CLI does not provide an already-installed non-interactive
command path for creating ordinary Android/iOS OAuth clients. The `alpha`
component is not installed and could not be installed non-interactively from
this shell.

Do not treat this as a code blocker. Treat it as an external provider setup
blocker: create the OAuth clients through Google Cloud Console / Google Auth
Platform, or provide a supported API/script path in a future setup slice.

## Flutter package decision

Use the maintained `google_sign_in` Flutter plugin for Google ID-token
acquisition. Task `52.22` added the package and introduced
`GOOGLE_SIGN_IN_SERVER_CLIENT_ID` as the Flutter compile-time config key.

Reason:

- `google_sign_in` v7 initializes with `serverClientId` for backend-verifiable
  ID tokens
- the value is a client ID, not a client secret, but should still stay
  environment-specific rather than hardcoded into app source
- if `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is missing, the Flutter sign-in Google
  rows stay disabled instead of faking success

## Next slice

Completed follow-ups:

`52.21 - Add Google OAuth Client IDs To Staging`

Result:

- initial Google OAuth client ID was provided out-of-band and stored in Secret
  Manager as `google-oauth-client-id`
- `/health/ready` through Cloud Run Proxy reports `googleAuth: ok`

`52.22 - Wire Flutter Google Sign-In Provider`

Result:

- Web OAuth client ID was provided out-of-band through the downloaded client
  config file; the client secret was not committed or recorded
- Secret Manager version 3 now carries the Web OAuth client ID
- Cloud Run revision `carenet-backend-staging-00008-5m9` serves 100 percent of
  traffic
- Flutter sign-in phone/email Google rows call `AuthRepository.googleSignIn`
  after obtaining a real Google ID token when
  `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is configured

Next queue:

`52.23 - Define Profile And Public Professional Wiring Contract`

## Non-claims

This setup does not claim:

- production Google sign-in works
- Google sign-up role selection is defined
- Google account link/unlink UI is wired
- iOS Google sign-in is proven
- release signing is ready
- production OAuth consent/app verification is complete

## APP-READY-070 iOS configuration audit (2026-10-17)

The canonical Firebase project `project-a96784ee-811c-46ab-a7b` resolves to
project number `599365440227`. Console evidence supplied on 2026-10-17
classifies
`599365440227-2q9l9capubk9bhmqslhsfliuve5u3ne6.apps.googleusercontent.com` as
Web application,
`599365440227-nu3bf67posvqpcd6uc38bubqu9rl28q4.apps.googleusercontent.com` as
Android, and the following ID as iOS:
`599365440227-dct2dkdh0tj79an085ocmghpgv6dic82.apps.googleusercontent.com` and
its exact reverse URL scheme is
`com.googleusercontent.apps.599365440227-dct2dkdh0tj79an085ocmghpgv6dic82`.
The copied details omit the Android package/SHA and iOS bundle ID; only one iOS
client is shown, so the evidence does not establish coverage for both
`com.carenet.app.staging` and `com.carenet.app`. The repository Android
identifiers are `com.carenet.app.staging` and `com.carenet.app`; its recorded
local debug SHA-1 is
`79:DC:39:4B:88:BF:0B:C5:3F:C9:A1:DC:08:1F:F7:09:E4:6D:95:53`. These do not
prove the console Android client's configured package/fingerprint.

The registered iOS apps are `com.carenet.app.staging` and `com.carenet.app`.
The shared `ios/Runner/Info.plist` currently has no `GIDClientID` or
`CFBundleURLTypes`, and no GoogleService-Info.plist is checked in. Flutter
passes the separately configured Web server client ID through
`GoogleSignIn.initialize(serverClientId: ...)`; this does not provide the iOS
app client ID or callback URL scheme. The smallest source repair, after client
metadata is verified, is environment-specific iOS client IDs for the two
bundle IDs plus each client's exact reversed-client-ID URL scheme. Retain the
Web client as the backend ID-token audience/server client.

On 2026-10-17, the authenticated gcloud principal could describe the canonical
Firebase project. `gcloud iam oauth-clients list` returned no workforce OAuth
client resources and is not evidence about standard Google Auth Platform
credentials. Firebase Management API reads for both registered iOS SDK configs
returned 403 for the current principal. No OAuth/Firebase setting, secret, or
app config file was changed. Confirm the iOS client's bundle association and
create/locate a matching iOS client for the other bundle before implementing
flavor-specific callback config.
