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

## Provisioning Evidence

Separate staging and production RSA-4096 upload keys were created outside Git
on 2026-09-30. Windows directory ACLs restrict local access to the operator and
SYSTEM; local password records use user-scoped DPAPI encryption. Both actual
certificates passed `validateReleaseSigning`. Secret Manager backups use
`android-{environment}-upload-keystore` and
`android-{environment}-upload-credentials` in the canonical project and region.
Credential readback and byte-for-byte keystore restoration checks passed.
Do not copy DPAPI records to another machine and assume they can be decrypted;
approved recovery uses the protected cloud backups.

| Environment | Approved Upload Certificate SHA-256 |
| --- | --- |
| Staging | `0D7E7F2FB1A0DA0B3D392B0EB542411DDC8590F6EA9E61FBEC9F3D736924C152` |
| Production | `2CD856CEE08CC78DFFB48EEB96C656A3E32D155720717595282F05D99E96A113` |

Their SHA-1 and SHA-256 fingerprints were registered with the matching
canonical Firebase Android apps. Backend runtime project-wide Secret Manager
access was replaced with grants on its 14 existing application secrets before
signing backups were stored. No runtime access to signing secrets was granted.
Staging readiness and a subsequent scheduled notification worker passed.

This configuration and provisioning are not release acceptance. Before
distribution, verify the final APK/AAB certificate, register Play signing
certificates and prove Google identity and upgrade behavior on signed builds.
Play App Signing's distribution certificate differs from the upload certificate.
Do not replace an existing distribution identity without an approved migration.
Never attach signing material to a PR or ordinary build artifact.

Staging and production remain explicit flavors; signing does not validate
runtime provider configuration or authorize production promotion. Physical
acceptance and iOS signing remain separate gates.
