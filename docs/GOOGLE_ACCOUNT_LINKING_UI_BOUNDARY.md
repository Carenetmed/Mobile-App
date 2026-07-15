# Google Account Linking UI Boundary

Task: 52.90

Status: Accepted boundary

## Context

Task `52.89` selected protected Google account linking as the next
backend-completed Flutter surface.

Existing implementation pieces:

- Backend route: `POST /auth/google/link`
- Flutter repository method: `AuthRepository.googleLink`
- Google ID-token provider: `GoogleIdTokenProvider.signInIdToken`
- Existing Google provider config gate:
  `GoogleIdTokenProvider.isConfigured`
- Current account host surface: `AccountShellPage`

This slice defines the UI/runtime boundary only. It does not add runtime UI.

## Decision

The next runtime slice may add a protected Google account linking action to the
Account screen.

Accepted placement:

- Add a new Account tile below `Authentication` and before
  `Settings & Profile`.
- Title: `Google account`
- Linked-action label/state can use safe copy such as `Link Google account`.
- The action belongs to Account because linking modifies the authenticated
  account's provider identity. It should not live on sign-up, profile edit,
  professional verification, public profile, scheduling, or onboarding screens.

Accepted runtime behavior for the next slice:

1. `AccountShellPage` may accept an optional `GoogleIdTokenProvider`.
2. If `GoogleIdTokenProvider.isConfigured` is false, the tile/action must stay
   disabled and explain that Google linking is not configured.
3. If the account is loading, the linking action should not start.
4. On tap, request a real Google ID token through
   `GoogleIdTokenProvider.signInIdToken`.
5. Call `AuthRepository.googleLink(idToken: token)`.
6. Show loading while linking is in progress.
7. Show success only after `googleLink` completes.
8. Show safe errors from `AuthFailure` without raw provider/backend internals.
9. Do not change local session/user role/status/email from the frontend after
   linking. The backend owns account/provider state.
10. The action must require an existing authenticated session through
    `AuthRepository.googleLink`; if the repository reports unauthorized, show a
    safe sign-in-again message.

## Safe Error Boundary

The runtime slice should use safe user-facing copy only:

- missing config: `Google account linking is not configured yet.`
- Google cancel/unavailable: reuse the provider's safe `AuthFailure.message`
- unauthorized: `Please sign in again.`
- validation/collision: `This Google account cannot be linked here.`
- network/server/unknown: `Google account linking failed. Please try again.`

The UI must not render:

- raw backend response bodies
- Google subject IDs
- ID tokens
- provider payloads
- access/refresh tokens
- account-linking audit data
- internal provider/client IDs

## Required Runtime Tests For Next Slice

The next runtime slice should add or update focused tests proving:

- Account exposes the Google account linking entry in the accepted location.
- The action stays disabled when `GoogleIdTokenProvider.isConfigured` is false.
- A configured provider returns an ID token and
  `AuthRepository.googleLink` receives that token.
- Success appears only after repository success.
- Provider cancellation/failure shows safe copy and does not call
  `googleLink`.
- Backend failure shows safe copy and does not show success.
- Unauthorized failure shows a sign-in-again state.
- No session/user role/status/email mutation is faked in the UI.
- No Google token, raw provider payload, provider subject, backend raw error,
  phone/OTP, MFA, unlinking, sign-up role selection, payment, review, call,
  calendar, note, prescription, staging, or production claim is exposed.

## Explicitly Deferred

- Google sign-up role selection
- Google unlinking
- cross-email account linking
- recovery-linking
- recent re-authentication policy
- phone/OTP
- MFA/PIN enablement
- production OAuth consent/app verification
- release/Play signing fingerprints
- iOS Google proof
- profile creation
- admin verification dashboard
- payments, notifications, reviews, calls, calendar sync, notes,
  prescriptions, and medical records
- staging data and production readiness claims

## Next

Queue `52.91 - Wire Google Account Linking From Account`.

This should be a narrow runtime slice limited to the Account screen linking
action, provider token acquisition, `AuthRepository.googleLink`, safe states,
and focused Account tests.
