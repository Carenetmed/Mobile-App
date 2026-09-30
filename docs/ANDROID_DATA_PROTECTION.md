# Android Local Data Backup Policy

CareNet does not transfer local session, booking-intent, notification, or
application data through Android cloud backup or Android device-to-device
transfer. Users authenticate on the destination device and reload authorized
account data from the backend.

The main application manifest sets `allowBackup` and `fullBackupContent` to
`false` for older Android versions. On Android 12 and newer,
`@xml/carenet_data_extraction_rules` explicitly excludes every supported
credential-protected, device-protected, and app-external storage domain from
both cloud backup and device transfer. Cache and no-backup directories are
already excluded by Android.

CI parses the manifest and resource using `tool/check_android_backup_policy.ps1`
and checks 25 negative regression cases. Android build and release lint also
validate the packaged resource. No lint suppression is used.

This policy does not replace secure session persistence, backend session
revocation, or logout/account-switch cleanup. Physical backup/restore and
device-transfer acceptance remain part of the final device session. Cross-platform
migration and iOS backup policy are not enabled or certified by this slice.
