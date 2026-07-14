# Next Surface After Specialist Details Decision

Task: 52.71

Status: Accepted

## Context

Specialist Details public professional/availability wiring is regression-proven
for the current frontend/backend milestone boundary.

The app now has backend-backed coverage for:

- Search public professional listing
- Search public availability and appointment request
- Specialist Details public professional detail from public listing data
- Specialist Details public availability and appointment request

The next surface should continue reducing visible local provider discovery seams
without starting a larger product module.

## Reviewed Options

| Option | Decision | Reason |
|--------|----------|--------|
| Find Mentor replacement | Select | It is the remaining drawer provider-discovery surface still backed by local mentor cards and local slot chips. It can use existing `ProfileRepository.publicProfessionals` and route to the already-regression-proven Specialist Details backend path. |
| Verification upload/list | Defer | Requires file picker/storage UX, document-state copy, verification-storage assumptions, and larger failure-state coverage. |
| Admin verification dashboard | Defer | Separate role/product surface; not part of the current user-facing provider discovery lane. |
| Scheduling staging data smoke | Defer | Still blocked on deliberate staging patient/professional/verified-professional data and cleanup guidance. |
| Google link/unlink or sign-up providers | Defer | Needs separate auth/product decisions around role selection, linking, unlinking, iOS proof, and release fingerprints. |
| Broader Specialist Details expansion | Defer | Reviews, prices, public detail endpoint, calls, calendar, and payments remain outside the accepted backend contract. |

## Decision

Select Find Mentor public professional listing replacement next.

Queue:

`52.72 - Wire Find Mentor To Public Professionals`

## Next Runtime Boundary

The next slice should:

- keep the existing `findMentor` route
- replace local mentor cards with `ProfileRepository.publicProfessionals`
  where a repository is available
- show safe loading, empty, and error states
- filter backend public professionals by category/specialty/search if the
  existing UI supports those filters
- pass the selected backend public professional id into `specialistDetails`
- keep direct local booking handoff disabled/deferred in the backend path
- keep old local behavior only for local-only test/dev navigation without a
  registered repository

## Out Of Scope

- no new backend route
- no public detail endpoint invention
- no verification upload/list
- no admin dashboard
- no payments
- no notifications
- no reviews/ratings expansion
- no calls/video
- no calendar sync
- no notes, prescriptions, or medical records
- no staging data seeding
- no production release claims

## Stop Conditions

Stop before runtime implementation if:

- Find Mentor cannot resolve backend public professional ids honestly
- the implementation would need a new backend route
- the implementation would need local slot fallback in the backend path
- product scope expands into verification, admin, payment, review, call,
  calendar, notes, prescriptions, staging, or production-release work

## Rationale

Find Mentor is the natural next slice after Specialist Details because it is
the remaining public provider-discovery entry point that still routes from
seeded local cards. Replacing it with backend public professionals lets the
drawer Providers path converge with Search and Specialist Details without
touching larger blocked modules.
