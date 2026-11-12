# Phase 1 Operational Readiness

## Current Checkpoint (2026-11-13)

Mobile integration is `d97e781194845427b2a996424e583f14f56031b3` after PR #287.
PR #287 reviewed head `1752dc660e0ec18c51e39f7a7b34594d19f03071` passed PR CI
`43270653477`; merged-result CI `43273323794` passed on the exact merge SHA.
The workflow passed 1,423 tests, analysis, debug APK, Android release lint,
protected signing, and release-environment regressions. PR #287 changed six
documentation/test files, changed no runtime code, and did not change test
inventory. No tests were removed, skipped, disabled, or weakened. PR #286's
previous integration was `e3ccafbc7dd2e831f4fc035166ee1d160443dacf`; its head
`bc757266fbb322d55f7aa47fe3eb39f97387b839` passed run `43155362903`.
APP-P1-007B PR #285's reviewed head
`c6178f3df557716e0feaa67da3b3a088bbc81f04` passed both PR CI lanes;
merged-result runs `43148540818` and `43148540838` passed on merge SHA
`83f2dfb095b022f1d9dc41952ae0ec13b4557180` and added 29 tests over its
1,394-test base.
Doctor authoring (#284) and the patient reader (#285) are implemented, but
public education delivery remains disabled pending media storage/IAM, reviewer
preview, content safety/retention/appeals, abuse controls, and an explicit
launch gate. The backend contract uses private Google Cloud Storage with
short-lived signed playback URLs. No Cloudflare Stream integration is
configured in the inspected CareNet staging runtime; short-form hosting has
not been activated. Backend `main` for the
education contracts is `431094b429581e62e5f5f21acdaae693031b7859`.

Nov 12 controlled database recovery proof: automated backups and PITR are
enabled with seven-day transaction-log retention; the newest successful
automated backup started `2026-11-09T20:28:51.567Z`. Eleven existing
actorless/subjectless `STAGING_RPO_PROBE` rows formed one ordered sequence. A
one-use Cloud SQL clone restored at `2026-11-09T23:41:46.171Z`, exactly five
minutes before sequence 11. The clone contained sequence 1 and excluded
sequences 2-11; actor, subject, and role fields were null. This proves one
controlled five-minute PITR cut point, not continuous RPO or an RPO SLO. The
clone was deleted; its inherited deletion protection was disabled only on that
clone. Source activation remains `NEVER`; the latest Cloud SQL API read reports
`STOPPED` (an earlier `RUNNABLE`/`NEVER` observation no longer reproduces).
No source change was made during this read-only inventory.

Fresh Cloud Run inventory lists admin, backend, and messaging staging services.
Only `carenet-backend-staging` declares the Cloud SQL attachment; admin calls
the API Gateway and messaging points to the backend. Admin default percentage
traffic is 100% on `carenet-admin-staging-00009-4t7`; the previously checked
download revision `carenet-admin-staging-00008-cig` remains tagged
`web-ready-011`. Its feature parity with the latest default revision and
current valid-file preview/download have not been rechecked. No positive service-level
or revision-level minimum instance setting was found across the three services
and their listed revisions (messaging explicitly sets service min to zero).
This means there is no configured idle minimum-instance floor; it does not
disable request-triggered instances or prevent usage charges. All three Cloud
Scheduler jobs remain paused. The backend's default percentage allocation is
100% to `carenet-backend-staging-be075-candidate`. Tagged revisions remain
independently addressable subject to their invoker IAM. No
revision was promoted. The backend service IAM lists only the gateway and
messaging-ingress service accounts as invokers, with no project-level
`run.invoker` binding found. The messaging service separately grants
`allUsers` `roles/run.invoker`; its WebSocket protocol requires an application
authentication frame and closes unauthenticated connections, but public
invocation can still incur request-based usage. Keep messaging ingress abuse
and cost controls open; it was not disabled because the application uses it.

Current Cloud SQL settings are: deletion protection enabled, backups/PITR with
seven-day transaction-log retention, connector enforcement `REQUIRED`,
`sslMode=ENCRYPTED_ONLY`, public IPv4 enabled, no private IP, and zero
authorized networks. `requireSsl=false` is the compatible legacy PostgreSQL
pair for `ENCRYPTED_ONLY`, not evidence that this setting allows plaintext.
The backend Cloud Run service declares the Cloud SQL connector attachment, and
its runtime service account has `roles/cloudsql.client`. Google documents that
connector traffic is TLS-encrypted and identity-verified and that required
connector enforcement rejects direct database connections
([SSL mode](https://docs.cloud.google.com/sql/docs/postgres/configure-ssl-instance),
[connector enforcement](https://docs.cloud.google.com/sql/docs/postgres/language-connectors)).
The public IP is still allocated and private IP is absent; the secret-backed
`DATABASE_URL` was not read, and the database is stopped, so a live runtime
connection was not retested. The remaining database review is limited to that
networking/deployment boundary and continuous recovery objectives, not the
legacy `requireSsl` field alone.

APP-READY-082 remains partial; exact-policy alert coverage, production liveness
window, actual spend/billing visibility, continuous RPO/SLO, provider/worker
operations, valid document preview, release/device, iOS, and separately
approved test-only Paystack gates remain.

## Previous Checkpoint (2026-11-09)

Mobile integration is `00a7021b60c620e1f4fae25fbce405ce17f322ad` after
APP-READY-102 PR #282. Reviewed head `260c8cec0d643498d328bcf18d1ee3bba4b9fe94`
passed PR CI `42570975195`; merged-result CI `42572846070` passed with 1,366
tests and configured Android gates. PR #282 changed six documentation/test
files without changing test inventory. The previous checkpoint was
`3d447f7d1e78c1bd32007b3038bef4b6b204c9b9` after APP-READY-101.
APP-READY-101 PR #281. Reviewed head
`bb8b117fe5e0741ceb28bb29af0b716cba1efade` passed PR-head CI `42091108978`;
merged-result CI `42093709035` passed on the exact merge SHA. The merged
workflow passed all 1,366 tests, analyzer, debug APK, Android release lint,
signing, and release-environment regressions. PR #281 changed six
documentation/test files and no test inventory. APP-READY-100 PR #280's
reviewed head `e6912068a722005e0a8b8341b9a6a8b66a8e9eea` passed PR CI
`42081173591`; merged-result CI `42084055217` passed on its exact merge SHA.
APP-READY-097 remains the only recent runtime-test increase: +2 over
the 1,364-test base. No tests were removed, skipped, disabled or weakened.
Local APK packaging had hit E: drive exhaustion; CI verified the APK.
Backend `main` is `1e2072bf2520b387d3dcc28f32918c21a86ad880` after docs-only
PR #194; PR-head CI `41982489735` and post-merge CI `41982963454` passed all
three lanes. APP-READY-090 and PR #265 are earlier checkpoints; this
reconciliation does not close the remaining operational gates.

- Cloud cost posture: Cloud SQL was briefly enabled for the Nov 5 admin proof
  and is now `STOPPED`, activation `NEVER`, deletion
  protection enabled; all three Scheduler jobs `PAUSED`; no positive
  service-level or revision-level Cloud Run minimum-instance setting was found.
  This is not the same as disabling request-based services. Cloud Billing and
  the Billing Budgets API are enabled. Firebase
  Hosting's control-plane API is enabled for static pages. The admin revision
  was updated as detailed below; backend and messaging were not deployed or
  scaled up, and no positive service/revision min-instance setting was found.
- Backend traffic: the default percentage allocation is 100% to
  `carenet-backend-staging-be075-candidate`. Other revisions retain tagged URLs
  and are independently addressable subject to invoker IAM; 100% does not mean
  tagged revisions are unreachable. The latest ready revision is
  `carenet-backend-staging-be079-expiry-proof`; the latest created revision is
  `carenet-backend-staging-be079-default-restored`. This is not approval to
  promote a candidate.
- IAM: the Firebase Admin SDK identity's project-wide
  `roles/iam.serviceAccountTokenCreator` grant was narrowed to a self-only
  service-account binding. Read-back confirms zero project binding, one
  self-scoped binding, no such grant on other service-account resources, and
  zero user-managed keys for that identity. Cloud Run does not use that
  identity; the runtime identity's existing self-only signing grant is
  unchanged. This closes only the cross-service-account impersonation finding,
  not the broader least-privilege review.
- Monitoring: the Nov 9 snapshot records 14 ongoing operational policies. The
  Nov 13 read-only inventory found 17 enabled policies total, all referencing
  the approved channel: those 14 plus three expired BE-P1-072 SQL-window
  policies. The user confirmed the firing
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
  not a natural outage. The API p95 policy separately fired at
  `2026-11-05T10:48:12Z` with a measured value of 11,457.57 ms against 3,000 ms
  and response class 5xx / status 503. Its alert email arrived; the resolved
  email at `2026-11-05T11:46:07Z` says the latency metric was missing and the
  incident lasted 57m55s. The policy has no `evaluationMissingData` setting, so
  this is alert-delivery evidence, not evidence the service recovered. Its
  timing overlaps the controlled SQL-off/recovery window; attribution to that
  exercise is an inference, not an independently proven request correlation.
  A five-minute HTTPS uptime check named `CareNet staging backend liveness`
  now checks API gateway `/health` in Asia-Pacific, Europe and US-Iowa. It
  requires HTTP 200 and JSON `status=ok`; current samples pass from all three
  regions. Its alert requires at least two regions failing persistently and
  treats prolonged missing check data as unhealthy. A bounded synthetic test
  pointed only the monitor at a nonexistent path, then produced firing and
  resolved emails through a temporary 60-second policy on the same uptime
  metric and approved channel at `2026-11-05T19:57:33Z` and
  `2026-11-05T19:58:15Z`. The test policy was deleted and `/health` restored;
  fresh samples passed in all three regions. This proves signal/channel email
  delivery, not the production policy's 20-minute alignment plus 300-second
  duration. This is an API liveness signal, not database readiness.
  The original 13 policies remain alongside the new policy. A project-scoped monthly budget alert is
  configured at $31.75 USD for the CareNet project (approximately ₹3,000
  at the Nov 5 mid-market rate), with 50%, 90%, and 100% current-spend email
  thresholds to the approved operations channel. This is an alert, not a spend
  cap or automatic shutdown. BigQuery billing export is absent and actual spend
  remains unread. The database memory policy is
  enabled with the intended `Usage > 90` for 600s and 60s mean alignment (last
  mutation Oct 23). BE-P1-058 is delivered; backend PR #194 records the
  controlled 5xx exercise. Recent samples remain below threshold; no real memory breach or
  memory-policy notification delivery is claimed.
- Historical Nov 5 database recovery: one disposable PITR clone completed
  verification in 56m08s; that earlier run did not establish RPO. The Nov 12
  controlled five-minute cut-point result is recorded in the current checkpoint
  above. Neither run establishes a continuous RPO SLO.
- Current database configuration (read-only, Nov 5): Cloud SQL is `STOPPED`,
  activation `NEVER`, deletion protection on, automated backups and PITR enabled,
  with seven retained backups. The newest successful automated backup is
  `2026-10-27T18:00:00Z`; it is not a fresh Nov 5 recovery point. Public IPv4
  remains assigned, private IP is not configured, no authorized network entries
  are configured, and `requireSsl` is false. This is a security/connectivity
  review item, not authorization to change networking or start the instance.
- Admin: Web PR #16 merged as `2a3f299f6cc00779b2d7625a0c60339e83551595`;
  post-merge CI `42000423597` passed. The valid one-page mock PDF receives
  HTTP 200 and `application/pdf` in the browser test, but this proves neither
  visual rendering in Chromium nor preview/download of a real staging upload.
  PR #16 changed only tests/docs and did not redeploy runtime. Web PR #15 main
  `f511d6a36d69157eed239a77c73d9253e57d8e7e` passed post-merge CI
  `41927227034`. Cloud Build
  `caace09e-6c85-4a48-b05e-d62b66575785` built the merged source; staging now
  served digest `sha256:bcf9814146b3cdf2008487ef61623d331ab0d18859574e753a4ad33041e61cc7`
  from revision `carenet-admin-staging-00008-cig` at the Nov 5 read. The Nov 13
  inventory shows default traffic on `carenet-admin-staging-00009-4t7` and keeps
  `00008-cig` under tag `web-ready-011`; latest-revision feature parity remains
  unverified. The old revision was Ready/ContainerHealthy and CI's smoke served
  `/admin`. The CLI
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

APP-READY-100 adds one five-minute, three-region HTTPS API liveness check and an
enabled alert policy; current checker samples pass. A temporary short-window
policy on the same metric and channel delivered firing and resolved messages;
the production policy's full evaluation window remains untested. The monthly
project budget is `$31.75 USD` (about `INR
3,000`), with 50%, 90%, and 100% current-spend notifications; it is not a cap.
The budget object was read back after the owner selected INR 3,000. Actual
current spend is still unread.

## Live Alert Policy Inventory (Read-Only, 2026-11-09)

The Nov 9 Cloud Monitoring snapshot found 14 persistent operational policies,
each referencing the same approved email channel. Three have controlled exact-policy
alert-email evidence; eleven are configuration-only. A separate temporary
short-window policy on the liveness metric produced firing and recovery emails
to that channel and was deleted; it is not counted among the 14. The check has
fresh passing three-region samples. The production liveness policy's complete
evaluation window has not been exercised.

| Policy | Live condition | Evidence status |
| --- | --- | --- |
| API server errors | Cloud Run 5xx request count >2 over a 5-minute sum | One controlled SQL-off incident fired and resolved; both real-policy emails were found in Gmail. |
| Database memory pressure | Cloud SQL `Usage` >90% for 600 seconds, 60-second mean | Configuration verified; no real breach or delivery proof. SQL is currently stopped. |
| Database disk pressure | Cloud SQL disk utilization >80% for 300 seconds, 60-second mean | Configuration verified; no threshold event or delivery proof. |
| RTC scheduler dispatch failed | Error-severity log for the RTC reconciliation Scheduler job | Configuration verified; no matching incident or delivery proof. The job is paused. |
| Sanitized mobile release-health report | Sanitized release-health counter above zero | One controlled counter event opened an incident and produced a matching email. This is not native-crash acceptance. |
| API p95 latency | Cloud Run request latency p95 >3,000 ms for 300 seconds | Fired at 11,457.57 ms on 503 responses and delivered email; resolved after 57m55s because metric data became missing. Delivery is proved, service recovery is not. |
| API gateway liveness | HTTPS `/health` returns HTTP 200 with JSON `status=ok`; check runs every 5 minutes from three regions | Fresh samples pass in Asia-Pacific, Europe and US-Iowa. A deleted short-window policy on this metric delivered firing and resolved email; production policy's 20-minute alignment/300-second duration remains untested. Prolonged missing check data is active. |
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
state. The original 13 metric policies leave `evaluationMissingData` unset; the
new uptime policy explicitly treats prolonged missing check data as active.
Missing metrics in the original policies are not proof of health. Four of the
original policies use a 30-minute auto-close and nine use 60 minutes. Only the RTC scheduler-dispatch,
sanitized release-health, and RTC-execution policies explicitly list an
`OPENED` notification prompt; the release-health policy also has a 60-minute
renotify interval. The current month cost report is available to the approved
Billing Viewer in [Google Cloud Billing Reports](https://console.cloud.google.com/billing/019357-62ECE6-84D214/reports?project=project-a96784ee-811c-46ab-a7b).
The project-scoped $31.75 USD monthly budget alert sends current-spend notices
at 50%, 90%, and 100%; it is not a hard cap. The CLI has no spend-report
command, and no BigQuery dataset or export was found. Actual current spend has
not been read in this checkpoint, so no cost forecast is claimed.

### Latest read-only inventory reconciliation (2026-11-13)

The current GCP read-back found 17 enabled policies, all referencing the same
approved notification channel: the 14 ongoing operational policies in the
Nov 9 snapshot above plus three retained BE-P1-072 SQL-shutdown window
policies scoped to window `8045dc20b77b18991f75740b6a0a8977`:

- `SQL shutdown execution FAILED`
- `SQL shutdown expected launch unobserved`
- `SQL shutdown shutdown completion unobserved`

Their PromQL upper time bound expired at
`2026-11-09T23:54:20Z`. They remain enabled; expiry did not delete them. They
are not included in the operational email-evidence denominator: controlled
delivery evidence is 3/14 ongoing policies. No Cloud Monitoring policy was
modified during this read-only check.

APP-READY-082 remains the recorded next operational track. Doctor authoring
and the patient reader are now merged; do not enable the public-content flag or
provision media until the separate storage, moderation, safety, retention,
abuse-control, and launch gates are proven. Do not turn this checkpoint into a
provider activation.
APP-READY-097 is merged; its fake-transport test proves only the local source
path. Deployed admission, logs/retention, real mobile submission, and native
crash behavior remain unproved.

## Scope And Authority

APP-READY-082 remains partially complete. This November 5 handoff reconciles
mobile status with current Hosting, monitoring and operator evidence. PR #279
changed only documentation and a regression test. After the merge, one
project-scoped HTTPS uptime check and alert policy were added; no app runtime,
provider, dependency, navigation, Cloud SQL or Scheduler configuration changed.
A bounded Cloud SQL recovery proof was run and the instance was returned to its
prior `STOPPED/NEVER` state; no database rows were changed.
Earlier dated
audit snapshots are historical. The full readiness program is not complete.
Protected worktrees and archive references remain outside this slice.

## Historical Verified Evidence

The following dated implementation records predate the current checkpoint
above and are retained for provenance. In particular, their earlier alert
counts and zero-uptime-check snapshot are superseded by the current 14-policy,
one-uptime-check state.

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
- Database/security: a controlled five-minute PITR cut point was verified on
  Nov 12, but continuous RPO/SLO remains unproved. Cloud SQL enforces connector
  use and `ENCRYPTED_ONLY` TLS; the legacy PostgreSQL `requireSsl=false` value
  is the documented compatible pair. Public IPv4 remains allocated, private
  IP is absent, and the secret-backed runtime connection was not re-tested
  while SQL is stopped. The live SQL memory condition now matches the intended metric, but the
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

This docs-only reconciliation records current mobile/cloud read-only evidence;
it changes no runtime or cloud configuration. It requires checked evidence
links, a focused diff, one task-table NEXT row, no private addresses or
credentials, and `git diff --check`. Full runtime tests are not newly claimed
from documentation checks. Normal repository CI must pass on the reviewed PR
head before merge.
APP-READY-082 stays the single next task; no content, messaging, consultation or
financial product expansion is authorized here.
