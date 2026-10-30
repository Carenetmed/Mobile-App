# Codebase status

## APP-READY-087 - Verification Load Safety (IN PROGRESS)

Document and readiness refreshes each join one in-flight request. Document
refresh keeps the last successful list visible during loading and recoverable
failure; initial loading, failure and backend-empty remain distinct. Pull to
refresh retries both sections. Upload selection is serialized before opening
the file picker, picker failures use safe errors, and cancellation/disposal
discards late picker results. A successful upload waits for older reads before
refreshing documents and readiness so a pre-upload response cannot suppress the
new state. No optimistic review/verification status is applied.

Existing 45 profile/verification regressions and 15 new deterministic race tests
pass. The refresh regression fails against the base implementation (three
requests instead of one) and passes with the repair. All 1,197 Flutter tests
(1,182 retained plus 15 additions, no removals/skips) and analyzer pass.
Staging debug APK and fresh release lint pass (zero errors, five warnings).
Initial Windows-only generated local.properties errors and a stale cached lint
retry are retained; escaping ignored local paths and rerunning all lint tasks
resolved them without tracked native changes or suppression. Source/test/lockfile
hashes remained stable across final checks. Independent review found no blockers.
PR/CI remain delivery gates. No API/backend, dependency,
navigation, appointment, messaging, RTC or payment changes. Expired signed-URL
recovery and orphan retention/cleanup still require their own backend contract;
these UI repairs do not claim that work complete. Prior APP086 delivered via
PR259, merge `f56518c`, PR/integration CI green; older pending notes are historical.

## APP-READY-086 - Readiness Alignment (IN PROGRESS)

Password validation uses NFC normalization for the 15-128 UTF-16 code-unit
length bounds, weak-password check, and confirmation comparison, with
`unorm_dart` pinned to `0.3.2`. Input is not rewritten. Five new password
regression tests cover canonical equivalence, length boundaries, confirmation,
and retained UTF-16/ASCII weak-password behavior.

`reminder` and `schedules` now fail closed through `DeferredFeaturePage`;
`selectedDates` remains the unchanged backend-owned professional Schedule
surface. The iPhone plist now declares portrait and portrait upside-down,
aligned with Flutter startup. All four iPad orientations remain preserved,
without a full-screen opt-out. The native checker guards this contract with
four in-memory negative regression probes.

Eight targeted tests (five password tests plus three route-contract tests) and
the native iOS configuration checker passed. The analyzer, all 1,182 Flutter
tests (1,177 base plus five additions, no removals), and diff check passed.
The staging debug APK build passed; independent diff review found no concrete
defects. CI verification remains outstanding; no full readiness or device
acceptance is claimed.

## APP-READY-085 - Notification Preference Accessible Names (IN PROGRESS)

Notification preference switches now include their category in the accessible
name, for example `Appointments: Push`, while retaining the visible channel
labels and native switch actions. One added widget test activates all fourteen
category/channel controls through semantics and checks that only the intended
preference changes. The twelve focused tests, all 1,177 full-suite tests,
analyzer and independent review pass. The baseline 1,176 tests remain retained;
one regression is added. Staging debug APK passes; CI remains a delivery gate. No notification
delivery or repository contract changes.

## APP-READY-084 - Executable Route Authority (IN PROGRESS)

`RouteName.values` now provides one complete 79-identifier inventory. The
executable route contract partitions every identifier exactly once into an
active exact widget, approved compatibility alias, fail-closed deferred route,
or the deliberately reserved `login` value. It also proves unknown routes fail
closed. The canonical route table now describes actual `generateRoute`
resolution instead of naming disconnected seeded screens. No route mapping,
navigation contract, dependency, native project, backend or cloud behavior is
changed. Three focused tests are added over the retained 1,173-test baseline;
analyzer, seven targeted route tests and all 1,176 full-suite tests pass. No
existing tests were removed or changed. Staging debug APK and independent
review pass; CI remains a delivery gate. The slice was reconstructed from
recorded patches on E: after the F:
worktree became unreadable; filesystem recovery remains separate.

## APP-READY-083 - Current repository README

The root README now describes the implemented role-aware Phase 1 marketplace
instead of the obsolete frontend-only prototype. It names backend-owned active
surfaces, separates retained deferred source from active product authority, and
keeps production, provider, store, iOS, and physical-device acceptance open.
The contribution target is the current `feature/frontend-milestone` integration
branch. `PRODUCTION_README_CURRENT_STATE.md` records the exact truthfulness and
scope boundary, with executable README regressions for current wording and local
links. This documentation-only slice changes no runtime source, route,
dependency, native project, environment, signing, backend, or cloud behavior.
Four focused README contract tests and all 1,173 Flutter tests pass, an exact
increase of four over the retained 1,169-test source inventory. Flutter analysis
reports no issues, the canonical staging debug APK builds, and diff checks pass.
Independent review found and repaired an overstatement about the historical
route table plus weak/wrapping-sensitive assertions; final re-review passes.

## APP-READY-082H - Consultation Audio Permission Policy (IN PROGRESS)

Base0913862/1,153 tests. Ordinary media preparation requests microphone and,
for VIDEO only, camera; it no longer requests Bluetooth connection permission.
SDK-owned routing remains unchanged. The accessible speaker control represents
preference, not an observed earpiece/headset. Active status/media/control regions
are separated, with scrollable enlarged captions and no text-scale cap.
Targeted65 tests, full1,169 tests (1,153 retained+16 added), analyzer and diff
checks pass. Staging debug APK, fresh623-task release lint, protected signing,
30 environment probes/eight packaging graphs, backup25 and iOS configuration
checks pass. Signed artifacts and CI remain delivery gates. Parent and
independent static review found no actionable issues; no device proof is claimed.
Physical routing/permissions and full readiness remain open. 082G delivered in
PR254/merge0913862 with green PR/integration CI; older pending notes are historical.

## APP-READY-082G - Foreground Realtime Recovery (IN PROGRESS)

Within sole NEXT task082, base `8b8e9fc`/1,126 tests. Failed real pre-ACK auth
attempts emit owner-typed recovery requests; inbox admission is foreground-only,
generation/role/account checked, bounded to a five-second ownership read and one
in-flight HTTP reload with a 30-second cooldown. No timer initiates traffic.
Generic socket rejection is not token-expiry authority; the retained repository
and HTTP401 coordinator alone own token refresh. No backend/protocol, storage,
dependency, native, route, message-write or product changes.

157 targeted messaging tests pass, including real Dio/coordinator401-versus403/
503 proof. The401 regression fails if emission is removed and passes restored.
Full inventory1,153 =1,126 retained+27 additions passes, no removed/renamed/skipped
tests. Analyzer, staging debug APK, fresh release lint623tasks, protected signing,
30environmentprobes/eightgraphs, backup25probes and iOS flavor checks pass.
Independent review is clear; signed artifacts and CI remain delivery gates. 082F source
delivered in PR253 with both PR/integration CI lanes green; its older pending
text below is historical. Real session/provider/device readiness remains open.

## APP-READY-082F - Messaging Transport Readiness (IN PROGRESS)

Source work is in progress on `slice/APP-READY-082F-messaging-realtime-ingress`
from `e9f21d4ac2e84a93c556d798a2184900e7a3ccf0` (968 passing baseline tests).
This is a prerequisite within the sole NEXT task APP-READY-082, not delivered
messaging transport or completion of the production-readiness program.
`PHASE_1_MESSAGING_REALTIME.md` owns the selected contract: explicit optional
staging WSS configuration, typed account/session-generation ownership, shared
refresh coordination, ACK-only connected state, per-view connections and
HTTP-authoritative reconnect/resume catch-up. Missing configuration retains
HTTP/manual-refresh fallback; no production WSS host is approved.

Backend PR176 and the 2026-10-25 standalone staging ingress negative-boundary
proof are recorded in that contract. Health 200, unrelated HTTP 404 and rejected
missing/malformed/invalid authentication do not prove a valid patient session,
message delivery, physical-device behavior or production acceptance. Final-source
analysis, staging debug APK, all 1,126 tests (968 retained plus 158 additions)
and diff checks pass after repairing dropped inbox reconnect catch-up.
Independent review's delayed-close refresh-dispatch race
was repaired with three regressions. No tests were deleted or skipped; the
obsolete HTTP-derived endpoint expectation was renamed without losing strict
frame/sequence assertions. Repaired-source release lint (623 executed tasks),
signing regressions, 30 environment probes and eight packaging graphs pass.
Signed staging artifacts and CI remain pending for 082F.
Legitimate fixture/session consent and later device acceptance remain open.

## APP-READY-082E - Verification Cancellation Coverage

One additive repository regression observes cancellation after the storage PUT
has entered the transport and proves upload-complete is not called. It fails
when the existing cancellation binding is removed and passes when restored.
All retained assertions and production files remain unchanged. Nine repository
and 45 combined repository/profile tests pass. Full analysis, all 968 tests
(967 retained plus one added), staging debug APK and fresh release lint pass
(623 tasks executed). Initial ignored local SDK path escaping was corrected
without tracked native changes or suppressed checks. PR/CI remain pending.
This is coverage of the existing implementation, not a demonstrated
runtime defect or proof of device/provider cancellation. APP-READY-082 remains
partial. Prior PR251 delivered with final/integration CI green and 967 tests.

## APP-READY-082D - Finance Notice Accessibility

In progress: finance success/error feedback needs live-region semantics. The
bounded repair changes only notice presentation and additive widget tests;
financial rules, repository calls and safe copy remain unchanged. Both new tests
failed before the repair and pass afterward; all seven focused tests, full
analysis and 967 full tests pass (965 retained plus two added). Independent
review, staging debug APK and fresh 623-task release lint pass. Only ignored
local SDK escaping was repaired; tracked native files and checks are unchanged.
Exact-head/integration CI remain pending. APP-READY-082 and wider
operational readiness remain partial.
Prior link-error repair PR250 delivered at merge70e8fa9 with exact-head and
merged-result CI green,965 passing tests. Older pending notes are historical.

## APP-READY-082C - Public Link Error Containment

Account and signup contain synchronous and asynchronous public-link launcher
failures with the existing fixed safe message and mounted check. Successful
launches remain unchanged; late completion after disposal must do nothing.
Twelve additive tests cover false, synchronous throw, asynchronous failure and
late success/false/error for both screens. All 69 focused tests and four-file
analysis pass. Full analysis and all 965 tests pass (953 retained plus 12 added).
Independent source/test review, staging debug APK and fresh release lint
(623 executed tasks) pass. Earlier local SDK-path escaping failures were
corrected only in ignored local.properties; no lint suppression or tracked build
change. Exact-head and merged-result CI remain pending.
No URLs, routes, dependencies, authentication or backend changes.
This is a prerequisite within partial APP-READY-082, not program completion.

## APP-READY-082B - Permission Failure Classification

Profile and Onboarding API clients now distinguish 403 `forbidden` from 401
`unauthorized`, following the existing Auth client contract. This stops a
permission denial being presented as a sign-in requirement and avoids the
readiness repository's unauthorized-only refresh path. Backend permissions,
session authority and 401 recovery are unchanged. Four actual-response
regressions prove status/copy/session semantics, including zero refreshes, one
readiness request and unchanged session contents/generation after 403. All 17
focused and 953 full tests pass; analysis, staging debug APK and release lint
also pass. The increase is exactly four tests over the retained 949. Exact-head
and integration CI remain delivery gates, not evidence of full readiness.

## APP-READY-082A - Registered Profile Editor Identity

The registered name editor no longer fills its name from retained local sample
identity when professional profile loading returns null or fails. Backend
prefill/save and the null-profile mutation guard remain unchanged. Seven new
canonical-router cases cover null profile, 401/403, network/unexpected failure,
missing DI and backend save-field preservation. The focused route/profile flow/
repository group passes 51 tests; targeted analysis reports no issues. Existing
tests are unchanged. Full analysis and all 949 tests pass (942 retained plus
seven new cases); staging debug APK and local Android release lint pass. Initial
source-head CI `39773149140` passes analysis, 949 tests, APK, lint, signing and
environment regressions. Final-head/integration proof is attached to
[PR #248](https://github.com/Carenetmed/Mobile-App/pull/248). No device acceptance
is claimed. No tracked native configuration or dependency change was required.
APP-READY-082 stays partial.

## APP-READY-082 - Operational Handoff (Partial)

October 21 read-back confirms nine enabled alert policies, zero uptime checks,
and three paused schedules. The controlled sanitized release-health alert has
counter, OPEN incident and matching email-receipt proof. RTC dispatch/execution
policy definitions are applied. One normal 16:10 UTC cron tick completed with
the expected scheduler identity, exact job spec and an empty-work result.
Useful provider cleanup, RTC failure-alert delivery and queue age remain
unproved; one tick is not cadence reliability. Explicitly approved temporary
organization deny-policy review made the access evaluation conclusive; the
reviewer binding was then removed, preserving unrelated IAM. Future operations
still require fresh authority checks, not a bypass of unknown results.
`PHASE_1_OPERATIONAL_READINESS.md` owns the cross-repository evidence map.

The serving API is `carenet-backend-staging-00014-jhw` at 100% traffic. This
documentation-only reconciliation does not promote an image, activate a
schedule, change the 942-test inventory or complete the readiness program.
Backend source/CI and mobile runtime/deployment/device proof remain separate.

## APP-READY-081 - Signed Android Auth-Link Association (Merged/Deployed)

The previous live association matched source but trusted the same debug key
for both packages. APP-READY-081 binds each package to its own protected upload
certificate from `ANDROID_RELEASE_SIGNING.md`, with two static regression
tests. No application/auth/backend/dependency behavior changes. Hosting deploy,
served association checks, CI, and real-device automatic verification are
distinct gates; do not treat a prior manual device link-selection override as
automatic verification. Play distribution certificates remain unregistered in
this association until their approved identities are available.
Focused public-link tests pass (3), full suite passes (942, +2 from 940;
existing tests unchanged), analyzer is clean, and the staging debug APK builds.
PR #245 reviewed head `edbd6f17b477b098845e06874659f8a6200017ba` passed CI
`39281499795` attempt 2 and merged as `1ab1075`. The first attempt's corrupt
Android SDK ZIP required an unchanged-source rerun. Integration run
`39288540689` passed on the exact integration commit. Documentation proof
PR #246 subsequently merged at `51c3a2a`; runtime code is unchanged.

Hosting version `3eed605e5b2bc4cc` is deployed with exactly one content hash
changed and existing config/other hashes preserved. Direct public GET confirms
the reviewed JSON and five-minute cache policy; all eight other source pages
and assets still return unchanged content. Firebase Management API read-back
confirms both approved upload certificates on the matching app registrations.
Phone automatic domain verification and Play release gates remain open.

Staging operational follow-up is summarized above and in
`PHASE_1_OPERATIONAL_READINESS.md`; earlier zero-policy observations below
are historical. Backup `1792427900036` completed SUCCESSFUL at 16:40:11Z on October 19;
gateway readiness returned 200 afterward. No restore, schema, traffic, payment
or worker-schedule change occurred. APP-READY-082 owns cost-conscious alerting.

APP-READY-080 is partial: operator password setup, IAP access, application login
and queue access succeeded. Web PR #10 fixed origin validation; PR #11 added
authenticated document Download. Web main `8dfbaada9d4a55d7e0781bca7ae9e97cc40a117e`
and staging revision `carenet-admin-staging-00006-55n` are live with green CI.
The 63-byte smoke PDF failed preview; no document decision was made. Valid-file
preview and actual operator download remain unproved. This supersedes earlier
password-setup-pending notes below, not the remaining admin acceptance gate.

## APP-READY-079 - Readiness-Aware Sign-In And Session Restore (Done; PR #243 Merged)

Base: `f8aea76957d242f8c23d35f20f4f6d66a28408bd` (PR #242 merge). Normal
email/Google sign-in and authenticated startup now request backend account
readiness when there is no pending booking intent, then use the existing
readiness route resolver for patient setup or professional verification.
Booking-intent recovery remains first and unchanged. Navigation requires the
readiness role to match the authenticated session role and the backend account
to be active; unsupported, mismatched, or failed readiness falls back without
clearing the session or granting authority. Email-verification gating remains
an unresolved policy and is not changed here.

Focused resume/startup/sign-in tests pass (61). Full suite passes (940: the
933-test base plus seven new tests); repository-wide analysis and the explicit
staging debug APK build pass. The new tests cover no-intent readiness routing,
role/status mismatch, patient setup, professional verification, and the
sign-in/startup entry points. No tests were removed, disabled, or skipped. PR
#243 reviewed head `6b97c72e742c4635a879f99570b50fb31483d91e` merged at
`94f20dc1beea79f3773c7c846a40dd32bc415a67`; PR CI `39203627650` and integration
CI `39205075146` passed. No dependency, lockfile, backend, provider, native, or
cloud changes were in scope.

## Current Staging Admin And Account State (Supersedes Earlier Audits)

APP-READY-077's previously pending setup is now complete: the staging Web
admin console is deployed behind Cloud Run IAP, and the first staging
super-administrator was provisioned through the backend's two-phase operator
procedure. The backend staging service runs revision
`carenet-backend-staging-00014-jhw` at 100% traffic. The operator completed
password setup, application login and queue access as recorded above. Valid-file
preview and actual operator download are still unproved. Cloud SQL remains
running because the staging API/admin require it;
temporary local proxies were stopped. No production provider was activated.

## APP-READY-075 - Deferred Reminder/Schedules Accessibility Follow-Up

PR #240 merged as `0e0a65b268d7561f2376c846b24a52045cbf2854` from final
reviewed head `f8593aaba297c36ede61a61a379417398ecbfce1`. Final-head CI
`39064828444` and integration CI `39066131745` passed 930 tests (the 928-test
base plus two new tests), analyzer, staging debug APK, Android release lint,
release-signing regression, and release-environment regression. Direct widget
coverage exercises Reminder and Schedules at 320x568 with 2x text. Reminder
selection and the date-specific empty state remain usable; the read-only event
disclosure exposes a named button with expanded/collapsed semantics. No reminder
persistence, schedule mutation, sharing, or notification delivery was
activated. Local full-suite execution was blocked by this Windows host's C:
free-space/test-isolate issue; final-head and integration CI passed.

## APP-READY-076 - Readiness Handoff Reconciliation (Done; Read-Only)

Corrected the production-readiness continuation after APP-READY-073 PR #239
and APP-READY-075 PR #240 merged. Verified their final and integration CI
evidence, and verified the admin console source is in
`Carenetmed/Web-Developers` main `8dc563435fb78be47c977a73a2311a377aed671e`,
not `ridwanmullick/carenet-web`. Web main has CI-tested console/container
preflight but explicitly does not push or deploy the image. Read-only GCP
inventory found only the staging backend service; SQL is STOPPED/NEVER and both
Scheduler jobs are PAUSED. No cloud resource, account, or archive ref changed.
APP-READY-077 was the next decision-gated staging admin operation at that
historical checkpoint; the later deployment and provisioning are recorded
above and below.

## APP-READY-078 - Account Email Verification Reachability (Merged; Device Check Pending)

The Account `Email address` row now opens `editEmail` through the named router.
The screen reads the authenticated account from `AccountRepository`, shows its
backend email and `emailVerified` value, and offers the existing verification
request API only when the backend reports the address unverified. Initial load
errors are retryable; refresh failures retain the last successful account
value. The request result is described as accepted by the API, not guaranteed
delivered. The confirmation deep-link/token implementation is unchanged.
Registration does not currently force or automatically request email
verification; whether it should gate signup/onboarding is unresolved and needs
a product/backend policy decision.

Branch `slice/APP-READY-EMAIL-VERIFICATION` is based on
`4d95b1cc25aef8d65974f27c5d51782b918e6ba9`. Focused account tests pass (44),
the full suite passes (933: 930 baseline plus three net new tests, replacing the
old expectation that `editEmail` was deferred), and targeted analysis is clean.
The staging debug APK also builds with the canonical explicit-flavor command
after using an E:-resident Pub cache; `pubspec.lock` is unchanged. No backend,
dependency, cloud/provider, or native configuration change. Commit
PR #242 merged into this integration at `f8aea76957d242f8c23d35f20f4f6d66a28408bd`.
The merged CI baseline is 933 tests; physical-device verification of Account
email status and verification-link completion remains pending.

## APP-READY-072 - Professional Verification Administration Audit (Done; Read-Only)

Backend main `43836bbe2b07b0c4a8e8f1b3fd64bd1ca26a5e0b` exposes the guarded
admin verification queue, eligible-document signed read, and approve/reject
decision routes. JWT/role guards require `ADMIN` or `SUPER_ADMIN`; decisions
are limited to the latest completed pending evidence and update document,
aggregate professional status, and audit data transactionally. The staging
first-admin procedure is preview-first and two-phase with explicit TTY
confirmation and revalidation. Repository records say no operator identity was
selected and provisioning was not run; this audit did not query the live DB.

The Web console is in `Carenetmed/Web-Developers` main at
`8dc563435fb78be47c977a73a2311a377aed671e`; historical merge
`6e94fcd3ee44c881a2625918e179928a0f65b659` is part of that history. The Web
PR #9 exact-head CI `39061542203` and main CI `39061797496` passed. The
repository includes mock-backed browser tests, a multi-stage container, and a
container preflight; its current documentation explicitly says the image is
not pushed or deployed. The read-only 2026-10-18 cloud inventory found only the
staging backend Cloud Run service. `carenet-staging-postgres` was `STOPPED` with
activation policy `NEVER`, and both staging Scheduler jobs were `PAUSED`. No
admin staging flow is proven. Operational gates remain host/perimeter selection,
explicit operator approval/provisioning, and a controlled admin staging smoke.
No account or cloud resource was changed.

## APP-READY-073 - Google OAuth iOS Callback Configuration (Done; PR #239 Merged)

PR #239 reviewed head `9beadb5863712c93210552fa0d2e80f052e98019` merged as
`4cfe18d73cd142f2c3f1f39c1cddddd407b0351a`. Exact-head Flutter CI
`39033607614`, iOS simulator CI `39033607610`, and integration runs
`39034721058`/`39034721104` passed. The 928-test suite remained intact. Firebase
SDK configuration confirms distinct staging and production iOS client/scheme
pairs, wired through each flavor's Xcode configuration into `Info.plist`. The
backend Web-client audience and provider authority are unchanged. Simulator CI
does not prove Apple signing or physical-device Google sign-in. Android
production OAuth remains a release-signing-specific gate.

## APP-READY-077 - Staging Admin Console Gate (Done)

The Web admin source is `Carenetmed/Web-Developers` main
`8dc563435fb78be47c977a73a2311a377aed671e`. The staging console is deployed
behind IAP, and the first staging super-administrator was provisioned using the
preview/prepare/wait/revalidate/activate process. This closes source deployment
and initial operator provisioning, but does not prove the operator has
completed password setup or that professional-verification review has passed
an end-to-end browser/device smoke. Production admin access remains separate.

## APP-READY-071 - Verification Authorization Semantics (Done; PR #236 Merged)

Verification API HTTP 401 maps to `AuthFailureType.unauthorized`; HTTP 403 maps
to `AuthFailureType.forbidden`. The existing UI presents separate safe copy and
does not turn an authenticated permission denial into a sign-in prompt. Focused
proof: 8 verification repository tests, the new forbidden-message widget test,
analyzer clean, and diff check clean. PR #236 head
`054d2da71e3426d5926ac8cb6f21b20d167e3ec6` merged as
`d25c810e5275b8a5b084b2e99766f6fe66033524`; PR CI `39019115901` and integration
CI `39021212587` passed the 928-test suite, analyzer, debug APK, release lint,
signing, and release-environment checks. Local execution of the full large
profile-management widget file hit a Flutter root-isolate failure; focused
repository and widget tests passed. No upload, storage, backend, dependency, or
lockfile behavior changed.

## APP-READY-068 - Notification Account Isolation (Done; PR #233 Merged)

Post-merge integration is `84856725171f49ee1731b5ade7a4aedc6286c7ac`, PR #233
merged from reviewed head `0a93aecb7675776d55ad4f232869735b3ccd0709`.
Android `38944217173`, iOS simulator `38944232798`, and integration CI
`38947622870` passed. The audit found
foreground local notification display trusts FCM title/body after a callback
that can return after logout/account switch. Late Firebase transport init can
also attach listeners after timeout/disposal because transport lacks disposal.
Implementation verifies each foreground notification ID through the authenticated
backend and current session generation, shows generic copy only, invalidates late
init, cancels attached subscriptions, clears local displays on account changes,
and retires a stale display after an in-flight native call returns. Local OS
cancellation invalidates presentation synchronously but does not block logout or
account rebinding. Detached callbacks and provider-stream errors are contained.
Flutter3.41.5 verification:28 targeted tests,924 full tests, analyzer clean, diff
check clean, lock unchanged. Inventory 911+9 transport lifecycle+4 account-
isolation=924, with no tests removed/skipped/disabled. Independent review found
no blocker. No provider/cloud change. Already-running native plugin calls cannot
be cancelled.

## APP-READY-069 - Auth And Onboarding UX Integrity (Done; PR #234 Merged)

Base: merged integration `84856725171f49ee1731b5ade7a4aedc6286c7ac`; branch
`slice/APP-READY-069-auth-onboarding-ux`. Fixes the missing verification-link
route to the then-deferred `editEmail`, signup's indefinite booking-intent restore error,
stale auth routes under the dashboard after normal authentication fallback, and
patient onboarding validators stricter than backend readiness. Patient backend
required fields are name and country; state and health interest remain optional.
Catalog/profile retry now restores persisted profile values while retaining
non-empty user input. PR #234 merged from reviewed head
`e98cd3cdef18812b112b9ba6ff218fba08a8c9ba` as
`4e3bfb3d011b112f4d4e22052448154d2dd6abf4`. PR CI `39002947831` and
post-merge integration CI `39004617605` passed. The 926-test suite, analyzer,
debug APK, Android release lint, protected signing regression, and release
environment regression are green. Inventory is 924 baseline +2 new tests, one
existing patient validation test renamed/reasserted, and no removed/skipped/
disabled tests. Exactly 14 files changed; no dependency, backend, provider/cloud,
payment, or native build changes.

## APP-READY-070 - Google OAuth And iOS Callback Audit (Done; Provider Setup Pending)

The canonical Firebase project `project-a96784ee-811c-46ab-a7b` has project
number `599365440227`. Console evidence classifies the supplied `2q9l...` ID as
Web, `nu3b...` as Android, and `dct2...` as iOS; the iOS reverse URL scheme is
known. The evidence omits the Android package/SHA and iOS bundle association,
and shows only one iOS client for the two registered bundle IDs. Repository
Android flavor IDs are `com.carenet.app.staging` and `com.carenet.app`; the
recorded debug SHA-1 is `79:DC:39:4B:88:BF:0B:C5:3F:C9:A1:DC:08:1F:F7:09:E4:6D:95:53`.
These values still need comparison against the console client. The app has no
iOS `GIDClientID` or callback URL type. Do not add flavor callbacks until the
iOS client is tied to its bundle and a client exists for the other flavor.
Read-only staging probes on 2026-10-17 returned `/health: ok` and
`/health/ready: unavailable` (database/migrations unavailable; email,
`googleAuth`, and verification-storage provider checks `ok`). The reason for
the database result is now explained by read-only Cloud SQL state:
`carenet-staging-postgres` is `STOPPED`, activation policy `NEVER`; staging
Cloud Run's latest ready candidate has 100% traffic and references that
instance. This supports leaving SQL off between smoke windows. No cloud service
was started or changed.

The audit is complete: provided console evidence classifies one Web, one
Android and one iOS client and gives the iOS reverse scheme. Android
package/SHA and iOS bundle association were not present in the copied details;
only one iOS client is evidenced. Do not wire iOS flavors or claim provider
acceptance until both bundle associations are confirmed and each iOS app has a
client. No runtime configuration was changed.

## APP-READY-067 - Auth Attempt Ownership (Done, CI Verified)

PR231 is merged as e63471a with838 tests and exact-head Android/iOS plus merged
CI38907469546 green.067 repairs a separately reproduced stale-auth-response race
and bounds secure-store read waits. Ownership is local operation ordering only;
backend identity/roles and existing generation guards remain authoritative.
Conditional queued writes must check ownership at execution, not just enqueue.
No raw queue release on timeout, unsafe replay or false durable-clear claim.
Local93 focused/full911 tests and analyzer pass.838+41 auth-attempt+24 store-wait
+6 refresh-wait+2 shared-refresh=911; no removed/skipped tests. Refresh/logout/reset
caller waits are bounded without releasing raw operations. Independent review
found no blocker. PR232 mergea4a2538; Android38913973578, iOS38913973129 and
integration38935361083 passed. Full readiness remains open.

## APP-READY-066 - Session Recovery Integrity (Source Verified)

Base PR230 merge `1f091d288239ff735f4bf1de5da5a4082dec290e` has 821 tests.
Current scope rejects independently stored legacy fields without shared-account
provenance, preserves valid versioned envelope/generation behavior and bounds
initial splash restoration/disposal. Fault-injection and recreation tests do not
prove physical native crash atomicity.33 targeted/full838 tests and analyzer
pass locally; backup25-negative/static iOS/diff/lock checks pass. Net+17,one
unsafe legacy migration test replaced by stronger rejection,all others retained.
Both unchanged native CI lanes remain merge gates. Local native APK/lint is not
claimed with C: low space and F: reporting Full Repair Needed. No physical-device
or complete-readiness acceptance follows from these source checks.
APP-READY-065's backend drift work was completed separately by BE-P1-043/PR142.
No provider, navigation, dependency, native or backend behavior changes here.

## APP-READY-064 - Locale Source Verified (2026-10-15)

Base `5955616039ce4bec8b9077d1c54f75e4649e5d82` is merged PR #229.
Its final-head CI `38549558633` and integration CI `38552538855` passed all
811 tests, analysis, Ubuntu APK, release lint and signing/environment probes.
The APP-READY-063 pending-merge entry below is historical, not current status.
Locale work now pins English/Nigeria presentation, bundled English day-first
date fallback and twelve-hour labels without changing time or money authority.
See `PHASE_1_LOCALE_POLICY.md` for scope, SDK-only dependency and pending gates.
All 821 tests pass locally (811 retained + 10 added); analyzer is clean. Backup
privacy probes, iOS static consistency, new-file formatting and diff checks pass.
No test was removed/renamed/skipped; only documented display assertions changed.
Both exact-head native CI lanes and integration CI remain merge gates. No local
native pass, cloud promotion, signing/device or full readiness claim is made.

## APP-READY-063 - Source Contract In PR #229 (2026-10-14)

Base PR #228 merge `31e0aa9f64a1ed75c7bef8a3f51b5ffd0e1f464a`.
Default-off Account diagnostic consent is bound to the existing secure session
generation. Allowlisted framework/asynchronous/optional-startup codes and strict
release metadata use a separate bounded JWT client; no raw/native crash SDK,
exception text, stack, identity or clinical/payment/message payload is sent.
The coordinator bounds outstanding work and drops duplicates without queuing.
Backend PR #141/main `f1a3f0b` implements strict admission; merged CI proves
669 unit/149 E2E/164 PostgreSQL and image policy, not deployed delivery.
Reviewed runtime `301f9395d44ac96b7283b3b101e35eed3f2c462f` passed all
811 tests and analysis in a same-drive C: validation checkout. Net +77, no old
test changes. Initial draft CI `38539680857` passed Ubuntu APK, release lint and
signing/environment probes on `ac3ffd5`; final reviewed-head CI is still a
mandatory merge gate for PR #229. Local native builds are not claimed passed:
cross-drive F: cache problems and C: disk safeguards blocked those attempts.
The single-worker C: attempt stopped at 995,098,624 free bytes after 57 seconds.
No dependency/native/domain-lifecycle changes or lowered CI checks. See
`PHASE_1_RELEASE_HEALTH.md`; operational log/retention/alerts, native crashes,
local signed-release headroom, locale, rollout/restore, device and final Paystack
gates remain open. APP-READY-064 locale work starts only after PR #229 merges.

## Production Readiness Checkpoint (APP-READY-061)

Superseding APP-READY-062 checkpoint (2026-10-13): mobile integration is
`739745a6786b07e1f4c0b392ee1f832896a118f0`, green CI `38357943329`, 734 tests.
This four-document reconciliation changes no runtime, tests, dependencies or
native files. Backend PRs #137-#140 merged at latest main
`ba40c1bc91ff81289c7bfb3f69c0bb69df24bf68`: CI `38445314885` passed
659 unit/105 E2E/152 PostgreSQL, build/lint and patched runtime. Image scan
`38445315082` passed existing policy, not a zero-CVE or deployment assertion.
Web PR #8 merged at `6e94fcd3ee44c881a2625918e179928a0f65b659`, CI
`38362609676` green (18 Node/five browser tests, lint/build/container smoke).
Notification authority/execution and admin preview-confirmation source repairs
are integrated; operational/provider/admin access and device proof remain open.
SQL STOPPED/NEVER and scheduler PAUSED were rechecked without mutation.
Crash/release-health and explicit English/Nigerian locale remain unfinished;
Paystack requires final confirmation. Earlier text below is historical.

Current mobile integration is `31ed6ae8d2627a5aae6c1c5b5fb5eb6798911593` in
`Carenetmed/Mobile-App`.
APP-READY-051 merged in PR #215, APP-READY-052 in PR #216, and APP-READY-053 in
PR #217. PR #217 exact-head CI passed analysis, 719 Flutter tests, Android
debug APK, Android release lint, and release signing/environment regressions.
APP-READY-048 aligned sign-in UX and backend-session role routing; APP-READY-049
preserves onboarding edits across readiness-load failure and retry. APP-READY-
050 reconciled the preceding handoff. APP-READY-054 is documentation-only: it
reconciles this mobile handoff with the Web admin source and records the
still-off cloud posture. APP-READY-055 merged in PR #219 and adds auth form,
accessibility, and responsive-width polish without changing auth authority or
providers. APP-READY-056 audited the Web verification journey and fixed the
same-origin read request guard in Web PR #5. APP-READY-057 added a Chromium
browser journey and corrected the Web queue DTO validator mismatch in PR #6;
exact-head CI passed 19 Node tests, one browser journey, lint, and production
build. Mobile PR #221 merged at `139b5153cc677a5ac77e0f6e7e857e0028a82492`
with four documentation-only files and green exact-head CI. APP-READY-058 PR
#222 merged at `547e5cc5b52c2e00f10d9c3371f4d20dbf68eafd`; exact-head CI passed
analyzer, 730 Flutter tests, debug APK, Android release lint, and release
checks. APP-READY-058 follow-up PR #224 head
`08774c1a15544cff72eae44f9b1f3b8d86b0d60b` adds an account-details retry after
failure, announces onboarding catalog errors as live regions, replaces
implementation-facing appointment/verification/consultation copy, tests a
payment failure's user-safe presentation, and checks consultation waiting
action reachability at 320x568 with 2x text. Its focused group passes 115
tests and `flutter analyze --no-pub` reports no issues. The full local suite
and local Gradle build stalled; exact-head GitHub CI passed analysis, 733 tests,
debug APK, Android release lint, signing, and environment checks. Compared with
the 732-test integration suite, one payment-error test was added; none were
removed, skipped, or disabled. No backend, provider, native, dependency, or
cloud changes are in this follow-up.

APP-READY-058 completed in mobile PR #225 at the current integration base;
exact-head CI passed the analyzer, 734 Flutter tests, debug APK, Android
release lint, signing, and environment checks. The test baseline is 734.

APP-READY-060 merged in mobile PR #226 at `31ed6ae`. Shared iOS staging and
production schemes, Firebase bundle mapping, CocoaPods configuration, and an
unsigned simulator-build lane are present. The ARC build-setting repair and
locked CocoaPods dependencies are committed at the PR code head
`6f0d656e76b85e58d829dc177522ec49957e0db7`. PR runs `38349401977` and
`38349401983`, then merge-push runs `38350943633` and `38350943941`, passed
on 2026-10-13: analysis, 734 Flutter tests, staging
debug APK, Android release lint, signing/environment regressions, and both
staging/production iOS simulator builds. The repository moved to
`Carenetmed/Mobile-App` and is public; the previous runner billing block is
resolved. Review repaired missing per-configuration CocoaPods includes and
aligned the Flutter framework minimum to iOS 15. CI now rejects the CocoaPods
base-configuration warning; final PR and merged-source builds are clean.
No tests or Flutter dependencies changed.
No backend, cloud, payment, or provider changes occurred in this slice.

APP-READY-051 cross-repository audit: backend main is
`8e5175e9ea569630eb91728e449877fafac9a530`; BE-P1-037 PR #136 and its CI plus
immutable image scan passed. Candidate image:
`asia-south1-docker.pkg.dev/project-a96784ee-811c-46ab-a7b/carenet-backend/carenet-backend@sha256:1c7f7e0e902914355fcab86ef185f09d4c27c6563b682d4cb426c19eff718ad6`.
This is only a scanned artifact: Cloud Run still serves
`carenet-backend-staging-be-p1-031-livekit` at digest
`sha256:869a7125fc5a981462e46bbfd72b7be50fc160510a942195b229d3960760b98a`.
The 2026-10-13 service read confirms that configured manifest; its ready
revision resolves the platform image to
`sha256:1ad1482e4be6634a8152cd2099bbbc136b1957370b97366ed8d3428ab5b5ec6f`.
The scan records one documented unfixed upstream high CVE (`CVE-2026-85091`),
with no fix available, and zero unrated unfixed findings. Deployment,
migration/rollback proof, and resolution tracking remain open.

The Web admin verification console is integrated separately in
`Carenetmed/Web-Developers` PRs #1-#7; current Web main is
`bcb7742af0ba6749da9d0a45f694bc6e79755206`. Run `38072892929` passed tests,
loopback-mock Chromium coverage, lint, production build, and container smoke.
The console remains source-only: no
hosting/deployment has been configured and no administrator was provisioned. Backend admin CLI
provisioning remains operator-controlled and requires an approved identity and
time-bounded execution; there is no first-admin endpoint.

Read-only staging observations on 2026-10-13: Cloud SQL
`carenet-staging-postgres` is STOPPED with activation policy NEVER; the
notification scheduler is PAUSED; Cloud Run `carenet-backend-staging` has no
minimum scale (service maxScale 2, revision maxScale 3). Cloud Run can still
incur request-based charges.
No cloud resource was changed. The read-only 2026-10-13 check confirms SQL
STOPPED/NEVER, the notification Scheduler job PAUSED, and the only Cloud Run
service has no minimum instance configured (scales to zero when idle). Keep SQL
and Scheduler off when not explicitly needed. Historical verification upload-init
returned staging HTTP 500; no fresh backend/provider smoke was invoked while
SQL is stopped. Current-revision diagnosis requires a bounded database-use
window. Local C: space remains constrained; do not delete protected
worktrees to reclaim it. APP-READY-057 used a CI-hosted Chromium install only;
it did not start cloud resources. The completed APP-READY-058 mobile route
audit initially identified missing recovery from an unsupported
authenticated role and implementation-facing copy in Account/Appointment
Detail; compact, 2x-text regression coverage for Messages, Chat, and
Notifications is in place, and the 94-test targeted group passes. Manual
TalkBack, keyboard-focus order, and full-device route acceptance remain
unproven. This follow-up also verifies active consultation controls and
unsupported-role recovery at 320x568 / 2x text. The iOS environment PR has
passed both GitHub CI lanes on the final PR and integration merge.

### Remaining pre-device evidence and repairs

| Gate | Current proof | Remaining work |
|---|---|---|
| Backend release | Main `8e5175e`, PR #136 CI/scan passed; scanned digest `1c7f7e0...` exists in Artifact Registry with one documented unfixed HIGH exception | Deploy approved current digest; prove migrations, rollback, and restored current schema |
| Database protection | STOPPED/NEVER; backups, seven-day PITR, deletion protection, REQUIRED connector, ENCRYPTED_ONLY transport enabled; latest successful backup 2026-10-07 | Fresh bounded restore proof, approved RPO/RTO/HA, and private-network boundary; no private network returned by current configuration |
| Monitoring | Live Monitoring read returns zero alert policies and zero notification channels | Approved recipients, policies for the required domains, read-back and alert/recovery delivery proof |
| Notification worker | Durable claim/retry source exists | Fix outcomes that write by ID after another worker reclaims a stale delivery; capture/fence the exact claim and endpoint effects |
| Admin verification | Web main `bcb7742`, mock-backed browser/container CI green | Reset confirmation on preview expiry/replacement; prove real document readability, protected hosting, real connectivity, and approved admin access |
| Messaging/email/RTC | Source contracts and historical staging evidence exist | Exact current deployed-revision/provider acceptance and reconnect/reconciliation proof; only migration and notification jobs exist, and the notification Scheduler is paused |
| Mobile crash reporting | Startup and declared dependencies contain no crash-reporting integration | Privacy-reviewed reporting and release-health metadata that exclude credentials, raw requests, and health content |
| Locale/accessibility | English UI and existing time/NGN formatters; 734 tests including focused enlarged-text cases | Explicit English/Nigerian locale policy; remaining focus/contrast/semantics evidence and final TalkBack/device acceptance |
| Platforms/payments | Android automated gates and both unsigned iOS simulator flavors pass | Signed exact release candidate/provider proof; Apple credentials/hardware gates; Paystack test activation only at the final confirmation gate |

APP-READY-061 is a source/control-plane reconciliation, not a claim that the
52-finding program or production acceptance is complete. No backend mutation,
database activation, provider event, or physical-device test occurred.

Remaining gates identified by APP-READY-051: staging upload diagnosis and
deployment of the scanned backend digest with migration/rollback proof;
admin hosting/access and controlled first-admin provisioning; notification,
email, RTC and provider/device acceptance; final Android physical-device
session; iOS/Apple hardware and credentials; and Paystack test-mode activation
only after all preceding gates plus one explicit user confirmation. No
services were activated in this audit. Doctor-authored posts and short-form
video are a separate product decision requiring safety/moderation, storage,
delivery, and cost planning; do not silently expand the Phase 1 marketplace.

## Session and notification startup hardening (APP-READY-045)

The secure session record carries a random generation so refresh-token
rotation preserves the current login while a new login, including one for the
same user, becomes a distinct session. Logout and account deletion clear only
the captured generation; notification registration and unread refresh no
longer block authentication callbacks. Authenticated mutation replay after a
401 requires both a replay-safe client opt-in and a non-empty idempotency key;
non-replayable bodies are not retried.

Notification installation work is serialized client-side and logout cleanup is
bounded. The mobile client also persists and advances a decimal-string
`bindingGeneration` for each installation registration. Backend PR #134
persists and transactionally compares that generation together with the
account's signed registration epoch. Stale registrations are rejected, logout
and account deletion advance the epoch, and PostgreSQL concurrency coverage
passed in CI. Mobile PR #209 merged the matching client contract; its exact
reviewed head passed the 707-test suite, analyzer, staging debug APK, Android
release lint, and release-safety checks. Cross-account installation rebinding
is fenced at both API boundaries; provider delivery, APNs production proof,
and physical-device acceptance remain separate gates.

## RTC Adapter Resource Safety (APP-READY-042)

The LiveKit adapter owns each room and captured track through completion or
release, serializes replacement behind room cleanup, and rejects media toggles
outside the join grant. Cleanup attempts continue after individual SDK errors;
release reports failure when media shutdown cannot be verified. The focused
adapter regression suite contains 51 passing tests. The full suite has 674
passing tests against the 623-test integration baseline, exactly 51 additions;
no existing test was removed or weakened. Analysis is clean.
Debug APK, CI, signed-native, and device gates remain pending; exact limits and
proof are recorded in `RTC_ADAPTER_RESOURCE_SAFETY.md`.

## Consultation Account Authority (APP-READY-041)

Open consultation controllers remain bound to their original account. Async
permission/grant/result delivery and media controls recheck persisted identity;
detected authority loss clears state and releases media. The thirty-nine new
regression cases and remaining SDK/provider/device gates are recorded in
`CONSULTATION_ACCOUNT_AUTHORITY.md`. All 48 targeted controller tests and the
613-test complete suite passed with analysis, signed staging APK/AAB, and
Android release lint before integration. The account-authority controller
changes are present in the current integration base.

## Session Account Isolation (APP-READY-040)

Protected requests, refresh sharing, account reads, explicit session exits,
and notification bindings reject stale cross-account work. Permission errors
are distinct from authentication expiry. `SESSION_ACCOUNT_ISOLATION.md`
documents the authority and atomic-clear contract. Existing tests remain
enabled; provider and physical-device acceptance remain separate gates.

## Android Release Environment Gate (APP-READY-039)

Release packaging requires flavor-specific runtime configuration alongside
protected signing. `ANDROID_RELEASE_CONFIGURATION.md` records required values,
canonical Firebase identity, HTTPS restrictions, regression probes, and the
separate provider/production/device acceptance boundaries. Debug and lint stay
credential-free. No application or dependency contract changed.

## Google Provider Recovery (APP-READY-038)

Google SDK initialization can retry after rejection, concurrent sign-in taps
share one operation, and initialization waits are bounded without duplicating
a timed-out SDK operation. `GOOGLE_PROVIDER_RECOVERY.md` records the contract
and 19 focused regression assertions. Signed-device OAuth/provider proof is
still a separate release requirement; no backend/session authority changed.

## Protected Release Signing (APP-READY-037)

Release packaging no longer falls back to the Android debug key. The protected
environment contract, certificate validation, and remaining upload/Play proof
are documented in `ANDROID_RELEASE_SIGNING.md`. CI uses disposable signing
fixtures only. Local analyzer, all 527 unchanged Flutter tests, staging debug
APK, and executable signing regressions pass. Separate upload keys, protected
backups, and Firebase upload-certificate registration are verified. Signed
distribution artifacts, Play certificate registration, release configuration,
physical acceptance, and production promotion remain explicit open gates.

**Last updated:** 2026-10-09 APP-READY-054 admin-readiness handoff reconciliation.

## Android Release Lint Gate

- Staging release lint now runs in Flutter PR/push CI after the debug APK build.
  Jetifier remains enabled; only the Byte Buddy test artifact is excluded from
  transformation because Jetifier cannot parse its newer class-file version.
- Local `lintStagingRelease` completed with zero errors and five warnings.
  The warnings include Android app-link data-tag structure and backup-policy
  configuration; a passing lint task is not a release-security sign-off.
- Android uses AGP 8.11.1 with Gradle 8.13 and Java 17, a toolchain supporting
  compileSdk 36. The staging debug APK and analyzer pass with this pair, and
  the full Flutter suite remains at 527 passing tests with no test changes.
- Release lint passes with zero errors and six warnings. Local Windows SDK
  paths in ignored `local.properties` require escaped drive-letter colons;
  Flutter may regenerate that file, so check its paths before local lint.
  Signed release artifacts still require separate signing and release proof.

## APP-P1-021 shared UX/accessibility foundation

- Shared marketplace tokens and active Material color schemes use the CareNet
  healthcare-green palette with tested text contrast for primary and semantic
  status pairs.
- `CarenetButton` provides one labelled, tappable button semantic, a minimum
  48-logical-pixel hit target, and a content-driven height that accommodates
  enlarged text.
- Professional Schedule no longer describes requestable times with
  engineering-facing "backend-generated" wording.
- Current route inventory is 79 named identifiers and 78 router registrations;
  `login` is the only reserved unwired constant. The three later routes now have
  explicit rows in the classification table.
- This is a shared foundation only, not an accessibility sign-off for every
  active route. Per-screen contrast, focus order, TalkBack, keyboard, and largest
  text checks remain in the APP-P1-021 follow-up sweep.
- APP-P1-021B adds compact 320x568 / 2x-text regressions for Account,
  Notification Preferences, failed-chat retry, Find Care categories, and
  professional booking date/time selection. It labels unread notifications and
  Schedule active state, prevents repeated live announcements from the
  consultation countdown, makes password-reset guidance account-safe, and
  identifies appointment timestamps as viewer-local. PR #201 merged at
  `e36c5c8`; its Ubuntu CI passed 619 Flutter tests, analysis, debug APK,
  release lint, and release-configuration regressions. Local Windows APK
  packaging remained unusually slow and was stopped; hosted CI is the verified
  build evidence. Screen-reader, keyboard-focus, and device acceptance remain
  open. APP-P1-021C routes legacy `medicalEdit` to the honest deferred page and
  retains `UserEdit` source for later cleanup. PR #202 merged at
  `50924eb`; GitHub CI passed 620 tests, analysis, debug APK, release lint, and
  release configuration/signing regressions. The local Windows debug build for
  that slice was blocked by a full C: drive; hosted CI supplied the build proof.
  APP-P1-021D adds explicit accessible Back semantics to the three active
  professional profile editors. PR #203 merged at
  `5be33cbec2ebdb9a2b0036ad879a68cacd6395ba`. APP-P1-021E improved compact
  Schedule editing; PR #204 merged at
  `010547811430a80bc15e72c6c34d2ae223457106`. The 622-test suite, analysis,
  Ubuntu debug APK, release lint, and release configuration regressions passed
  in CI. APP-P1-021F covers Account status announcements and key action
  semantics; PR #205 merged at `ebe50184dcd3063ec9c138e2b6b127cc08bab8a0`.
  Its GitHub workflow passed the 623-test suite, analysis, debug APK, Android
  release lint, and release signing/configuration regressions.

## Verification upload integrity

- Verification files are SHA-256 hashed off the UI isolate before upload
  completion; completion always sends the file byte count and digest required by
  the backend integrity contract.
- The signed GCS transfer exposes bounded progress and an explicit cancel action.
  Cancellation aborts the active Dio request and never reports review success.
- Signed URLs, object keys, checksums, local paths, and provider internals remain
  absent from the UI and logs.
- Malware scanning, retention/orphan cleanup, background uploads, admin review,
  production bucket IAM proof, and physical-device acceptance remain separate.

## Legal and authentication links

- Canonical Firebase Hosting serves Terms, Privacy, Support, account deletion,
  email-verification fallback, and password-reset fallback pages.
- Signup and Account open the canonical HTTPS legal/support pages.
- Android verified links enter the existing token-confirmation screens only for
  the canonical Hosting host. Production certificate and iOS proof remain
  release gates.

## Authentication and onboarding authority

- Direct phone sign-in/signup routes resolve to the supported email surfaces;
  retained phone, Facebook, and Apple source is not active product UI.
- Legacy community, notification-agreement, and medical-agreement routes resolve
  to the role-appropriate backend-owned setup forms rather than reviving the
  obsolete onboarding chain.
- Patient and professional setup load existing backend profiles before edits.
  Stored catalog codes are restored only when they match the current backend
  catalog; new users must make explicit country, state, health-interest, and
  profession selections instead of accepting a client-chosen first option.

## Account lifecycle

- Account deletion uses the protected backend contract and requires explicit
  `DELETE` confirmation plus a current password or a freshly verified linked
  Google identity.
- A successful request clears the secure session and pending booking/payment
  intents, reports that every session was revoked, and states truthfully that
  required records remain under the applicable retention policy.
- Local account state never grants deletion authority and no hard-erasure or
  restoration behavior is claimed.

## Environment separation

- Canonical Firebase apps are registered for Android and iOS staging/production in `project-a96784ee-811c-46ab-a7b`.
- Android staging (`com.carenet.app.staging`) and production (`com.carenet.app`) are explicit Gradle flavors with distinct labels.
- Runtime environment validation rejects wrong-project Firebase configuration and insecure production API URLs.
- iOS now has shared staging/production Xcode schemes, registered bundle IDs, flavor-specific labels, CocoaPods configuration mappings, and an unsigned simulator-build CI lane. Apple signing, APNs, Apple identity capability, and device proof remain unresolved release gates; production startup remains blocked until its API host is registered.

## Authentication readiness

- Active email sign-in and signup use the green marketplace presentation and scroll under constrained layouts.
- Phone, Facebook, and Apple identity choices are not advertised before supported provider contracts exist.
- Password signup collects only backend-owned registration fields: email, password, and selected role. Profile identity and date of birth remain in the role-specific backend profile flow.
- Mobile password validation matches the backend 15-128 character passphrase policy and known-weak-password baseline.

Honest snapshot of `Mobile-App-master` so a new chat does not rediscover problems.

For a consolidated list of local/mock seams and skipped backend work, see `DEFERRED_WORK.md`.

For the approved Phase 1 product boundary and route/dependency disposition, see
`PHASE_1_MARKETPLACE_BOUNDARY.md`, `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md`, and
`PHASE_1_DEPENDENCY_IMPACT_MAP.md`.

---

## Maturity level

The broad Figma product is no longer the Phase 1 target. The active target is a
focused patient/professional consultation marketplace. Auth/onboarding,
profile/verification, public professional discovery, availability, and the
appointment lifecycle have real backend boundaries. APP-P1-002 replaces the broad
dashboard with backend-session-owned patient/professional navigation, header bell
and account access, honest messaging/notification empty states, and no active drawer.
APP-P1-003 replaces the static Home wireframe with backend-composed patient and
professional identity, readiness, appointment, and professional availability
states. Home selection is deterministic, section failures remain retryable, and
no payment, messaging, call, recommendation, earnings, or demand state is invented.
APP-P1-004 makes `RouteName.search`/`SearchShellPage` the canonical patient Find
Care experience. It loads the verified public directory once, filters only by
name/category/specialty, keeps refresh failures separate from empty results, and
hands the exact backend professional id to the existing Specialist Details route.
The legacy `findMentor` route aliases Find Care instead of opening a competing
marketplace. APP-P1-005 makes `specialistDetails` a fail-closed single-profile
boundary, renders backend-generated requestable times with IANA timezone rules,
persists a 24-hour account-bound booking intent through auth/onboarding, and submits
patient-only appointment requests with a durable idempotency key. Legacy local
detail and booking routes no longer expose seeded booking behavior.
PAY-P1-008 adds backend-authoritative consultation pricing, hosted Paystack
checkout, payment-state refresh, and a professional finance surface for held
earnings, balances, bank setup, payout cooling, ledger, and payout history.
Flutter never confirms payment from browser return and never handles card data.
APP-P1-011 establishes one bounded Dio transport for active API clients,
serializes one refresh and one authenticated retry after an HTTP 401, stores the
complete authenticated session as one versioned secure record with fail-closed
legacy migration, and moves optional notification initialization after the first
app frame with a bounded provider timeout. A 403 is never treated as an expired
session, and public requests remain unauthenticated.
NOTIF-P1-010 adds a backend-owned durable transactional inbox, channel
preferences, FCM installation lifecycle, contextual permission UX, unread header
badge, privacy-safe foreground/background/terminated handling, and owner-checked
allowlisted routing. Push and email remain transport rather than product authority.
Many retained routes and local account/profile seams still require the ordered
Phase 1 narrowing plan before release claims.

Historical numbered phases remain useful implementation records, but they do
not override the `APP-P1` product boundary.

---

## What works today

| Item | Details |
|------|---------|
| App entry | `lib/main.dart` -> `CarenetApp` in `lib/app.dart` |
| Start screen | `RouteName.splash` (not notifications) |
| Splash -> session guard | 800ms then `AuthRepository.restore()` routes usable stored sessions to `dashboard`; missing or invalid restore falls back to `onboarding`. Auth refresh and booking-resume readiness calls are bounded to five seconds so an unavailable dependency cannot leave startup hanging, and pending notification routing begins only after the replacement frame is ready |
| Named routes | Current inventory has **79 constants and 78 router cases**; `login` is the reserved unused constant. Final Phase 1 disposition is in `PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md` |
| Onboarding UI | First launch shows a care gateway with `Browse verified care`, `Create account`, and `Already have an account? Sign in`. Create account opens role-first signup instead of direct phone signup |
| Role-based onboarding boundary | `ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md` records the PRD-backed product decision that CareNet sign-up must branch into patient and professional onboarding before Google sign-up or broader auth expansion. Professional accounts must proceed through profile, credential upload, and manual verification before public listing |
| Role-registration backend contract | `ROLE_REGISTRATION_BACKEND_CONTRACT.md` records the exact frontend/backend boundary: email/password and Google-created accounts must use explicit `PATIENT`/`PROFESSIONAL` role selection before account creation is treated as complete. Existing linked Google sign-in and authenticated Google linking remain valid, but first-time Google sign-up stays disabled until role-selection onboarding exists |
| Role-selection signup | `signUpRole` now sits between signup entry and account creation. Email/password registration sends only `email`, `password`, and the selected backend role. Configured Google signup also requires patient/professional role selection, sends a real Google `idToken` plus selected role, then routes into the matching setup surface. Patient registration continues to `patientOnboardingSetup`; professional registration continues to `medicalProfessional` |
| Patient/professional onboarding requirements | `PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md` defines the serious next onboarding flow against backend `CAR-BE-119` fields. Profile entity/model/repository expansion is now complete; polished patient/professional setup screens remain the next runtime slice |
| Profile contract expansion | `PROFILE_NIGERIA_ONBOARDING_CONTRACT_EXPANSION.md` records that patient/professional profile entities, models, API payloads, and repository methods now support the backend `CAR-BE-119` onboarding fields. Runtime polished setup screens are still the next slice |
| Patient/professional setup UI | `patientOnboardingSetup` and `medicalProfessional` load backend-owned onboarding catalogs, existing profiles, and account readiness. Matching persisted catalog codes are restored for edits; otherwise country/state/interest/profession choices remain empty until explicitly selected. Professional listing still waits for backend verification |
| Onboarding setup recovery | Patient and professional setup expose a serialized retry when the backend catalog/profile/readiness load fails. Retry refreshes backend state without overwriting text entered after the failed load; save remains blocked until catalog data is available |
| Backend-owned onboarding catalog/readiness repository | `OnboardingApiClient` and `OnboardingRepository` consume backend `APP-ID-003` contracts for public `GET /catalogs/onboarding` and protected `GET /account/readiness`. Setup screens now consume this repository without fake local fallback, block save when catalog options are unavailable, and send catalog-owned codes through the currently accepted profile DTO fields |
| Onboarding profile payload code alignment | `ONBOARDING_PROFILE_PAYLOAD_CODE_ALIGNMENT_DECISION.md` decides not to invent unsupported Flutter request fields for `countryCode`, `professionCode`, or `regulatorCode` yet. `ONBOARDING_SETUP_PAYLOAD_VALUE_ALIGNMENT.md` records that patient setup now sends `country`, `state`, and `healthInterests` as backend-accepted catalog codes, while professional setup sends `category`, `licensingCouncil`, `practiceCountry`, and `practiceState` as backend-accepted catalog/regulator codes through current DTO fields |
| Production onboarding domain boundary | `PRODUCTION_ONBOARDING_DOMAIN_HARDENING_BOUNDARY.md` accepts the serious MVP boundary for onboarding: no in-app role switching or dual-mode accounts yet, duplicate identity/application state remains backend-owned, partial professional applications resume through readiness, professional setup stays Nigeria-catalog/regulator driven, required evidence guidance comes from backend catalogs/readiness, and the next slice should plan readiness/resume UX hardening before runtime edits |
| Onboarding readiness route resolver | `ONBOARDING_READINESS_ROUTE_RESOLVER.md` records the runtime resolver. After successful email/password or first-time Google signup, Flutter calls backend `account/readiness` and routes by `nextAction`; readiness failure falls back by selected role so professionals do not go straight to dashboard |
| Onboarding progress/evidence guidance plan | `ONBOARDING_PROGRESS_EVIDENCE_GUIDANCE_PLAN.md` records the next runtime boundary: patient/professional setup and professional verification documents should show backend readiness, required profile fields, required/missing evidence, status/retry copy, and no dummy local approval/readiness state |
| Onboarding readiness progress panel | Patient setup, professional setup, and professional verification documents now show backend-owned readiness guidance. Setup screens display required profile fields returned by `account/readiness`; verification documents displays required/missing evidence with catalog labels plus safe retry copy when requirements cannot load |
| Onboarding regression and phone-smoke plan | `ONBOARDING_REGRESSION_AND_PHONE_SMOKE_PLAN.md` defines the focused proof gate for the hardened onboarding/auth setup: local regression, staging Android patient/professional signup, Google first-time signup, readiness routing, setup progress panels, verification evidence guidance, safe failure states, and exact blocker recording |
| Onboarding phone-smoke execution | `ONBOARDING_PHONE_SMOKE_EXECUTION.md` records that the staging Android debug APK builds with staging gateway and Google config, but real phone smoke is blocked because no Android device is visible to Flutter/ADB |
| Auth onboarding UX recovery | `AUTH_ONBOARDING_UX_RECOVERY.md` records APP-ID-015: the gateway and role-first signup UX from older unmerged APP-66 through APP-73 work was recovered without rolling back newer backend catalog/readiness/profile/verification contracts |
| Recovered onboarding device checkpoint | APP-ID-016 rebuilt the staging APK with the corrected Google Web OAuth client, installed it on Android device `6tkvkvindaqogurk`, confirmed Google login on device, and proved the public staging gateway returns the backend-owned Nigeria catalog at `GET /catalogs/onboarding` after backend redeploy. Controlled onboarding selectors are unblocked without dummy fallback. Public gateway `GET /health/ready` was restored to `200` after applying committed staging migration `20260719090000_identity_catalog_alignment` |
| Onboarding setup regression | `ONBOARDING_SETUP_REGRESSION_AND_PHONE_SMOKE.md` records APP-61 grouped regression proof: 116 auth/onboarding/profile/account tests passed, focused analyze passed, and the staging-configured debug APK built. Phone install/manual smoke is still pending because ADB reported no connected device during APP-61 |
| Sign-up phone | Validates country/region + phone, then routes to `finishSignUp` |
| Sign-up email | Validates email, then routes to `finishSignUp` |
| Sign-up to sign-in links | "Already have an account? Sign in" routes to `signInPhone` / `signInEmail` from matching entry screens |
| Sign-in phone | Validates country/region, phone, and password locally, then routes to `dashboard`; configured Google sign-in obtains a real Google ID token and calls `AuthRepository.googleSignIn` |
| Sign-in email | Validates email and password locally, then routes to `dashboard`; configured Google sign-in obtains a real Google ID token and calls `AuthRepository.googleSignIn` |
| Password recovery | `Forgot Password?` routes to `enterEmail`; valid email requests reset through `AuthRepository.requestPasswordReset`; `resetPasswordConfirm` can complete password reset only when opened with a transient reset token, sends `{ token, newPassword }`, clears local session, and returns to email sign-in. Production app-link setup remains deferred |
| Finish sign-up | Validates required fields, date picker birthday, 15-character password policy, and confirm password match before calling backend registration and routing into the selected role's next setup step |
| Social auth rows on sign-up | Google signup is enabled only when the Google provider is configured and runs through explicit patient/professional role selection before backend account creation. Facebook and Apple remain disabled. Sign-in Google remains separate for existing/linked accounts |
| Dashboard shell | Backend session role resolves a four-tab shell. Patient: Home/Find Care/Appointments/Messages. Professional: Home/Schedule/Appointments/Messages. Notifications and Account/Profile open from header actions; unknown roles fail closed; no drawer is active |
| Find Care discovery | Patient Home and the persistent Find Care tab use `RouteName.search` / `SearchShellPage`. One `ProfileRepository.publicProfessionals()` call loads the backend verified directory; local filtering supports display name, category, and specialty only. Loading, backend-empty, filtered-empty, initial failure, retry, refresh, and refresh-failure-with-preserved-data are distinct. Cards show only supported backend identity fields, and selection passes the exact backend id to `specialistDetails`. No seeded/local professional fallback or duplicate availability/request sheet remains in Search |
| Canonical professional detail | `specialistDetails` requires the exact backend `ProfessionalProfile.id` and calls `GET /professionals/:id`. It renders only approved public fields, omits missing biography, and fails closed for missing/malformed/unavailable IDs without directory scans, `SearchLocalStore`, or seeded identity data |
| Real appointment request handoff | Detail calls the public requestable-times endpoint and renders backend UTC intervals in the professional IANA timezone. A structured 24-hour secure booking intent survives authentication and patient setup, binds to account identity, reuses one idempotency key for safe retry, revalidates the selected time, and sends `POST /appointments` as a patient. Success remains backend `REQUESTED`, not confirmed |
| Role-aware appointment experience | `appointments` loads only the authenticated account's backend-owned list, groups it deterministically, and opens `appointmentDetail` by exact appointment ID. Patient and professional action visibility is centralized by role/status/time, every mutation waits for backend confirmation and reloads authority, 409 and uncertain outcomes never apply a false local status, and reschedule uses backend requestable times at the fixed 30-minute Phase 1 duration |
| Professional Schedule | The professional Schedule reads and atomically replaces `/availability/me` using backend `availabilityWindows`/`isActive` fields, weekday `0..6`, and valid IANA timezones. Add/edit/remove operations are serialized and reconciled with a backend reload. Patients fail closed, and recurring windows are never presented as guaranteed requestable slots |
| Paid consultation experience | Public detail displays the exact backend NGN consultation price and fails closed when not bookable. Appointment Detail renders backend payment state, serializes hosted Paystack initialization with one persisted account/appointment idempotency key, opens only the exact HTTPS Paystack checkout host, and refreshes backend authority on app resume. Professional Account exposes price, held/eligible/available/processing/paid balances, masked payout profile, bank resolution/confirmation, ledger, and payout history. No card data, recipient code, or local payment success is stored or shown |
| Home inner tabs | `Feed`, `Messages`, and `Articles` all render real content; Messages preview hands off to the dedicated `messages` route |
| Messaging flow | Primary Messages destination shows an honest appointment-conversation empty state; seeded social conversations and arbitrary new-chat behavior are not presented as production data |
| Notifications screen | Header bell opens the authenticated backend inbox with loading, empty, error, retained refresh, pagination, unread styling, read-one/read-all, and no seeded fallback. The account area and inbox settings action open backend notification preferences |
| Notification routing | FCM taps carry an opaque notification ID. Flutter retains cold-start taps until navigation and the authenticated session are ready, fetches that owner-scoped notification, marks it read, then resolves only appointment/consultation, conversation, professional verification, professional finance, or account-security route codes. Recoverable session/network/server failures preserve the pending tap for retry; unknown/stale/foreign items fail closed to the inbox. Physical Android staging proof opened the exact appointment conversation from a terminated-app message notification |
| Notification categories | Backend categories are Appointments, Messages, Consultations, Payments, Earnings and payouts, Account and security, and Professional verification. The in-app inbox remains durable while push/email preferences are changed per category |
| Legacy messaging cleanup | `Chat_2.dart` and `Message.dart` are removed; `RouteName.message` is a fail-closed compatibility alias and cannot expose a seeded conversation |
| Readings flow | `readings` now routes into `manageReadings` via the `Add new Readings` tile, and `Done` returns to `readings` |
| Readings export state | `Download Readings` is intentionally deferred and labeled as such until add-reading/device onboarding exists |
| Guided readings lane | Selecting `Blood Sugar` in `manageReadings` now continues into `addDevice`, then into the dedicated `bloodSug` destination shell |
| Blood sugar entry | `bloodSug` now has a real local form: required numeric reading, required context selection, optional note, and a saved-state summary card |
| Readings dashboard sync | Saved blood sugar entries now update the `Blood Sugar` card on `readings` and show a latest-entry summary when the user returns |
| Health record slice | `healthRecord` is a real local health-file summary route with vitals cards and latest blood sugar state from the readings store. The lane intentionally stops here before backend health history, report export, and synced-vital support |
| Blood sugar history/trend | The `bloodSug` lane now keeps short local history and shows a simple up/down trend summary once at least two readings exist |
| Blood sugar history cleanup | Saved blood sugar rows can now be deleted, and the latest-entry/trend state recalculates from the remaining local history |
| Appointments slice | `appointments` now shows real local upcoming/recent appointment sections and a working `Book appointment` handoff into `bookAppointment` |
| Booking form | `bookAppointment` keeps validation and route availability, but local booking confirmation/success has been removed. The form can review typed details only and shows `Backend request not sent`; real appointment request wiring remains deferred |
| Booking draft lifecycle | Appointment drafts can now be locally confirmed or cancelled instead of sitting as inert summaries |
| Emergency slice | `emergency` now shows real local status/update content and hands off into a working `distressCall` form |
| Emergency dispatch seam | Distress updates can now be queued or cleared locally; this is the explicit seam to replace with real backend dispatch/escalation later |
| Articles reader | `articles` now supports a real local list/detail reader flow on the same route instead of only a static preview shell |
| Article saved/read state | Opening an article now marks it read locally, and users can save an article locally from the detail view; later account/content sync should replace that local store |
| Saved articles slice | `savedArticles` now shows an honest empty state, routes back to the article reader, lists locally saved articles from the shared article store, opens saved article details, and removes saved articles locally. Account sync, drafts, and creator/content APIs remain deferred |
| Saved/content-library scope boundary | The saved/content lane intentionally stops after the local `savedArticles` route. `subscribers`, `article-story`, drafts, creator publishing, author/publication analytics, comments, account sync, and content APIs remain deferred until creator/content backend rules exist |
| Published articles slice | `publishedArticles` is now a registered route based on blueprint `/published-articles`, opened from `managePortfolio -> Articles`. It shows `For you` / `Request` / `Drafts`, lists locally known portfolio articles, opens in-page article detail, and keeps edit/publish/delete/comments/analytics/subscriber/draft behavior locked or deferred |
| Case studies slice | `caseStudies` now has a real local case-study library with `All` / `Case studies` / `Best` filters, in-page detail reading, and local read state. Content APIs, verified clinical review, author/publication records, comments, sharing, account sync, and moderation remain deferred |
| Case studies scope boundary | The case-studies lane intentionally stops after local list/filter/detail/read-state behavior. Content APIs, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, and moderation remain deferred until content/backend rules exist |
| Articles scope boundary | Articles intentionally stop here for now; deeper content/account sync is deferred while we move to the next blueprint-backed route |
| Communities slice | `circles` now shows real local community content, routes into `discoverCommunities`, syncs joined communities back into `My communities`, opens a blueprint-backed local `communityProfile`, and supports a real local `createCommunity` flow that hands off into an owner profile note; the communities lane intentionally stops here before invitation acceptance and moderation workflows |
| Q&A slice | The Post tab now hosts a real local Q&A feed with seeded questions, local follow toggles, and a working `qAAsk` form that validates question-style prompts and returns saved local questions back into the feed; the blueprint-backed answer lane now works locally through `qAAnswerRequests` -> `qAAnswerForYou` -> `commentAnswer`, with saved local answers feeding back into answer drafts. The Q&A lane intentionally stops here before the mixed `q-a-post` composer/distribution flow |
| Account slice | The dashboard drawer `Profile` row now routes into a real local `account` screen with account rows and working `deleteAccount` plus `settings` handoffs. `Settings & Profile` now supports local validation and local save for core profile fields, while delete/deactivate remains an explicit local seam until real auth-change and destructive account APIs exist. The account lane intentionally stops here before public profile, scheduling, and auth-security flows |
| Account current read | Account can read `AccountRepository.currentAccount` for safe display-only identity fields. Backend account email/status can replace local display when available; failures show a safe message and keep local display. Profile editing, delete/deactivate, phone/email drafts, password, and security mutations remain local/deferred |
| Email verification request/confirm | Account -> Email address opens a backend-backed screen that reads authenticated email and verification state, and offers `AccountRepository.requestEmailVerification` only when unverified. API acceptance is not proof of delivery. `emailVerificationConfirm` requires a transient token and refreshes current account state. Signup does not force verification; mandatory signup gating remains undecided. Production app-link/device proof remains separate |
| Auth/session/account regression | The current backend-ready auth/account frontend boundary has a focused regression pass covering auth infrastructure, email sign-in, email sign-up completion, session restore, logout/session clear, password reset request boundary, current account read, and email verification request. Remaining auth/account gaps stay deferred instead of being faked |
| Next integration lane | After the auth/session/account regression pass, the next selected lane is workflow guardrail restoration. `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` are referenced by authoritative docs but missing from this checkout, so restore those before more auth/account wiring or another backend contract group |
| Workflow guardrails | `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` are restored and match the current one-slice, honest-backend-ready workflow. Future work should read those docs before implementation |
| Next frontend integration step | Do not add more runtime backend wiring immediately. The next selected slice is a frontend/backend integration checkpoint that summarizes what auth/session/account wiring is complete and what backend/deep-link contracts are needed before password reset confirmation, email verification confirmation, or another contract group is wired |
| Frontend/backend checkpoint | `FRONTEND_BACKEND_INTEGRATION_CHECKPOINT.md` records the completed auth/session/account frontend wiring, remaining blockers, and backend/deep-link questions needed before more runtime wiring |
| Reset/verification token wiring | `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md` defines the frontend boundary for reset and verification confirmation. Runtime Flutter token-confirm routes are wired behind `resetPasswordConfirm` and `emailVerificationConfirm`; tokens are passed as transient route arguments and are not persisted or logged. Platform deep-link production setup remains out of scope |
| Completed backend surface wiring map | `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` records the backend-completed surfaces that remain to be consumed by the Flutter app. The safe order is auth/account staging checkpoint first, then professional/profile/verification, then public professionals/availability, then appointment lifecycle. Phone/OTP, MFA, payments, notifications, reviews, calls, calendar sync, medical notes, prescriptions, admin dashboard behavior, public staging access, and production readiness remain out of scope |
| Auth/account staging checkpoint | `AUTH_ACCOUNT_STAGING_CHECKPOINT.md` records that the developer-private proxy reached staging through `http://127.0.0.1:8080`; `/health` returned `ok`, `/health/ready` returned database/migrations/email `ok`, and readiness reported `googleAuth: disabled` plus `verificationStorage: disabled`. Flutter config key remains `CARENET_API_BASE_URL`. No runtime Flutter code changed |
| App identifiers | Android namespace/application ID and iOS bundle ID now use `com.carenet.app`; iOS test bundle uses `com.carenet.app.RunnerTests`. `GOOGLE_SIGN_IN_FOUNDATION.md` records the remaining OAuth/client/fingerprint/provider prerequisites before Google UI can be enabled |
| Google OAuth prerequisites | `GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md` records Android package `com.carenet.app`, iOS bundle `com.carenet.app`, local debug SHA-1/SHA-256 fingerprints, release fingerprint blocker, current staging `googleAuth: disabled`, and the need to configure backend `GOOGLE_OAUTH_CLIENT_ID` before Flutter Google UI wiring |
| Google sign-in/signup wiring | `google_sign_in` is added behind `GoogleIdTokenProvider`; sign-in phone/email Google rows are enabled only when `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` is configured, then call `AuthRepository.googleSignIn` without a role for existing/linked accounts. Sign-up Google uses the same real provider token but requires explicit `PATIENT`/`PROFESSIONAL` role selection before sending the role to backend auth and routing into patient/professional setup. Google unlink, iOS proof, release signing, production OAuth, phone/OTP, MFA, and broader profile trust rules remain deferred |
| Google account linking | Account now exposes a constrained `Google account` entry below `Authentication`. When `GoogleIdTokenProvider` is configured, it obtains a real Google ID token and calls `AuthRepository.googleLink`; missing config, provider failure, backend validation, and unauthorized failures show safe copy. Account/session email, role, and status remain backend-owned and are not locally mutated after linking. Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, production OAuth, release signing, iOS proof, phone/OTP, MFA, profile creation, admin verification, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Google account linking regression | `GOOGLE_ACCOUNT_LINKING_REGRESSION.md` records focused proof for Account placement, disabled missing-config behavior, configured provider token handoff to `AuthRepository.googleLink`, provider failure without backend call, backend validation/unauthorized safe copy, no raw token/error exposure, and no local account/session mutation |
| Next backend-completed surface after Google linking | `NEXT_SURFACE_AFTER_GOOGLE_LINKING_REGRESSION_DECISION.md` and `ADMIN_VERIFICATION_REVIEW_SURFACE_BOUNDARY.md` selected a separate Web console rather than adding reviewer authority to Flutter; the Web console source and route integration tests are implemented in Web-Developers PRs #1-#4 |
| Admin verification review boundary | The separate Web console provides admin session, queue, signed-read, and approve/reject flows with backend authority. It is not deployed or hosted, and no administrator is provisioned. This patient/professional Flutter app must not add admin routes, hidden admin mode, signed-read handling, approve/reject controls, or admin document previews |
| Final backend-completed mobile surface checkpoint | `FINAL_BACKEND_COMPLETED_MOBILE_SURFACE_CHECKPOINT.md` and the updated `BACKEND_COMPLETED_SURFACE_WIRING_MAP.md` found no remaining backend-completed surface that clearly belongs in this patient/professional mobile app and is still waiting for first-pass runtime wiring. Next mobile-app work should plan stabilization/regression for the already-wired backend milestone |
| Mobile backend integration stabilization plan | `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` defines grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and the next execution slice for the already-wired backend mobile milestone. The next slice should execute the regression pass and record evidence before new product surfaces are added |
| Mobile backend integration regression pass | `MOBILE_BACKEND_INTEGRATION_REGRESSION_PASS.md` records green grouped regression evidence for auth/session/account, profile/verification, discovery/booking, and scheduling lifecycle after one password-recovery widget-test harness fixture fix. Focused analyze reports no issues. This is not a production, public staging, store, admin dashboard, or deferred-module completion claim |
| Mobile milestone handoff/staging boundary | `MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` selects a frontend milestone handoff package as the next lane. Staging seed-data/smoke setup, release-signing/app-link readiness, admin dashboard, and deferred product modules remain separate future lanes |
| Mobile backend milestone handoff package | `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` is the current presentation package for the regression-passed frontend/backend mobile milestone. It lists wired surfaces, regression evidence, staging smoke inputs, admin/release/deferred boundaries, and safe wording. Next work should define staging seed data and smoke execution |
| Staging seed data and smoke plan | `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` defines the staging environment, accounts, verified professional data, availability, appointment lifecycle data, verification upload access, cleanup/reset rules, build commands, manual smoke checklist, evidence requirements, and blocker rules needed before public staging/demo proof can be claimed |
| Staging phone install checkpoint | `STAGING_MOBILE_GATEWAY_PHONE_INSTALL_CHECKPOINT.md` records task 53.2 progress: the Android debug APK builds against the public staging API Gateway URL, installs on the connected Android phone, launches under `com.carenet.app`, and required an Android `MainActivity` package fix. Staging-only patient/professional accounts, verified professional seed, public availability, and backend appointment lifecycle proof now exist. Patient phone sign-in, Account current-account display, Settings/Profile patient profile read, Search public professional listing, public availability display, a real phone UI appointment request, and Notifications -> Appointments own-list rendering passed on the phone with backend `REQUESTED` rows for `cmrnd9w31000701s6tse0lyf1`. Professional phone sign-in also passed; Account showed `PROFESSIONAL account - active`, Appointments exposed role-aware Accept/Decline/Reschedule actions, accept/decline/reschedule returned backend status updates, and terminal recent rows did not expose duplicate completion. Professional Account now exposes Manage Profile and Verification documents, and both routes were proved on the phone. Public availability parsing, UTC request-time generation, Android backup/restore auth-storage issues, the protected `appointments` response envelope, and immediate post-login secure-session writes found during phone smoke are fixed locally and verified. Full real-device phone UI smoke remains open until separate appointment-detail, successful verification upload after staging upload-init HTTP 500 is fixed, optional fresh completion, and cleanup/reset proof are completed or explicitly deferred |
| Profile/public professional contract | `PROFILE_PUBLIC_PROFESSIONAL_CONTRACT.md` defines the backend-backed profile lane. `ProfileRepository` now covers patient self profile, professional self profile, and public verified professional listing. Manage Profile reads the current professional profile for allowed display fields only, and Add Description can update existing professional profile `bio` only. Profile creation, name/category/specialty editing, patient profile UI, public listing UI, verification upload, admin dashboard, availability, appointment lifecycle, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, and public professional detail remain deferred |
| Profile repository boundary | `ProfileApiClient` and `ProfileRepository` now cover `GET/PUT /patients/me`, `GET/PUT /professionals/me`, and public `GET /professionals` behind safe models/entities and focused tests. Protected calls require a stored session and bearer headers; `404` self-profile reads become empty-profile states; public listing sends no auth header. Manage Profile now uses the professional self-read path only |
| Profile bio update | `addDescription` now reads an existing professional profile, preserves `displayName`, `category`, and `specialty`, and updates only `bio` through `ProfileRepository.updateProfessionalMe`. Missing professional profile disables save with an honest empty-profile state. Profile creation, name/category/specialty editing, website, address, patient profile, public listing, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions remain deferred |
| Search public professional listing | `SearchShellPage` reads public verified professionals through `ProfileRepository.publicProfessionals` and does not fall back to seeded local specialists when the backend fails. It maps only public display/category/specialty/bio fields, shows real loading/error/empty states, and passes the exact backend profile ID to canonical Specialist Details. Search itself owns no availability or booking behavior |
| Scheduling/appointment next lane | `SCHEDULING_AVAILABILITY_APPOINTMENT_LANE_DECISION.md` selects scheduling as the next backend-integration lane, but requires a contract slice before runtime wiring. Availability and appointment repository/entities/screen boundaries must be defined before booking, business-hours, own-list, or lifecycle actions are wired. Public detail invention, local fallback booking, payments, notifications, reviews, calls, calendar sync, admin override, notes, and prescriptions remain deferred |
| Scheduling frontend contract | `SCHEDULING_AVAILABILITY_APPOINTMENT_CONTRACT.md` defines accepted availability and appointment routes, allowed payloads, screen mapping, safe errors, and no-local-fallback rules. The next implementation is repository/API boundary only: entities, models, client, repository, DI, and tests; no UI screen wiring yet |
| Scheduling repository boundary | `SchedulingApiClient` and `SchedulingRepository` now cover public availability, professional own availability read/replace, appointment request/list, and appointment accept/decline/cancel/reschedule/complete behind typed entities/models and focused tests. Public availability sends no auth header; protected calls require stored session bearer auth. No UI screens are wired yet, so booking, Specialist Details availability, selected dates persistence, and appointment list/lifecycle screens remain deferred |
| Public requestable times | Specialist Details calls `SchedulingRepository.publicRequestableTimes` for the exact backend professional profile ID and an initial half-open 14-day UTC range. Explicit `Load later times` requests contiguous bounded pages, validates the echoed range and policy, deduplicates UTC starts, and preserves prior results on later-page failure. Flutter renders backend intervals in the professional IANA timezone and does not generate times from recurring windows, weekdays, lead time, horizon, or conflicts |
| Appointment request UI path | `specialistDetails` is the sole active patient request path. The old free-text `bookAppointment` route resolves to Find Care and cannot claim local success. A ready patient explicitly confirms one backend-returned time; success is shown as backend `REQUESTED`, not booked or confirmed |
| Local booking success removal | `bookAppointment`, `publicProfile`, and `findMentor` route constants resolve to canonical Find Care. Retained legacy source remains recoverable but cannot create the appearance of a real booking through normal or direct route resolution |
| Concrete appointment request UX | Specialist Details loads one backend profile and backend-generated requestable times, resumes a secure 24-hour account-bound intent through authentication and patient setup, and calls `requestAppointment` with a persistent idempotency key |
| Appointment request time options | `AppointmentRequestTimeOptions` remains historical/deferred source and is not used by canonical detail. Backend `requestable-times` owns fixed duration, cadence, timezone conversion, lead time, horizon, availability, and accepted-conflict rules |
| Appointment request handoff | Find Care passes only the exact backend professional profile ID to Specialist Details. Detail, time loading, and submission fail closed without seeded profiles, local availability, or draft-booking fallback |
| Own appointment list read | `appointments` now reads `SchedulingRepository.ownAppointments` and renders backend appointment statuses as upcoming/recent cards with safe loading, empty, and error states. Seeded local appointment cards are no longer used as fallback. Accept/decline/cancel/reschedule/complete UI remains deferred |
| Scheduling next UI lane | `SCHEDULING_NEXT_UI_LANE_DECISION.md` selects patient appointment cancellation as the next narrow runtime lane after request/list visibility. Professional availability management, professional accept/decline, reschedule, complete, payments, notifications, calls, calendar sync, notes, and prescriptions remain deferred |
| Patient appointment cancellation | `appointments` now exposes `Cancel appointment` only for eligible upcoming `REQUESTED`/`ACCEPTED` backend cards, calls `SchedulingRepository.cancelAppointment`, and updates the visible card from the backend response. Terminal/recent cards do not expose cancellation; failures show safe errors without local fallback |
| Scheduling regression decision | `SCHEDULING_REGRESSION_DECISION.md` selects a patient-path regression checkpoint before professional availability management or professional lifecycle UI. The next slice should prove Search listing/availability/request and Appointments own-list/cancel behavior before expanding the scheduling surface |
| Scheduling patient-path regression | `SCHEDULING_PATIENT_PATH_REGRESSION.md` records focused proof for the backend-backed patient scheduling path: Search public listing/availability/request, generated time options, Appointments own-list status rendering, requested/accepted cancellation, terminal/recent hidden actions, and safe failure states |
| Professional availability boundary | `PROFESSIONAL_AVAILABILITY_UI_BOUNDARY_DECISION.md` selects `selectedDates` as the professional own-availability management surface. `manageProfile` remains the entry point/summary surface; availability persistence is separate from profile mutation and appointment lifecycle UI |
| Professional availability management | `selectedDates` now reads backend own availability through `SchedulingRepository.ownAvailability`, renders backend empty/error/window states, and saves via `replaceOwnAvailability` while preserving other existing backend weekdays. Success appears only after repository success; raw backend errors and local saved-draft claims are not shown |
| Professional appointment lifecycle boundary | `PROFESSIONAL_APPOINTMENT_LIFECYCLE_UI_BOUNDARY_DECISION.md` selects role-aware professional accept/decline as the next narrow lifecycle UI. The Appointments screen must read authenticated session role before showing professional actions; reschedule/complete remain separate decisions |
| Professional appointment accept/decline | `appointments` now reads authenticated session role via `SessionStore` before showing role-specific actions. Professional users see `Accept`/`Decline` only on eligible upcoming `REQUESTED` appointments; patient users keep cancellation and do not see professional actions. Success replaces visible status from backend response; failures use safe errors |
| Professional appointment lifecycle regression | `PROFESSIONAL_APPOINTMENT_LIFECYCLE_REGRESSION.md` records focused proof for patient cancel, professional accept/decline, role separation, state separation, safe failure behavior, and the absence of reschedule/complete/payment/calendar/notes UI |
| Appointment reschedule/completion boundary | `APPOINTMENT_RESCHEDULE_COMPLETION_BOUNDARY_DECISION.md` selects professional completion before reschedule. Completion should be professional-only, accepted-only, after scheduled end time, and should send no trusted request body; reschedule remains deferred until availability/time-selection UX is decided |
| Professional appointment completion | `appointments` now shows `Complete` only to professional sessions for accepted backend appointments whose scheduled end time has passed. The action calls `SchedulingRepository.completeAppointment`, replaces visible status from the backend response, and keeps safe error handling. Reschedule, patient completion, payments, notifications, calendar sync, reviews, notes, prescriptions, admin override, no-show/disputes, and calls remain deferred |
| Appointment completion regression | `APPOINTMENT_COMPLETION_REGRESSION.md` records focused proof for exact scheduled-end completion, patient denial, cancelled/declined/completed denial, safe failure behavior, and absence of reschedule/payment/calendar/review/notes/prescription controls on completion-eligible cards |
| Post-completion scheduling lane | `POST_COMPLETION_SCHEDULING_LANE_DECISION.md` selects a broader scheduling core regression checkpoint before any reschedule UX/runtime work. Reschedule remains deferred until actor rules, eligible statuses, time/duration selection, availability re-checks, conflict handling, audit, notification, calendar, and payment boundaries are decided |
| Scheduling core regression checkpoint | `SCHEDULING_CORE_REGRESSION_CHECKPOINT.md` records focused proof across Search public listing/availability/request, Appointments own-list/cancel/accept/decline/complete, selectedDates availability management, scheduling repository payload boundaries, safe error/no-fallback behavior, and absence of reschedule/payment/notification/calendar/review/notes/prescription/call/admin UI |
| Post-regression scheduling lane | `POST_REGRESSION_SCHEDULING_LANE_DECISION.md` selects a dedicated appointment reschedule UX/product boundary decision before any runtime reschedule wiring. Reschedule remains blocked until actor, status, time-selection, duration, conflict, payload, success/error, and deferred notification/payment/calendar/review/notes/call/admin boundaries are defined |
| Appointment reschedule UX boundary | `APPOINTMENT_RESCHEDULE_UX_BOUNDARY_DECISION.md` allows a constrained next runtime slice for patient/professional reschedule of upcoming `REQUESTED`/`ACCEPTED` appointments using existing public availability and generated request options. Success must replace the card from backend response, expected status returns to `REQUESTED`, and payments, notifications, calendar sync, reviews, calls, admin override, notes, prescriptions, medical records, free-text datetime entry, and reschedule reasons remain deferred |
| Appointment reschedule wiring | `appointments` now exposes `Reschedule` only for patient/professional sessions on upcoming `REQUESTED`/`ACCEPTED` backend appointment cards. It loads public availability for the appointment professional, generates bounded request options, submits `requestedStartAt` and `durationMinutes` through `SchedulingRepository.rescheduleAppointment`, replaces visible status from the backend response, and keeps safe errors/no raw backend messages. Non-patient/non-professional roles, recent cards, and terminal states do not expose reschedule |
| Appointment reschedule regression | `APPOINTMENT_RESCHEDULE_REGRESSION.md` records focused proof for patient/professional reschedule success, backend `REQUESTED` response handling, non-patient/non-professional hiding, recent/terminal hiding, empty generated-option handling, safe failure messages, narrow payload behavior, and continued absence of payments, notifications, calendar, reviews, calls, admin, notes, and prescriptions UI |
| Scheduling smoke checkpoint decision | `SCHEDULING_CORE_PAUSE_OR_SMOKE_DECISION.md` pauses scheduling feature expansion and selects a staging smoke checkpoint next. The current local regression evidence is strong enough for the scoped core, but app-build/staging proof is still missing before claiming the scheduling core is externally proven |
| Scheduling staging smoke checkpoint | `SCHEDULING_CORE_STAGING_SMOKE_CHECKPOINT.md` records that the developer-private staging proxy reaches `/health` and `/health/ready`, database/migrations/email/googleAuth report `ok`, verification storage remains disabled, public professionals endpoint is reachable but empty, unauthenticated protected scheduling routes return `401`, and a staging-configured debug APK builds. End-to-end appointment smoke remains blocked by missing staging patient/professional/verified-professional/availability/appointment data |
| Scheduling smoke data decision | `SCHEDULING_SMOKE_DATA_OR_NEXT_SURFACE_DECISION.md` rejects ad hoc Flutter-created staging scheduling users/data. Full scheduling smoke remains blocked until deliberate backend/staging test data exists: patient/professional accounts, a verified public professional, availability windows, appointment path, and cleanup/reset guidance |
| Next backend-completed surface | `NEXT_BACKEND_COMPLETED_FLUTTER_SURFACE_DECISION.md` selects patient self profile as the next Flutter surface because `ProfileRepository.patientMe/updatePatientMe` already exist and do not depend on scheduling seed data or verification storage. Runtime wiring is blocked until Settings/Profile maps backend `name`, `age`, and `location` separately from username, email, auth/security, public profile, and destructive account behavior |
| Patient profile settings mapping | `PATIENT_PROFILE_SETTINGS_MAPPING_DECISION.md` maps Settings/Profile to patient `name`, `age`, and `location` only. The next runtime slice should read `ProfileRepository.patientMe`, show safe loading/error/empty-profile states, display backend name and read-only age/location when available, and avoid `updatePatientMe` until a separate mutation slice |
| Patient profile read wiring | Settings/Profile now reads `ProfileRepository.patientMe`, shows safe loading/error/empty-profile states, displays backend patient `name`, `age`, and `location` read-only when available, and keeps local save behavior local. It does not call `updatePatientMe` or create profile data |
| Patient profile read regression | `PATIENT_PROFILE_READ_REGRESSION.md` records focused proof for patient profile read success, empty-profile, safe failure, local save preservation, and absence of `updatePatientMe` mutation |
| Patient profile update boundary | `PATIENT_PROFILE_UPDATE_BOUNDARY_DECISION.md` selects a constrained next runtime slice: Settings/Profile may update backend patient `name` only from combined first/last name. Age/location mutation, username/email/bio persistence, auth/security, verification, scheduling, and destructive account actions remain deferred |
| Patient profile name update | Settings/Profile now calls `ProfileRepository.updatePatientMe` with combined first/last name only, shows safe loading/error behavior, preserves local username/email/bio save behavior, and blocks false success on backend name-save failure. Age/location mutation and account/security fields remain deferred |
| Patient profile name update regression | `PATIENT_PROFILE_NAME_UPDATE_REGRESSION.md` records focused proof for name-only payload, no age/location mutation, safe failure/no false success, local username/email/bio preservation, and deferred-work accuracy |
| Next backend-completed surface after patient profile | `NEXT_SURFACE_AFTER_PATIENT_PROFILE_DECISION.md` selects Specialist Details public professional/availability wiring as the next narrow Flutter lane. The next runtime slice should use existing public professional and public availability repository surfaces without inventing a public detail endpoint, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims |
| Specialist Details public availability | Historical implementation used the public directory, recurring availability, and Flutter-generated request options. APP-P1-005 supersedes that path with one public detail request plus backend-generated requestable times; the old generator and local compatibility path are not active |
| Specialist Details public availability regression | `SPECIALIST_DETAILS_PUBLIC_AVAILABILITY_REGRESSION.md` records focused proof for backend id resolution, Search handoff, dashboard local compatibility, no local slot fallback, generated request payload, safe request/availability failures, and absence of public-detail endpoint invention or deferred feature leakage |
| Next surface after Specialist Details | `NEXT_SURFACE_AFTER_SPECIALIST_DETAILS_DECISION.md` selects Find Mentor public professional replacement as the next narrow Flutter lane. The next runtime slice should replace local mentor cards with public verified professionals where a repository is available and pass backend ids into Specialist Details without local slot fallback, verification/admin behavior, payments, reviews, calls, calendar sync, staging data, or production claims |
| Find Mentor compatibility | `RouteName.findMentor` now resolves to canonical `SearchShellPage`; normal route resolution cannot open the legacy mentor marketplace. `FindMentorShellPage` remains only as recoverable deferred source pending later dead-code cleanup |
| Find Mentor public professionals regression | `FIND_MENTOR_PUBLIC_PROFESSIONALS_REGRESSION.md` records focused proof for loading, empty, success, category filtering, backend id handoff, safe failure, no local fallback/direct fake booking, dashboard local compatibility, Specialist Details compatibility, and deferred-work accuracy |
| Next surface after Find Mentor | `NEXT_SURFACE_AFTER_FIND_MENTOR_DECISION.md` selects professional verification upload/list as the next backend-completed Flutter lane. The next slice must define the private-document/file-picker/upload/list/status boundary before runtime implementation |
| Professional verification repository boundary | `PROFESSIONAL_VERIFICATION_UPLOAD_LIST_BOUNDARY.md` accepts Manage Profile as the professional-owned entry point, and `VerificationRepository` now covers owner document list, upload-init, internal signed upload PUT, and upload-complete behind safe entities and focused tests. Runtime screen wiring, file picker UI, visible upload flow, admin review, private previews/downloads, public document access, staging data, and production claims remain deferred |
| Professional verification documents shell | Manage Profile now has a `Verification` entry that opens `professionalVerificationDocuments`. The shell reads owner verification documents through `VerificationRepository.documents`, shows loading/empty/safe-error states, displays safe status metadata only, and keeps upload locked until the file-picker/upload UX boundary is decided |
| Professional verification upload picker boundary | `PROFESSIONAL_VERIFICATION_UPLOAD_PICKER_BOUNDARY.md` selects a PDF-capable picker path for the next runtime upload slice. Do not use the existing `image_picker` dependency for verification upload because PDF support is required. Runtime upload and package changes remain queued for 52.79 |
| Professional verification upload flow | `professionalVerificationDocuments` supports one controlled upload flow with `file_picker`, document type selection, PDF/JPEG/PNG validation, a 10 MB app-side size guard, off-UI-isolate SHA-256, bounded transfer progress, active cancellation, integrity completion, safe states, and owner document reload. Previews/downloads, admin review, rejection reasons, malware scanning, public exposure, and production claims remain deferred |
| Professional verification upload regression | `PROFESSIONAL_VERIFICATION_UPLOAD_REGRESSION.md` records focused proof for owner list success/empty/error, upload success with reload, picker cancellation, invalid type, 10 MB guard, safe backend failure, dependency presence, and private-data non-exposure |
| Next surface after verification regression | `NEXT_SURFACE_AFTER_VERIFICATION_UPLOAD_REGRESSION_DECISION.md` selects professional basic profile field editing as the next backend-completed Flutter surface, with a boundary decision before runtime `displayName`/`category`/`specialty` wiring. Website/address, verification expansion, admin review, scheduling staging data, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional basic profile edit boundary | `PROFESSIONAL_BASIC_PROFILE_EDIT_BOUNDARY.md` selects `editYourName` as a display-name-only runtime update. The next implementation must read an existing professional profile, preserve category/specialty/bio, block empty-profile creation, and keep website/address/account/verification/availability/appointment/payment/review/call/calendar/note/prescription data out |
| Professional display name update | `editYourName` now reads an existing professional profile, pre-fills backend `displayName`, saves only a changed `displayName` through `ProfileRepository.updateProfessionalMe`, preserves existing category/specialty/bio, blocks empty-profile creation, and shows safe validation/error/success states. Category/specialty editing, profile creation, website/address persistence, verification, availability, appointments, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional display name update regression | `PROFESSIONAL_DISPLAY_NAME_UPDATE_REGRESSION.md` proves the current display-name-only profile update boundary with focused tests, analyzer, targeted preservation checks, empty-profile blocking, safe failure handling, and deferred-work accuracy. No broader profile editing is selected until the next decision slice |
| Next surface after display-name regression | `NEXT_SURFACE_AFTER_DISPLAY_NAME_REGRESSION_DECISION.md` selects professional category/specialty editing as the next backend-completed Flutter surface, with a boundary decision before runtime wiring. Profile creation, website/address persistence, verification/admin, scheduling staging data, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging, and production claims remain deferred |
| Professional category/specialty edit boundary | `PROFESSIONAL_CATEGORY_SPECIALTY_EDIT_BOUNDARY.md` selects a new constrained category/specialty edit surface. The next implementation must require category, allow optional/cleared specialty as null, preserve existing displayName/bio, block profile creation, and keep website/address/account/verification/availability/appointment/payment/review/call/calendar/note/prescription data out |
| Professional category/specialty update | Manage Profile Basic now exposes `Edit category`, opening `editProfessionalDetails`. The route reads the existing professional profile, prefills category/specialty, requires category, sends cleared specialty as `null`, preserves existing displayName/bio in `ProfileRepository.updateProfessionalMe`, blocks empty-profile creation, and shows safe loading/error/success states. Website/address, account identity, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Professional category/specialty update regression | `PROFESSIONAL_CATEGORY_SPECIALTY_UPDATE_REGRESSION.md` records focused proof for entry separation from display-name edit, backend category/specialty prefill, category-required validation, displayName/bio preservation, specialty clearing as `null`, empty-profile blocking, safe backend failure, and absence of broader profile/module behavior |
| Next surface after category/specialty regression | `NEXT_SURFACE_AFTER_CATEGORY_SPECIALTY_REGRESSION_DECISION.md` selects protected Google account linking as the next backend-completed Flutter surface. The next slice must define the UI boundary before runtime wiring; Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin dashboard, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Google account linking UI boundary | `GOOGLE_ACCOUNT_LINKING_UI_BOUNDARY.md` accepts Account as the host surface for protected Google linking: add a Google account entry below Authentication, require configured `GoogleIdTokenProvider`, call `AuthRepository.googleLink`, show safe loading/success/error states, and keep account/session fields backend-owned. Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin dashboard, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain deferred |
| Logout/session clear | Account has a real `Log out` action that calls `AuthRepository.logout`; success clears the navigation stack back to onboarding, while failure shows a safe inline error. Destructive account deletion, MFA/PIN, phone auth, social auth, and password reset remain separately scoped |
| Change authentication slice | `changeAuthentication` is now a registered route from Account -> Authentication. It shows local two-step verification copy and keeps Change PIN, Turn off, and Learn more visibly locked/deferred until auth backend, re-authentication, secure storage, audit, and product security copy exist |
| Turn on authentication slice | `turnOnAuthentication` is now a registered route from Change Authentication -> Review turn-on setup. It shows blueprint two-step verification copy and keeps Turn on disabled until PIN/session/audit backend rules exist |
| Turn on authentication scope boundary | The turn-on-authentication lane intentionally stops after the local two-step verification review route. PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D027) |
| Create PIN slice | `createPin` is now a registered route from Turn On Authentication -> Review PIN setup. It validates local 6-digit PIN format and can hand a valid route-local draft into `confirmPinSave` without storing PIN or enabling 2FA |
| Create PIN scope boundary | The create-pin lane intentionally stops after local PIN format validation and route-local confirmation handoff. Secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D028) |
| Confirm PIN Save slice | `confirmPinSave` is now a registered route from Create PIN -> Review confirmation step. It validates a local 6-digit confirmation, compares against the route-local draft when provided, and shows a ready-for-secure-backend-storage summary without saving PIN or enabling 2FA |
| Confirm PIN Save scope boundary | The confirm-pin-save lane intentionally stops after route-local confirmation. Secure PIN storage, session/device checks, audit/security notifications, recovery rules, account persistence, and enabling two-step verification remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D029) |
| Reminder slice | `reminder` is now a registered route from the Notifications app-bar calendar action. It provides a selectable calendar, updates the selected-date heading, and shows an honest date-specific empty state without creating fake reminders or scheduling notifications |
| Reminder scope boundary | The reminder lane intentionally stops before reminder records, persistence/API ownership, recurrence/timezone rules, notification delivery, permission behavior, edit/delete rules, and failure states (`DECISIONS.md` D030) |
| Schedules slice | `schedules` is now a registered route from the dashboard drawer Schedule row. It provides a selectable calendar, expandable seeded event details for the current date, and an honest empty state for dates without local schedule data; Add/Edit/Share/Delete stay visibly disabled |
| Schedules scope boundary | The schedules lane intentionally stops before schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permissions, and failure states (`DECISIONS.md` D031) |
| Selected dates slice | `selectedDates` is now a registered route from Manage Profile -> Business -> Edit hours. It supports date selection, all-day/time-range drafts, end-after-start validation, and a prepared local summary without mutating profile schedule state |
| Selected dates scope boundary | The selected-dates lane intentionally stops before profile/business-hours persistence, timezone and overlap rules, multiple hour sets, upgrade entitlements, server conflicts, and availability APIs (`DECISIONS.md` D032) |
| Community invitations/discover slice | `discoverCommunities` now covers the blueprint `/community-invitations-discover` tabs. For you keeps local discover/join, Requests accepts a seeded invitation into joined-community state, and Drafts shows an honest empty state |
| Community invitations/discover scope boundary | The community-invitations-discover lane intentionally stops before invitation delivery, rejection/approval workflows, draft persistence, invite permissions, moderation, and backend membership sync (`DECISIONS.md` D033) |
| Find mentor slice | `findMentor` is now a registered route from the dashboard drawer Providers row. It reuses the local specialist store, shows mentor cards with available times, supports category filtering, and hands Book Appointment to the existing local booking form |
| Find mentor scope boundary | The find-mentor lane intentionally stops before live availability, mentor/profile APIs, detailed reviews, pricing/payment rules, booking confirmation, provider calendar sync, and cancellation policy (`DECISIONS.md` D034) |
| Specialist details slice | `specialistDetails` is now a registered route from Find Mentor -> View details. It renders local provider info, day/time chip selection, selected-slot summary, and hands Book appointment to the existing local booking form |
| Specialist details scope boundary | The specialist-details lane intentionally stops before live availability, review details, payment/pricing enforcement, provider profile APIs, confirmed booking slots, calendar sync, and cancellation/error states (`DECISIONS.md` D035) |
| Remaining route triage | After `specialistDetails`, the remaining `routes.json` tail is component/demo/grid/marketing routes. Product work resumes at the earlier unresolved creator/content route `/published-articles` before touching payment, subscriptions, ads, or media upload (`DECISIONS.md` D036) |
| Published articles boundary | `/published-articles` is a frontend-ready read/list/detail surface only. Subscribers, article-story, add-new-article, persisted drafts, requests, subscriber access, comments, analytics, moderation, edit/delete, account sync, and content persistence remain backend/product replacement work (`DECISIONS.md` D038) |
| Route triage after creator content | After `publishedArticles`, backend-heavy creator/payment/media routes are skipped until contracts exist. Product work resumes at `/edit-your-name` as the next Manage Profile basic-info draft route (`DECISIONS.md` D039) |
| Edit your name slice | `editYourName` is now a registered route from Manage Profile `Edit`. It validates a local name draft, shows inline errors, and displays a prepared-name summary that explicitly does not save profile state |
| Edit your name boundary | `editYourName` stops after local validation and draft summary. Profile name persistence, account identity sync, verification status changes, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D041) |
| Edit your website slice | `editYourWebsite` is now a registered route from Manage Profile Basic `Edit website`. It validates a local website draft, shows inline errors, and displays a prepared-website summary that explicitly does not save profile state |
| Edit your website boundary | `editYourWebsite` stops after local validation and draft preparation. Profile website persistence, verification changes, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D043) |
| Add description slice | `addDescription` is now a registered route from Manage Profile About `Edit description`. It reuses the shared multiline text field, validates local profile copy, and shows a prepared-description summary that explicitly does not save profile state |
| Add description boundary | `addDescription` stops after local validation and draft preparation. Profile-copy persistence, moderation/compliance review, public profile publishing, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D045) |
| Manage Profile route triage after description | After `/add-desicription`, `/edit-your-email` is skipped because account/security email routes already own email review/change/verification drafts, `/add-time-and-day` is skipped because `selectedDates` already owns local business-hours drafting, and `/set-address` is selected as the next honest profile draft route (`DECISIONS.md` D046) |
| Set address slice | `setAddress` is now a registered route from Manage Profile Basic `Edit address`. It validates local location/address text and shows a prepared-address summary that explicitly does not save profile state or use location services |
| Set address boundary | `setAddress` stops after local validation and draft preparation. Profile-address persistence, location/geocoding/map services, device-location permissions, verification changes, account identity sync, audit/security records, conflict handling, and backend profile APIs remain deferred (`DECISIONS.md` D048) |
| Remaining blueprint tail triage | After Manage Profile basics, no new honest frontend-only route is selected from the remaining blueprint tail. Ads/payments/audience, media upload/recording, backend account verification, duplicate feed/Q&A/schedule/reminder routes, and component/demo frames are deferred or already covered (`DECISIONS.md` D049) |
| Historical frontend coverage audit | At that earlier audit, the route inventory was reported as 68 wired routes. Later appointment detail, consultation, finance, and other routes superseded that count; current inventory is 79 constants / 78 cases. Backend/product seams remain in `DEFERRED_WORK.md` (`DECISIONS.md` D050) |
| Backend/product readiness handoff | `DEFERRED_WORK.md` now groups deferred seams by contract group and replacement path so backend work can replace local stores/repositories without rewriting completed frontend routes (`DECISIONS.md` D051) |
| Historical frontend handoff review | At that review, 68 wired routes were reported and `login` was the only reserved unwired constant. The live count has since advanced to 78 cases / 79 constants; route-specific UX/accessibility review continues under APP-P1-021 (`DECISIONS.md` D052) |
| First backend contract selection | Backend/product integration starts with `Auth/session/account persistence`. The next slice must define the API/session/provider/repository contract before implementation; no locked controls are enabled by this decision (`DECISIONS.md` D053) |
| Auth/session/account contract | `docs/AUTH_SESSION_ACCOUNT_CONTRACT.md` defines the Flutter-side backend contract: environment/base URL rules, REST API style, bearer-token auth, secure refresh-token storage, auth/account models, validation/error behavior, provider boundaries, and repository replacement plan. Runtime screens remain local/client-only until the next infrastructure slice (`DECISIONS.md` D054) |
| Auth/session/account infrastructure | The app now has a backend-ready auth boundary without screen wiring: `CareNetApiConfig`, `AuthApiClient`, secure/in-memory session stores, auth/session/user models, `AuthRepository`, `AccountRepository`, DI registration, and focused tests. Existing auth screens still use local/client-only behavior until a later wiring slice (`DECISIONS.md` D055) |
| Email sign-in backend wiring | `signInEmail` now preserves local validation, calls `AuthRepository.login` for valid credentials, shows a loading state while pending, navigates only after repository success, and shows safe backend/config errors without navigating. Phone sign-in, sign-up, social auth, password reset, and account-security flows remain unchanged/deferred (`DECISIONS.md` D056) |
| Email sign-up backend wiring | `signUpEmail` still validates email before opening `finishSignUp`; `finishSignUp` now accepts the validated email, preserves full local form validation, calls `AuthRepository.register` with patient role/profile data, shows loading/error states, and navigates only after repository success. Phone sign-up, social auth, password reset, and account-security flows remain unchanged/deferred (`DECISIONS.md` D057) |
| Change authentication scope boundary | The change-authentication lane intentionally stops after the local two-step verification information route. PIN creation/confirmation, disabling two-step verification, password re-authentication, secure PIN storage, device/session checks, audit logs, phone/email verification, and security help copy remain deferred until auth backend/product contracts exist (`DECISIONS.md` D019) |
| Add phone number slice | `addPhoneNumber` is now a registered route from Account -> Phone number. It validates a local phone-entry draft and shows a ready-for-SMS-verification summary without changing the account phone number or pretending to send an OTP |
| Add phone number scope boundary | The add-phone lane intentionally stops after the local phone-entry draft. OTP/SMS delivery, code verification, phone uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery rules, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D020) |
| Confirm phone number slice | `confirmPhoneNumber` is now a registered route from Add Phone Number -> Open confirmation step. It validates a local phone confirmation draft and shows a ready-for-backend-OTP-verification summary without sending OTP or changing account phone state |
| Confirm phone number scope boundary | The confirm-phone-number lane intentionally stops after the local confirmation draft. OTP/SMS delivery, code confirmation, phone uniqueness checks, session updates, rate limiting, audit/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D026) |
| Add email slice | Legacy `addEmail` retains its local draft source but is not the Account email entry. The active Account `Email address` row opens backend-owned `editEmail`; `addEmail` must not alter the authenticated account email |
| Add email scope boundary | The add-email lane intentionally stops after the local email-entry draft. Verification email delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D022) |
| Edit email slice | `editEmail` is registered to a backend-backed verification screen. It displays the authenticated account email and actual verification state, and can request verification for an unverified address. Email change/removal remain deferred |
| Edit email scope boundary | The edit-email lane intentionally stops after the local current-email management route. Email removal, password re-authentication, recovery rules, account-session updates, audit/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D024) |
| Enter password to save slice | `enterPasswordToSave` is now a registered route from Edit Email -> Review password step. It validates a local password entry and shows a ready-for-backend-reauthentication summary without verifying the password, saving account changes, or mutating account state |
| Enter password to save scope boundary | The enter-password-to-save lane intentionally stops after the local password-entry validation route. Real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D025) |
| Change email slice | `changeEmail` is now a registered route from Add Email -> Change existing email. It validates a local change-email draft, rejects the current email, and shows a ready-for-code-verification summary without changing the account email address or pretending to send a code |
| Change email scope boundary | The change-email lane intentionally stops after the local change-email draft. Verification-code delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D023) |
| Password slice | `password` is now a registered route from Account -> Password. It shows local password security information and the current local password hint; Edit password remains visibly locked/deferred until auth backend and password-change contracts exist |
| Password scope boundary | The password lane intentionally stops after the local password security information route. Password editing, current-password verification, password policy enforcement, code confirmation, session invalidation, recovery/security notifications, and account persistence remain deferred until auth backend/provider contracts exist (`DECISIONS.md` D021) |
| Public profile slice | `publicProfile` now shows a read-only local professional profile with article previews, specializations, contact details, about text, and section summaries. `Message` opens messages, `Schedule` opens the local booking form, and portfolio/podcast/share are explicitly disabled until creator/media/sharing workflows exist |
| Public profile scope boundary | The public-profile lane intentionally stops after local read-only profile content plus real message/schedule handoffs. Profile APIs, creator portfolio, media/podcast profile content, product-approved sharing, provider scheduling, verified public identity, public reviews/testimonies, and subscription/upgrade behavior remain deferred |
| Owner circle profile slice | `ownerCircleProfile` is now a registered local route based on blueprint `/owner-circle-profile`. It shows the owner circle content, member previews, articles, events, and owner-only settings actions that are visibly locked/deferred until community-management APIs exist |
| Owner circle scope boundary | The owner-circle lane intentionally stops after the local owner profile and locked settings surface. Permissions, member invitations, role changes, moderation, editing circle details, sharing, favourites sync, reporting, exiting, and destructive circle deletion remain deferred until backend/community-management and product safety rules exist |
| Manage profile slice | `manageProfile` is now a registered local route based on blueprint `/manage-profile`. It shows local Basic, About, Business schedule, and Articles sections, with real handoffs to `editYourName`, `editYourWebsite`, `setAddress`, `addDescription`, `messages`, `selectedDates`, and `managePortfolio`; Events, Boost, Podcast, Share, member management, and group-detail edits remain visibly disabled/deferred |
| Manage profile scope boundary | The manage-profile lane intentionally stops after local profile summary plus settings/messages handoffs. Profile update APIs, schedule persistence, events, ads/payment review, media, sharing, member management, group persistence, and creator verification remain deferred until backend/product contracts exist. Replacement contract is documented in `DEFERRED_WORK.md` |
| Manage portfolio slice | `managePortfolio` is now a registered local route based on blueprint `/manage-portfolio`. `Manage Profile` hands off from `Articles -> Manage`; the route shows local Page/Circles portfolio content behind `ManagePortfolioLocalStore`, with real `Edit -> settings` and `Message -> messages` handoffs. Add new article, Upload new podcast, Upgrade, Events, Boost, Podcast, and Share remain visibly disabled/deferred |
| Manage portfolio scope boundary | The manage-portfolio lane intentionally stops after the local Page/Circles portfolio surface. `/add-new-article`, `/add-new-podcast`, `/recording`, ads/boosting, subscription upgrades, payment setup, moderation, analytics, and sharing remain deferred until backend/product contracts exist (`DECISIONS.md` D018) |
| Podcast slice | Podcast notifications now route to a real local `podcast` screen with local episode content, image-backed episode cards, and local `Watch` state. The podcast lane intentionally stops here before streaming, episode APIs, comments, uploads/recording, account sync, and search filtering so those backend/media workflows are not faked |
| Focused verification | Shared widget tests plus auth, dashboard, messaging, notifications, and readings flow tests pass; focused analyze is clean |

---

## What was wrong before Phase 0 (fixed)

| Issue | Fix |
|-------|-----|
| `home: NotificationsPage()` bypassed all flows | Removed; `initialRoute` + `onGenerateRoute` |
| `Messages.dart` had its own `main()` | Removed |
| Splash 5 second delay | 800ms |
| `pushNamed` without router | Router enabled |
| Home drawer `Scaffold.of` crash risk | `Builder` wrapper |

---

## Intentional stubs (not bugs)

| Location | What's missing | Phase |
|----------|----------------|-------|
| Google / Facebook / Apple auth | Backend/provider integration; UI now intentionally disabled instead of no-op | 2b |
| API / auth backend | `ApiService` unused by features | 2b+ |

---

## Design tokens & components (Phase 1)

| Item | Status |
|------|--------|
| `CarenetColors` (primary + neutral) | **Done** - `lib/core/tokens/carenet_colors.dart` |
| Semantic text-field colors (`success`, `error`, `info`) | **Done** - added to `CarenetColors` from blueprint palette |
| `CarenetButton` (primary, outline, disabled, large) | **Done** - `lib/shared/widgets/carenet_button.dart` |
| `CarenetTextField` | **Done** - `lib/shared/widgets/carenet_text_field.dart` |
| Onboarding uses shared button | **Done** |
| Sign-up phone/email use shared text field/button | **Done** |
| Other UI still on `AppColors` | Messaging, theme, and additional auth screens - later phases |

---

## Process guardrails

| Item | Status |
|------|--------|
| `ARCHITECTURE_RULES.md` | **Done** - folder ownership, routing, reusable UI, state, testing, and handoff rules |
| `TASK_TEMPLATE.md` | **Done** - required task spec and acceptance checklist for implementation tasks |

## Latest verification note

| Check | Result |
|-------|--------|
| 2026-06-12 pre-push milestone audit | Passed: `flutter analyze` reports no issues, all 132 tests pass, and `flutter build apk --debug` produces `build/app/outputs/flutter-apk/app-debug.apk`. Android now uses Kotlin 2.1.0. Route coverage remains 68 wired routes plus the intentionally reserved `login` constant. Local archives and credentials are ignored, and the legacy API helper no longer logs request bodies, credentials, cookies, or server responses. iOS still requires macOS/Xcode verification. Play Store/App Store release identifiers, signing, provider credentials, backend contracts, and compliance remain team-owned launch work rather than completed frontend behavior. |
| `flutter test` after docs-only reliability hardening | Timed out after 5 minutes; no Flutter/Dart process remained afterward. Treat as baseline issue for full-suite runs. |
| Focused task 10.5 test/analyze | Passed: focused `flutter analyze` and `communities_flow_test` after the named-route cleanup; communities now has an explicit scope stop before invitation/approval workflows |
| Focused task 11.1 test/analyze | Passed: focused `flutter analyze` and `qa_flow_test`; Post tab now hosts the first real Q&A feed + ask flow |
| Focused task 11.2 test/analyze | Passed: focused `flutter analyze` and `qa_flow_test`; Q&A answer requests, tagged questions, and local comment/answer flow now work end to end |
| Focused task 11.3 test/analyze | Not needed beyond task 11.2 verification: this task is a documented scope boundary decision to stop Q&A before `q-a-post` invents mixed feed logic |
| Focused task 12.1 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; drawer Profile now opens a real account flow with delete/deactivate behavior |
| Focused task 12.2 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; settings/profile local validation and save now work end to end |
| Focused task 12.3 test/analyze | Not needed beyond task 12.2 verification: this task is a documented scope boundary decision to stop the account lane before public profile/auth-security dependencies |
| Focused task 13.1 test/analyze | Passed: focused `flutter analyze`, `podcast_flow_test`, and `messaging_flow_test`; podcast notification routing and local watch state work end to end |
| Focused task 13.2 test/analyze | Not needed beyond task 13.1 verification: this task is a documented scope boundary decision to stop podcast before media/upload/comment/backend content workflows |
| Focused task 14.1 test/analyze | Passed: focused `flutter analyze`, `search_flow_test`, and `dashboard_shell_test`; Search tab now has local specialist search/filter/profile/request behavior |
| Focused task 14.2 test/analyze | Not needed beyond task 14.1 verification: this task is a documented scope boundary decision to stop search before live availability/payment/booking/provider-profile workflows |
| Focused task 15.1 test/analyze | Passed: focused `flutter analyze` and `health_record_flow_test`; Health Record shows local vitals and latest blood sugar values |
| Focused task 15.2 test/analyze | Not needed beyond task 15.1 verification: this task is a documented scope boundary decision to stop health record before backend history/export/synced-vital workflows |
| Focused task 16.1 test/analyze | Passed: focused `flutter analyze`, `articles_flow_test`, and `saved_articles_flow_test`; saved articles now has empty/list/detail/remove behavior backed by the shared local article store |
| Focused task 16.2 test/analyze | Not needed beyond task 16.1 verification: this task is a documented scope boundary decision to stop saved/content-library work before creator publishing, subscribers, article-story, analytics, account sync, comments, and content APIs |
| Focused task 17.1 test/analyze | Passed: focused `flutter analyze` and `case_studies_flow_test`; case studies now has list/filter/detail/read-state behavior backed by a local content store |
| Focused task 17.2 test/analyze | Not needed beyond task 17.1 verification: this task is a documented scope boundary decision to stop case studies before content API, verified review, author/publication, comments, sharing, account sync, and moderation dependencies |
| Focused task 18.1 test/analyze | Passed: focused `flutter analyze` and `public_profile_flow_test`; public profile route now has local profile content, real message/schedule handoffs, and disabled deferred creator/media/share actions |
| Focused task 18.2 test/analyze | Not needed beyond task 18.1 verification: this task is a documented scope boundary decision to stop public profile before profile APIs, creator portfolio, media, sharing, provider scheduling, reviews, verified identity, and subscription/upgrade dependencies |
| Focused task 19.1 test/analyze | Passed: focused `flutter analyze` and `communities_flow_test`; owner circle profile route shows local owner content and locked/deferred owner settings |
| Focused task 19.2 test/analyze | Not needed beyond task 19.1 verification: this task is a documented scope boundary decision to stop owner-circle work before permissions, invites, moderation, editing, sharing, reporting, exiting, and destructive community APIs |
| Focused task 20.1 test/analyze | Passed: focused `flutter analyze` and `manage_profile_flow_test`; manage profile route shows local profile-management content, settings/messages handoffs, and disabled backend-dependent controls |
| Focused task 20.2 test/analyze | Not needed beyond task 20.1 verification: this task is a documented scope boundary and backend replacement contract for manage-profile work |
| Focused task 21.1 test/analyze | Added `manage_portfolio_flow_test`; tool-side Flutter/Dart commands froze/timed out in this session, so run `flutter test test/features/home/manage_portfolio_flow_test.dart` and focused analyze from PowerShell before treating verification as device-proven |
| Focused task 21.2 test/analyze | Not needed beyond task 21.1 verification: this task is a documented scope boundary decision to stop manage portfolio before creator publishing, media upload/recording, ads/payment/subscription workflows, moderation, analytics, and sharing |
| Focused task 22.1 test/analyze | Added Account -> Authentication -> `changeAuthentication` coverage to `account_flow_test`; tool-side Dart/Flutter commands timed out in this session, so run `dart format`, `flutter test test/features/home/account_flow_test.dart`, and focused analyze from PowerShell before treating verification as device-proven |
| Focused task 22.2 test/analyze | Not needed beyond task 22.1 verification: this task is a documented scope boundary decision to stop change-authentication before PIN/security/auth-backend workflows |
| Focused task 23.1 test/analyze | Passed from PowerShell: `account_flow_test` covers Account -> Phone number -> addPhoneNumber validation, ready-for-SMS-verification draft, and unchanged account phone |
| Focused task 23.2 test/analyze | Not needed beyond task 23.1 verification: this task is a documented scope boundary decision to stop add-phone-number before OTP/SMS/code/auth-session workflows |
| Focused task 24.1 test/analyze | Passed from PowerShell: `account_flow_test` covers Account -> Password -> password route and locked Edit password action |
| Focused task 24.2 test/analyze | Not needed beyond task 24.1 verification: this task is a documented scope boundary decision to stop password before password-change/auth-backend workflows |
| Focused task 25.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Account -> Email address -> addEmail required/invalid/valid states and unchanged account email all verify cleanly |
| Focused task 25.2 test/analyze | Not needed beyond task 25.1 verification: this task is a documented scope boundary decision to stop add-email before verification/code/auth-session workflows |
| Focused task 26.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Add Email -> Change existing email -> changeEmail required/invalid/same/valid states and unchanged account email all verify cleanly |
| Focused task 26.2 test/analyze | Not needed beyond task 26.1 verification: this task is a documented scope boundary decision to stop change-email before verification-code/auth-session workflows |
| Focused task 27.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Add Email -> Review current email -> editEmail verified display, locked Remove email, and Edit email handoff to `changeEmail` all verify cleanly |
| Focused task 27.2 test/analyze | Not needed beyond task 27.1 verification: this task is a documented scope boundary decision to stop edit-email before email removal/re-auth/account-persistence workflows |
| Focused task 28.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Edit Email -> Review password step -> enterPasswordToSave required/short/valid-length states and unchanged account email all verify cleanly |
| Focused task 28.2 test/analyze | Not needed beyond task 28.1 verification: this task is a documented scope boundary decision to stop enter-password-to-save before real password verification/session/audit/account-persistence workflows |
| Focused task 29.1 test/analyze | Passed: focused `flutter analyze` and `account_flow_test`; confirm phone number route validates locally, prepares backend OTP verification, and does not mutate account phone state |
| Focused task 29.2 test/analyze | Not needed beyond task 29.1 verification: this task is a documented scope boundary decision to stop confirm-phone-number before OTP/code/session/account-persistence workflows |
| Focused task 30.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> Review turn-on setup -> turnOnAuthentication copy and disabled Turn on action all verify cleanly |
| Focused task 30.2 test/analyze | Not needed beyond task 30.1 verification: this task is a documented scope boundary decision to stop turn-on-authentication before PIN/session/audit/account-persistence workflows |
| Focused task 31.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> Review turn-on setup -> Review PIN setup -> createPin required/invalid/valid PIN states verify cleanly |
| Focused task 31.2 test/analyze | Not needed beyond task 31.1 verification: this task is a documented scope boundary decision to stop create-pin before PIN confirmation/storage/session/account-persistence workflows |
| Focused task 32.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `account_flow_test`; Authentication -> turn-on -> createPin -> confirmPinSave required/invalid/mismatch/match states verify cleanly |
| Focused task 32.2 test/analyze | Not needed beyond task 32.1 verification: this task is a documented scope boundary decision to stop confirm-pin-save before secure storage/session/audit/account-persistence workflows |
| Focused task 33.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `messaging_flow_test`; Notifications -> reminder navigation, calendar rendering, date selection, and empty state verify cleanly |
| Focused task 33.2 test/analyze | Not needed beyond task 33.1 verification: this task is a documented scope boundary decision to stop reminders before persistence/delivery/provider workflows |
| Focused task 34.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; drawer Schedule navigation, event details, active status, disabled Add reminder, and detail collapse verify cleanly |
| Focused task 34.2 test/analyze | Not needed beyond task 34.1 verification: this task is a documented scope boundary decision to stop schedules before CRUD/persistence/delivery/provider workflows |
| Focused task 35.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `manage_profile_flow_test`; Business Edit hours navigation, calendar, all-day draft preparation, and no-save summary verify cleanly |
| Focused task 35.2 test/analyze | Not needed beyond task 35.1 verification: this task is a documented scope boundary decision to stop selected dates before profile-hours persistence/product workflows |
| Focused task 36.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `communities_flow_test`; For you, Requests acceptance into joined communities, and Drafts empty state verify cleanly |
| Focused task 36.2 test/analyze | Not needed beyond task 36.1 verification: this task is a documented scope boundary decision to stop community invitations before delivery/approval/moderation/backend sync workflows |
| Focused task 37.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; drawer Providers -> findMentor and Book Appointment -> local booking form verify cleanly |
| Focused task 37.2 test/analyze | Not needed beyond task 37.1 verification: this task is a documented scope boundary decision to stop find-mentor before live availability/profile/payment/booking-confirmation workflows |
| Focused task 38.1 test/analyze | Passed: focused `dart format`, focused `flutter analyze`, and `dashboard_shell_test`; Find Mentor -> Specialist Details -> local day/time selection -> booking form handoff verify cleanly |
| Focused task 38.2 test/analyze | Not needed beyond task 38.1 verification: this task is a documented scope boundary decision to stop specialist-details before live availability/reviews/payment/booking-confirmation workflows |
| Focused task 39.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting `routes.json`; next implementation target is `/published-articles` |
| Focused task 40.1 test/analyze | `flutter test test/features/home/manage_portfolio_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_portfolio_shell.dart lib/features/Home/presentation/pages/published_articles_shell.dart test/features/home/manage_portfolio_flow_test.dart` reports no issues |
| Focused task 40.2 test/analyze | Not needed beyond task 40.1 verification: this task is a documented scope boundary decision to stop published articles before subscribers/article-story/add-new-article/drafts/analytics/comments/content APIs |
| Focused task 41.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting remaining blueprint routes; next implementation target is `/edit-your-name` |
| Focused task 42.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/edit_your_name_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 42.2 test/analyze | Not needed beyond task 42.1 verification: this task is a documented scope boundary decision to stop edit-your-name before profile persistence/account sync/verification/audit/backend APIs |
| Focused task 43.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/edit_your_website_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 43.2 test/analyze | Not needed beyond task 43.1 verification: this task is a documented scope boundary decision to stop edit-your-website before profile persistence/verification/account sync/audit/backend APIs |
| Focused task 44.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes all 7 tests; focused `flutter analyze` on the shared text field, route wiring, Manage Profile, Add Description page, and flow test reports no issues |
| Focused task 44.2 test/analyze | Not needed beyond task 44.1 verification: this task is a documented scope boundary decision to stop add-description before profile-copy persistence/moderation/publishing/account-sync/backend APIs |
| Focused task 45.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting remaining Manage Profile blueprint routes; next implementation target is `/set-address` |
| Focused task 46.1 test/analyze | `flutter test test/features/home/manage_profile_flow_test.dart` passes all 8 tests; `flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Home/presentation/pages/manage_profile_shell.dart lib/features/Home/presentation/pages/set_address_shell.dart test/features/home/manage_profile_flow_test.dart` reports no issues |
| Focused task 46.2 test/analyze | Not needed beyond task 46.1 verification: this task is a documented scope boundary decision to stop set-address before profile-address persistence/location services/maps/account-sync/backend APIs |
| Focused task 47.1 test/analyze | Not needed: route triage/documentation-only decision after inspecting the remaining blueprint tail; no new runtime route selected |
| Focused task 48.1 test/analyze | Not needed: documentation/router coverage audit only; checked route constants vs router cases and docs/deferred-work consistency without runtime code changes |
| Focused task 49.1 test/analyze | Not needed: documentation-only backend/product readiness handoff; no runtime code changed |
| Focused task 50.1 test/analyze | Not needed: documentation-only final handoff review; checked docs/router status and deferred-work readiness without runtime code changes |
| Focused task 52.1 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on the auth config/client/session/model/repository files and auth infrastructure test reports no issues |
| Focused task 52.2 test/analyze | Passed: `flutter test test/features/authentication/sign_in_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on email sign-in, auth repository/failure, and sign-in tests reports no issues |
| Focused task 52.3 test/analyze | Passed: `flutter test test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on email sign-up, finish sign-up, router, and sign-up tests reports no issues |
| Focused task 52.4 test/analyze | Passed: `flutter test test/features/authentication/session_restore_guard_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on splash guard, session restore test, and auth repository reports no issues |
| Focused task 52.5 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on Account and account-flow tests reports no issues |
| Focused task 52.6 test/analyze | Passed: `flutter test test/features/authentication/password_recovery_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on password reset screens and password recovery tests reports no issues |
| Focused task 52.7 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on Account and account-flow tests reports no issues |
| Focused task 52.8 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart`; focused `flutter analyze` on current-email review and account-flow tests reports no issues |
| Focused task 52.9 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/session_restore_guard_test.dart test/features/home/account_flow_test.dart`; focused `flutter analyze` on auth data, auth screens, splash guard, Account/Edit Email, and related tests reports no issues |
| Focused task 52.10 test/analyze | Not needed: decision-only docs slice. Checked current docs and selected guardrail-doc restoration as `52.11`; no runtime code changed |
| Focused task 52.11 test/analyze | Not needed: docs-only guardrail restoration. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.12 test/analyze | Not needed: decision-only docs slice. Checked `DEFERRED_WORK.md` and selected a frontend/backend checkpoint as `52.13`; no runtime code changed |
| Focused task 52.13 test/analyze | Not needed: docs-only checkpoint. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.14 test/analyze | Not needed: decision-only docs slice. User selected password reset + email verification deep-link/code contract as the next target; no runtime code changed |
| Focused task 52.15 test/analyze | Not needed: contract-only docs slice. `git diff --check` passes for changed docs; no runtime code changed |
| Focused task 52.16 test/analyze | Passed: `flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/home/account_flow_test.dart`; focused `flutter analyze` on reset/verification routes, auth client/repository, router, and related tests reports no issues |
| Focused task 52.17 test/analyze | Not needed: decision/map docs slice. `git diff --check` covers formatting; no runtime code changed |
| Focused task 52.18 test/analyze | Not needed beyond proxy smoke: docs/checkpoint slice. Verified `GET /health` and `GET /health/ready` through the developer-private proxy; `git diff --check` covers formatting; no runtime Flutter code changed |
| Focused task 52.19 test/analyze | Run `flutter analyze android/app/build.gradle.kts ios/Runner.xcodeproj/project.pbxproj` is not applicable because those are platform config files; use `rg "com\\.example\\.(app_t|appt)" android ios` to verify old app IDs are gone and `flutter test test/features/authentication/auth_infrastructure_test.dart` for a focused Dart sanity check |
| Focused task 52.20 test/analyze | Not needed beyond prerequisite evidence: docs/setup slice. Verified `/health/ready` still reports `googleAuth: disabled`, listed staging secrets, collected debug SHA fingerprints with `keytool`, and `git diff --check` covers formatting |
| Focused task 52.21 test/analyze | Not needed beyond staging readiness evidence: backend/config checkpoint. Verified Cloud Run revision `carenet-backend-staging-00006-ph6` at 100 percent traffic and `/health/ready` through Cloud Run Proxy reports `googleAuth: ok` |
| Focused task 52.22 test/analyze | Passed: `flutter test test/features/authentication/sign_in_flow_test.dart test/features/authentication/auth_infrastructure_test.dart`; focused `flutter analyze` on Google provider DI, sign-in pages, and sign-in tests reports no issues; `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080 --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=<web-client-id>` passes after transient Maven/DNS recovery |
| Focused task 52.23 test/analyze | Not needed: contract-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.24 test/analyze | Passed: `flutter test test/features/home/profile_repository_test.dart`; focused `flutter analyze` on profile API client, repository, entities/models, DI, and test reports no issues |
| Focused task 52.25 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Manage Profile read wiring and tests reports no issues |
| Focused task 52.26 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.27 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Add Description bio update, Manage Profile read wiring, profile repository/API client, professional entity, and related tests reports no issues |
| Focused task 52.28 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.29 test/analyze | Passed: `flutter test test/features/home/search_flow_test.dart test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart`; focused `flutter analyze` on Search public listing, Manage Profile, Add Description, profile repository/API client, public/professional entities, and related tests reports no issues |
| Focused task 52.30 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.31 test/analyze | Not needed: contract-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.32 test/analyze | Passed: `flutter test test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on scheduling entities/models/API client/repository, DI, and related test reports no issues |
| Focused task 52.33 test/analyze | Passed: `flutter test test/features/home/scheduling_repository_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on Search public availability read, scheduling repository/entity, and related tests reports no issues |
| Focused task 52.34 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.35 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/public_profile_flow_test.dart`; focused `flutter analyze` on booking route and related tests reports no issues |
| Focused task 52.36 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.37 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart`; focused `flutter analyze` on the appointment request time-option entity/helper/test reports no issues |
| Focused task 52.38 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on Search request wiring, appointment option helper/entity, and related tests reports no issues |
| Focused task 52.39 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on appointments list read wiring and related Search regression tests reports no issues |
| Focused task 52.40 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.41 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/search_flow_test.dart`; focused `flutter analyze` on appointments cancellation wiring and related Search regression tests reports no issues |
| Focused task 52.42 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.43 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/search_flow_test.dart test/features/home/appointments_flow_test.dart`; focused `flutter analyze` on appointment option generation, Search request wiring, Appointments cancellation/listing, and related tests reports no issues |
| Focused task 52.44 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.45 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on selectedDates availability management, Manage Profile flow test, scheduling repository/API client, and repository test reports no issues |
| Focused task 52.46 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.47 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments role-aware lifecycle UI, appointment flow tests, scheduling repository/API client, and repository tests reports no issues |
| Focused task 52.48 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments lifecycle regression, appointment flow tests, scheduling repository/API client, and repository tests reports no issues |
| Focused task 52.49 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.50 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments completion wiring, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.51 test/analyze | Passed: `flutter test test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart`; focused `flutter analyze` on Appointments completion regression and related scheduling files reports no issues |
| Focused task 52.52 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.53 test/analyze | Passed: focused scheduling core regression tests across appointment request options, Search, Appointments, selectedDates, manage profile, and scheduling repository; focused analyze reports no issues |
| Focused task 52.54 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.55 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.56 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on Appointments reschedule wiring, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.57 test/analyze | Passed: `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on Appointments reschedule regression, scheduling repository/API client, and related tests reports no issues |
| Focused task 52.58 test/analyze | Not needed: decision-only docs slice. `git diff --check` covers changed docs; no runtime code changed |
| Focused task 52.59 test/analyze | Passed: `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=http://127.0.0.1:8080`; `flutter test test/features/home/appointment_request_time_options_test.dart test/features/home/appointments_flow_test.dart test/features/home/scheduling_repository_test.dart -r compact`; focused `flutter analyze` on scheduling config/API/repository/Search/Appointments/selectedDates and related tests reports no issues |
| Focused task 52.87 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`; focused `flutter analyze` on route constants/router, Manage Profile, editProfessionalDetails, and manage-profile tests reports no issues |
| Focused task 52.88 test/analyze | Passed: `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`; focused regression searches confirmed update/preservation/null-clearing coverage and no new category/specialty runtime behavior for broader modules |
| Focused task 52.91 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart -r expanded`; focused `flutter analyze` on Account Google account linking and account-flow tests reports no issues |
| Focused task 52.92 test/analyze | Passed: `flutter test test/features/home/account_flow_test.dart -r expanded`; focused `flutter analyze` on Account Google account linking and account-flow tests reports no issues; source/test inspection confirmed regression requirements and no broader provider/account behavior |
| Focused task 52.93 test/analyze | Not needed: decision-only docs slice. Reviewed Google linking regression, backend-completed map, codebase status, deferred-work register, and backend API plan; selected admin verification review boundary as the next lane without runtime code changes |
| Focused task 52.94 test/analyze | Not needed: decision-only docs slice. Reviewed backend admin verification API rules and accepted a separate admin dashboard/web console boundary; no runtime Flutter code changed |
| Focused task 52.95 test/analyze | Not needed: checkpoint/docs slice. Updated completed backend surface map, reviewed backend API plan and current Flutter repository boundaries, and selected stabilization/regression planning; no runtime Flutter code changed |
| Focused task 52.96 test/analyze | Not needed: planning/docs slice. `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md` defines grouped regression suites, focused analyze/docs checks, manual smoke checklist, known blockers, and 52.97 regression execution; no runtime Flutter code changed |
| Focused task 52.97 test/analyze | Passed after one test-harness fix: auth/session/account suite `72 tests passed`; profile/verification suite `42 tests passed`; discovery/booking suite `27 tests passed`; scheduling lifecycle suite `42 tests passed`; focused analyze reports no issues; `git diff --check` reports no whitespace errors |
| Focused task 52.98 test/analyze | Not needed: decision/docs slice. `MOBILE_MILESTONE_HANDOFF_STAGING_BOUNDARY.md` selects a handoff package as the next lane and keeps staging seed-data/smoke, release readiness, admin dashboard, and deferred product modules separate; no runtime Flutter code changed |
| Focused task 52.99 test/analyze | Not needed: handoff/docs slice. `MOBILE_BACKEND_MILESTONE_HANDOFF_PACKAGE.md` summarizes the regression-passed milestone and selects staging seed-data/smoke planning next; no runtime Flutter code changed |
| Focused task 53.1 test/analyze | Not needed: planning/docs slice. `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` defines required staging data/config and smoke evidence rules; no runtime Flutter code changed |
| Focused APP-ID-004 test/analyze | Passed: `flutter test test/features/home/onboarding_repository_test.dart`; focused `flutter analyze` on onboarding catalog/readiness entities, models, API client, repository, DI, and tests reports no issues |
| Focused APP-ID-005 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart -r expanded`; focused `flutter analyze` on patient/professional setup UI and tests reports no issues |
| Focused APP-ID-006 verification | Not needed beyond docs/source inspection: decision-only slice. Backend profile DTOs/service normalization were checked, and `git diff --check` passes |
| Focused APP-ID-007 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart -r expanded`; focused `flutter analyze` on patient/professional setup catalog-code payload wiring and tests reports no issues |
| Focused APP-ID-008 verification | Not needed beyond docs/source inspection: decision-only slice. Checked PRD, role/onboarding decision docs, backend API plan, and APP-ID-007 payload alignment before recording the production onboarding domain boundary |
| Focused APP-ID-009 verification | Not needed beyond docs/source inspection: planning-only slice. Checked Flutter readiness models, signup routes, verification shell, and backend `AccountReadinessService`; `git diff --check` passes |
| Focused APP-ID-010 test/analyze | Passed: `flutter test test/features/onboarding/onboarding_readiness_route_resolver_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/sign_up_flow_test.dart -r expanded`; focused `flutter analyze` on resolver, signup pages/arguments/router, and related tests reports no issues |
| Focused APP-ID-011 verification | Not needed beyond docs/source inspection: planning-only slice. Checked setup screens, verification documents shell, readiness docs, and backend `AccountReadinessService`; `git diff --check` passes |
| Focused APP-ID-012 test/analyze | Passed: `flutter test test/features/onboarding/profile_setup_test.dart test/features/home/manage_profile_flow_test.dart -r expanded`; focused `flutter analyze` on onboarding setup, verification documents shell, and related tests reports no issues |
| Focused APP-ID-013 test/analyze | Passed: onboarding/auth regression group covering sign-up flow, finish sign-up, readiness resolver, profile setup, and manage profile/verification documents; focused analyze on related auth/onboarding/verification files reports no issues |
| Focused APP-ID-014 build/device check | Build passed: staging Android debug APK at `build/app/outputs/flutter-apk/app-debug.apk`; phone smoke blocked because `flutter devices` lists only Windows/Chrome/Edge and `adb devices` lists no Android serial |
| Focused APP-P1-004 verification | Passed: 29 targeted Find Care/dashboard route tests, full `flutter test` with 308 tests, full `flutter analyze` with no issues, Android debug APK build, `git diff --check`, and unchanged `pubspec.lock`. No Specialist Details, Schedule, appointment lifecycle, dependency, asset, native, or backend source changed |

## APP-P1-019 appointment participant identity

- Appointment responses now parse the backend viewer-scoped counterpart profile
  id, role, and display name.
- Active Home, appointment list, and appointment detail surfaces display the
  persisted counterpart name when its role matches the authenticated viewer.
- Missing, malformed, or role-mismatched identity falls back to a neutral role
  label and cannot alter appointment ownership or action authority.
- Messaging keeps its existing conversation-owned counterpart contract;
  notification presentation remains server-authored.

## MSG-P1-007 appointment messaging

- Backend authority is merged at
  `4e3e49df6490798374b245d6061f849ca02e6b4f`.
- The authenticated Messages destination loads backend conversation pages with
  stable activity ordering, unread badges, exact counterpart identity, and
  honest lifecycle state.
- `RouteName.chat` requires typed conversation or appointment authority and
  renders backend history through Flyer Chat. The legacy `message` alias fails
  closed and no seeded conversation remains active.
- WebSocket protocol-version-1 frames are hints only; reconnect, app resume,
  and disconnected polling recover through HTTP.
- Message bodies remain private in memory and are cleared with route disposal
  or account change.
- Verification passes with 41 focused messaging tests, 393 complete Flutter
  tests, clean `flutter analyze`, a debug Android APK, and `git diff --check`.
- Canonical contract: `PHASE_1_APPOINTMENT_MESSAGING.md`.

## CALL-P1-009 appointment consultations

- Backend consultation authority is merged at
  `42c595b5a34c8e203f411180fb76ef4ce25f4036`.
- Appointment Detail now consumes backend-owned consultation projection and
  opens one appointment-linked VIDEO/AUDIO consultation route.
- Flutter uses the official LiveKit SDK behind `RtcRoomAdapter`; CareNet
  retains waiting, admission, timing, participant, payment, incident,
  attendance, and completion authority.
- Prejoin, permission recovery, patient waiting, professional admission,
  active media controls, reconnect/rejoin, leave/end, incident reporting, and
  disposal/account-change cleanup are implemented without a Calls tab.
- Local verification passes with 14 focused consultation tests, 431 complete
  Flutter tests, clean `flutter analyze`, standard and staging-configured debug
  Android APK builds, stable dependency resolution, and `git diff --check`.
- Canonical contract: `PHASE_1_APPOINTMENT_CONSULTATIONS.md`.

## NOTIF-P1-010 transactional notifications

- Backend `NOTIF-P1-010A` owns durable domain events, recipient resolution,
  inbox projection, preferences, reminders, provider delivery state, retry and
  signed Resend webhook processing.
- Flutter `APP-P1-010B` owns authenticated inbox presentation, read/unread,
  preference controls, secure installation lifecycle, contextual FCM permission,
  foreground display, pending cold-start taps, and owner-checked route resolution.
- Push content is generic and privacy-safe. Destination pages reload current
  appointment, conversation, consultation, finance, verification, or account
  authority from CareNet APIs.
- Firebase configuration is compile-time and environment-specific. Provider
  secrets and Firebase Admin credentials are not present in the mobile repository.
- Staging and physical Android proof covers native high-importance channel
  creation, a valid notification drawable, foreground/background/terminated
  receipt, owner-scoped cold-start routing to the exact appointment conversation,
  and bounded splash/readiness recovery. Provider acceptance and signed email
  webhook processing are proven separately; production delivery and iOS APNs are
  not claimed.
- Canonical contract: `PHASE_1_TRANSACTIONAL_NOTIFICATIONS.md`.

## Design debt (fix in Phase 2+)

## APP-P1-014 account and route authority

- The active Account screen renders only `/account/me` identity, role, status,
  and email. It never falls back to `AccountLocalStore`.
- Patient profile access uses the existing backend patient profile setup;
  professional profile uses the backend professional setup editor, while
  verification, finance, notification preferences,
  Google linking, and logout retain their authoritative integrations.
- Unsupported local PIN, phone, email mutation, deactivation, and deletion
  controls are no longer active. Account deletion remains blocked pending a
  backend reauthentication, retention, audit, and session-revocation contract.
- Deferred social/content/readings/emergency/creator routes now fail closed to
  a common unavailable screen. Their source is retained for later deletion.
- Route inventory verification: 79 declared constants, including the reserved
  and unwired `login` constant.
- Verification baseline remains 481 complete Flutter tests; no test was
  skipped, disabled, or removed.

| Issue | Where |
|-------|--------|
| `finishSignUp` still uses legacy `BorderedTextInput` and wrapper button | `lib/features/Authentication/presentation/pages/sign_up_con.dart` |
| Legacy blue (`AppColors`) in theme / non-button UI | `app_colors.dart`, `theme.dart`, messaging - later phases |
| Notification visual cleanup remains | `Notification.dart` retains legacy styling while active Messages and Chat use the Phase 1 token direction |
| Feature state remains mostly page-local/static | DI now registers auth, account, profile, onboarding, scheduling, and verification services; only theme uses BLoC, while legacy feature state still relies on page state and local stores |
| Feature BLoC only for theme | No auth/home blocs |
| `RouteName.login` unused | No screen |

---

## Feature folders (what exists)

```text
lib/features/
  splash/          - splash screen
  Onboarding/      - onboarding + agreements + profession + user edit
  Authentication/  - sign in/up email & phone, sign_up_con
  Home/            - dashboard, home, feed_tab, readings, drawer, widgets
  Messaging/       - messages, chat, notification (needs Phase 1/5 styling)
```

Appointment-linked Messaging now has typed backend models, an authenticated repository,
Flyer Chat thread projection, body-free WebSocket recovery, and lifecycle-aware
read-only behavior. No dedicated features yet for: creator tools, subscriptions/ads,
or backend-backed public profile/security flows.

---

## Files that matter for routing

| File | Role |
|------|------|
| `lib/main.dart` | `configureDependencies()` + `runApp` |
| `lib/app.dart` | `MaterialApp`, theme, `initialRoute: splash` |
| `lib/core/constants/navigators/routeName.dart` | Constants |
| `lib/core/constants/navigators/router.dart` | `generateRoute` switch |
| `docs/ROUTES.md` | Human-readable table |

**Never** add `MaterialApp` or `void main()` elsewhere.

---

## Commands

```bash
cd C:\Users\asd\Music\Mobile-App-master
flutter pub get
flutter run
flutter test
flutter analyze lib test
```
