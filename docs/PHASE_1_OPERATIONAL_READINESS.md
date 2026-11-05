# Phase 1 Operational Readiness

## Current Checkpoint (2026-11-05)

Mobile integration is `09a3e1c3ab3c7983aba7a2cfdf331608dd00dea6` after
APP-READY-096 docs-only PR #276; post-merge integration CI `42031227938` passed
1,364 tests plus analyzer, debug APK, Android release lint, signing, and
environment regressions. APP-READY-097 adds two local source-path tests for
sanitized diagnostics; all 1,366 tests and analysis pass. Local APK packaging
ran out of E: disk space while stripping native libraries; exact-head CI remains
the APK gate.
Backend `main` is `1e2072bf2520b387d3dcc28f32918c21a86ad880` after docs-only
PR #194; PR-head CI `41982489735` and post-merge CI `41982963454` passed all
three lanes. APP-READY-090 and PR #265 are earlier checkpoints; this
reconciliation does not close the remaining operational gates.

- Cloud cost posture: Cloud SQL was briefly enabled for the Nov 5 admin proof
  and is now `STOPPED`, activation `NEVER`, deletion
  protection enabled; all three Scheduler jobs `PAUSED`; Cloud Run backend,
  admin and messaging have no minimum-instance floor (messaging explicitly
  minScale 0). Cloud Billing and the Billing Budgets API are enabled. Firebase
  Hosting's control-plane API is enabled for static pages. The admin revision
  was updated as detailed below; backend and messaging were not deployed or
  scaled up, and no service has a minimum-instance floor.
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
- Monitoring: 13 policies and the email channel are enabled; all 13 policies
  reference the approved operations channel. The user confirmed the firing
  email from a bounded test-only canary policy on existing staging-admin
  request metrics; that temporary policy was deleted. Separately, nine bounded
  API Gateway readiness GETs while Cloud SQL was intentionally stopped produced
  backend 503s and crossed the existing API 5xx threshold (aligned count 3,
  threshold >2), opening its incident. The incident auto-closed while SQL
  remained stopped. A later bounded recovery window waited until the complete
  Cloud SQL start operation finished, then one `GET /health/ready` returned
  HTTP 200 with database, migrations, email, Google auth, and verification
  storage all healthy. SQL was returned to `STOPPED/NEVER`; schedulers remained
  paused and no Cloud Run traffic or database rows changed. This proves one
  controlled recovery, not continuous availability or natural-outage behavior.
  Gmail confirms the real-policy firing and resolved emails for this incident
  arrived at `2026-11-04T19:55:21Z` and `2026-11-04T20:00:21Z`; this proves one
  incident's delivery, not every policy. The earlier 503 exercise was controlled,
  not a natural outage. The original 13 policies remain. No budget is
  configured and BigQuery billing export is absent, so cost breakdown and budget alerts remain
  unavailable; no monthly cap was invented. The database memory policy is
  enabled with the intended `Usage > 90` for 600s and 60s mean alignment (last
  mutation Oct 23). BE-P1-058 is delivered; backend PR #194 records the
  controlled 5xx exercise. Recent samples remain below threshold; no real memory breach or
  memory-policy notification delivery is claimed.
- Database recovery: a disposable PITR clone was verified and deleted. Time
  from clone submission to completed verification was 56m08s, below the
  provisional 60-minute target for this one run. The latest available restore
  point was about 16m22s before source shutdown; actual RPO and data loss remain
  unknown. No RPO SLO is claimed.
- Admin: Web PR #16 merged as `2a3f299f6cc00779b2d7625a0c60339e83551595`;
  post-merge CI `42000423597` passed. The valid one-page mock PDF receives
  HTTP 200 and `application/pdf` in the browser test, but this proves neither
  visual rendering in Chromium nor preview/download of a real staging upload.
  PR #16 changed only tests/docs and did not redeploy runtime. Web PR #15 main
  `f511d6a36d69157eed239a77c73d9253e57d8e7e` passed post-merge CI
  `41927227034`. Cloud Build
  `caace09e-6c85-4a48-b05e-d62b66575785` built the merged source; staging now
  serves digest `sha256:bcf9814146b3cdf2008487ef61623d331ab0d18859574e753a4ad33041e61cc7`
  in revision `carenet-admin-staging-00008-cig` at 100% traffic. The revision
  is Ready/ContainerHealthy and CI's container smoke served `/admin`. The CLI
  check reached IAP's OAuth redirect, so operator visual confirmation of the
  updated sign-in copy remains open. The operator previously confirmed admin
  sign-in and one document download during a bounded SQL window; byte integrity
  and valid PDF rendering are still unproved. Do not approve/reject or overwrite
  the observed 63-byte smoke document.
- Support/legal: the default Firebase Hosting site
  `https://project-a96784ee-811c-46ab-a7b.web.app` serves the approved Support
  page and Terms, Privacy, Account Deletion,
  verification, reset and Android asset-links endpoints returned HTTP 200.
  The approved contact is live. One approved plain test email was sent from
  the disposable alias on Nov 4; the owner confirmed it arrived in the support
  mailbox. No response hours or times are promised.
- Release/device: APP-READY-081 Hosting checks and APP-READY-090 merged CI are
  complete. Play signing/release acceptance, physical Android tests, Apple
  signing/provider setup and Mac/iPhone acceptance remain open.
- Payments: Paystack test activation remains last and requires the single final
  explicit confirmation. The previously exposed test key must not be reused.

## Live Alert Policy Inventory (Read-Only, 2026-11-05)

Read-only Cloud Monitoring inspection found 13 enabled policies, each
referencing the same approved email channel. Two have controlled alert-delivery
evidence; eleven are configuration-only. The separately created test canary
was deleted and is not counted among these 13.

| Policy | Live condition | Evidence status |
| --- | --- | --- |
| API server errors | Cloud Run 5xx request count >2 over a 5-minute sum | One controlled SQL-off incident fired and resolved; both real-policy emails were found in Gmail. |
| Database memory pressure | Cloud SQL `Usage` >90% for 600 seconds, 60-second mean | Configuration verified; no real breach or delivery proof. SQL is currently stopped. |
| Database disk pressure | Cloud SQL disk utilization >80% for 300 seconds, 60-second mean | Configuration verified; no threshold event or delivery proof. |
| RTC scheduler dispatch failed | Error-severity log for the RTC reconciliation Scheduler job | Configuration verified; no matching incident or delivery proof. The job is paused. |
| Sanitized mobile release-health report | Sanitized release-health counter above zero | One controlled counter event opened an incident and produced a matching email. This is not native-crash acceptance. |
| API p95 latency | Cloud Run request latency p95 >3,000 ms for 300 seconds | Configuration verified; no threshold event or delivery proof. |
| Notification deliveries overdue or abandoned | Observer log: due work >300 seconds late, stale claim, or unclaimed processing | Configuration verified; no matching incident or delivery proof. Observer schedule is paused. |
| Notification observer execution failed | Observer Cloud Run Job execution result is not succeeded | Configuration verified; no matching incident or delivery proof. Observer schedule is paused. |
| RTC execution failed | RTC reconciliation Cloud Run Job execution result is not succeeded | Configuration verified; no matching incident or delivery proof. RTC schedule is paused. |
| Notification events overdue or abandoned | Observer log: due work >300 seconds late, stale claim, or unclaimed processing | Configuration verified; no matching incident or delivery proof. Observer schedule is paused. |
| Database CPU pressure | Cloud SQL CPU utilization >85% for 600 seconds, 60-second mean | Configuration verified; no threshold event or delivery proof. SQL is currently stopped. |
| Staging job failure | Notification-worker or migration Cloud Run Job execution result is not succeeded | Configuration verified; no matching incident or delivery proof. |
| Notification reminders overdue or abandoned | Observer log: due work >300 seconds late, stale claim, or unclaimed processing | Configuration verified; no matching incident or delivery proof. Observer schedule is paused. |

This inventory proves current policy configuration and channel references, not
end-to-end delivery for all conditions. Do not deliberately induce the eleven
unobserved conditions, start paused workers, or enable recurring schedules just
to produce test alerts; obtain a bounded proof plan before changing operational
state. The metric conditions do not configure `evaluationMissingData`; an absent
metric is therefore not evidence of a healthy system. Four policies use a
30-minute auto-close and nine use 60 minutes. Only the RTC scheduler-dispatch,
sanitized release-health, and RTC-execution policies explicitly list an
`OPENED` notification prompt; the release-health policy also has a 60-minute
renotify interval. The current month cost report is available to the approved Billing
Viewer in [Google Cloud Billing Reports](https://console.cloud.google.com/billing/019357-62ECE6-84D214/reports?project=project-a96784ee-811c-46ab-a7b).
The CLI has no spend-report command; the billing account currently has no
budget, and no BigQuery dataset was found in the canonical project. Existing
documentation records that billing export is not configured. Actual current
spend has not been read in this checkpoint, so no cap or forecast is claimed.

APP-READY-082 remains the recorded next operational track. Do not turn this
checkpoint into a provider activation or start short-form content work.
APP-READY-097's fake-transport test proves only the local source path; deployed
admission, logs/retention, real mobile submission, and native crash behavior
remain unproved.

## Scope And Authority

APP-READY-082 remains partially complete. This November 5 handoff reconciles
mobile status with current Hosting, monitoring and operator evidence. It
changed no app runtime, provider, dependency, navigation, or deployed service
configuration. A bounded Cloud SQL recovery proof was run and the instance was
returned to its prior `STOPPED/NEVER` state; no database rows were changed.
Earlier dated
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
- Admin: IAP, CareNet application login and queue access are proved, and
  Download is deployed. The operator confirmed one staging document download
  on Nov 5; byte integrity, valid-file preview and operator recovery remain
  open. Do not approve, reject or overwrite the smoke document to clear this
  gate.
- Support/legal: the approved contact is live and its page returns HTTP 200.
  The owner confirmed the approved mailbox test arrived; no response hours are
  promised.
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
