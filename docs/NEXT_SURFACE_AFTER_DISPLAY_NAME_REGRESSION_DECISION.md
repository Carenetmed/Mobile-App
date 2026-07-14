# Next Surface After Display Name Regression Decision

Task: 52.85

Status: Accepted decision

## Context

The professional display-name-only update path is regression-proven for the
current frontend milestone boundary. The current professional profile lane now
has:

- professional self-profile read in `manageProfile`
- professional `bio` update from `addDescription`
- professional `displayName` update from `editYourName`
- focused regression proof for the display-name-only update

The accepted backend professional profile contract still allows `category` and
`specialty`, but the current app does not have a safe category/specialty edit
UI. Website and address remain unsupported by the current professional profile
contract.

## Reviewed Options

| Option | Decision | Reason |
| --- | --- | --- |
| Category/specialty editing | Select boundary decision next | Backend accepts these fields, but the app needs explicit UI/field rules before runtime wiring |
| Professional profile creation | Defer | Existing slices intentionally require an existing professional profile to avoid partial profile creation |
| Website/address persistence | Defer | Current backend professional profile contract does not accept website or address fields |
| More verification upload features | Defer | Checksum, previews, rejection reasons, scanning claims, and admin review need separate provider/admin decisions |
| Admin verification dashboard | Defer | Separate admin role/product surface |
| Scheduling staging smoke | Defer | Still blocked on deliberate backend-owned staging data |
| Patient/account expansion | Defer | Patient name is already wired and regression-proven; auth/account security/phone/email changes need separate contracts |
| Payments/reviews/calls/calendar/notes/prescriptions | Defer | Separate product/backend modules, not profile field editing |

## Decision

Select professional category/specialty editing as the next backend-completed
Flutter surface, but start with a boundary decision before runtime wiring.

Queue:

`52.86 - Define Professional Category Specialty Edit Boundary`

The next slice should decide how the current Manage Profile surface can safely
edit `category` and optional `specialty`, while preserving existing
`displayName` and `bio`, requiring an existing professional profile, and keeping
website/address/account/verification/availability/appointment/payment modules
out of scope.

## Required Boundary Questions For 52.86

- Should category and specialty be edited together in one route or split into
  separate future controls?
- Should an existing route be adapted, or should Manage Profile expose a new
  constrained profile-details edit route?
- Which category values are allowed: free text, existing displayed category,
  or a constrained local list?
- Is specialty optional, and how should clearing specialty behave?
- How should the app preserve existing `displayName` and `bio` when updating
  category/specialty?
- What happens if `GET /professionals/me` returns an empty profile?
- Which validation and safe error states are required?
- Which tests prove no website, address, account identity, verification,
  availability, appointment, payment, review, call, calendar, note,
  prescription, staging, or production data is mixed into the update?

## Explicit Boundaries

The next slice must not implement runtime behavior. It should only define the
safe UI/repository boundary and choose the following implementation slice.

Future runtime work must not:

- create professional profiles from partial UI
- send website or address to `PUT /professionals/me`
- modify account identity, verification, availability, appointment, payment,
  review, call, calendar, note, or prescription data
- invent a public professional detail endpoint
- claim staging or production readiness

## Next

Run `52.86` as a decision-only boundary slice for professional category and
specialty editing. Runtime wiring should only follow after that boundary is
accepted.

