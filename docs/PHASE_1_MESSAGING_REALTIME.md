# Appointment Messaging Transport Readiness

## APP-READY-082G Task Spec

Status: IN PROGRESS, prerequisite within sole NEXT task APP-READY-082.
Base: `8b8e9fc2747e0708df93e36f67f1059498baa520`, 1,126 passing tests.
Branch: `slice/APP-READY-082G-messaging-http-recovery`.

Goal: recover a foreground inbox after disconnection spans the token-expiry
hint and expiry itself. Stored credentials alone cannot resolve a pre-ACK
rejection; only an authenticated HTTP response may invoke existing 401 refresh.

Selected contract:
- A real auth frame sent without subsequent ACK may emit an owner-typed HTTP
  recovery request when that attempt fails. No token or guessed failure cause.
- No request for absent configuration, failure before auth dispatch, an
  acknowledged connection closing, retirement, backgrounding or disposal.
- The inbox accepts only its expected account/role/session generation, checks
  current stored ownership with a bounded wait, and reloads through the existing
  repository. At most one probe in flight and one admission per 30 foreground
  seconds while continuously foregrounded; repeated requests coalesce. Pause
  cancels the cooldown; the existing explicit resume reload remains independent.
  Timers never initiate network work.
- Pause/dispose fence pending reads, cancel cooldown timers and admit no new
  probes. Ordinary manual/resume refresh and ACK catch-up remain supported.
- Generic socket code1008 is not token-expiry authority. This recovery path never
  directly refreshes or clears sessions. Existing explicit backend expiry-hint
  handling is unchanged. No role invention, backend/protocol change or polling.

Allowed files: existing realtime client and Messages page, messaging test fake,
focused transport/inbox/auth-boundary tests and canonical handoff/status/docs.
Do not change session storage/coordinator/interceptor, backend, dependencies,
native source, routes, chat writes, appointments, payments, calls or notifications.
Reuse existing repository, typed identity, loading/error states and visual tokens;
no new visual surface. Preserve full test inventory and sole NEXT task082.

Acceptance: reproduce the lost-hint recovery gap; prove pre-ACK-only signals,
bounded owner-aware HTTP probes, canonical401 refresh and no refresh for403,
cooldown/concurrency, disposal/pause/account fencing, and absent-config safety.
Run targeted and full tests, analyzer, debug/signed staging artifacts, release
lint/signing/environment gates, diff checks and exact-head/integration CI.
Review/repair and merge only an unchanged green clean head. Valid-session,
poor-network and physical-device acceptance remain explicitly separate.

Implementation evidence: 157 targeted messaging tests pass. Removing the new
recovery emission makes the real HTTP401 regression fail (expected one canonical
refresh, observed zero); restoring it passes. Real coordinator/interceptor tests
prove401 rotates once with generation preserved, whereas403/503 preserve tokens
without direct refresh. Test inventory adds27: client13, inbox flow10, HTTP/real
transport integration4. Expected full suite1,153 =1,126 retained +27 additions;
no removed, renamed, skipped or weakened tests. All1,153 tests and analyzer pass;
staging debug APK, fresh623-task release lint, protected signing regressions,
30 environment probes/eight packaging graphs, backup25negative probes and iOS
flavor source checks pass. Independent source/test review reports no unresolved
findings. Signed staging artifacts and exact-head/integration CI remain delivery
gates; none of this replaces live session/provider/device acceptance.

082F source was delivered through PR253 at this base, reviewed `aec4e8f`;
both PR and integration Android/iOS CI passed with1,126 tests. Its older
pending-CI text below is as-at-commit history, not current delivery status.

## APP-READY-082F Task Spec

Status: IN PROGRESS, prerequisite within the sole NEXT task APP-READY-082.
Base: `e9f21d4ac2e84a93c556d798a2184900e7a3ccf0` (968 passing tests).
Branch: `slice/APP-READY-082F-messaging-realtime-ingress`.

Goal: connect the existing appointment-linked messaging experience to the
verified standalone staging socket ingress, without inventing a second
authentication or message-persistence system. This implements the already
approved readiness program's realtime requirement, not product expansion.

## Backend Evidence And Boundary

BE-P1-065 merged through backend PR176, reviewed
`ce69faf138b833427d9575dd78575a6aa1aef6c7`, merge
`a8d212e93332b27ad2c043f1d56c1323663a2644`. Exact-head and integration CI,
real PostgreSQL and immutable image scan passed. The standalone native entry is
`wss://carenet-messaging-staging-tkgduhftha-el.a.run.app/messaging`.
The ordinary API remains private behind its retained gateway.

Staging ingress negative boundary proof completed2026-10-25T21:33:26.488Z:
static health200, unrelated HTTP404, missing/malformed first-frame rejection,
and backend rejection of a synthetic invalid JWT without auth.accepted.
Minimum instances0, service and revision maximum1. Dedicated invocation is
verified; temporary organization-review authority was removed with seven
original bindings preserved. No database/provider credential or domain module
is loaded by the standalone transport. Unrelated cloud controls were preserved.

This is not valid-patient session, message-delivery, physical-device or
production acceptance. Legitimate session/fixture consent and later device
proof remain open. No tokens may be forged or existing accounts reset to
manufacture acceptance. Existing unfixed HIGH container finding remains
documented by the backend scan policy; successful scan is not zero findings.

## Selected Implementation Contract

- Add explicit optional `CARENET_MESSAGING_WS_URL`; never derive it from the
  HTTP gateway. Only the exact registered staging WSS host/path may receive
  tokens. Reject credentials, query, fragment, wrong scheme/port/host/path or
  unsupported environment. No production WSS host is approved yet.
- Missing configuration uses the existing honest HTTP/resume/manual-refresh
  fallback, not a repeating gateway socket attempt or false connected state.
- Pass typed user/session-generation intent into the realtime connection.
  Resolve actual credentials through an adapter over existing SessionStore
  snapshots and the shared SessionRefreshCoordinator. Widgets do not invent
  account authority or retain a token to replay forever.
- Before connecting, accepting an acknowledgement, delivering a hint or
  resuming after refresh, validate the expected user and session generation.
  A changed/logout/unsupported session stops the old connection. A new sign-in
  generation for the same user is not the previous session's authority.
- The backend `auth.accepted` protocolVersion1 is required before connected=true
  or hint delivery. Transport readiness alone is not authentication success.
- `auth.expiring` refreshes through existing serialized coordinator authority,
  closes the old socket and reconnects with a fresh snapshot. Never send a
  second auth frame on the authenticated socket or implement parallel refresh
  ownership. HTTP401 recovery remains with existing authenticated execution.
- Reconnects read the current account-bound token; backoff resets only after
  backend acknowledgement. Bound handshake, acknowledgement, close and session
  waits. Duplicate callbacks, concurrent starts and disposal cannot create
  extra connections or accept stale frames. Timers/subscriptions are released.
- Retain text-only8KiB/protocol checks and decimal-string BigInt sequences.
  Hints remain hints. Messages are persisted and caught up through the existing
  authenticated HTTP repository, never reconstructed from socket frames.
- Chat and inbox catch up after an authenticated reconnect; resume/manual
  refresh and existing chat fallback remain truthful when transport fails.

## File Boundary

Expected runtime files: typed core messaging configuration and its startup
validation, DI factories, feature-local identity/session adapter, existing
realtime client, MessagingRepository session projection, chat controller and
the two retained messaging pages' factory/owner wiring.

Expected tests: explicit configuration rejection, session adapter/coordinator,
real client protocol/ACK/expiry/reconnect/race/disposal, inbox/chat catch-up and
retained messaging/auth/navigation regressions. Existing protocol assertions
must remain; obsolete HTTP-derived socket expectations are replaced explicitly
and every inventory change reconciled against968. No test skip or weakening.

Expected docs: this contract, AI_HANDOFF, CODEBASE_STATUS, DOC_SYNC, DECISIONS,
DEFERRED_WORK and the existing appointment-messaging/operational handoff where
needed. Preserve exactly one task-table NEXT row, APP-READY-082.

No backend, dependencies, native source, route/navigation, appointment/booking,
message persistence/lifecycle, payments, calls, notifications or broad deferred
source changes. Backend permissions stay authoritative. Signed staging build
configuration may receive the public WSS value only after source validation;
no access token or provider secret belongs in that configuration.

## Acceptance Gates

Working-tree verification: the first complete run passed 1,121 tests. Review
then added three lifecycle-race regressions; final-source verification passed
1,124 tests. Subsequent independent review repaired a reconnect ACK/hint being
dropped during an active inbox fetch by coalescing one trailing refresh. Two
delayed-response regressions prove fresh data and disposal cancellation; the
complete repaired suite passes 1,126 (968 retained plus 158 additions). The only
replaced test name removes the obsolete HTTP-derived socket URL expectation;
strict authentication-frame and sequence assertions remain. No test is deleted,
skipped or disabled. Final-source analyzer, diff checks and staging debug APK
build passed, including the final incremental rebuild. Fresh release lint passes
with all 623 tasks executed after correcting ignored Windows SDK path escaping;
no lint baseline/suppression or tracked native change. Signing regressions,
30 release-environment probes, eight packaging graphs, 25 backup-policy negative
probes and iOS flavor source checks pass. Signed artifacts and CI remain required
before delivery; source checks do not claim Apple signing/device acceptance.

Test inventory against the 968-test base:

| File | Net Added |
| --- | ---: |
| messaging_realtime_config_test.dart | 64 |
| app_environment_test.dart | 8 |
| messaging_contract_test.dart | 1 |
| messaging_realtime_session_provider_test.dart | 23 |
| messaging_realtime_client_test.dart | 56 |
| messaging_controller_test.dart | 3 |
| messaging_flow_test.dart | 3 |
| Total | 158 |

The obsolete socket-URL test is renamed to require explicit canonical staging
configuration. The additional missing-endpoint test accounts for its net +1.
All retained authority, frame and sequence assertions remain; BigInt coverage
now also exceeds JavaScript integer precision. The three delayed-close cases
prove no stale refresh dispatch after dispose, suspend or owner replacement.

Focused protocol/session/widget tests, full analyzer and Flutter suite, staging
debug APK, Android release lint/signing/environment gates and diff checks.
Reconcile all added/replaced/renamed tests, review exact diff, require exact-head
and integration CI before merge, and retain operational/device limits.

Later manual checks: legitimate patient/professional sign-in, ACK-only status,
token expiry/reconnect, reconnect catch-up, logout/account switch, poor network
and process restoration. Physical acceptance stays in the approved final device
session. Payments remain last, test-only and require the separate final explicit
confirmation. The full production-readiness program remains active.
