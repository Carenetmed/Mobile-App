# Android Release Configuration Gate

Staging and production APK/AAB packaging require both protected signing and
runtime configuration. The flavor-specific `validate*ReleaseEnvironment`
tasks validate Flutter's base64-encoded `dart-defines` before release packaging,
including direct APK and bundle package-task invocation.
Debug builds and release lint need neither provider values nor signing secrets.

Required values are `CARENET_ENVIRONMENT`, `CARENET_API_BASE_URL`,
`CARENET_FIREBASE_PROJECT_ID`, `CARENET_FIREBASE_APP_ID`,
`CARENET_FIREBASE_MESSAGING_SENDER_ID`, `CARENET_FIREBASE_API_KEY`, and
`GOOGLE_SIGN_IN_SERVER_CLIENT_ID`. Values must be present, trimmed, and
unambiguous. Invalid encoding and duplicate definitions fail closed without
printing their values.

The environment must match the Android flavor. Firebase uses the canonical
project, sender number, and registered Android app ID for that flavor.
Provider key/client formats are checked. API URLs require HTTPS and cannot
contain credentials, query parameters, or fragments. Production rejects the
staging gateway and staging/local hostnames; staging values are not promoted
implicitly. Keep the configuration file outside Git and supply it using
`--dart-define-from-file`.

`tool/check_android_release_environment.ps1` exercises positive and negative
configuration fixtures, release task graphs, and debug/lint independence in
CI. Its `.invalid` endpoints and fake provider values never build a distributable
artifact, contact providers, or prove provider ownership.

This is a necessary build gate, not release acceptance. Correctly formatted
values do not prove OAuth client ownership, Firebase API-key association,
provider delivery, production backend identity, or device behavior. Canonical
Google identity, protected certificate/Play proof, immutable backend promotion,
production environment acceptance, and physical testing remain separate gates.
