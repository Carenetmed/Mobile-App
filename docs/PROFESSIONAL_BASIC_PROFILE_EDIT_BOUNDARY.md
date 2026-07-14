# Professional Basic Profile Edit Boundary

Task: 52.82

Status: Accepted boundary

## Context

Task `52.81` selected professional basic profile field editing as the next
backend-completed Flutter surface after the verification upload regression.

The accepted backend contract for `PUT /professionals/me` allows:

- `displayName`
- `category`
- `specialty`
- `bio`

The app already wires:

- professional self-profile read in `manageProfile`
- professional `bio` update through `addDescription`

The remaining visible local profile edit seam is `editYourName`, but that
screen currently has one text field and cannot honestly edit category or
specialty.

## Decision

The next runtime slice should wire `editYourName` as a constrained
professional `displayName` update only.

The runtime slice must:

1. Read the existing professional profile through
   `ProfileRepository.professionalMe`.
2. Require an existing professional profile before saving.
3. Treat an empty professional profile as a safe blocked state, not as profile
   creation.
4. Validate a non-empty display name with the existing minimum length behavior.
5. Call `ProfileRepository.updateProfessionalMe` with:
   - new `displayName`
   - existing `category`
   - existing `specialty`
   - existing `bio`
6. Show success only after the repository call succeeds.
7. Keep safe loading, empty-profile, validation, and backend-failure states.

## Why Display Name Only

`editYourName` has a single field. Updating `category` or `specialty` from that
screen would either require hidden assumptions or new UI. A display-name-only
runtime slice can preserve the existing backend-required category while
removing the current local draft seam.

## Explicitly Deferred

- category editing UI
- specialty editing UI
- professional profile creation
- website persistence
- address/location persistence
- account email, phone, role, or status changes
- verification status or document changes
- availability/business-hours changes
- appointment state changes
- public professional detail endpoint
- payments, reviews, calls, calendar sync, notes, prescriptions
- staging data and production readiness claims

## Required Tests For Runtime Slice

The next runtime slice should add or update focused tests proving:

- `editYourName` reads an existing professional profile and pre-fills the
  backend `displayName`
- valid save sends new `displayName` while preserving existing `category`,
  `specialty`, and `bio`
- empty profile blocks save and does not call `updateProfessionalMe`
- backend save failure shows a safe error and does not show success
- validation failure does not call the repository
- website, address, account, verification, availability, appointment, payment,
  review, call, calendar, note, and prescription data are not included

## Next

Queue `52.83 - Wire Professional Display Name Update From Edit Your Name`.

This should be a runtime slice limited to the existing `editYourName` route and
focused Manage Profile tests. Do not add category/specialty editing or profile
creation in that slice.

