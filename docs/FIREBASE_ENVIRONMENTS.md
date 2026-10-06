# Firebase environments

CareNet uses Firebase/GCP project `project-a96784ee-811c-46ab-a7b` as the canonical project. Configuration files supplied from `carenet-175b7` are invalid for this application and must not be installed.

## Registered applications

| Environment | Platform | Application identifier | Firebase app ID |
| --- | --- | --- | --- |
| Staging | Android | `com.carenet.app.staging` | `1:599365440227:android:fb589a833cd2e8b251abd6` |
| Production | Android | `com.carenet.app` | `1:599365440227:android:7fbb7d5e3784327751abd6` |
| Staging | iOS | `com.carenet.app.staging` | `1:599365440227:ios:6680baeffacc0ce051abd6` |
| Production | iOS | `com.carenet.app` | `1:599365440227:ios:fac1f0bd4f73677051abd6` |

The staging Android app has the current debug SHA-1 and SHA-256 certificates. Upload and Play App Signing certificates remain release-signing gates and must be registered before production distribution.

## Android builds

Use `--flavor staging` for staging and `--flavor production` for production. The package IDs and launcher labels differ, so both apps can coexist on one device.

Runtime values remain explicit `--dart-define` inputs:

- `CARENET_ENVIRONMENT`
- `CARENET_API_BASE_URL`
- `CARENET_FIREBASE_PROJECT_ID`
- `CARENET_FIREBASE_APP_ID`
- `CARENET_FIREBASE_MESSAGING_SENDER_ID`
- `CARENET_FIREBASE_API_KEY`
- `GOOGLE_SIGN_IN_SERVER_CLIENT_ID`

The application validates its selected flavor and core runtime values before
Firebase initialization, including in debug builds. The environment, API URL,
canonical project ID, and flavor-specific Firebase app ID must be supplied at
launch/build time; a missing or mismatched value shows a safe configuration
error instead of starting against an ambiguous backend. Production also
requires HTTPS and rejects staging/local API hosts. Staging requires a
`staging` marker in the API hostname; this is a fail-closed guard, not a
replacement for reconciling and allowlisting the canonical live staging host.
The Google server client ID is optional for local debug startup but required
by the Android release configuration gate.

Keep local runtime configuration files outside Git and pass them with
`--dart-define-from-file`. Debug APK compilation can succeed without those
values, but the resulting app will intentionally stop at the configuration
error screen until launched with matching runtime defines.

## iOS boundary

Both bundle IDs are registered in the canonical Firebase project. Xcode schemes, Apple signing, APNs keys, Apple Sign In capability, and physical-device proof require Apple Developer access and a Mac; iOS is not release-ready until those gates pass.
