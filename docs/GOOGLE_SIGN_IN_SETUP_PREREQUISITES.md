# Google sign-in setup prerequisites

Owner task: `52.20`

Status: Accepted prerequisites

Purpose: collect the exact Google OAuth prerequisites for `com.carenet.app`
before enabling Google sign-in UI.

This slice does not wire the Google button and does not claim backend Google
readiness.

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

There is no `GOOGLE_OAUTH_CLIENT_ID` secret/config currently present in the
staging project evidence.

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
3. A backend-accepted Google OAuth client ID configured as
   `GOOGLE_OAUTH_CLIENT_ID` in staging.
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
acquisition, but do not add it until OAuth client IDs/config are available.

Reason:

- adding the package without client IDs would not make the button work
- tests would have to mock success without provider proof
- backend readiness would still report `googleAuth: disabled`

## Next slice

Queue:

`52.21 - Add Google OAuth Client IDs To Staging`

Goal:

- create or collect OAuth client IDs for `com.carenet.app`
- configure backend staging `GOOGLE_OAUTH_CLIENT_ID` without committing secrets
- verify `/health/ready` reports `googleAuth: ok`
- only then add Flutter Google provider package/config and wire UI in a later
  runtime slice

## Non-claims

This slice does not claim:

- Google OAuth clients exist
- backend Google readiness is enabled
- Google sign-in UI works
- release signing is ready
- production OAuth consent/app verification is complete
