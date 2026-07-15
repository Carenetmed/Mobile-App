# Next Surface After Category Specialty Regression Decision

Task: 52.89

Status: Accepted decision

## Context

Task `52.88` regression-checked the professional category/specialty update
path. The Flutter app now consumes the main completed profile/public
professional surfaces that are safe to wire without creating new product areas:

- auth/session/account read and email/password flows
- Google sign-in
- patient self profile read and name-only update
- professional self profile read, bio update, display-name update, and
  category/specialty update
- public verified professional listing
- public availability read and appointment request from supported surfaces
- own appointment list and scoped lifecycle actions
- professional availability management
- professional verification owner list/upload

The next lane should still come from already-completed backend surfaces, but it
must avoid turning deferred product modules into fake UI.

## Candidate Review

| Candidate | Current status | Decision |
| --- | --- | --- |
| Scheduling staging smoke | Still blocked on deliberate backend/staging patient, professional, verified professional, availability, appointment, and cleanup data | Defer |
| Professional profile creation | Backend `PUT /professionals/me` can create if required fields exist, but onboarding/profile-creation policy and empty-profile UX are still not defined | Defer |
| Patient age/location mutation | Backend allows patient `age`/`location`, but current settings mapping intentionally stopped at name-only mutation and needs a boundary before broader patient data editing | Defer |
| Website/address persistence | Not accepted in the current profile contract fields | Defer |
| Public professional detail | Backend docs still list `GET /professionals/:id` as future work | Defer |
| Admin verification dashboard | Backend routes exist, but mobile app has no admin dashboard lane and admin review belongs to a separate product/admin surface | Defer |
| Phone/OTP and MFA | Backend docs explicitly defer these provider/security models | Defer |
| Payments, reviews, notifications, calls, calendar, notes, prescriptions | Not backend-completed for this Flutter lane | Defer |
| Google account linking | Backend has `POST /auth/google/link`; Flutter `AuthRepository.googleLink` already exists; Google provider config is established for sign-in | Choose, with a boundary decision first |

## Decision

Choose Google account linking as the next backend-completed Flutter surface,
but do not wire runtime UI yet.

The next slice should define the account-linking boundary before implementation:

- where the link action belongs in the current app, likely Account or
  Authentication/Security settings rather than sign-up
- whether it should be visible only when Google provider config is present
- how to use the existing `GoogleIdTokenProvider` and
  `AuthRepository.googleLink`
- how to handle backend safe errors, especially existing-email/linking
  collisions
- why Google sign-up role selection, unlinking, cross-email linking,
  recovery-linking, recent re-auth policy, phone/OTP, MFA, production OAuth,
  release signing, and iOS proof remain deferred

## Reasoning

Google account linking is the best next narrow lane because:

- the backend route exists and resolves ownership from the authenticated user
- the Flutter auth repository already exposes `googleLink`
- the Google ID-token provider is already wired for sign-in
- it fits the existing account/security area instead of opening a new product
  module
- it does not depend on scheduling staging seed data or verification storage
- it can be implemented as an explicit protected account action without
  claiming production OAuth readiness

Profile creation is deliberately not selected because creating patient or
professional profiles after registration affects onboarding, role policy,
empty-profile copy, and required-field UX. That needs a separate boundary and
should not be smuggled into a small mutation slice.

## Next Slice

Queue `52.90 - Define Google Account Linking UI Boundary`.

This should be a decision/contract slice only. It should not implement runtime
behavior.

## Explicitly Out Of Scope

- runtime Google linking UI
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
- payments, notifications, reviews, calls, calendar sync, notes, prescriptions,
  or medical records

## Non-Claims

This decision does not claim:

- Google account linking is already visible in the app
- production Google OAuth is ready
- Google sign-up role-selection is defined
- account unlinking or provider-management settings are ready
- the app is Play Store-ready or production-ready
