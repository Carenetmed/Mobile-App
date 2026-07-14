# Next Surface After Patient Profile Decision

Task: 52.68

Status: Accepted

## Context

The patient profile lane is now stable for the current milestone boundary:

- Settings/Profile reads backend patient `name`, `age`, and `location`
- Settings/Profile updates backend patient `name` only
- regression proof exists for name-only payload, safe failure, and local-field
  preservation

The next step should consume already-wired backend/repository surfaces without
starting a new product module or reopening blocked staging setup.

## Reviewed Options

| Option | Decision | Reason |
|--------|----------|--------|
| Continue patient profile mutation | Defer | Age/location mutation and username/email/bio persistence need separate product/account decisions |
| Verification upload/list | Defer | Requires file picker/storage UX, verification-storage assumptions, document-state UX, and likely larger test setup |
| Admin verification dashboard | Defer | Admin dashboard is a separate role/product surface, not a mobile provider-detail continuation |
| Scheduling staging smoke data | Defer | Still blocked on deliberate staging patient/professional/verified-professional data and cleanup guidance |
| Google/link/unlink | Defer | Sign-in Google rows are already wired when configured; link/unlink and sign-up role rules need separate auth/product decisions |
| Public professional detail surfaces | Select | Search already uses public verified professionals, public availability, and appointment request boundaries. Find Mentor and Specialist Details remain local/provider-detail surfaces and can be replaced using existing app repository capabilities |

## Decision

Select the public professional detail lane next.

The next runtime slice should start with the existing `specialistDetails` route
because it is currently local, already represents provider-detail selection, and
can be backed by the same public-professional and public-availability data that
Search already consumes.

## Next Runtime Boundary

Queue:

`52.69 - Wire Specialist Details To Public Professional Availability`

The next slice should:

- keep the existing `specialistDetails` route
- pass or resolve a backend public professional from the existing public listing
  context where possible
- show safe loading/error/empty states
- use `ProfileRepository.publicProfessionals` only for public provider fields
- use `SchedulingRepository.publicAvailability` only for public availability
- keep appointment request behavior constrained to existing generated
  availability options if runtime request is included
- avoid local slot fallback after backend-backed data is available

## Out Of Scope

- no new backend route
- no assumed public professional detail endpoint
- no verification upload/list
- no admin dashboard
- no profile creation/edit expansion
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

- `specialistDetails` cannot be wired without inventing a public detail endpoint
- the route cannot receive or resolve a backend professional id honestly
- wiring would require reviews, prices, payments, calls, calendar sync,
  verification, admin behavior, or a fake local fallback
- the screen needs broader UX decisions than provider display plus availability

## Rationale

This continues the already-started public professional discovery/scheduling
lane while avoiding blocked or larger-scope modules. It also reduces visible
local-provider seams in the app by moving a user-facing detail surface toward
the same backend-backed data already used by Search.
