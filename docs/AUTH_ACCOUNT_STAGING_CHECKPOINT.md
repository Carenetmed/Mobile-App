# Auth account staging checkpoint

Owner task: `52.18`

Status: Accepted checkpoint

Purpose: verify the Flutter auth/account integration base against the current
backend staging bridge before wiring profile, verification, availability, or
appointment screens.

This is not a production-readiness claim and not a public/stakeholder staging
claim.

## Backend proxy evidence

Cloud Run Proxy was started locally against the documented private staging
Cloud Run host.

The backend docs show this intended shape:

```powershell
cloud-run-proxy carenet-backend-staging --project carenet-staging-20260712 --region asia-south1 --port 8080
```

The installed proxy binary on this Windows machine uses `-host`/`-bind`
arguments instead. The working local command shape is:

```powershell
$token = (& "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd" auth print-identity-token).Trim()
& "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\cloud-run-proxy.exe" -host "carenet-backend-staging-ys6pb6ix5q-el.a.run.app" -bind "127.0.0.1:8080" -token $token
```

Do not commit the token. It is a local runtime secret.

## Staging checks observed

Local proxy URL:

```text
http://127.0.0.1:8080
```

Observed `GET /health` result:

```json
{
  "status": "ok",
  "service": "carenet-backend"
}
```

Observed `GET /health/ready` result:

```json
{
  "status": "ok",
  "service": "carenet-backend",
  "checks": {
    "database": "ok",
    "migrations": "ok",
    "providers": {
      "email": "ok",
      "googleAuth": "disabled",
      "verificationStorage": "disabled"
    }
  }
}
```

Interpretation:

- staging backend is reachable through the developer-private proxy
- database and migrations are ready
- email provider is enabled
- Google auth provider is disabled at readiness level
- verification storage is disabled at readiness level

## Flutter config status

The app already has the correct compile-time config key:

```text
CARENET_API_BASE_URL
```

For local web or desktop-style developer smoke:

```powershell
flutter run --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080
```

For Android emulator proxy testing:

```powershell
flutter run --dart-define=CARENET_API_BASE_URL=http://10.0.2.2:8080
```

Do not commit private Cloud Run URLs, Google identity tokens, CareNet app
tokens, refresh tokens, passwords, or provider secrets to source files.

## Auth/account wiring status

Already wired in Flutter:

- email registration through `AuthRepository.register`
- email login through `AuthRepository.login`
- session restore through `AuthRepository.restore`
- logout through `AuthRepository.logout`
- current-account read through `AccountRepository.currentAccount`
- password reset request through `AuthRepository.requestPasswordReset`
- password reset token confirmation through `AuthRepository.confirmPasswordReset`
- email verification request through `AccountRepository.requestEmailVerification`
- email verification token confirmation through
  `AccountRepository.confirmEmailVerification`

Still not completed:

- production Android App Links or iOS Universal Links for reset/verification
- a checked-in live Flutter staging smoke test harness
- real-device/public staging access
- Google sign-in UI and provider-token acquisition
- phone/OTP
- MFA/PIN backend enablement
- destructive account APIs

## Google decision

Do not wire Google sign-in/link UI as the next runtime slice.

Reason:

- backend readiness currently reports `googleAuth: disabled`
- Flutter has backend client/repository methods for Google token handoff, but
  no scoped frontend Google ID-token acquisition package/config is active in
  this slice
- social buttons should remain explicitly disabled until a Google frontend
  provider slice decides package, platform config, client IDs, error states,
  and staging provider readiness

## Verification upload decision

Do not wire professional verification upload as the immediate next runtime
slice.

Reason:

- backend readiness currently reports `verificationStorage: disabled`
- upload-init/upload-complete route contracts exist, but mobile file-picking,
  storage-provider readiness, upload failure states, and document UX need a
  separate contract before runtime wiring

Professional/profile read/write and public professional listing are safer first
profile-domain targets than document upload.

## Next frontend lane

Queue:

`52.19 - Define profile and public professional wiring contract`

Goal:

- define how Flutter should consume patient self profile, professional self
  profile, and public verified professional listing
- decide which existing local screens move first behind repository boundaries
- keep verification document upload, admin dashboard, availability, appointment
  lifecycle, payments, notifications, reviews, calls, calendar sync, medical
  notes, and prescriptions out of scope

## Non-claims

This checkpoint does not claim:

- live Flutter UI auth smoke was manually completed end-to-end
- Google sign-in/link is ready
- professional verification upload is ready
- public/stakeholder staging access is ready
- production app links are ready
- production deployment or release readiness
