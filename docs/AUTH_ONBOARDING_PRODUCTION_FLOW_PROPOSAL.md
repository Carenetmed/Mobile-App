# Auth And Onboarding Production Flow Proposal

**Slice:** APP-64  
**Date:** 2026-07-18  
**Status:** Proposed for product-lead review. No runtime behavior changed.  
**Decision gate:** Do not begin implementation until the proposal is accepted or amended.

## Outcome

CareNet should replace the current signup sequence with a role-first healthcare
entry flow and add a backend-owned onboarding readiness/resume contract.

The recommended product boundary is:

```text
First launch
-> browse care as a guest, create an account, or sign in
-> choose Patient or Medical professional before choosing a signup method
-> create the secure account
-> complete only the setup required for that role
-> resume the correct incomplete step after interruption or later sign-in
```

Patient access should be low-friction. A patient may browse public content and
verified professionals without completing a profile, but must have verified
contact identity and the minimum care profile before booking.

Professional onboarding should be a resumable application. A professional must
complete identity, registration, qualifications, practice details, document
submission, and manual review before becoming publicly listed or receiving
appointments.

Google proves provider identity only. It never supplies trusted CareNet patient
or professional profile data, and it never bypasses role-specific setup.

## Evidence Used

### CareNet product and implementation

- `C:\Users\asd\Downloads\Carenet_PRD_v1.0.pdf` defines optional patient
  profile setup, guest browsing before booking, multi-step professional
  registration, credential uploads, and manual verification before listing.
- `ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md` and
  `ROLE_REGISTRATION_BACKEND_CONTRACT.md` already establish explicit patient and
  professional roles and forbid Google from bypassing role selection.
- `CAR-BE-119` and the current Flutter profile repository already own the core
  Nigeria onboarding fields.
- Current backend profile reads return `404` when the role profile does not
  exist. Professional profiles expose backend-owned `verificationStatus`.
- Current session restore routes every usable session directly to the dashboard;
  it does not resolve incomplete onboarding.

### Comparable healthcare products

- Zocdoc allows account creation at booking time and asks patients to use names
  and demographics matching their medical or insurance records:
  https://www.zocdoc.com/patient-help/en/articles/8724679-how-do-i-create-a-zocdoc-account
- Teladoc allows account setup first and requires medical history before the
  first visit rather than forcing every care detail into authentication:
  https://www.teladochealth.com/start/faq
- Practo separates practitioner registration from profile verification and
  requires identity, degree, registration, and related professional evidence
  before a professional profile goes live:
  https://help.practo.com/practo-ray/getting-started/steps-to-get-listed-on-practo/
- MDCN provides practitioner status/folio verification and registration
  services, supporting regulator-aware professional onboarding:
  https://mdcn.gov.ng/
- PCN, NMCN, MLSCN, and RRBN maintain profession-specific registration or
  licensing processes. CareNet should not treat one generic licence field as
  authoritative for every profession:
  https://pcn.gov.ng/
  https://www.nmcn.gov.ng/
  https://hub.mlscn.gov.ng/
  https://portal.rrbn.gov.ng/registration/

### Form, accessibility, and privacy expectations

- NHS and GOV.UK transactional form guidance supports focused question pages,
  asking only necessary questions, preserving answers after errors, and using a
  simple progress indicator only when it helps:
  https://service-manual.nhs.uk/design-system/patterns/question-pages
  https://design-system.service.gov.uk/patterns/validation/
- Long or consequential applications should include a review-and-change step
  before final submission:
  https://design-system.service.gov.uk/patterns/check-answers/
- The current Nigerian privacy authority is the Nigeria Data Protection
  Commission under the Nigeria Data Protection Act 2023. The PRD's NDPR wording
  is not sufficient as the final production compliance statement:
  https://www.ndpc.gov.ng/ndp-act-2023/

These references are inputs, not templates to copy. CareNet's final flow must
match its own backend authority, Nigerian regulator rules, and product scope.

## Current Flow Problems

1. The three first-launch slides describe a broad professional community more
   than a patient-to-professional healthcare marketplace.
2. `Get started` opens phone signup even though phone/OTP account creation is not
   a real supported backend path.
3. Signup method is chosen before role. Google then introduces role selection at
   a different point, so email and Google feel like different products.
4. The email finish-signup screen asks for name and birthday even though current
   registration sends only email, password, and role. Role-specific setup asks
   for authoritative profile information afterward.
5. Any restored session enters the dashboard even when the role profile is
   missing, professional documents are missing, or verification is pending.
6. Professional setup is one long form with no durable draft, review screen, or
   reliable resume point after app closure, token expiry, or network loss.
7. Patient setup is effectively mandatory before entry even though the PRD calls
   it optional and supports guest browse before booking.
8. Email verification exists as a backend capability but is not a coherent part
   of account creation or booking/professional-submission readiness.
9. Generic errors such as `Please check details and try again` do not tell the
   user which recoverable action to take.
10. A professional reaches document upload but does not have a complete
    application-status hub for draft, submitted, pending, verified, or rejected
    outcomes.

## Target Entry Flow

```text
Splash
-> restore session
   -> no session: CareNet welcome gateway
   -> session: onboarding readiness resolver

CareNet welcome gateway
-> Browse verified care
-> Create account
-> Sign in

Create account
-> Choose account type
   -> Patient
   -> Medical professional
-> Choose method
   -> Continue with Google
   -> Continue with email
   -> Phone unavailable until real OTP support exists
```

Role must be chosen before Google or email account creation. The selected role
should remain visible on the auth screen with a clear `Change` action.

Guest browsing should use only public verified-professional/content surfaces.
Booking, saving private health information, messaging, and other protected
actions should open a sign-in/create-account gate and then return the user to the
intended action when safe.

## Patient Flow

### Account and setup

```text
Choose Patient
-> choose Google or email
-> backend creates PATIENT account
-> request/confirm email verification where required
-> optional patient setup
-> browse dashboard
```

Initial patient setup fields:

| Field | First-session rule | Booking rule |
|-------|--------------------|--------------|
| Full name | Recommended; may be skipped for browsing | Required |
| Date of birth | Optional during first-session setup | Required before the first consultation unless product/legal review decides otherwise |
| City/state/country | Optional | Ask only when needed for service/location rules |
| Health interests | Optional and clearly labelled | Never required for account creation |

The existing backend requires `name` when the first patient profile is created.
The app may therefore leave the profile absent when setup is skipped, then create
it once required information is supplied.

Google display name must not prefill the authoritative full-name field as a
trusted value. It may be offered as an editable suggestion only if the product
later approves that behavior; the conservative first implementation should ask
the user directly.

### Patient readiness

A patient can browse while setup is incomplete. Before booking, CareNet should
check:

- active authenticated account
- verified email/provider identity according to the accepted auth policy
- patient profile exists
- required booking identity fields are complete
- accepted current terms/privacy and consultation-safety notices

Missing requirements should open a focused completion screen and return to the
original booking after success. The app must not discard the selected
professional or appointment intent.

## Professional Flow

### Account and application

```text
Choose Medical professional
-> choose Google or email
-> backend creates PROFESSIONAL account
-> verify contact identity
-> professional application introduction/checklist
-> Step 1: identity
-> Step 2: profession and registration
-> Step 3: qualifications and experience
-> Step 4: practice details
-> Step 5: review and submit profile
-> Step 6: upload required evidence
-> application status hub
-> manual review
-> verified public listing
```

Recommended fields by step:

| Step | Fields |
|------|--------|
| Identity | Legal name, public display name, profile photo later if storage policy is approved |
| Profession | Controlled professional category, regulator/council, registration or licence number, specialty where applicable |
| Qualifications | Qualification entries, awarding institution/year in a later schema if approved, years of experience |
| Practice | Practice/facility name, city, state, country, optional address |
| Evidence | Government identity, current licence/registration evidence, qualification/certification evidence |

The backend currently supports three private document types: `IDENTITY`,
`LICENSE`, and `CERTIFICATION`. The first production flow should require one
accepted submission for each applicable type before the application can be
treated as submitted. Actual verification remains manual/backend-owned.

### Regulator-aware category selection

The professional category must be controlled rather than free text. At minimum,
the product catalog should map supported professions to the relevant Nigerian
regulator, for example:

| Profession | Regulator direction |
|------------|---------------------|
| Medical doctor or dentist | MDCN |
| Nurse or midwife | NMCN |
| Pharmacist | PCN |
| Medical laboratory scientist | MLSCN |
| Radiographer | RRBN |

The full launch catalog must be approved separately. Dietitians, mental-health
professionals, therapists, and other PRD categories must not be mapped to a
guessed regulator or allowed to make unsupported credential claims. They should
remain unavailable or enter an explicit manual-review category until the
product/compliance mapping is accepted.

### Professional access while pending

Recommended boundary:

- `NOT_SUBMITTED`: resume application; not public; cannot receive appointments.
- `PENDING`: show application status and allow safe profile/document review;
  not public; cannot receive appointments.
- `VERIFIED`: public listing and professional scheduling/appointment features
  may become available.
- `REJECTED`: show a safe decision state and product-approved correction or
  support path; never expose internal admin notes by accident.

A pending professional may access account settings, help, and educational/public
content. The normal professional operational dashboard must not imply that the
profile is live or accepting bookings.

## Age, Consent, And Legal Records

The PRD targets adult account holders and separately mentions parents seeking
paediatric guidance. It does not define minor-owned accounts or dependent
profiles. The conservative MVP rule should therefore be:

- CareNet account holders must be at least 18.
- A parent or guardian uses their own adult patient account.
- Child/dependent patient profiles and consent relationships remain unavailable
  until a dedicated product, legal, privacy, and backend contract exists.
- Date of birth validation must not silently invent an age exception.

Terms, privacy, community rules, and online-consultation safety notices must not
be represented by navigation alone. Before production, the backend should record
the accepted document type/version, user, timestamp, and appropriate audit
metadata. Re-consent rules are required when a material document version changes.

Recommended separation:

- Terms of Service and Privacy Notice acceptance belongs to account activation.
- Community standards apply before publishing or participating in community
  features.
- Professional declaration of accurate credentials belongs to application
  submission.
- Consultation consent, limitations, and emergency guidance belong immediately
  before the first relevant consultation/booking action.

The legal text itself requires Nigerian legal/compliance approval. This proposal
defines placement and proof only; it does not draft or approve legal wording.

## Interruption And Resume Contract

This is the most important foundation missing from the current flow.

The frontend should not infer completion from the last route visited. After
registration, sign-in, session restore, or token refresh, it should resolve a
backend-owned readiness snapshot such as:

```text
role
emailVerified
profileStatus: MISSING | DRAFT | COMPLETE
verificationStatus: NOT_SUBMITTED | PENDING | VERIFIED | REJECTED
requiredDocumentTypes
submittedDocumentTypes
nextAction
```

Exact response fields require a backend contract slice. `nextAction` may be
computed by the backend or deterministically by a shared documented contract;
the client must not invent verification authority.

Professional multi-step data should be saved as a server-side draft after each
completed step. The current all-fields-required first `PUT /professionals/me`
contract cannot support durable step-by-step resume and should be deliberately
extended before the final multi-step UI is built. A local-only draft is not the
recommended production authority for credential information.

Required interruption behavior:

- Back preserves completed answers.
- `Save and exit` is available in professional setup.
- App closure resumes at the first incomplete step.
- Session expiry reauthenticates, then resumes the same application.
- Network failure keeps entered values on screen and offers retry.
- Repeated submit/upload operations are idempotent or safely rejected.
- Provider cancellation returns to method selection without creating a local
  success state.
- Existing-email Google collision directs the user to email sign-in and later
  account linking.
- Logout removes local session data but does not delete the backend application
  draft.

## Email Verification Boundary

The PRD requires verified email or phone identity. The backend can request and
confirm email verification, but registration does not currently make verification
a coherent mandatory stage.

Recommended product rule:

- Send/request verification immediately after email/password account creation.
- Allow profile setup and public browsing while the email is pending.
- Require verified email before the first patient booking.
- Require verified email before professional application submission.
- A backend-verified Google email satisfies the email-identity requirement.
- Provide resend, change-email, expiry, and already-verified states.

The enforcement point must be implemented in the backend for protected actions;
a frontend-only gate is not sufficient security.

## Screen And Interaction Standards

- Use a quiet healthcare visual system with clear hierarchy, generous touch
  targets, restrained color, and no marketing-style form cards.
- Ask one focused question or one tightly related group per screen.
- Use `Step n of m` for the professional application only; do not show a dense
  all-step mobile stepper.
- Use controlled selects for profession, regulator, and Nigerian state once the
  catalog is approved. Do not rely on free text for authority-bearing fields.
- Show why sensitive information is requested and whether it is public or
  private.
- Validate on `Continue`/submit, preserve entered values, focus the first error,
  and show field-level messages plus a short summary when several fields fail.
- Include a review-and-change screen before professional submission.
- Separate `Save draft`, `Continue`, and `Submit for verification`; these actions
  must not look or behave interchangeably.
- Document upload must show allowed types/size, progress, retry, cancellation,
  and safe status without exposing signed URLs or storage object keys.
- Support screen readers, text scaling, keyboard traversal, sufficient contrast,
  and stable layouts on small Android devices.
- Design for intermittent Nigerian mobile connectivity: no lost form after a
  request failure and no duplicate account/application creation on retry.

## Error And Recovery Model

| Situation | Required user outcome |
|-----------|-----------------------|
| Invalid field | Preserve all values and identify the exact field/action |
| Duplicate email | Offer sign in or password recovery; do not reveal extra account/provider details |
| Google provider cancelled | Stay on the current step without an error alarm or backend call |
| Google account collision | Sign in with email, then link Google from Account |
| Session expired during setup | Reauthenticate and resume the saved step |
| Backend unavailable | Keep the form, show retry, do not claim save success |
| Upload failed | Keep document type/file choice when safe and allow retry |
| Verification pending | Show status and expectations; do not expose professional features as active |
| Verification rejected | Show product-approved next action; do not display internal review data |

Generic copy remains a safe fallback for unknown server errors, but known
validation and state conflicts should receive specific, non-leaking guidance.

## Backend Work Required Before Final UI

1. Define an onboarding readiness response for authenticated users.
2. Define resumable professional draft semantics and completion requirements.
3. Define required verification document types and application submission
   readiness.
4. Enforce verified-contact gates on patient booking and professional submission.
5. Define rejected/resubmission behavior and owner-safe rejection information.
6. Define controlled profession/regulator/specialty catalogs and versioning.
7. Add audit events for professional application submission and resubmission.
8. Define versioned terms/privacy/professional-declaration acceptance records.
9. Define adult account eligibility and defer dependent/minor profiles explicitly.

These are targeted extensions to the existing auth/profile/verification
foundation, not a broad backend rewrite.

## Recommended Implementation Sequence

### Decision and contract gate

1. Accept or amend this APP-64 proposal.
2. Create a backend decision slice for onboarding readiness, resumable
   professional drafts, verification submission, and contact-verification gates.
3. Implement and test that narrow backend contract before building the final
   professional multi-step UI.

### Frontend slices

1. Auth gateway and role-first entry: welcome, guest browse, create account,
   sign in, role first, then method choice.
2. Account-creation cleanup: email/password collects only auth fields; Google and
   email converge on the same role-specific destination; remove duplicate
   authoritative profile questions from auth.
3. Onboarding readiness resolver: splash/sign-in/refresh route each role to the
   correct missing, pending, rejected, verified, or ready destination.
4. Patient setup and booking gate: optional first-session setup, required
   pre-booking completion, return to intended booking.
5. Professional application shell: introduction plus resumable identity,
   profession, qualification, and practice steps.
6. Professional review, submission, and evidence upload: review-and-change,
   explicit submission, document requirements, safe retry.
7. Professional status hub: not submitted, pending, verified, and rejected
   states with only the features allowed by each state.
8. Auth/onboarding regression and device smoke: email and Google, both roles,
   interruption/resume, expired session, slow/offline recovery, duplicate retry,
   text scaling, and accessibility checks.

Each item remains its own branch/PR slice. Do not combine the entire redesign
into one large implementation PR.

## Proposed Acceptance Decisions

The product lead should accept or amend these decisions before implementation:

1. Role is selected before Google/email signup method.
2. Guest users may browse public verified care; protected actions require auth.
3. Patient setup may be skipped for browsing, but minimum identity and verified
   contact are required before booking.
4. Professional onboarding is a resumable application, not one long form.
5. Professional public listing and appointment operations require backend
   `VERIFIED` status.
6. Email verification is required before patient booking and professional
   application submission, while browsing/setup may continue.
7. Professional categories and regulator mappings use an approved catalog, not
   unrestricted free text.
8. Server-side drafts/readiness are implemented before final professional UI.
9. Pending professionals receive a limited status experience rather than a
   misleading fully operational dashboard.
10. The Nigeria Data Protection Act 2023 and regulator/legal review are explicit
    launch gates; UI completion alone is not a compliance claim.
11. MVP account holders are 18+; child/dependent profiles require a separate
    consent and relationship contract.
12. Terms/privacy and professional declarations are versioned backend records,
    not frontend-only checkboxes or route transitions.

## Out Of Scope For This Proposal

- Runtime Flutter changes
- Backend implementation
- Admin dashboard design
- Payments, payouts, refunds, and commission
- Video, voice, chat, notes, prescriptions, reviews, and emergency escalation
- Production legal wording or legal approval
- Automatic regulator verification
- Final professional category/specialty catalog
- Phone OTP, Facebook, Apple, MFA, and Google unlink
- Production OAuth/release signing

## Review Result Needed

APP-64 is ready for product-lead review when this proposal is presented. It is
not an accepted runtime specification until the product lead approves the twelve
proposed acceptance decisions or records amendments.
