# Next Surface After Google Linking Regression Decision

**Task:** 52.93
**Status:** Accepted decision
**Date:** 2026-07-15

## Context

`GOOGLE_ACCOUNT_LINKING_REGRESSION.md` proves the constrained Account-hosted
Google linking path. The already-consumed backend-completed mobile surfaces now
include:

- email/password auth, session restore, logout, and current account read
- password reset and email verification token-confirm routes
- Google sign-in and protected Google account linking
- patient self-profile read/name update
- professional self-profile read and scoped profile edits
- professional verification owner list/upload
- public verified professionals in Search, Find Mentor, and Specialist Details
- public availability reads
- professional own availability management
- appointment request, own list, cancel, accept, decline, complete, and
  reschedule

The remaining completed backend surface with meaningful product impact is the
admin verification review surface:

- admin verification queue
- private signed-read for submitted documents
- approve/reject decision routes

This surface is sensitive. It should not be placed into the patient/professional
mobile app by assumption.

## Decision

Select an admin verification review boundary decision as the next lane.

Queue:

`52.94 - Define Admin Verification Review Surface Boundary`

The next slice should decide where admin review belongs and what the first
frontend integration target is. It must not implement runtime admin behavior.

## Why This Is Next

Professional verification upload/list is already wired for professionals, but
the reviewer side remains backend-completed and frontend-unconsumed. Without an
admin/reviewer surface decision, submitted verification documents can be sent
but not reviewed through a frontend workflow.

This is the next backend-completed surface that can reduce product incompletion
without inventing new backend modules such as payments, notifications, reviews,
calls, calendar sync, medical notes, prescriptions, phone/OTP, or MFA.

## Required Questions For 52.94

- Does admin verification review belong in this Flutter app, a separate admin
  dashboard, or a web/admin console?
- Which authenticated roles may access the surface?
- Should the app contain any admin route constants or should admin remain in a
  separate frontend repo?
- What safe document metadata may be displayed?
- How should private signed-read URLs be opened without exposing or persisting
  them?
- What approve/reject states and safe error messages are allowed?
- Should rejection reasons exist now or stay deferred?
- What evidence is needed before any runtime admin route is implemented?

## Explicitly Out Of Scope For 52.93

- no runtime routes
- no admin UI
- no document preview or download
- no signed-read URL handling
- no approve/reject implementation
- no role/permission implementation
- no production/staging claims
- no payments
- no notifications
- no reviews
- no calls
- no calendar sync
- no notes
- no prescriptions
- no phone/OTP
- no MFA

## Deferred Until After Boundary

- admin queue UI
- admin signed-read UI
- admin approve/reject UI
- rejection reason product rules
- admin audit display
- document preview/download handling
- reviewer access model
- production admin hardening

## Next

Run `52.94` as a decision-only boundary slice. Do not add admin runtime behavior
until the target frontend surface and access model are explicitly accepted.
