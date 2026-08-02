# Phase 1 Transactional Notifications

Slice: `APP-P1-010B`

Backend authority: `NOTIF-P1-010A`

## Product boundary

CareNet notifications are durable projections of authoritative backend events.
Firebase Cloud Messaging is push transport only. Resend is transactional email
transport only. Neither provider, nor a Flutter route argument, changes domain
state or grants access to an appointment, conversation, consultation, financial
record, verification record, or account.

The authenticated header bell opens the canonical notification inbox. Account
and inbox settings actions open one notification-preferences page. There is no
Notifications bottom tab and no user-created reminder product in Phase 1.

## Mobile contracts

The client uses these owner-scoped APIs with the stored Bearer session:

- `GET /notifications`
- `GET /notifications/unread-count`
- `GET /notifications/:notificationId`
- `POST /notifications/:notificationId/read`
- `POST /notifications/read-all`
- `GET /notifications/preferences`
- `PATCH /notifications/preferences`
- `POST /notification-installations`
- `DELETE /notification-installations/:installationId`

The inbox has distinct initial loading, empty, error, refresh-with-retained-data,
pagination, read-one, and read-all states. It never falls back to seeded or local
notifications.

## Categories and preferences

The backend category set is:

- Appointments
- Messages
- Consultations
- Payments
- Earnings and payouts
- Account and security
- Professional verification

The durable in-app inbox remains available for transactional events. Per-category
preferences control additional push and email delivery. Backend critical-event
policy remains authoritative where external delivery cannot safely be suppressed.
OS push permission is independent of backend preferences.

## Installation lifecycle

Flutter creates one random installation identifier in encrypted local storage.
The FCM registration token is sent to the backend as endpoint kind
`FCM_REGISTRATION_TOKEN`; it is not persisted separately by Flutter and is never
logged. Registration includes bounded platform, application, version, locale,
and permission metadata. Device timezone is omitted because the platform's short
timezone abbreviation is not a reliable IANA identifier.

Registration occurs after an authenticated session is stored, on token refresh,
and after notification permission changes. Logout attempts authenticated server
invalidation before clearing local account binding. Account changes clear pending
tap state and unread presentation before registering the installation for the new
account. Notification setup failure never invalidates successful authentication.

Firebase client identifiers are provided at build time through:

- `CARENET_FIREBASE_PROJECT_ID`
- `CARENET_FIREBASE_APP_ID`
- `CARENET_FIREBASE_MESSAGING_SENDER_ID`
- `CARENET_FIREBASE_API_KEY`

No Firebase Admin credential, Resend credential, `google-services.json`, or
production provider secret belongs in the mobile repository.

## Permission behavior

Permission is requested contextually inside the inbox, not at first launch. A
denied user can open system settings, while the in-app inbox remains functional.
The app resynchronizes permission and installation metadata on resume.

## Push handling and routing

Foreground messages refresh unread authority and display a privacy-safe local
notification. Background and terminated notifications use FCM transport. A tap
stores only the opaque notification ID until the navigator and authenticated
session are available.

Before navigation Flutter fetches `GET /notifications/:notificationId`. The
backend therefore verifies current ownership. Flutter then marks the inbox item
read and resolves only these allowlisted route codes:

| Route code | Destination |
|---|---|
| `APPOINTMENT_DETAIL` | Canonical Appointment Detail by opaque appointment ID |
| `CONSULTATION` | Canonical Appointment Detail, which reloads consultation authority |
| `CONVERSATION` | Appointment conversation by opaque conversation ID |
| `PROFESSIONAL_VERIFICATION` | Professional verification documents |
| `PROFESSIONAL_FINANCE` | Professional finance |
| `ACCOUNT_SECURITY` | Account |

Missing entities, owner mismatch, stale notifications, and unknown route codes
fail closed to the authenticated inbox. Destination screens fetch current backend
state. Push title/body/data never becomes current domain state.

## Privacy

Visible and data payloads contain generic transactional copy plus opaque routing
identifiers only. They do not contain message bodies, symptoms, diagnoses,
appointment reasons, payment references, bank details, provider room data,
authentication tokens, email addresses, phone numbers, or clinical evidence.

## Native and dependency boundary

FlutterFire provides `firebase_core` and `firebase_messaging`.
`flutter_local_notifications` renders privacy-safe foreground alerts.
`package_info_plus` supplies bounded application metadata. Android declares
`POST_NOTIFICATIONS` and enables the package-required Java 17 core-library
desugaring. The existing `permission_handler` package opens system settings.

Resolved package versions are `firebase_core 4.12.1`,
`firebase_messaging 16.4.3`, `flutter_local_notifications 20.1.0`, and
`package_info_plus 9.0.1`. Their bundled licences were inspected and are
permissive BSD-style licences. No donor source was copied into CareNet.

## Verification boundary

Automated coverage proves API ownership headers and parsing, installation
metadata, secure persistent installation identity, account switching, logout,
permission UX, inbox states, read/read-all, preference rollback, cold-start tap
retention, route allowlisting, auth lifecycle isolation, and the header unread
badge. Full analyze, Flutter tests, Android debug build, CI, staging migration,
provider delivery, and physical-device evidence remain release gates until their
results are recorded.

## Explicit exclusions

- Marketing campaigns, newsletters, SMS, and WhatsApp
- User-created or generic reminders
- Notification-based domain mutations
- Raw message or clinical content in provider payloads
- Firebase Auth, Firestore, Analytics, or Cloud Functions as workflow authority
- iOS APNs production certification without Apple signing/provider authority
- Tax, reviews, and later product milestones
