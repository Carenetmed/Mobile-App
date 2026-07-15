# Mobile Milestone Handoff And Staging Data Boundary

**Task:** 52.98
**Status:** Accepted decision
**Date:** 2026-07-15

## Purpose

Choose the next lane after the mobile backend integration regression pass.

Task 52.97 proved the already-wired backend mobile milestone at the grouped
Flutter test/analyze level. This decision separates that proof from larger
release, staging, admin, and deferred product work.

## Decision

Proceed next with a frontend milestone handoff package.

Recommended next slice:

`52.99 - Create Mobile Backend Milestone Handoff Package`

The handoff package should summarize:

- what backend-completed mobile surfaces are wired
- what grouped regression evidence passed
- what manual smoke checks still need real staging data
- what is intentionally outside the patient/professional mobile app
- what remains deferred
- what exact backend/staging/release inputs are needed next

## Why Handoff First

The mobile app has reached a useful checkpoint:

- no remaining backend-completed patient/professional mobile surface was found
  waiting for first-pass wiring
- grouped auth/session/account regression passed
- grouped profile/verification regression passed
- grouped discovery/booking regression passed
- grouped scheduling lifecycle regression passed
- focused analyze passed

The next risk is not another mobile route. The next risk is unclear claims.

Creating the handoff package first prevents the milestone from being described
as production-ready, public-staging-ready, admin-complete, or full-product
complete when it is actually a regression-passed frontend/backend mobile
integration milestone.

## Staging Data Boundary

Staging seed data and manual smoke proof are valuable, but they are a separate
lane after the handoff package.

Required staging inputs before a real manual smoke pass:

- usable patient test account
- usable professional test account
- verified public professional profile
- professional availability windows
- appointment request/list/lifecycle data path
- verification upload storage access
- cleanup/reset guidance for repeated smoke runs
- API base URL and app build configuration to use

Without these, the app can still be locally regression-passed, but a public demo
or full manual staging smoke claim would be premature.

## Release Boundary

Release readiness is also separate from the mobile integration milestone.

Release-signing/app-link readiness should wait for a dedicated slice covering:

- Android signing and Play fingerprints
- iOS signing/provisioning if needed
- production OAuth client/fingerprints
- production reset/email-verification app links
- store metadata and release checklist
- production API/environment selection

The current milestone does not claim those.

## Admin Boundary

Admin verification review remains outside this patient/professional Flutter app.

The accepted admin target is a separate dashboard or web console for:

- admin queue
- private signed-read document review
- approve/reject decisions
- rejection reasons
- reviewer audit tools

Do not add hidden admin mode or admin review routes to this mobile milestone.

## Deferred Product Boundary

These remain future product/backend lanes, not missed work in the current mobile
milestone:

- phone/OTP
- MFA/PIN persistence
- Google unlinking and cross-email/recovery policy
- payments, refunds, and payouts
- notifications and reminders
- reviews and ratings
- calls, video, and audio
- calendar provider sync
- consultation notes and prescriptions
- messaging backend
- community backend
- content/publishing backend

## Next Lane

Next:

`52.99 - Create Mobile Backend Milestone Handoff Package`

Out of scope for 52.99:

- no runtime app changes
- no new backend wiring
- no staging data creation
- no production release setup
- no admin dashboard implementation
- no deferred product module implementation

After 52.99, choose one of:

- staging seed-data and smoke proof
- release-signing/app-link readiness
- admin dashboard lane
- deferred product module contract lane
