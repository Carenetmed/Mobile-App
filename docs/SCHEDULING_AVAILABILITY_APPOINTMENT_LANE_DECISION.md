# Scheduling and appointment next lane decision

**Task:** 52.30
**Status:** Accepted decision before contract/runtime wiring

Purpose: choose the next backend-integration lane after Search public verified
professional listing was wired without local fallback.

This is a decision slice. It does not add runtime scheduling, availability, or
appointment code.

---

## Sources reviewed

- `docs/BACKEND_COMPLETED_SURFACE_WIRING_MAP.md`
- `docs/PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md`
- `docs/DEFERRED_WORK.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\05-api-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\24-appointment-core-regression-plan.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\36-frontend-backend-staging-contract.md`
- `C:\Users\asd\Music\carenet-backend-lab\docs\45-frontend-backend-staging-integration-readiness.md`

---

## Decision

Select scheduling as the next backend-integration lane, starting with
availability and appointment contract boundaries.

Do not continue profile/public-professional expansion as the next runtime lane
because the remaining profile discovery surfaces need contracts that do not
exist yet in the frontend:

- public professional detail should not be faked before a documented
  `GET /professionals/:id` contract exists
- Find Mentor and Specialist Details currently depend on seeded local specialist
  data and must not become fallback backups for Search
- booking requires availability and appointment request contracts, not only a
  public professional list

Do not wire appointment booking directly next. Appointment request depends on
backend-owned availability policy, verified professionals, role-specific auth,
and safe state transitions. The next slice should first define the Flutter
repository/entities/screen boundary for the completed backend availability and
appointment surfaces.

---

## Accepted next lane order

1. Define the scheduling/availability/appointment frontend contract.
2. Add repository/API boundary and focused tests for availability and
   appointments.
3. Wire public availability read into public professional discovery/detail
   surfaces without local fallback.
4. Wire professional own availability management from the existing business
   hours/selected-dates route.
5. Wire patient appointment request only after availability read is available.
6. Wire own appointment list and professional lifecycle actions in small
   follow-up slices.

This order prevents a fake booking UI. If the backend is unavailable or a route
is unsupported, the app should show loading, empty, disabled, or safe error
states instead of seeded booking success.

---

## Next slice

`52.31 - Define Scheduling Availability Appointment Frontend Contract`

Scope:

- Map backend routes into Flutter repository/API boundaries.
- Define entities for availability windows and appointment summaries.
- Decide which existing screens may consume each backend surface.
- Define allowed request payloads and safe response fields.
- Define safe loading/error/empty behavior.
- Preserve the no local fallback rule for backend-wired scheduling data.
- Queue the first runtime/repository slice only after the contract is clear.

Out of scope:

- No runtime route wiring.
- No appointment creation UI changes.
- No availability management UI changes.
- No public professional detail route invention.
- No Find Mentor or Specialist Details replacement.
- No payments, refunds, payouts, notifications, reviews, calls, calendar sync,
  admin override, patient completion, no-show/disputes, notes, prescriptions, or
  medical records.

---

## Deferred work preserved

- public professional detail read
- Find Mentor replacement
- Specialist Details replacement
- live booking confirmation
- appointment payment/refund state
- notifications/reminders
- reviews/ratings
- calls/video/audio
- calendar provider sync
- admin appointment override
- patient completion
- no-show/dispute workflows
- consultation notes, prescriptions, and medical records
- public/stakeholder staging access and production release readiness

---

## Stop conditions

Stop before implementation if:

- a required backend route is not documented
- the UI would need seeded/local backup data to look successful
- the slice would trust client-supplied owner ids, statuses, roles,
  verification state, availability claims, payment state, or calendar state
- the work needs payments, notifications, reviews, calls, calendar sync, admin
  override, medical notes, prescriptions, or production staging access
