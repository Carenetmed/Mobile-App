# Auth Form Cleanup And Method Convergence

**Slice:** APP-67  
**Date:** 2026-07-18  
**Status:** Runtime slice complete. Stacked after APP-64, APP-65, and APP-66.  
**Contract:** `AUTH_ONBOARDING_EXPERIENCE_CONTRACT.md`

## Outcome

`finishSignUp` now creates only the authentication account. It no longer asks
for first name, last name, birthday, government-ID matching copy, or any other
profile-owned field.

The screen now shows:

- selected account role context
- email
- password
- confirm password
- clear copy that patient or professional details are collected in the next
  role-specific onboarding surface

Successful email/password registration still sends only:

```text
email
password
role
```

and routes to:

- `patientOnboardingSetup` for patients
- `medicalProfessional` for professionals

## Product Boundary

Auth owns account credentials and selected role only.

Patient setup owns patient profile details such as care name, date of birth,
location, and booking-required consent.

Professional onboarding owns legal identity, public display name, profession,
regulator/licence details, qualifications, experience, practice details, and
verification evidence.

Google display names and old email-signup name fields must not become trusted
medical or professional identity.

## UI Direction Applied

The old stacked two-column generic input blocks were replaced with a cleaner
credential form:

- calm healthcare copy
- role context card
- single-field rows for readability
- safer error container
- no crowded birthday/name block
- no fake claim that identity was checked during auth

This is still a sliced improvement, not the full auth/onboarding redesign.
Patient setup, professional application, readiness resolver, and status hubs
remain separate slices.

## Out Of Scope

- no readiness resolver
- no patient setup redesign
- no professional application redesign
- no backend profile creation changes
- no terms/privacy backend payload
- no email verification route change
- no phone OTP
- no Google provider/backend contract change
- no Facebook/Apple
- no MFA/PIN/security redesign
- no production OAuth/release-readiness claim

## Verification

- `dart format lib\features\Authentication\presentation\pages\sign_up_con.dart test\features\authentication\finish_sign_up_test.dart`
- `flutter test test\features\authentication\finish_sign_up_test.dart test\features\authentication\sign_up_flow_test.dart test\features\authentication\sign_in_flow_test.dart test\features\onboarding\onboarding_gateway_test.dart`
- `flutter test`
- `flutter analyze`
- `git diff --check`

Focused auth/onboarding tests passed. The full Flutter suite passed after
updating stale test harnesses that still expected the old onboarding headline
and older profile repository override signatures.

## Next Slice

APP-68: Onboarding readiness resolver shell.

Recommended scope:

- add the client-side readiness boundary after sign-in/signup/session restore
- route known local/backend states honestly
- avoid professional dashboard access claims before backend readiness supports
  them
- do not redesign patient setup or professional application in this slice
