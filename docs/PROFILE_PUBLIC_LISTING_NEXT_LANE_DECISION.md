# Profile/public professional next lane decision

**Task:** 52.28
**Status:** Accepted decision; Search runtime wiring implemented in 52.29

Purpose: choose the next profile/public-professional runtime lane after
professional self-read and professional bio update are wired.

---

## Current State

Implemented profile runtime wiring:

- `ProfileRepository.professionalMe`
- Manage Profile professional self-read
- `addDescription` existing-professional bio update

Implemented repository boundary but not yet wired to screens:

- `ProfileRepository.patientMe`
- `ProfileRepository.updatePatientMe`
- `ProfileRepository.updateProfessionalMe` for fields beyond `bio`
- `ProfileRepository.publicProfessionals`

Still local:

- `SearchShellPage`
- `FindMentorShellPage`
- `SpecialistDetailsShellPage`
- `SearchLocalStore`

---

## Options Considered

| Option | Decision | Reason |
| --- | --- | --- |
| Public verified professional listing replacement | Choose next | Backend route already exists, is public, and maps cleanly to list-card fields: `displayName`, `category`, `specialty`, `bio`, `verified` |
| Name/category/specialty profile edit UI | Defer | Existing edit-name screen only edits display text and no category/specialty edit UI exists yet; backend update requires `displayName` and `category` |
| Patient profile UI | Defer | Current profile lane has focused on professional surfaces; patient profile UI needs separate product mapping |
| Public professional detail | Defer | No documented `GET /professionals/:id` route is available yet |
| Availability/appointments | Defer | Separate backend lane with availability and appointment lifecycle contracts |

---

## Decision

The next runtime slice should wire public verified professional listing into the
Search specialists surface only.

Recommended next slice:

`52.29 - Wire Public Professional Listing To Search`

Implemented:

- Use `ProfileRepository.publicProfessionals`.
- Map backend public professionals into a small presentation model for
  `SearchShellPage`.
- Replace list-card name/category/specialty/bio data only.
- Keep local category filtering/search behavior if it can be derived from
  public listing fields.
- Show safe loading/error/empty states.
- Do not send auth headers for public listing.
- Do not fall back to `SearchLocalStore` when the backend listing fails; show the
  real error/empty state so integration failures can be debugged.

Follow-up:

`52.30 - Decide Next Backend-Integration Lane`

Do not continue to public detail, Find Mentor, Specialist Details, availability,
appointments, booking, ratings, prices, or payments without a new decision
slice and backend contract check.

---

## Explicitly Out Of Scope For Next Slice

- `GET /professionals/:id` or public detail replacement
- `FindMentorShellPage` replacement
- `SpecialistDetailsShellPage` replacement
- live availability
- appointment request/lifecycle
- booking confirmation
- reviews/ratings
- prices/payments/payouts/refunds
- calls/video/audio
- calendar sync
- verification upload/admin dashboard
- patient profile UI
- profile creation
- name/category/specialty edit UI
- website/address persistence
- notifications/reminders
- notes, prescriptions, medical records

---

## Guardrails

Do not imply that backend public listing provides availability, rating, price,
image, public detail, booking, reviews, or verified documents. Those fields must
remain local, hidden, or explicitly deferred until separate contracts exist.
