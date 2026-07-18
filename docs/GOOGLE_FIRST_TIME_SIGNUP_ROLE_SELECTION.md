# Google first-time signup role selection

**Slice:** APP-63
**Date:** 2026-07-18
**Status:** Implemented and locally verified; PR/CI record required before milestone merge.

## Decision

Enable Google first-time signup only through explicit CareNet role selection.

The signup Google button is enabled only when `GoogleIdTokenProvider` is configured. It routes to `signUpRole` in Google signup mode. After the user selects `PATIENT` or `PROFESSIONAL`, the app obtains a real Google ID token and calls the backend Google auth route with:

- `idToken`
- selected backend role

Successful patient Google signup routes to `patientOnboardingSetup`.
Successful professional Google signup routes to `medicalProfessional`.

## Product boundary

Google identity is not treated as medical profile authority.

The app does not copy Google display names into trusted professional profile fields, does not skip patient/professional onboarding, and does not claim public professional readiness. Required profile and credential data still belongs to the post-auth setup flow.

## Runtime behavior

- Sign-up Google from email/phone entry opens account-type selection when configured.
- Role selection calls `AuthRepository.googleSignIn(idToken, role)`.
- `AuthApiClient.googleSignIn` sends `role` only when provided, preserving existing sign-in behavior for linked/existing accounts.
- Provider/backend failures show safe inline copy and do not navigate.
- Missing Google config keeps the signup row disabled instead of faking success.

## Deferred

- Facebook and Apple signup remain disabled.
- Google unlink, cross-email/recovery linking, recent re-auth, iOS OAuth proof, release/Play signing fingerprints, production OAuth consent/app verification, phone/OTP, MFA, admin review, payments, calls, reviews, notes, and prescriptions remain separate future work.

## Verification

- `flutter test test\features\authentication\sign_up_flow_test.dart test\features\authentication\sign_in_flow_test.dart test\features\authentication\finish_sign_up_test.dart`
- `flutter analyze lib\features\Authentication\data\services\auth_api_client.dart lib\features\Authentication\data\repositories\auth_repository.dart lib\features\Authentication\presentation\pages\sign_up_arguments.dart lib\features\Authentication\presentation\pages\sign_up_email.dart lib\features\Authentication\presentation\pages\sign_up_phone.dart lib\features\Authentication\presentation\pages\sign_up_role_selection.dart lib\core\constants\navigators\router.dart test\features\authentication\sign_up_flow_test.dart test\features\authentication\sign_in_flow_test.dart`
