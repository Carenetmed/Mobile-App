# Protected Android Release Signing

Release APK/AAB packaging must use a protected upload key, never the Android
debug key. Keep the keystore and passwords outside every repository checkout.
Supply these process environment values through protected operator storage or
an approved CI secret environment:

- `CARENET_UPLOAD_KEYSTORE_PATH`: external absolute keystore path.
- `CARENET_UPLOAD_STORE_PASSWORD`: keystore password.
- `CARENET_UPLOAD_KEY_ALIAS`: private-key alias.
- `CARENET_UPLOAD_KEY_PASSWORD`: signing-key password.
- `CARENET_UPLOAD_CERT_SHA256`: approved public certificate fingerprint.

`validateReleaseSigning` fails closed for missing configuration, a repository
keystore, a non-key alias, a debug certificate, or a fingerprint mismatch.
Release packaging depends on this task. Debug builds and release lint require
no signing credentials. No password or private key is printed or committed.

CI runs `tool/check_android_release_signing.ps1` with disposable random-password
keys. It checks absent credentials, an approved non-debug certificate,
fingerprint mismatch, repository paths, debug certificate rejection, all four
flavor APK/AAB task graphs, and credential-free release lint. These fixtures
must never be used for installation or distribution.

This source configuration is not release acceptance. Before distribution,
generate and back up the protected upload key, verify the final APK/AAB
certificate, register the required upload/Play signing certificates with the
correct Firebase/OAuth applications, and prove sign-in and upgrade behavior.
Play App Signing's distribution certificate differs from the upload certificate.
Do not replace an existing distribution identity without an approved migration.
Never attach signing material to a PR or ordinary build artifact.

Staging and production remain explicit flavors; signing does not validate
runtime provider configuration or authorize production promotion. Physical
acceptance and iOS signing remain separate gates.
