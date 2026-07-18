# Identity And Onboarding Open Questions Register

**Slice:** APP-ID-001
**Date:** 2026-07-18
**Status:** Active product register.

This register prevents hidden assumptions. Questions stay here until they are
decided, deliberately deferred, or moved into an implementation slice.

| ID | Question | Why it matters | Recommended MVP answer | Status |
|----|----------|----------------|-------------------------|--------|
| ID-Q001 | Can one login be both patient and professional? | Affects privacy, audit, dashboard routing, and account collisions | No self-service dual-role in MVP; one role per account, dual-role deferred | Recommended |
| ID-Q002 | Can a professional switch to patient mode? | Could mix patient health data with professional verification state | Public browse allowed; full patient profile under same login deferred | Recommended |
| ID-Q003 | What if user chose the wrong role? | Wrong role can trap users or create duplicate accounts | Support/admin correction or approved fresh-account path only | Open |
| ID-Q004 | What if email/Google/phone already exists? | Prevents duplicate identities and account takeover confusion | Backend returns safe collision states; app routes to sign-in/recovery/linking | Recommended |
| ID-Q005 | Can Google display name prefill legal/profile name? | Google names may be fake or casual | No trusted prefill; optional editable suggestion only after explicit approval | Recommended |
| ID-Q006 | What happens to half-completed professional applications? | Professionals will abandon/resume forms; route memory is unsafe | Backend-owned draft/resume state required | Recommended |
| ID-Q007 | What professions are supported at launch? | Unsupported professions can make invalid medical claims | Start with approved Nigeria regulator-backed catalog only | Open |
| ID-Q008 | Which regulator maps to each profession? | Licence requirements differ by profession | Controlled catalog owned by backend/product/compliance | Open |
| ID-Q009 | What licence number formats are valid? | Bad validation can reject real users or accept abuse | Normalize and basic character/length checks first; authoritative format by regulator later | Open |
| ID-Q010 | Is licence expiry required? | Current registration must be valid/current under PRD | Required where document/regulator includes expiry or renewal | Recommended |
| ID-Q011 | What evidence is required per profession? | Verification cannot be generic for every profession | Identity + licence/registration + qualification evidence as baseline | Recommended |
| ID-Q012 | Can rejected professionals resubmit? | Needed for typo/correction recovery | Allow only through backend-controlled correction path | Open |
| ID-Q013 | How are duplicate licence numbers handled? | Fraud and duplicate public listings | Block or manual-review duplicate regulator + registration tuple | Recommended |
| ID-Q014 | Are patient diseases collected in onboarding? | Sensitive medical data needs consent and structure | No; use controlled health interests only until health-intake contract | Recommended |
| ID-Q015 | Are minors/dependents supported? | Parents are in PRD, but minor accounts are legally sensitive | Adult account only; dependent profiles deferred | Recommended |
| ID-Q016 | Which Nigerian locations are supported? | Free text creates unusable discovery/filtering data | Nigeria-first controlled country/state/city/LGA catalog | Recommended |
| ID-Q017 | What can pending professionals access? | Avoids false public/booking readiness | Account/help/status/document upload only; no live public booking dashboard | Recommended |
| ID-Q018 | What happens when verification expires/suspends? | PRD requires current registration | Remove public booking ability until renewal/review policy | Recommended |
| ID-Q019 | What legal/consent proofs are required? | Navigation/check boxes are not enough for production | Backend records accepted document version/timestamp | Open |
| ID-Q020 | What support path exists for locked states? | Users need recovery without unsafe self-override | Support/admin workflow required before production launch | Open |

## Register Rule

If a future slice hits an identity/onboarding uncertainty that is not in this
table, add it here before implementing. Do not solve serious identity,
professional-verification, legal, or patient-health questions by UI copy alone.
