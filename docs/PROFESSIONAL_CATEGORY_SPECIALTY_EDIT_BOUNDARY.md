# Professional Category Specialty Edit Boundary

Task: 52.86

Status: Accepted boundary

## Context

Task `52.85` selected professional category/specialty editing as the next
backend-completed Flutter surface after the display-name regression.

The accepted backend contract for `PUT /professionals/me` allows:

- `displayName`
- `category`
- `specialty`
- `bio`

The app already wires:

- professional self-profile read in `manageProfile`
- professional `bio` update from `addDescription`
- professional `displayName` update from `editYourName`

The current `editYourName` route must remain display-name-only. Category and
specialty need their own constrained edit surface so the app does not hide
multiple backend fields behind a name editor.

## Decision

The next runtime slice should add a constrained professional details edit
surface for `category` and `specialty` together.

The runtime slice should:

1. Add a new route/screen for professional category/specialty editing, reachable
   from Manage Profile Basic.
2. Read the existing professional profile through
   `ProfileRepository.professionalMe`.
3. Require an existing professional profile before saving.
4. Treat an empty professional profile as a safe blocked state, not as profile
   creation.
5. Require a non-empty `category`.
6. Treat `specialty` as optional; an empty specialty should be sent as `null`.
7. Call `ProfileRepository.updateProfessionalMe` with:
   - existing `displayName`
   - new `category`
   - new or cleared `specialty`
   - existing `bio`
8. Show success only after repository success.
9. Keep safe loading, empty-profile, validation, and backend-failure states.

## Category Input Rule

For the first runtime slice, use a free-text category field with local
non-empty validation.

Reason: the current codebase does not have an authoritative backend category
taxonomy or product-approved option list. A fake local taxonomy would create
future rework. A free-text field mirrors the current backend contract while the
backend remains the final validator.

## Why Category And Specialty Together

The current Manage Profile Basic section displays category and specialty
together. The backend update call also treats professional profile fields as one
payload. Editing them together lets the app preserve `displayName` and `bio`
without adding hidden assumptions or mixing profile details with website,
address, availability, or verification.

## Explicitly Deferred

- professional profile creation
- category taxonomy/dropdown rules
- specialty autocomplete or verified specialty taxonomy
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

- Manage Profile exposes a category/specialty edit entry without replacing the
  display-name-only edit path
- the edit screen reads an existing professional profile and pre-fills category
  plus specialty
- valid save sends the new category and specialty while preserving existing
  `displayName` and `bio`
- clearing specialty sends `null`
- empty category blocks save and does not call `updateProfessionalMe`
- empty professional profile blocks save and does not create a profile
- backend save failure shows a safe error and does not show success
- website, address, account, verification, availability, appointment, payment,
  review, call, calendar, note, and prescription data are not included

## Next

Queue `52.87 - Wire Professional Category Specialty Update`.

This should be a runtime slice limited to the new constrained category/specialty
edit surface and focused Manage Profile tests. Do not add profile creation,
website/address persistence, verification changes, or scheduling behavior.

