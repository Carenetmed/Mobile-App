# Password Reset And Email Verification Contract

**Task:** 52.15
**Status:** Contract defined before runtime wiring.
**Date:** 2026-07-14

This document defines the Flutter-side boundary for password reset confirmation
and email verification confirmation. It is a contract slice only: no runtime
route, repository, or screen behavior is implemented here.

---

## Source Of Truth

Backend sources checked for this contract:

- `C:\Users\asd\Music\carenet-backend-lab\docs\25-auth-frontend-integration-contract.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\48-auth-session-frontend-bridge-package.md`
- `C:\Users\asd\Music\carenet-backend-lab\src\auth\auth.controller.ts`
- `C:\Users\asd\Music\carenet-backend-lab\src\auth\dto\email-verification-confirm.dto.ts`
- `C:\Users\asd\Music\carenet-backend-lab\src\auth\dto\password-reset-confirm.dto.ts`
- `C:\Users\asd\Music\carenet-backend-lab\src\auth\dto\password-reset-request.dto.ts`

The backend contract is explicit enough for Flutter wiring of token-confirm
requests. Deep-link platform registration is not yet production-ready and must
remain a separate setup task.

---

## Backend Route Contract

| Frontend need | Backend route | Auth | Request | Success |
|---------------|---------------|------|---------|---------|
| Request password reset | `POST /auth/password-reset/request` | Public | `{ "email": "patient@example.com" }` | `{ "success": true }` |
| Confirm password reset | `POST /auth/password-reset/confirm` | Public | `{ "token": "opaque-reset-token", "newPassword": "a new long passphrase" }` | `{ "success": true }` |
| Request email verification | `POST /auth/email-verification/request` | Bearer access token | Empty JSON body or no meaningful fields | `{ "success": true }` |
| Confirm email verification | `POST /auth/email-verification/confirm` | Public | `{ "token": "opaque-verification-token" }` | `{ "success": true }` |

Password reset request success is intentionally generic. The app must show the
same user-facing result whether the account exists, does not exist, is
suspended/deleted, or is rate-limited.

---

## Password Reset Confirmation Boundary

The existing `enterEmail` screen may continue to request password reset through
`AuthRepository.requestPasswordReset`.

The existing `enterPassword` screen must not call `confirmPasswordReset` unless
it receives a reset token from a verified route argument or link entry path.
The current screen does not own a token yet, so it cannot honestly complete the
password reset by itself.

Next runtime wiring should add an explicit reset confirmation entry point. It
may reuse the existing password-entry UI only if the token is provided through
route arguments or a deep-link landing route. It must not ask the user to paste
a token unless product chooses a manual internal-test flow.

Required behavior:

- Send only `token` and `newPassword` to `POST /auth/password-reset/confirm`.
- Do not submit email, user id, role, status, refresh token, access token, or
  account state to the confirm route.
- Treat successful confirmation as unauthenticated: the backend does not issue
  a new session.
- Clear any existing local session after a successful password reset because
  the backend revokes existing refresh sessions.
- Return the user to sign-in after success.
- Show safe copy for invalid, expired, or already-used token failures.
- Allow the user to request another reset from the email step.

Token handling:

- Keep the reset token transient: route argument or in-memory state only.
- Never persist the reset token in secure storage, shared preferences, local
  stores, logs, analytics, screenshots, or debug payloads.
- Clear the token on success, back navigation, route disposal, or terminal
  failure.

---

## Email Verification Confirmation Boundary

The current-email review screen may continue to request verification through
`AccountRepository.requestEmailVerification` for the signed-in account.

Email verification confirmation is a public token-confirm operation. It should
have an explicit link/token landing route before calling
`AccountRepository.confirmEmailVerification`.

Required behavior:

- Send only `token` to `POST /auth/email-verification/confirm`.
- Do not submit email, user id, role, status, or client-supplied
  `emailVerified` state.
- Treat successful confirmation as a state update, not as login: the backend
  does not issue a new session.
- If the app still has a valid session, refresh current account state with
  `GET /auth/me` or the existing account repository current-account flow.
- If the app is unauthenticated or the session expired, show a safe success
  result and ask the user to sign in again.
- Show safe copy for invalid, expired, or already-used token failures.

Token handling:

- Keep the verification token transient: route argument or in-memory state only.
- Never persist the verification token in secure storage, shared preferences,
  local stores, logs, analytics, screenshots, or debug payloads.
- Clear the token on success, back navigation, route disposal, or terminal
  failure.

---

## Route Ownership

The next implementation slice should choose the smallest clear route ownership:

| Need | Recommended frontend owner |
|------|----------------------------|
| Password reset request | Existing `enterEmail` route |
| Password reset confirmation | New dedicated reset-confirm landing route, or existing `enterPassword` only when opened with a required reset token argument |
| Email verification request | Existing current-email review route |
| Email verification confirmation | New dedicated verification-confirm landing route with a required token argument |

Do not overload existing local account-security routes to pretend that a token
exists. The route that calls a confirm endpoint must own the token source.

---

## Deep-Link Boundary

The backend can send reset and verification links, but production mobile
universal/app-link setup is not completed in this Flutter repo.

For the first Flutter wiring slice:

- Accept token input from route arguments produced by an app link or internal
  handoff.
- Keep manual token/code entry out of production UX unless product explicitly
  chooses an internal test route.
- Do not claim universal links, custom scheme links, Android App Links, or iOS
  Associated Domains are production-ready until platform/domain setup is
  completed and tested.

Deep-link platform setup remains a separate release/infrastructure task.

---

## Error And Privacy Rules

Frontend user-facing errors should stay generic:

- "Reset link is invalid or expired."
- "Verification link is invalid or expired."
- "Session expired, please sign in again."
- "Check your email if an account exists."

The app must not display backend internals, provider delivery errors, token
hashes, account existence hints, suspended/deleted status, or raw exception
payloads.

The app must never log:

- access tokens
- refresh tokens
- reset tokens
- verification tokens
- passwords
- reset or verification links
- email bodies
- provider payloads

---

## Out Of Scope

This contract does not implement or claim readiness for:

- runtime Flutter route wiring
- Android App Link or iOS Universal Link registration
- production domain/app-link setup
- manual code-entry UX for production
- phone OTP/SMS sign-in or phone verification
- social auth expansion
- MFA/PIN activation
- account deletion/deactivation APIs
- profile persistence
- payment, notification, content, or scheduling modules
- backend endpoint implementation
- email template design
- production sender/domain readiness

---

## Next Slice

Queue `52.16` as the first runtime wiring decision/implementation slice:

`Implement reset and email verification token-confirm route wiring from the
confirmed backend contract, or stop if platform deep-link setup is required
first.`

The next slice should not broaden into phone OTP, social auth, MFA/PIN,
profile persistence, production deep-link setup, or another backend contract
group.
