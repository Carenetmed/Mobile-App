# Auth Onboarding Experience Contract

**Slice:** APP-65  
**Date:** 2026-07-18  
**Status:** Draft contract. Depends on APP-64 product decision approval.  
**Base decision:** `AUTH_ONBOARDING_PRODUCTION_FLOW_PROPOSAL.md`

## Purpose

This document turns APP-64 into an implementation-ready experience contract for
the first app launch, authentication, role selection, patient setup, professional
application, readiness routing, and recovery states.

The goal is to settle this product area before UI implementation begins:

- no screen without a known state
- no field without a backend/product owner
- no polished UI that hides broken recovery behavior
- no role-specific medical onboarding logic inside generic auth forms
- no fake phone, verification, licence, document, or completion claims

This slice does not implement runtime Flutter behavior.

## Non-Negotiable Experience Rules

1. Role is chosen before signup method.
2. Google and email converge on the same role-specific onboarding contract.
3. Phone signup/sign-in stays unavailable until real OTP exists.
4. Guest browse is allowed only on public verified-care surfaces.
5. Patient setup is light and skippable until booking requires identity.
6. Professional onboarding is a resumable application, not a single long form.
7. Backend readiness decides where a signed-in user lands.
8. The app preserves entered data after recoverable errors.
9. Sensitive medical/professional claims are backend-owned.
10. Every pending, rejected, expired, incomplete, or blocked state has a visible
    next action or a documented support/admin path.

## Product Information Architecture

| Area | Owns | Must not own |
|------|------|--------------|
| Auth | email, password, OAuth provider identity, selected role, session | legal name, licence, patient medical identity, documents |
| Patient profile | patient display/care name, date of birth, location when required, care preferences | professional credentials, account security, document upload |
| Professional application | legal identity, public display name, profession, regulator, registration number, qualifications, practice details, submission state | account password, patient booking data, admin decision notes |
| Verification documents | private evidence files, document type, upload status, review status | public profile copy, appointment state, payment state |
| Legal/consent | accepted document type/version/timestamp, role declarations, consultation notices | visual-only checkboxes with no backend proof |
| Account settings | email/phone changes, password/security, logout, account recovery | role switching, licence review, medical consultation state |

The same field must not be asked in two places as if both are authoritative. For
example, Google display name and email signup name cannot become trusted patient
or professional legal identity. They may only help the user type, if that
behavior is separately approved.

## App Open State Resolver

Every app launch, sign-in, signup completion, token refresh, and reauth return
must pass through a readiness resolver before entering a dashboard.

Recommended snapshot:

```text
sessionStatus: NONE | VALID | EXPIRED | INVALID
role: PATIENT | PROFESSIONAL | ADMIN
emailVerified: true | false
profileStatus: MISSING | DRAFT | COMPLETE
professionalApplicationStatus:
  NOT_APPLICABLE | NOT_STARTED | DRAFT | READY_TO_SUBMIT |
  SUBMITTED | PENDING | VERIFIED | REJECTED | EXPIRED | SUSPENDED
requiredActions: string[]
nextAction:
  WELCOME | SIGN_IN | VERIFY_EMAIL | PATIENT_SETUP |
  PATIENT_BOOKING_GATE | PROFESSIONAL_INTRO |
  PROFESSIONAL_RESUME | PROFESSIONAL_REVIEW |
  PROFESSIONAL_UPLOAD_EVIDENCE | PROFESSIONAL_STATUS |
  PROFESSIONAL_RENEWAL | DASHBOARD | SUPPORT_REQUIRED
returnIntent: optional safe route/action
```

The exact payload belongs to a backend contract slice. The frontend may render
known states, but it must not infer professional verification, licence validity,
or application completion from local routes.

## Opening Flow

```text
Splash
-> restore session
   -> no session: Welcome gateway
   -> expired session with recoverable return intent: Sign in, then resolver
   -> valid session: Readiness resolver
   -> invalid/corrupt session: Clear local session, Welcome gateway
```

Splash is not a marketing page. It should be brief, calm, and functional.

## Welcome Gateway

Primary jobs:

- communicate that CareNet helps people find verified care
- offer `Browse verified care`
- offer `Create account`
- offer `Sign in`
- avoid forcing profile setup before the user understands the product

Recommended visual direction:

- premium healthcare marketplace feel
- white/soft-neutral base with one CareNet accent and clinical green/blue
  support tones
- real human-care language, not social-network language
- first viewport should feel trustworthy and useful, not like a generic
  onboarding carousel

Out of scope:

- phone signup
- social feed promises
- emergency-care claims
- provider availability promises before backend data exists

## Guest Browse

Guest users may view public verified-care discovery where backend public data is
available. Guest users may not book, message, save private health data, upload
documents, or access account-only surfaces.

When a guest starts a protected action:

```text
Protected action
-> auth gate explains why account is needed
-> create account or sign in
-> readiness resolver
-> return to original action only when required readiness is complete
```

The return intent must not include private or forged state from the client.

## Create Account Flow

```text
Create account
-> Choose account type
   -> Patient
   -> Medical professional
-> Method screen with role visible
   -> Continue with Google
   -> Continue with email
   -> Phone unavailable
```

The role screen should use simple, serious cards:

- Patient: find verified professionals, book care, manage appointments.
- Medical professional: apply for verification, manage availability, receive
  appointment requests after approval.

The method screen must show the selected role and a `Change` action.

## Email Signup

Fields:

- email
- password
- confirm password if product accepts that pattern
- accepted account terms/privacy version when backend support exists

Not allowed here:

- full legal name
- birthday
- licence number
- profession
- health interests
- practice location

After success:

```text
email signup success
-> request email verification
-> readiness resolver
```

Email verification may be pending while profile setup continues, but protected
actions enforce verification as defined by APP-64.

## Google Signup And Sign-In

Google proves provider identity and may satisfy verified-email requirements when
the backend validates the Google ID token and email verification claim.

Rules:

- Google signup requires selected role.
- Google sign-in must not create a wrong-role account silently.
- Existing account collisions show a safe path: sign in with the existing
  method, then link Google from Account when supported.
- Provider cancellation returns to the method screen without a scary error.
- Google display name is not trusted profile identity.

## Sign-In Flow

```text
Sign in
-> choose email or Google
-> authenticate
-> readiness resolver
```

Sign-in must not route directly to dashboard. A professional with pending
verification, missing documents, rejected application, expired licence, or
incomplete draft must land in the correct status/resume screen.

## Patient Onboarding

Patient setup is optional for browsing and required only when a protected care
action needs it.

Recommended first-session screen:

- explain that setup can be completed now or later
- ask only for fields useful now
- provide `Skip for now`
- do not make the user feel blocked from seeing the app

Booking gate fields:

| Field | Owner | Rule |
|-------|-------|------|
| Full name | Patient profile | Required before first booking |
| Date of birth | Patient profile | Required before first consultation unless legal/product changes this |
| Location | Patient profile/service rule | Ask only when needed for service eligibility/location |
| Consultation consent | Legal/consent | Required at first relevant booking/consultation |
| Email verified | Auth/backend | Required before booking |

After completion, return to the booking/action that triggered the gate.

## Professional Onboarding

Professional setup is an application with explicit save/resume behavior.

```text
Professional intro/checklist
-> Identity
-> Profession and regulator
-> Qualifications and experience
-> Practice details
-> Review and change
-> Submit application
-> Upload required evidence
-> Application status hub
```

### Professional screen rules

- Use one focused page or one tight group per step.
- Show `Step n of m`, not a crowded mobile stepper.
- Include `Save and exit` after the application has started.
- Validate on continue and preserve data after errors.
- Use controlled selects for profession/regulator/state after catalogs exist.
- Clearly label what is public and what is private.
- Review screen must show every submitted field with edit actions.
- Submission is separate from saving a draft.

### Professional fields and owners

| Field | Owner | Notes |
|-------|-------|-------|
| Legal name | Professional application | Private/admin review; not Google-owned |
| Public display name | Professional application/public profile | Product-approved display rules |
| Profession | Controlled catalog | Not free text for launch |
| Regulator/council | Controlled catalog | Depends on profession |
| Registration/licence number | Professional application | Normalize for duplicate review |
| Licence expiry/renewal date | Professional verification lifecycle | Required when regulator evidence has expiry |
| Specialty | Controlled or approved catalog | No unsupported medical claims |
| Qualifications | Professional application | Schema may need expansion before final UI |
| Years of experience | Professional application | Numeric validation |
| Practice/facility | Professional application | Public/private handling defined per field |
| City/state/country | Professional application | Nigeria-aware selects when available |
| Identity document | Verification documents | Private upload |
| Licence document | Verification documents | Private upload |
| Certification document | Verification documents | Private upload |

### Professional status hub

| State | User experience |
|-------|-----------------|
| Draft | Resume application, see incomplete steps |
| Ready to submit | Review, edit, submit |
| Submitted/Pending | See status, safe expectations, no operational dashboard |
| Verified | Enter professional dashboard/features allowed by backend |
| Rejected | See safe next action; no internal admin notes |
| Expired/Suspended | See renewal/support path; public booking disabled |
| Support required | Show contact/support direction; no fake completion |

## Recovery And Error Contract

| Scenario | Required behavior |
|----------|-------------------|
| Backend unavailable | Preserve form state, retry, no false success |
| Offline | Keep local screen state, show reconnect/retry |
| Session expired | Reauth, then resolver returns to saved step |
| Duplicate email | Offer sign in/password recovery without leaking internals |
| Google cancelled | Return quietly to method screen |
| Google account collision | Direct to existing sign-in/linking path |
| Wrong role chosen | Controlled support/admin or fresh-account path |
| Upload failed | Keep document type/file choice when safe, allow retry |
| Upload partial/stuck | Show status and support path; do not claim submitted |
| Rejected application | Show approved correction/resubmission path |
| Expired licence | Show renewal/review path; disable public booking |
| Lost email access | Support/account-recovery path; no local email overwrite |
| Legal name change | Support/admin review path |
| Regulator mismatch | Correction/review path, no self-override |

Unknown errors may use generic safe copy, but known server validation/state
errors should receive specific, non-leaking guidance.

## Visual Direction

CareNet should feel like a serious modern healthcare marketplace, not a generic
template auth flow.

Principles:

- calm, spacious, clinical, warm
- visually premium but not decorative-heavy
- clear role cards and step pages
- restrained accent use
- strong readable typography
- stable mobile layouts on small Android devices
- no fake dashboard access for pending professionals
- no huge nested cards or crowded form pages

Recommended UI pattern:

- Welcome gateway: one strong healthcare message plus direct actions.
- Role choice: two large but restrained option rows/cards with icons and clear
  consequences.
- Method choice: selected role header, Google/email actions, disabled phone row.
- Patient setup: short friendly setup page with skip and booking gate.
- Professional setup: application-style pages with progress, save/resume, and
  review-and-change.
- Status hub: clear state, current requirement, next action, and support route.

Copy tone:

- direct, calm, specific
- avoid blame
- explain why sensitive data is needed
- never claim verification or booking availability until backend confirms it

Example direction:

- Good: `We need your licence details before your profile can be reviewed.`
- Bad: `Please check details and try again.`

## Accessibility And Device Standards

- Minimum touch targets should be comfortable on small Android devices.
- Text must scale without clipping.
- Error messages should be tied to fields and announced by screen readers.
- Focus should move to the first failed field after submit.
- Contrast must remain readable in disabled, loading, and error states.
- Long forms must support back navigation without losing completed answers.
- Low-bandwidth and interrupted-session behavior must be tested.

## Do-Not-Build List For Auth/Onboarding Redesign

Do not add these while implementing the first production auth/onboarding flow:

- phone OTP signup/sign-in
- Facebook/Apple auth
- MFA/PIN/security redesign
- dual-role self-service
- clinic/organization staff accounts
- dependent/minor profiles
- automatic regulator verification
- payments, payouts, refunds
- reviews, calls, chat, prescriptions, medical notes
- admin dashboard replacement
- legal wording approval claims
- document deletion/retention guarantees without policy
- production OAuth/release readiness claims

## Implementation Slice Plan

APP-66: Auth gateway and role-first entry  
Create the welcome gateway, guest browse entry, create-account/sign-in choices,
role-first selection, method screen, disabled phone row, and converged
email/Google entry points. No backend readiness resolver yet.

APP-67: Auth form cleanup and method convergence  
Remove duplicated authoritative profile fields from email signup, ensure email
and Google both create/sign in through the selected role contract, and keep
specific errors.

APP-68: Onboarding readiness resolver shell  
Add the client state resolver boundary and route signed-in users to the correct
known local/backend states without pretending missing backend fields exist.

APP-69: Patient setup and booking gate contract UI  
Make patient setup skippable for browsing and required for booking-intent return
where backend/profile state supports it.

APP-70: Professional application shell and visual system  
Replace the long professional form with application intro, step shell,
save/resume placeholders tied to backend-required states, and review/status
structure. Do not fake server-side drafts.

APP-71: Professional evidence/status experience  
Integrate the existing verification document flow into the professional status
hub, with pending/rejected/verified/expired/suspended UI states as far as the
backend contract supports.

APP-72: Auth/onboarding regression and device smoke  
Prove email and Google, patient and professional, session restore, interruption,
offline/retry, duplicate account, pending/rejected, and text-scaling behavior.

Backend contract slices must happen before final professional draft/resume,
licence lifecycle, duplicate identity, support recovery, and data-retention
claims are treated as complete.

## Acceptance Criteria

1. Every screen in the auth/onboarding journey has a state that causes it to
   appear.
2. Every field has a single owner.
3. Sign-in and signup route through readiness resolver before dashboard.
4. Patient browsing remains low-friction.
5. Professional onboarding remains application-grade and resumable.
6. Google/email behavior is consistent after role selection.
7. Phone remains disabled until real OTP exists.
8. Pending/rejected/expired professional states do not enter a live dashboard.
9. Error and recovery states are defined before visual implementation.
10. The visual direction is premium healthcare, not current generic form UI.
11. Implementation is sliced and does not combine the full redesign into one PR.
12. Backend-dependent claims are explicitly deferred until backend contracts
    exist.

## Review Result Needed

APP-65 is accepted when the product lead confirms this experience contract is
the source of truth for the auth/onboarding redesign. Runtime implementation
should begin only after APP-64 and APP-65 are approved, with APP-66 as the first
implementation slice.
