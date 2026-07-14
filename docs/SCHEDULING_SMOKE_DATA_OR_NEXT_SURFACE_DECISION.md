# Scheduling Smoke Data Or Next Surface Decision

Task: 52.60

Status: Accepted decision

## Context

Task `52.59` proved the staging backend is reachable through the
developer-private proxy, the staging-configured Android debug build succeeds,
and protected scheduling routes reject unauthenticated access.

It did not prove the scheduling core end to end because staging does not yet
have the required scheduling test state:

- patient staging account credentials
- professional staging account credentials
- a verified/approved public professional
- public availability windows for that professional
- a safe appointment seed or an app/backend path to create one deliberately
- a rule for whether disposable staging users and appointments may be created

## Decision

Do not create ad hoc scheduling staging data from the Flutter repo.

Keep full scheduling end-to-end staging smoke blocked until a deliberate
backend/staging data setup exists. That setup should be owned outside this
Flutter slice because it mutates staging data and depends on backend identity,
profile verification, availability, and appointment state.

Continue the Flutter milestone by choosing the next backend-completed surface
only after reviewing what can be advanced without fake users, fake seed data, or
dummy success paths.

## Reasoning

Scheduling already has focused local regression proof for:

- public professional listing and public availability reads
- appointment request
- own appointment list
- patient cancellation
- professional accept/decline
- professional completion
- patient/professional reschedule
- professional own availability management
- safe errors and no local fallback behavior

The remaining scheduling confidence gap is staging data, not another Flutter
feature. Creating one-off users or appointments from this repo would make the
result hard to reproduce and would blur whether the app, backend, or staging
setup owns the proof.

## Options Considered

| Option | Decision | Reason |
| --- | --- | --- |
| Create disposable scheduling users/data from Flutter now | Rejected | Would mutate staging without an owned backend/staging data contract and could become hidden test debt |
| Keep scheduling smoke blocked and create a deliberate backend/staging setup later | Accepted | Preserves honest proof and makes end-to-end smoke repeatable |
| Move Flutter to another backend-completed surface immediately | Deferred to next decision | The next surface should be selected deliberately from current docs instead of guessed inside this slice |

## Required Future Scheduling Smoke Data

Before claiming scheduling is end-to-end staging-proven, staging needs:

- one patient account usable by the Flutter app
- one professional account usable by the Flutter app
- a professional profile approved for public listing
- availability windows that generate valid request/reschedule options
- a known appointment path covering request, list, cancel, accept/decline,
  complete, and reschedule
- cleanup or reset guidance so smoke data does not become stale

## Explicit Non-Claims

This decision does not claim:

- scheduling is production-ready
- scheduling is Play Store-ready
- end-to-end scheduling smoke has passed
- verification storage is ready
- admin verification setup belongs in the mobile app
- fake users or local fallback data are acceptable

## Next Slice

Queue `52.61 - Decide Next Backend-Completed Flutter Surface After Scheduling
Smoke Blocker`.

That slice should review the completed backend surface map, deferred-work
register, current profile/verification/auth/account status, and the scheduling
smoke blocker before choosing one narrow next Flutter lane. It should not
implement runtime behavior.
