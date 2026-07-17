# Role-Based Onboarding And Auth Boundary

**Slice:** APP-55
**Date:** 2026-07-17
**Source:** `C:\Users\asd\Downloads\Carenet_PRD_v1.0.pdf`
**Status:** Accepted product/backend boundary; no runtime behavior changed.

## Why This Boundary Exists

The PRD defines CareNet as a dual-sided healthcare marketplace, not a generic
single-role login app. The platform serves:

- regular users/patients who need credible medical guidance
- medical professionals who list services, publish content, and provide paid
  consultations

Those roles have different onboarding, compliance, profile, verification,
permissions, and dashboard needs. Therefore, authentication cannot be treated as
"Google/email returns identity, then enter the app" for every user.

## Current App Reality

The app currently has:

- onboarding screens that route to sign-up phone
- sign-up phone/email entry screens
- a shared `finishSignUp` step
- email sign-in/sign-up wired to the backend auth repository
- Google sign-in rows wired on sign-in when configured
- Google account linking from Account when configured
- professional profile, verification upload, public listing, availability, and
  appointment flows already partially wired

The app does not yet have a complete role-based onboarding flow. Sign-up social
auth rows remain disabled because Google/Facebook/Apple sign-up needs role and
profile rules first.

## Product Decision

CareNet onboarding must explicitly branch by account type before the app claims
sign-up completion.

The accepted account types for the mobile app are:

| Role | Product meaning | Initial destination |
|------|-----------------|---------------------|
| Patient | Regular user seeking medical guidance, content, and consultations | Patient profile setup or dashboard with profile prompts |
| Professional | Licensed medical professional seeking listing, content, consultations, and earnings | Professional onboarding and verification |

Admin/reviewer accounts do not belong in the patient/professional mobile app.
Admin verification review remains a separate dashboard/web-console lane.

## Patient Onboarding Boundary

Patient onboarding should collect only the minimum safe information needed for
the user to use patient-side features.

Required for account creation:

- email or phone credential, depending on selected method
- password for email/password flow
- role: `PATIENT`
- acceptance of terms/privacy/community agreement where required by the current
  flow

Allowed as profile setup:

- name
- age
- location
- health interests

Patient profile setup may be optional after registration, but booking and
medical interactions should be allowed to prompt for missing required profile
fields later if backend/product rules require them.

## Professional Onboarding Boundary

Professional onboarding is stricter because the PRD requires verified
professionals and manual credential review before public listing.

Required for account creation or immediate post-registration onboarding:

- email or phone credential, depending on selected method
- password for email/password flow
- role: `PROFESSIONAL`
- display name / professional name
- professional category
- specialty where applicable
- credential/license upload path

Professional public listing must not become active merely because the account
exists. The professional must go through verification. The safe state is:

```text
registered professional account
-> professional profile setup
-> credential upload
-> admin/manual verification
-> verified public listing
```

## Google Auth Boundary

Google sign-in and Google sign-up must be separated.

Google can provide identity and email. It cannot decide whether the user is a
patient or professional, cannot collect professional credentials, and cannot
complete CareNet compliance requirements by itself.

Accepted behavior:

- Existing linked users may use Google sign-in.
- Signed-in users may link Google from Account when the backend allows it.
- Google sign-up must route through role selection before creating a CareNet
  account.
- If Google identity is selected before role exists, the app should hold only a
  transient provider token/result and continue to role-specific onboarding.
- If backend Google sign-in rejects an unlinked/unregistered Google account, the
  app should show safe copy and offer sign-up/linking direction later, not claim
  login success.

Not accepted:

- auto-creating every Google identity as a patient
- auto-creating every Google identity as a professional
- bypassing professional credential verification
- storing provider tokens longer than needed
- exposing raw provider/backend errors
- presenting Google sign-up as complete before role/profile rules exist

## Backend Contract Needed

Before runtime Google sign-up or role-based signup expansion, backend and
frontend should agree on these contracts:

| Contract | Required decision |
|----------|-------------------|
| Register patient | exact payload, required fields, response session behavior |
| Register professional | exact payload, initial verification/profile status, response session behavior |
| Google sign-in | linked-user-only vs create-if-known behavior |
| Google sign-up | endpoint/payload for provider token plus selected role/profile fields |
| Google link | existing-account linking rules, duplicate provider/email handling |
| Verification gate | professional status values and when public listing activates |
| Terms/privacy | whether acceptance is required in payload before account activation |
| Error model | safe error copy for unlinked Google account, duplicate email, unverified professional, missing role |

## Recommended Next Implementation Order

1. Define the backend API contract for role-based registration and Google
   sign-up/link behavior.
2. Add or adjust backend endpoints only after the contract is explicit.
3. Add a Flutter role-selection step before final sign-up completion.
4. Split patient and professional post-sign-up onboarding destinations.
5. Keep Google sign-up disabled until it can pass through the same role and
   verification boundary.
6. Re-test Google sign-in/linking only after the backend decision clarifies
   unlinked-account behavior.

## Explicitly Deferred

- phone OTP provider completion
- Facebook/Apple sign-up
- Google unlink UI
- production OAuth consent/app verification
- release/Play signing fingerprints
- iOS Google proof
- payments, refunds, payouts, and commission rules
- video/voice/chat consultation runtime
- consultation notes and prescriptions
- reviews and ratings
- emergency escalation workflow
- content moderation and article publishing backend
- admin verification dashboard implementation inside this mobile app
- legal/compliance documents beyond the onboarding boundary decision

## Stop Conditions For Future Slices

Stop and ask for project-lead input if a future auth/onboarding slice tries to:

- create a user without an explicit role
- make a professional publicly listed before verification
- make Google sign-up skip role selection
- add payments/calls/reviews/medical notes into onboarding
- treat PRD goals as implemented code
- claim production healthcare compliance without legal/compliance review

## Decision Summary

CareNet should move forward with role-based onboarding before expanding Google
sign-up or broader auth behavior. The current Google picker/provider path can
remain for existing linked-user sign-in and Account linking, but Google sign-up
must wait until role-specific patient/professional onboarding is implemented.
