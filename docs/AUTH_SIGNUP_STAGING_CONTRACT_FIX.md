# Auth signup staging contract fix

**Slice:** APP-62
**Date:** 2026-07-18
**Status:** Implemented and locally verified; PR/CI record required before milestone merge.

## Problem

Professional onboarding setup was failing against staging with `Please check details and try again`.

Root cause was contract drift:

- deployed staging backend did not yet include the `CAR-BE-119` Nigeria onboarding profile schema/API behavior
- Flutter email signup still sent a stale nested `profile` object to `POST /auth/register`
- Flutter password validation still allowed 8-character passwords while staging requires at least 15 characters

## Backend staging correction

Backend staging was deployed from a clean backend checkout at commit `b07e0ac` after applying migration `20260717143000_nigeria_onboarding_profile_schema`.

Staging deployment evidence:

- Cloud Run revision: `carenet-backend-staging-00016-dw4`
- Gateway health: `/health` returned `ok`
- Gateway readiness: database, migrations, email, Google auth, and verification storage reported `ok`
- Professional setup proof: `POST /auth/register` with email/password/role succeeded, then `PUT /professionals/me` accepted legal, credential, specialty, qualification, experience, and practice fields and returned `verificationStatus: NOT_SUBMITTED`

No passwords, tokens, API keys, or user secrets are recorded in this doc.

## Flutter fix

Flutter registration now matches the current backend contract:

- `finishSignUp` sends only `email`, `password`, and selected `role` to `AuthRepository.register`
- stale nested signup `profile` payload was removed
- local password validation and signup/reset helper copy now require at least 15 characters
- focused auth tests were updated to use 15+ character valid passwords

Profile fields remain backend-owned by the post-registration setup screens:

- patient profile setup writes patient fields after registration
- professional setup writes professional legal/credential/practice fields after registration
- verification documents remain a separate professional-owned flow

## Verification

Focused Flutter verification passed:

- `flutter test test\features\authentication\finish_sign_up_test.dart test\features\authentication\password_recovery_flow_test.dart test\features\authentication\sign_up_flow_test.dart`
- `flutter analyze lib\core\model\validator.dart lib\features\Authentication\presentation\pages\sign_up_con.dart lib\features\Authentication\presentation\pages\enter_password.dart test\features\authentication\finish_sign_up_test.dart test\features\authentication\password_recovery_flow_test.dart test\features\authentication\sign_up_flow_test.dart`

Backend clean-source verification before deployment passed:

- `npm run prisma:generate`
- `npm run build`
- `npm test -- --runInBand`

## Still not done

Google first-time signup is still not complete and must not be presented as fixed by APP-62.

Next recommended slice:

`APP-63 - Google First-Time Signup With Role Selection`

Required boundary:

- Google signup must use a real Google ID token
- role must be explicitly selected before account creation
- backend call must include `idToken` plus selected `PATIENT` or `PROFESSIONAL` role
- Google display name must not become trusted professional profile data
- patient/professional setup screens remain authoritative for required profile fields
- no dummy provider fallback or fake Google success path is allowed
