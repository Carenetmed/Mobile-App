# Onboarding Setup Payload Value Alignment

**Slice:** APP-ID-007
**Date:** 2026-07-19
**Status:** Implemented.

## Decision Applied

Flutter keeps the currently accepted backend profile DTO field names, but setup
screens now send backend-owned catalog codes instead of display labels where the
catalog provides a stable code.

Patient setup sends:

- `country`: selected country code, for example `NG`
- `state`: selected Nigerian state code, for example `LA`
- `healthInterests`: selected health-interest code, for example `PRIMARY_CARE`

Professional setup sends:

- `category`: selected profession code, for example `MEDICAL_DOCTOR`
- `licensingCouncil`: selected profession regulator code, for example `MDCN`
- `practiceCountry`: selected country code, for example `NG`
- `practiceState`: selected Nigerian state code, for example `LA`

## Why

The backend DTOs do not yet accept native request fields such as `countryCode`,
`professionCode`, or `regulatorCode`, but the backend service resolves catalog
codes and labels through the existing string fields. Sending catalog codes is
less ambiguous than display labels and keeps Flutter aligned with the
backend-owned Nigeria onboarding catalog.

## Not Solved Here

This slice does not complete the full production onboarding policy. The next
decision slice should define the broader domain rules for account-type behavior,
partial applications, professional license guidance, required evidence,
role-switching, duplicate identities, city/state UX, and abuse-resistant
validation.

## Verification

Passed:

- `flutter test test/features/onboarding/profile_setup_test.dart -r expanded`
- `flutter analyze lib/features/Onboarding/presentation/pages/profile_setup.dart test/features/onboarding/profile_setup_test.dart`
- `git diff --check`
