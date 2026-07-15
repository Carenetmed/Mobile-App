# Admin Verification Review Surface Boundary

**Task:** 52.94
**Status:** Accepted boundary
**Date:** 2026-07-15

## Context

`NEXT_SURFACE_AFTER_GOOGLE_LINKING_REGRESSION_DECISION.md` selected admin
verification review as the next backend-completed surface requiring a boundary
decision.

The backend already exposes:

- `GET /admin/verifications`
- `GET /admin/verifications/:documentId/read-url`
- `POST /admin/verifications/:documentId/decision`

Backend API rules from `carenet-backend-lab/docs/05-api-plan.md`:

- admin review routes require authenticated `ADMIN` or `SUPER_ADMIN`
- the queue returns only pending document metadata and professional profile
  context needed for review triage
- the queue does not return private storage object keys, signed URLs, file
  contents, provider credentials, or approve/reject behavior
- signed-read generates a short-lived signed URL for one verification document
  and returns safe document/professional metadata
- signed-read does not return provider credentials, broad bucket access, raw
  checksum values, or approval mutation behavior
- decisions accept only `APPROVED` or `REJECTED`, update document status and
  professional verification status consistently, and write audit metadata
- decision responses do not return document file contents, storage object keys,
  signed URLs, or provider credentials
- rejection reason persistence remains deferred

## Decision

Admin verification review should not be implemented inside the current
patient/professional Flutter mobile app.

The accepted target surface is a separate admin dashboard or admin web console.
This mobile app may continue to host professional-owned verification upload/list
behavior only.

## Reason

Admin verification review is a reviewer operations workflow with private
document access and account-status impact. Mixing it into the consumer/provider
mobile app would increase route exposure, role complexity, signed URL handling
risk, and product confusion.

The current Flutter app is primarily patient/professional-facing. Keeping admin
review in a separate admin surface gives cleaner access control, audit posture,
desktop-friendly document review, and safer handling of short-lived signed-read
URLs.

## Accepted Admin Surface Requirements

A future admin dashboard/web console may implement the admin review workflow if
it satisfies these boundaries:

- requires authenticated `ADMIN` or `SUPER_ADMIN`
- never trusts role, reviewer id, professional id, document status, provider
  metadata, or verification status from frontend state
- reads the queue through `GET /admin/verifications`
- requests a signed-read URL only for a selected document
- treats signed-read URLs as short-lived secrets
- does not persist signed-read URLs in local storage, logs, analytics, or app
  state beyond the active review interaction
- does not expose private storage object keys, provider credentials, raw
  checksum values, or file contents outside the signed-read interaction
- allows only `APPROVED` or `REJECTED` as decision values
- shows success only after the backend decision route succeeds
- refreshes the queue after a decision
- uses safe errors for unauthorized/forbidden/not-found/expired-read/failure
  cases

## Mobile App Boundary

This Flutter app should not add:

- admin route constants
- admin drawer entries
- admin verification queue screens
- admin document preview/download screens
- admin approve/reject controls
- hidden admin mode
- role-switched admin tooling inside Account/Profile

If the product later requires mobile admin review, that must be a separate
decision slice with explicit risk acceptance and new route/access rules.

## Safe Metadata Boundary

Admin queue and review UI may display only backend-provided safe metadata such
as:

- document id
- document type
- document status
- MIME type
- file size
- checksum presence
- created/updated timestamps
- professional profile context needed for review triage

It must not display or store:

- storage object keys
- bucket names or provider credentials
- raw checksum values
- raw signed URL values as visible text
- access/refresh tokens
- raw auth headers
- audit internals
- private patient data

## Signed-Read Handling

The future admin dashboard should:

- request signed-read only when the reviewer explicitly opens a document
- open the signed URL in a controlled browser/document viewer interaction
- avoid copying the signed URL into visible UI text
- avoid writing signed URLs to local persistence, logs, analytics, crash
  reports, screenshots, or debug traces
- treat expiry as normal and allow the reviewer to request a fresh URL
- require a fresh signed-read request after page reload or long inactivity

## Decision State Boundary

Allowed decisions:

- `APPROVED`
- `REJECTED`

Deferred:

- rejection reason persistence
- appeal workflows
- document resubmission guidance
- reviewer assignment
- escalation/review notes
- admin audit display
- bulk decisions
- file scanning status
- retention/deletion policy UI

## Safe Error Boundary

Future admin UI should map errors safely:

- unauthenticated: `Please sign in again.`
- forbidden/non-admin: `You do not have access to verification review.`
- not found/already reviewed: `This document is no longer available for review.`
- signed-read expired: `Document access expired. Open it again to continue.`
- validation: `This verification decision cannot be applied.`
- network/server/unknown: `Verification review failed. Please try again.`

Raw backend messages, storage provider errors, signed URL internals, document
paths, and audit metadata should not be rendered.

## Evidence Required Before Runtime Admin UI

Before any admin review frontend is implemented:

- admin dashboard/web-console repo or app surface is selected
- admin auth/session strategy is confirmed
- admin route/API client boundary is defined
- signed-read viewer behavior is chosen
- safe metadata fields are documented
- safe error mapping is documented
- rejection reason deferral is acknowledged
- local tests prove queue/read-url/decision behavior without token or URL leaks
- docs/deferred-work records any remaining admin hardening gaps

## Explicitly Out Of Scope

- no runtime admin UI in this Flutter app
- no admin routes in this Flutter app
- no signed-read URL handling in this Flutter app
- no approve/reject implementation in this Flutter app
- no rejection reasons
- no admin audit display
- no bulk review
- no staging data claims
- no production readiness claims
- no payments
- no notifications
- no reviews
- no calls
- no calendar sync
- no notes
- no prescriptions
- no phone/OTP
- no MFA

## Next

Because the admin review surface is intentionally outside this mobile app,
the next mobile-app slice should be a final backend-completed surface checkpoint
that confirms no remaining backend-completed mobile-facing routes are being
missed before choosing either:

1. a separate admin dashboard lane outside this app, or
2. a mobile milestone stabilization/regression lane.
