# Auth Onboarding PR Review And Merge Readiness

**Slice:** APP-73
**Date:** 2026-07-18
**Status:** Review/readiness recorded; no runtime behavior changed.

## Purpose

Review the stacked auth/onboarding redesign PR chain after APP-72 regression
proof and decide the safe handoff/merge posture.

This slice does not mark production release readiness and does not merge to
`main` or `master`.

## PR Chain

| Slice | PR | Status | Target | Readiness |
|-------|----|--------|--------|-----------|
| APP-64 | #123 | Merged | `feature/frontend-milestone` | Already merged into the milestone branch |
| APP-65 | #124 | Open draft, clean | `feature/frontend-milestone` | Can be reviewed first; docs/contract slice |
| APP-66 | #125 | Open draft, clean | `feature/frontend-milestone` | Review after APP-65 |
| APP-67 | #126 | Open draft, clean | `feature/frontend-milestone` | Review after APP-66 |
| APP-68 | #127 | Open draft, clean | `feature/frontend-milestone` | Review after APP-67 |
| APP-69 | #128 | Open draft, clean | `feature/frontend-milestone` | Review after APP-68 |
| APP-70 | #129 | Open draft, clean | `feature/frontend-milestone` | Review after APP-69 |
| APP-71 | #130 | Open draft, clean | `feature/frontend-milestone` | Review after APP-70 |
| APP-72 | #131 | Open draft, clean | `feature/frontend-milestone` | Review after APP-71 |

Observed through GitHub CLI:

- APP-65 through APP-72 target `feature/frontend-milestone`
- APP-65 through APP-72 are still draft PRs
- APP-65 through APP-72 currently report clean merge state
- sampled PR checks report no GitHub checks on the branches

## Verification Basis

APP-72 provides the current proof baseline:

- focused APP-66 through APP-71 regression passed 70 tests
- full `flutter test` passed 293 tests
- `flutter analyze` passed
- `git diff --check` passed
- staging-configured debug APK build passed
- device smoke was not claimed because no ADB device was attached

## Readiness Decision

The stacked chain is ready for project-lead review in order, but not automatic
merge.

Recommended order:

1. Review #124 APP-65.
2. Mark #124 ready and merge into `feature/frontend-milestone` if accepted.
3. Repeat one PR at a time through #131.
4. After each merge, confirm the next PR still targets `feature/frontend-milestone`
   and remains clean.
5. Run a final milestone regression after the chain is merged.

## Blockers / Cautions

- GitHub checks are not reported on the sampled PR branches, so merge readiness
  is based on local verification, not GitHub CI proof.
- Real-device APP-72 smoke remains blocked until an Android device is attached
  and authorized.
- Do not merge `feature/frontend-milestone` into `main`/`master` without explicit
  release/handoff approval.
- Do not start new auth/onboarding feature expansion before the PR chain review
  is complete.

## Explicitly Not Complete

- backend readiness endpoint
- return-to-intent booking gate
- phone OTP
- production app links
- server-side professional drafts/resume
- licence expiry/renewal lifecycle
- duplicate regulator identity checks
- rejection reasons and admin review
- public listing activation from mobile UI
- production Google release/iOS proof
- final real-device smoke

## Follow-Up

Next slice:

`APP-74 - Auth onboarding chain final milestone regression`

APP-74 should happen only after the project lead decides which APP-65 through
APP-72 PRs are ready and merges them into `feature/frontend-milestone`.
