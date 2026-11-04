# Phase 1 Operational Readiness

## Current Checkpoint (2026-11-04)

Mobile integration is `040cbd7d033b2cdb7e969623f8e55a38a3b3d9f2` after
docs-only PR #266; exact-head CI `41793512082` and post-merge integration CI
`41798115546` passed. Backend `main` is `2d4b320771479e00ca7034a0859821a6b1fb7863`
after docs-only PR #193; PR-head CI `41802198065` and post-merge CI `41802721952`
passed all three lanes. APP-READY-090 and PR #265 are earlier checkpoints; this
reconciliation does not close the remaining operational gates.

- Cloud cost posture: Cloud SQL `STOPPED`, activation `NEVER`, deletion
  protection enabled; all three Scheduler jobs `PAUSED`; Cloud Run backend,
  admin and messaging have no minimum-instance floor (messaging explicitly
  minScale 0). Cloud Billing and the Billing Budgets API are enabled; no runtime
  service was started for this checkpoint.
- Backend traffic: read-only Cloud Run state shows
  `carenet-backend-staging-be075-candidate` at 100%. The latest ready revision
  is `carenet-backend-staging-be079-expiry-proof` but receives no traffic; the
  latest created revision is `carenet-backend-staging-be079-default-restored`.
  This is not approval to promote a candidate.
- IAM: the Firebase Admin SDK identity's project-wide
  `roles/iam.serviceAccountTokenCreator` grant was narrowed to a self-only
  service-account binding. Read-back confirms zero project binding, one
  self-scoped binding, no such grant on other service-account resources, and
  zero user-managed keys for that identity. Cloud Run does not use that
  identity; the runtime identity's existing self-only signing grant is
  unchanged. This closes only the cross-service-account impersonation finding,
  not the broader least-privilege review.
- Monitoring: 13 policies and the email channel are enabled. All alert records
  observed in the Nov 4 read-back are `CLOSED`. This proves current state, not
  successful delivery for every failure condition. No budget is configured and
  BigQuery billing export is absent, so cost breakdown and budget alerts remain
  unavailable; no monthly cap was invented. The database memory policy is
  enabled with the intended `Usage > 90` for 600s and 60s mean alignment (last
  mutation Oct 23). BE-P1-058 is delivered and backend PR #193 reconciles its
  documentation. Recent samples remain below threshold; no breach or
  condition-triggered notification-delivery proof is claimed.
- Database recovery: a disposable PITR clone was verified and deleted. Time
  from clone submission to completed verification was 56m08s, below the
  provisional 60-minute target for this one run. The latest available restore
  point was about 16m22s before source shutdown; actual RPO and data loss remain
  unknown. No RPO SLO is claimed.
- Admin: Web PR #11 added the authenticated Download action/route; PR #12 added
  browser fixture/flow coverage. Both are merged with CI green, and the
  deployed staging revision is `download-lf-63c089c`. A real-file operator
  download and valid PDF rendering have not been proven. The observed 63-byte
  smoke document failed browser preview; do not approve/reject or overwrite it
  to clear this gate.
- Support/legal: the approved Support page and Terms, Privacy, Account Deletion,
  verification, reset and Android asset-links endpoints returned HTTP 200.
  The approved contact is live. One approved plain test email was sent from
  the disposable alias on Nov 4 and appears in the sender's Sent folder;
  receipt in the recipient mailbox remains unconfirmed.
- Release/device: APP-READY-081 Hosting checks and APP-READY-090 merged CI are
  complete. Play signing/release acceptance, physical Android tests, Apple
  signing/provider setup and Mac/iPhone acceptance remain open.
- Payments: Paystack test activation remains last and requires the single final
  explicit confirmation. The previously exposed test key must not be reused.

APP-READY-082 remains the recorded next operational track. Do not turn this
checkpoint into a provider activation or start short-form content work.

## Scope And Authority

APP-READY-082 remains partially complete. This October 21 handoff reconciles
mobile status with the owning backend/cloud work; it changes no runtime,
provider, dependency, navigation, test or cloud configuration. Earlier dated
audit snapshots are historical. The full readiness program is not complete.
Protected worktrees and archive references remain outside this slice.

## Verified Evidence

- Mobile integration `51c3a2a3353dfe2c6544072300651ec4b23680a4` contains
  APP-READY-081 and its documentation proof. The runtime baseline is 942 tests,
  clean analysis and successful Android build/release gates. Integration
  [CI 39288540689](https://github.com/Carenetmed/Mobile-App/actions/runs/39288540689)
  passed on `1ab1075`; this handoff introduces zero test-inventory changes.
- Canonical staging project remains `project-a96784ee-811c-46ab-a7b`.
  Read-only cloud inspection confirms nine enabled policies: six passive
  API/database/job policies, sanitized release health, and two RTC failure
  policies. There are zero uptime-check configurations. The notification,
  SQL-window-stop and RTC schedules are all paused.
- A controlled sanitized release-health counter produced an OPEN incident and
  a matching alert email receipt. This is not actual crash acceptance or proof
  that every policy delivers mail. The original passive policy definitions
  remain preserved. [Backend PR #158](https://github.com/ridwanmullick/carenet-backend-lab/pull/158)
  and [monitoring contract](https://github.com/ridwanmullick/carenet-backend-lab/blob/main/docs/62-staging-monitoring-and-response.md)
  own that evidence and its limits.
- At the October 21 checkpoint, the API served
  `carenet-backend-staging-00014-jhw` at 100% traffic. This is historical; the
  Nov 4 traffic state is recorded in the current checkpoint above.
  Reconciliation-job configuration is separate from API image promotion.
  [Backend PR #164](https://github.com/ridwanmullick/carenet-backend-lab/pull/164)
  records applied RTC configuration, one authenticated manual Scheduler dispatch,
  empty-work completion and cleanup. Its checkpoint predates the later normal
  tick described below.
- Later on October 21, the normal 16:10 UTC tick dispatched with HTTP 200.
  Execution `carenet-rtc-reconciliation-staging-f7smk` matched the exact parent
  job UID, ownership label and full specification; its creator matched the
  dedicated Scheduler identity. It completed at 16:10:25.877287Z with one
  successful task, no failures or retries. The complete three-entry execution
  log page contained one result: inspected0/closed0/reviewRequired0. This proves
  one normal scheduled empty-work execution, not useful provider cleanup,
  sustained cadence reliability or exactly-once delivery.
- The RTC job has no retained invocation binding and no active execution at
  the verified checkpoint. Failed proof windows were cleaned up; exactly three
  successful terminal executions remain, including the normal tick above.
  An already-expired diagnostic
  binding also returned to an empty policy without running a job.
- A controlled account-security email has provider, mailbox and signed-callback
  delivery evidence. The owning [notification contract](https://github.com/ridwanmullick/carenet-backend-lab/blob/main/docs/56-phase1-transactional-notifications.md)
  keeps live worker retry, FCM and full-worker acceptance distinct.
- At the October 21 checkpoint, SQL was running because the staging API and
  admin required it. The October 19 backup was not fresh restore acceptance,
  continuous RPO proof, permission to stop a required database or a billing cap.

## Remaining Gates

- RTC: useful provider cleanup, sustained cadence, failure-alert delivery and
  queue-age evidence remain open. Invocation IAM and schedules remain paused or
  empty. Unknown access must fail closed. See the owning
  [reconciliation contract](https://github.com/ridwanmullick/carenet-backend-lab/blob/main/docs/66-rtc-reconciliation-serialization.md).
- Worker/provider: natural retry, actual FCM delivery and full-worker execution
  are not proved by local tests, one delivered email or an SDK response alone.
  The worker schedule remains paused.
- Database/security: one PITR restore verification completed within 56m08s, but
  RPO is unknown; the latest restore point preceded shutdown by about 16m22s.
  The live SQL memory condition now matches the intended metric, but the
  backend's stale status note and a real breach/notification proof remain open.
  Remaining least-privilege review also remains open after the narrowly scoped
  Firebase SDK binding repair above. Do not resize, restart or suppress an alert
  based on an unverified diagnosis.
- Admin: IAP/application login and queue access are proved, and Download is
  deployed. Source and mocked-browser tests pass; real valid-file preview,
  download and operator recovery acceptance remain open. Do not approve, reject
  or overwrite the smoke document to clear a gate.
- Support/legal: the approved contact is live and its page returns HTTP 200.
  Mailbox delivery remains unproved; no response hours are promised.
- Release/device: Hosting auth-link checks and merged CI passed. Approved Play
  signing/release acceptance and physical Android proof remain open. iOS still
  requires Apple signing/provider and Mac/iPhone proof.
- Payments: final test-only Paystack activation still requires one explicit
  confirmation. The exposed test key must not be reused. Live payments and
  payouts are not approved by this handoff.

## Verification Boundary

This docs-only reconciliation requires checked evidence links, a focused diff,
one task-table NEXT row, no private addresses or credentials, and
`git diff --check`. Full runtime tests are not newly claimed from documentation
checks. Normal repository CI must pass on the reviewed PR head before merge.
APP-READY-082 stays the single next task; no content, messaging, consultation or
financial product expansion is authorized here.
