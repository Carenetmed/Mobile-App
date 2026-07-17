# Role Registration Backend Contract

**Slice:** APP-56
**Date:** 2026-07-17
**Status:** Accepted frontend/backend contract; no runtime behavior changed.

## Purpose

Define how the Flutter app should use the already implemented backend auth
routes for patient and professional registration before adding role-selection
UI or Google sign-up behavior.

This contract follows `ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md` and the backend
auth contract in
`C:\Users\asd\Music\carenet-backend-lab\docs\25-auth-frontend-integration-contract.md`.

## Current Backend Capability

The backend currently exposes:

| Route | Capability |
|-------|------------|
| `POST /auth/register` | Creates email/password `PATIENT` or `PROFESSIONAL` users |
| `POST /auth/google/sign-in` | Signs in an existing linked Google identity, or creates a new Google user when a valid `role` is supplied |
| `POST /auth/google/link` | Links Google to the currently authenticated active patient/professional when the verified Google email matches |

Backend authority rules:

- the backend is the source of truth for `user.id`, `role`, `status`, and
  `emailVerified`
- Flutter must not submit or trust user ids, account status, verification
  status, provider identity ids, or decoded JWT claims for authority
- provider tokens are only transient request inputs
- Google profile data is not CareNet profile authority

## Current Flutter Reality

The current Flutter auth repository can call:

- `AuthRepository.register(email, password, role, profile)`
- `AuthRepository.googleSignIn(idToken)`
- `AuthRepository.googleLink(idToken)`

The current shared `finishSignUp` screen still submits `role: "PATIENT"`
directly. That is acceptable only as a legacy scoped path, not as the final
CareNet onboarding model.

Sign-up social rows remain disabled because the app does not yet have a
role-selection and role-specific onboarding branch.

## Email/Password Registration Contract

### Patient Registration

Flutter may create a patient only after the user has explicitly selected or
entered the patient onboarding path.

Request:

```json
{
  "email": "patient@example.com",
  "password": "a long passphrase",
  "role": "PATIENT",
  "profile": {
    "firstName": "Ada",
    "lastName": "Okafor",
    "birthday": "1990-01-01"
  }
}
```

Accepted frontend behavior:

- collect only patient-safe profile fields at account creation
- navigate to patient dashboard/profile completion only after backend success
- show safe generic errors for duplicate email, validation failure, or backend
  rejection
- keep age, location, health interests, and medical preferences as profile
  setup fields unless a later backend/product slice makes them required

### Professional Registration

Flutter may create a professional only after the user has explicitly selected
or entered the professional onboarding path.

Request:

```json
{
  "email": "doctor@example.com",
  "password": "a long passphrase",
  "role": "PROFESSIONAL",
  "profile": {
    "firstName": "Ada",
    "lastName": "Okafor"
  }
}
```

Accepted frontend behavior:

- account creation may happen before full professional profile completion
- immediately route the user into professional profile and verification setup
- keep public listing inactive until profile, credential upload, and manual
  verification are complete
- never let the user self-set `verificationStatus`, public-listing status,
  document status, admin decision fields, or review state

Professional onboarding required after account creation:

```text
registered PROFESSIONAL account
-> professional profile setup
-> credential/license upload
-> admin/manual verification
-> verified public listing
```

## Google Sign-In And Sign-Up Contract

### Existing Linked Google Sign-In

Current Flutter behavior may keep calling:

```json
{
  "idToken": "google-id-token"
}
```

This is valid for existing linked Google identities. If the backend rejects the
request, Flutter must show safe failure copy and must not create a local
session.

### First-Time Google Sign-Up

First-time Google account creation requires explicit role selection before the
backend call.

Patient request:

```json
{
  "idToken": "google-id-token",
  "role": "PATIENT"
}
```

Professional request:

```json
{
  "idToken": "google-id-token",
  "role": "PROFESSIONAL"
}
```

Flutter must not enable this until the role-selection UI and post-registration
destinations exist.

Accepted behavior:

- obtain the Google ID token from the configured Google SDK
- hold it only long enough to complete the immediate backend request
- require a user-selected role before calling Google-created account signup
- send only `idToken` plus selected `role`
- after `PROFESSIONAL` creation, route to professional profile and verification
  setup, not straight to a public-provider dashboard

Not accepted:

- auto-creating Google users without a role
- defaulting all Google users to `PATIENT`
- defaulting all Google users to `PROFESSIONAL`
- storing Google tokens as app state
- treating Google display name/photo as verified CareNet professional data
- bypassing professional credential upload or admin review

### Google Account Linking

The existing protected account-linking path remains accepted:

```json
{
  "idToken": "google-id-token"
}
```

Rules:

- user must already be authenticated
- backend-authenticated user is the only link target
- verified Google email must match the CareNet account email
- Flutter must not submit user id, email, role, status, provider subject, or
  identity id

## Safe Error Direction

Flutter should map backend/provider failures to safe product language:

| Situation | Safe direction |
|-----------|----------------|
| Existing linked Google sign-in succeeds | enter app with returned backend session |
| Google sign-in rejects because role is missing for a new account | offer role-based sign-up later; do not claim Google is broken |
| Google email collides with existing unlinked account | ask the user to sign in with email/password, then link Google from Account |
| Backend validation fails | ask user to check details and try again |
| Unauthorized/protected route fails | ask user to sign in again |
| Provider cancellation | keep the user on the current auth screen without backend call |

## Required Next Runtime Slice

The next runtime onboarding slice should add the role-selection step before
account creation:

1. create/select a role-choice screen for `PATIENT` vs `PROFESSIONAL`
2. pass the selected role into email/password registration
3. route patient accounts to patient profile/dashboard
4. route professional accounts to professional profile and verification setup
5. keep Google sign-up disabled until the same role branch can call
   `POST /auth/google/sign-in` with `idToken` plus role

## Explicitly Deferred

- phone/OTP account creation
- Facebook and Apple providers
- Google unlink
- Google cross-email linking
- Google recovery linking
- recent re-authentication and MFA
- production OAuth consent/app verification
- release/Play signing fingerprints
- iOS Google proof
- terms/privacy persistence unless backend requires it in a later contract
- professional public listing before verification
- admin verification dashboard inside this patient/professional mobile app
- payments, refunds, payouts, reviews, calls, notes, prescriptions, calendar
  sync, emergency escalation, and content publishing

## Stop Conditions

Stop and ask for project-lead review if a future auth/onboarding slice tries to:

- create a user without explicit role selection
- hide Google provider errors as fake success
- make Google sign-up bypass role-specific onboarding
- let a professional become publicly listed before verification
- add payment, call, review, medical-note, prescription, or admin behavior into
  onboarding
- claim production healthcare compliance from this registration contract

## Decision Summary

Use the backend's existing role-capable auth routes, but do not enable broader
signup UI until Flutter has a role-selection and role-specific onboarding path.
Google provider wiring is real, but first-time Google signup is not product-safe
until it sends an explicit selected role and lands in the correct patient or
professional onboarding path.
