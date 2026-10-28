# Production README Current-State Contract

APP-READY-083 keeps the repository entrypoint aligned with the implemented
CareNet Phase 1 application without turning source completion into a production
readiness claim.

## Required statements

The root README must:

- describe CareNet as the active role-aware healthcare marketplace;
- name only backend-owned active Phase 1 surfaces;
- distinguish retained deferred source from active product authority;
- distinguish implemented source and staging evidence from production release;
- identify Android as the first distributable platform and preserve the iOS
  signing/device limitation;
- point contributors to the status, architecture, route-disposition,
  environment, and signing documents without presenting historical route-table
  rows as current runtime authority;
- use `feature/frontend-milestone` as the current pull-request target; and
- prohibit secrets, signing material, private proof artifacts, and generated
  output from Git.

The README must not claim that authentication, appointments, messaging,
notifications, payments, or consultation media are absent. Those statements
became stale after the corresponding backend and mobile milestones shipped.

## Readiness boundary

The README does not prove provider availability, live-payment activation,
production infrastructure, store approval, iOS acceptance, or physical-device
acceptance. Those gates remain authoritative in `CODEBASE_STATUS.md`,
`DEFERRED_WORK.md`, and the release/provider runbooks.

## Change boundary

APP-READY-083 changes documentation only. It does not change runtime source,
routes, dependencies, native projects, environment configuration, signing,
backend contracts, cloud resources, or deferred-source reachability.

`test/documentation/readme_current_state_test.dart` prevents the obsolete
frontend-only description and old pull-request target from returning, checks
the role-aware navigation, authority, deferred-source, platform, release-gate,
and artifact-safety wording, and verifies every local README document link
resolves. Assertions normalize whitespace so harmless Markdown reflow does not
cause a failure.
