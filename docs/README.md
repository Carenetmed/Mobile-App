# CareNet project documentation

Current Mobile integration is `0406f53da7e5a7e53fcd31a1767226c1255bb545` after
PR #289. Reviewed head `9155c58703d746bbd46827ee9ee25fd029848691` passed PR CI
`43309919222`; merged-result CI `43312643931` passed on the exact merge SHA.
Both runs were verified through `gh`: 1,424 tests, analysis, debug APK, Android
release lint, protected signing and release-environment regressions passed.
PR #289 changed four files with no dependency/native changes; one new date-only
professional timezone formatter test in
`test/core/presentation/carenet_locale_test.dart` raised the suite from 1,423
to 1,424. The existing large-response widget regression was strengthened. No
tests were removed, skipped, disabled, or weakened. Local debug APK packaging
was blocked by storage, but CI built it. No Android device acceptance or
freeze/ANR resolution is claimed.

The immediate user goal is a working Android staging pilot INCLUDING doctor
posts/shorts, with Paystack excluded/deferred until separate final approval.
Full readiness remains partial, APP-READY-082 remains the sole NEXT task, and
no product guard is removed, including backend payment eligibility. Admin
login/queue/download and documented notification delivery are completed
evidence, distinct from extra production assurance; physical push proof does
not cover every flow. Backend PR191 proves the real-PDF provider expiry/renewal,
412/replay and generation-pinned download path, not browser preview/admin parity.
See `PHASE_1_OPERATIONAL_READINESS.md` for remaining pilot proof and assurance.

The private education bucket and zero-traffic tagged BE087 education candidate
are verified Ready with public content disabled. Postdeploy BE075 remains 100%,
candidate 0%, SQL STOPPED/NEVER; synthetic private-MP4 storage/access proof
passed, not published shorts/mobile playback. No migration/public content was
activated. Safe review,
moderation/abuse controls, device proof and explicit launch approval remain gates.

## Historical Checkpoints And Inventory (Before Pilot Preparation)

Previous Mobile integration was `d97e781194845427b2a996424e583f14f56031b3` after
PR #287. Its reviewed head `1752dc660e0ec18c51e39f7a7b34594d19f03071` passed
PR CI `43270653477`; merged-result CI `43273323794` passed on the exact merge
SHA, including 1,423 tests, analyzer, debug APK, Android release lint, signing,
and release-environment regressions. The six-file docs/test reconciliation did
not change runtime or test inventory. PR #286's previous integration was
`e3ccafbc7dd2e831f4fc035166ee1d160443dacf`; its head
`bc757266fbb322d55f7aa47fe3eb39f97387b839` passed run `43155362903`.
APP-P1-007B PR #285's reviewed head
`c6178f3df557716e0feaa67da3b3a088bbc81f04` passed both PR CI lanes;
merged-result runs `43148540818` and `43148540838` passed on merge SHA
`83f2dfb095b022f1d9dc41952ae0ec13b4557180`. That suite was 1,423 tests
(1,394 base + 29 net added by #285), with no tests removed, skipped, disabled,
or weakened. PR
#285 adds the patient education reader; it does not enable public delivery or
provision media storage. Backend education source is `431094b429581e62e5f5f21acdaae693031b7859`.
The previous operational checkpoint was `00a7021b60c620e1f4fae25fbce405ce17f322ad`
after APP-READY-102 PR #282; its exact-head CI `42570975195` and merged-result
CI `42572846070` passed with 1,366 tests. Historical checkpoint details follow
for provenance.
Nov 12 controlled PITR proof restored eleven pre-existing actorless/subjectless
staging markers to `2026-11-09T23:41:46.171Z`, exactly five minutes before the
last marker. The restored clone contained marker 1 and excluded markers 2-11;
actor, subject, and role fields were null. The one-use clone was deleted and
staging SQL returned to activation `NEVER`; the latest instance read reports
`STOPPED`, resolving the earlier `RUNNABLE`/`NEVER` observation. This proves one
five-minute recovery cut point, not a continuous RPO SLO. The latest successful
automated backup started `2026-11-09T20:28:51.567Z`; PITR retention is seven
days. Current configuration is connector enforcement `REQUIRED` and
`sslMode=ENCRYPTED_ONLY`; `requireSsl=false` is the compatible legacy
PostgreSQL pair. The backend service declares the Cloud SQL connector
attachment, and its runtime identity has `roles/cloudsql.client`. Public IPv4
is allocated, but authorized networks are empty and direct database connections
are rejected; private IP is absent. The secret-backed URL was not inspected and
live connectivity was not retested while SQL is stopped. Only the backend
Cloud Run service is attached to SQL; admin uses API Gateway, messaging points
to backend, and all schedulers remain paused. No positive service-level or
revision-level Cloud Run minimum-instance setting was found, but this does not
disable request-based services. No Cloudflare Stream integration is configured
in the inspected CareNet staging runtime; the education API currently returns
short-lived signed Google Storage URLs. Messaging grants `allUsers` Cloud Run
invocation and relies on application-level WebSocket authentication; ingress
abuse/cost controls remain open. The backend's 100% default percentage
allocation does not make tagged revision URLs unreachable.
Public education remains disabled until media access, moderation, retention,
safety, abuse handling and launch approval are closed.
Current Mobile integration was `3d447f7d1e78c1bd32007b3038bef4b6b204c9b9` after
APP-READY-101 PR #281. Reviewed head `bb8b117fe5e0741ceb28bb29af0b716cba1efade`
passed CI `42091108978`; merged-result CI `42093709035` passed on the exact
merge SHA, including 1,366 tests, analyzer, debug APK, Android release
lint/signing, and environment checks. PR #281 changed six documentation/test
files without changing test inventory. APP-READY-100 PR #280's CI
`42081173591` and merged-result CI `42084055217` passed. APP-READY-100 changed six
documentation/test files and did not change test inventory. APP-READY-098
changed no test inventory. APP-READY-097 increased the suite from 1,364 to
1,366 with no removed, skipped, disabled or weakened tests.
Backend `main` is
`1e2072bf2520b387d3dcc28f32918c21a86ad880` after docs-only PR #194; all three
CI lanes passed on the PR and merged result (`41982489735`, `41982963454`). See `AI_HANDOFF.md`,
`CODEBASE_STATUS.md`, and `PHASE_1_OPERATIONAL_READINESS.md` for current gates.
Admin default percentage traffic is 100% on
`carenet-admin-staging-00009-4t7`. The previously checked Download revision
`carenet-admin-staging-00008-cig` remains tagged `web-ready-011`; latest-revision
feature parity is unverified. The operator previously confirmed sign-in and a
staging document download on Nov 5; that admin download's integrity and browser
preview were not verified. Backend PR191 separately proves real-PDF provider
download; browser preview/current-default-admin parity remain open. The default
Firebase Hosting site serves the approved public/legal pages, and the owner
confirmed the support mailbox test arrived. Cloud Billing and the Budgets API
are enabled. A project-scoped $31.75 USD monthly budget alert (~₹3,000 at the
Nov 5 mid-market rate) sends 50%, 90%, and 100% current-spend notifications to
the approved operations email; it is not a cap or automatic shutdown. No
BigQuery billing export is configured, so actual spend is unknown.
The user confirmed the test-only canary firing email. A separate bounded API
5xx alert-condition exercise opened and auto-closed its incident while SQL
remained stopped. A separate bounded SQL restart and one readiness request
verified HTTP 200 with all checks healthy; SQL is again STOPPED/NEVER.
Gmail confirms the actual API 5xx policy's firing and resolved messages for
this incident; it does not prove delivery for every policy. The API p95 policy
also fired on staging 503s at 11,457.57 ms and delivered an email. It resolved
after 57m55s because metric data became missing; this is not service-recovery
proof. A Nov 13 read-only inventory found 17 enabled policies on the approved
channel: 14 ongoing operational policies and three retained BE-P1-072
SQL-window policies whose query gates expired at `2026-11-09T23:54:20Z`.
The expired policies remain enabled but do not enter the operational
delivery-evidence denominator; controlled alert-email evidence exists for
3/14 ongoing policies, with configuration-only evidence for eleven.
A five-minute three-region HTTPS check validates API gateway `/health` (HTTP
200 and JSON `status=ok`); fresh samples pass. A bounded synthetic failure test
delivered firing and resolved emails through a temporary 60-second policy on
the same liveness metric and approved channel at `2026-11-05T19:57:33Z` and
`2026-11-05T19:58:15Z`. That policy was deleted and `/health` restored. This
proves metric-to-channel delivery, not the production liveness policy's full
20-minute alignment and 300-second duration. Its policy treats prolonged
missing check data as unhealthy. The other 13 policies mostly leave missing-metric evaluation
unset; four auto-close in 30 minutes, nine in 60, and only three explicitly
request an `OPENED` prompt. Actual
current spend remains unread: the Billing Viewer report is available in the
Cloud Console, and no BigQuery dataset was found in the canonical project.
Historical Nov 5 database inspection reported the Oct 27 backup as newest at
that time. APP-READY-082 remains partial: the controlled five-minute PITR cut
point is verified, while continuous RPO, network/SSL security, provider,
release/device, and final Paystack gates remain open. Web PR #16 merged at
`2a3f299f6cc00779b2d7625a0c60339e83551595`
and post-merge CI `42000423597` passed. It validates a valid mocked PDF
response (HTTP 200, `application/pdf`), not visual rendering or a real staging
upload; it changed no runtime code and triggered no deployment. Older
checkpoint summaries below are historical.

Historical: APP-READY-075 merged as PR #240 at `0e0a65b268d7561f2376c846b24a52045cbf2854`.
Final-head and integration CI passed all 930 tests, analyzer, Android debug APK,
release lint, signing, and environment gates. APP-READY-073 is also merged; see
`AI_HANDOFF.md`, `CODEBASE_STATUS.md`, and `DOC_SYNC.md` for exact proof.
APP-READY-076 reconciled the current readiness handoff. APP-READY-077 is next:
staging verification-admin hosting/operator readiness,
which requires explicit user choices before any cloud mutation. Production
OAuth/release signing, live provider proof, admin staging operation, final
Paystack activation, and physical-device acceptance remain separate gates.
Historical checkpoint notes below do not supersede the current handoff.

**You do not need any old chat.** Everything required to continue this project lives in this `docs/` folder and in the codebase.

Current: APP-READY-064 locale source passes 821 tests and analyzer; see
`PHASE_1_LOCALE_POLICY.md`. PR #229 merged at `5955616`; final CI `38549558633`
and integration CI `38552538855` passed 811 tests and native CI gates. Earlier
pending-merge wording below is historical. Source proof is not deployment,
signed release-candidate, device acceptance or full-program completion.

APP-READY-063 source is in PR #229. See PHASE_1_RELEASE_HEALTH for the approved
default-off sanitized backend diagnostics contract and remaining native,
deployment, retention and alerting gates. Backend PR #141 is merged. Runtime
`301f939` passed 811 tests/analyzer; final exact-head CI is a merge gate. Local
native builds hit cache/disk limits, not a pass. No payments or device acceptance.

APP-READY-062 reconciles merged notification authority/execution and admin
preview-confirmation proof. See AI_HANDOFF, CODEBASE_STATUS and DOC_SYNC for exact
source/CI evidence and operational limits. After PR #229 merges, APP-READY-064
locale is next; deployment/alerts/provider acceptance and final device gates remain
open. No payments activate before final explicit user confirmation.

If you use a new IDE or a new AI tool, paste this:

```
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\

Read docs/WORKING_AGREEMENT.md (mandatory).
Read docs/README.md, then docs/AI_HANDOFF.md - complete ONLY the task marked NEXT.
Read docs/ARCHITECTURE_RULES.md and docs/TASK_TEMPLATE.md before coding.
Follow docs/FLOW_MAP.md, docs/ROUTES.md, docs/DEFINITION_OF_DONE.md.
Context: docs/BLUEPRINT_OVERVIEW.md, docs/CODEBASE_STATUS.md, docs/DECISIONS.md.
Do not use old chat history. Do not start the next task without my approval.
```

---

## Read order (first time)

| Order | File | Purpose |
|-------|------|---------|
| 1 | **WORKING_AGREEMENT.md** | **Strict rules:** one task/session, no placeholders, when to ask you |
| 2 | **AI_HANDOFF.md** | The **one** task marked NEXT + task queue |
| 3 | **ARCHITECTURE_RULES.md** | Folder, routing, state, testing, and handoff rules |
| 4 | **TASK_TEMPLATE.md** | Required task shape before any implementation |
| 5 | **DECISIONS.md** | Your answers (auth, API, etc.) so AI never re-guesses |
| 6 | **PROJECT_PLAN.md** | Phases, principles, folder layout |
| 7 | **FLOW_MAP.md** | Screen order and button navigation (logic) |
| 8 | **ROUTES.md** | Route names to Dart files |
| 9 | **BLUEPRINT_OVERVIEW.md** | Figma export: scale, colors, domains, limits |
| 10 | **CODEBASE_STATUS.md** | What is already built vs stub vs wrong |
| 11 | **DEFERRED_WORK.md** | One table of skipped/backend replacement work |
| 12 | **COMPONENTS.md** | Reusable widgets rules |
| 13 | **DEFINITION_OF_DONE.md** | Checklist before marking DONE |
| 14 | **GLOSSARY.md** | Plain-language dev terms |
| 15 | **DOC_SYNC.md** | Which doc wins if confused; last audit |
| 16 | **AUTH_SESSION_ACCOUNT_CONTRACT.md** | Auth/session/account backend contract for Phase 22 integration |
| 17 | **BACKEND_COMPLETED_SURFACE_WIRING_MAP.md** | Completed backend surfaces and remaining frontend wiring order |
| 18 | **AUTH_ACCOUNT_STAGING_CHECKPOINT.md** | Developer-private staging proxy/auth checkpoint for Phase 22 |
| 19 | **GOOGLE_SIGN_IN_FOUNDATION.md** | Real app identifiers required before Google OAuth setup |
| 20 | **GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md** | Google OAuth client prerequisites and fingerprints |
| 21 | **ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md** | PRD-backed patient/professional onboarding and Google sign-up boundary |
| 22 | **ROLE_REGISTRATION_BACKEND_CONTRACT.md** | Exact frontend/backend contract for patient/professional registration and Google sign-up role handling |
| 23 | **PHASE_1_MARKETPLACE_BOUNDARY.md** | Current product scope, approved role navigation, Git/archive safety, unresolved blockers |
| 24 | **PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md** | Complete route/screen KEEP-ADAPT-DEFER-DELETE inventory |
| 25 | **PHASE_1_DEPENDENCY_IMPACT_MAP.md** | Shared versus deferred files, state, models, services, assets, packages, and tests |
| 26 | **PHASE_1_IMPLEMENTATION_PLAN.md** | Ordered A-J slice plan, verification, risks, stop conditions, and non-goals |
| 27 | **PHASE_1_APPOINTMENT_CONSULTATIONS.md** | Paid appointment-linked VIDEO/AUDIO authority, LiveKit boundary, Flutter lifecycle, privacy, operations, and deferred scope |

Current implementation policy:
- Build only the approved Phase 1 consultation marketplace surface.
- Preserve and extend real auth/onboarding, profile/verification, discovery,
  availability, and appointment repository boundaries.
- Do not expose local/mock fallback as real retained Phase 1 behavior.
- Treat broad Figma/social/content/readings/emergency/creator screens as archive
  references, not active product scope. The implemented doctor education
  posts/shorts are the bounded exception included in the staging pilot goal;
  this does not restore legacy social/creator functionality or remove launch gates.
- Avoid dummy widget logic that would force screen rewrites later.

---

## External inputs (not in git)

| Input | Path |
|-------|------|
| Figma blueprint export | `C:\Users\asd\Music\project-blueprint\project-blueprint\` |
| Flutter app (this repo) | `C:\Users\asd\Music\Mobile-App-master\` |

Inside the blueprint folder:

| File / folder | Use |
|---------------|-----|
| `routes.json` | Figma screen name -> URL path (reference; app uses `ROUTES.md`) |
| `screens/<name>/screen.png` | Visual truth for layout |
| `screens/<name>/screen.json` | Sizes, text, components, prototype `reactions` |
| `screens/<name>/README.md` | Route path for that export |
| `diagnostics.json` | Export stats |
| `failed-screens.json` | Failed exports (currently empty) |

**Note:** `project-manifest.json` was not in the export. Tech stack is defined by this repo's `pubspec.yaml` (Flutter).

---

## What "100% precision" means here

| Covered by docs + code | Still needs blueprint / judgment |
|------------------------|----------------------------------|
| App structure, routing, phases | Exact pixel spacing per screen |
| User flows A-D order | ~300 screens not yet in app (prioritize by phase) |
| Route table for wired screens | Duplicate Figma frames (implement once, use states) |
| Design tokens to extract in Phase 1 | API contracts (no backend spec yet) |
| Stubs list (what not to fake as done) | Copy text where JSON has placeholders |

No chat history is required for any row in the left column.

Confused? Read `DOC_SYNC.md` - already in the read-order table.
