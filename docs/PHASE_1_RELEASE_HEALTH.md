# Mobile Release Health

## APP-READY-063 - Source Contract In PR #229

Base: mobile PR #228 merge `31e0aa9f64a1ed75c7bef8a3f51b5ffd0e1f464a`.
The complete readiness program requires privacy-reviewed diagnostics without
tokens or health content. This document does not claim reporting is operational.

### Current Implementation Boundary

Typed diagnostic codes accept no exception, diagnostic context, route, account
identifier, URL, custom log, stack or arbitrary payload. Release metadata accepts
bounded numeric version/build fields, reviewed prerelease tags, an environment
enum and a schema version. Validation errors never repeat rejected inputs.
Secure generation-bound consent storage, a bounded typed API adapter, coordinator,
and Account opt-in switch are implemented. Startup installs safe root-isolate
framework/asynchronous hooks without awaiting optional reporting. Dependencies
remain unchanged. Sharing defaults off and requires explicit consent; no native
crash SDK or pre-consent report queue exists.

### Approved Transport Decision

Firebase Crashlytics cannot guarantee sanitized-only uploads through a Dart
wrapper: queued native reports bypass that sanitizer, and bulk-send includes
all unsent reports. Disabling automatic upload does not guarantee no local
capture. No Crashlytics SDK is installed or activated by this partial work.

The user explicitly selected strictly allowlisted reports through CareNet's
existing backend on 2026-10-14, retaining disabled raw/native uploads. Backend
BE-P1-042 merged through PR #141 at
`f1a3f0b482d533268b43a2caf6ca1df115f5e776`; reviewed-head and merged-main CI
passed 669 unit, 149 E2E and 164 PostgreSQL tests, plus image-scan policy.
`POST /diagnostics/release-health` is JWT protected, strictly validated and
rate bounded. It accepts the closed report shape and returns 202 with exactly
`{ "accepted": true }`. This is source proof, not deployment/gateway exposure.
Deployment/gateway exposure, log access/retention review, operational alerting and
controlled deployed acceptance remain required. An accepted report is a technical
hint, not a delivery guarantee, health diagnosis or crash-free-user measurement.

Consent storage contains schema version and the existing opaque session
generation only, never tokens or account IDs. Refresh preserves the generation;
new login changes it. A different generation cannot reuse a prior grant, and
late old-generation revocation cannot remove a newer grant. The coordinator
checks the session generation again after asynchronous metadata loading, drops
concurrent reports without queuing, and limits each closed code to one attempt
per minute using monotonic time. Cancellation invalidates pending work; disposal
prevents late submission. Storage and metadata waits are bounded. It does not
refresh or clear sessions. An underlying plugin that outlives its deadline keeps
its capacity until actual settlement, preventing a timeout-driven request queue.
Permission checks are coalesced before I/O. The coordinator reads the validated
opaque consent grant first: no grant means no read of the shared SessionStore
queue and no package metadata load. Preferences retain only generation/account
binding in memory, not a cached session object or authentication tokens.

The app-scoped preferences controller survives Account navigation, preventing an
unsaved opt-out from being overridden on reopening that page. Opt-out immediately
suspends/cancels reporting before any storage await. A failed or uncertain write
shows that sharing is paused in this app session, not that the preference was
durably saved. The user can retry after the original operation settles. A prior
stored grant can survive a process restart if an opt-out write failed; the UI
does not claim otherwise. Successful opt-out removes the stored grant. Account
logout/deletion invalidates the UI binding immediately; subsequent reports also
require a matching live session. A request already accepted by the server cannot
be recalled. No identifiers or authentication tokens are persisted in consent.

Framework hooks submit only `frameworkFailure`; root-isolate uncaught callbacks
submit only `asynchronousFailure`. Optional notification initialization has a
15-second caller deadline and emits `optionalStartupFailure` on failure. This
does not cancel an already-running provider operation. In release/profile builds,
hooks print fixed local messages rather than raw error/context/stack details;
debug builds retain existing local debugging handlers. Raw callback arguments
are never forwarded to reporting. Root-isolate handling is not native crash,
child-isolate, process-death, or crash-free-user coverage. The hook returning
handled suppresses the embedding's raw stderr fallback; it does not prove error
recovery or process survival. All current automatic reports use `fatal: false`.

The API adapter uses a separate client from the shared bounded HTTP factory,
without session-refresh interception. It never retries, changes auth state or
echoes backend errors. Connect/send/receive limits are three seconds, with a
five-second request deadline and cancellation. Only strict 202 acceptance counts
as accepted; 401, 429, cancellation and generic unavailability are distinct.

### Wire Contract And Test Inventory

`POST /diagnostics/release-health` uses the existing Bearer JWT with this shape:

```json
{
  "code": "frameworkFailure",
  "fatal": false,
  "release": {
    "version": "1.0.0",
    "buildNumber": "42",
    "environment": "staging",
    "diagnosticsSchema": "1"
  }
}
```

The only other codes are `asynchronousFailure` and `optionalStartupFailure`.
Environment is staging or production. Version/build values are validated,
not arbitrary labels. Package metadata comes from existing `package_info_plus`;
the validated app environment supplies environment. No dependency was added.
Backend JWT/active-account admission remains authoritative for every role.
401/403/network/server failures never refresh, clear or change the app session.
429 is dropped without retry; the backend also enforces durable account/global
fixed-window admission limits. No body or exception is logged by this client.

All new tests live under `test/core/diagnostics/`; no pre-existing test changes.

| File | New Passing Cases | Evidence |
|------|------------------:|----------|
| release_health_metadata_test.dart | 7 | Exact projection and rejected arbitrary/private metadata |
| diagnostic_consent_store_test.dart | 8 | Secure record, recreation, generation isolation and corruption |
| release_health_api_client_test.dart | 31 | Exact POST, deadlines/cancellation, status and schema handling |
| release_health_coordinator_test.dart | 13 | Consent, refresh/logout/account fencing, concurrency, disposal, stalled capacity |
| release_health_error_bridge_test.dart | 4 | Private-argument traps, fixed-code forwarding and handler restoration |
| diagnostic_preferences_controller_test.dart | 12 | Explicit opt-in/out, uncertain writes, retries, page persistence and 3.2x text |
| account_diagnostics_integration_test.dart | 2 | Actual Account switch and logout binding invalidation |

Net addition is 77: the 734-test baseline becomes 811. Secure storage is tested
through its explicit platform mock; Account rendering uses an explicit consent
fake to avoid native-channel scheduling inside fake-time widget tests. An early
Account test attempt failed on that harness mismatch; production assertions were
not removed. Physical secure-storage/device acceptance is still a separate gate.

### Planned File Boundary

- Core diagnostics models/coordinator/selected transport and focused tests.
- Existing startup and DI only for bounded optional setup and safe handlers.
- Existing Account surface only for truthful diagnostic consent when selected.
- Native/dependency files only if a justified SDK is approved and required.
- Canonical handoff/status/deferred/sync and this contract document.
- No booking, messaging, payment, consultation or account-authority redesign.

### Privacy Evidence

- [Flutter framework error callback](https://api.flutter.dev/flutter/foundation/FlutterError/onError.html)
- [Root-isolate error callback and fallback semantics](https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onError.html)
- [Flutter reporting controls](https://firebase.google.com/docs/crashlytics/flutter/customize-crash-reports)
- [Native queued-report semantics](https://firebase.google.com/docs/reference/android/com/google/firebase/crashlytics/FirebaseCrashlytics)
- [Firebase data handling and retention](https://firebase.google.com/support/privacy)

An SDK installation identifier is not anonymous just because CareNet does not
set a user ID. Do not describe Crashlytics as anonymous or claim raw native data
is sanitized by the Flutter reporting model.

### Later Controlled Acceptance

1. Verify no diagnostic request on a fresh install or before opt-in. Use only
   synthetic failures, never private account/clinical/message content.
2. Opt in explicitly, trigger one closed test event and inspect the deployed
   strict event projection and admission response without logging the JWT.
3. Opt out and prove no later report is sent. A previously admitted request cannot
   be recalled. Exercise failed/hanging storage and the explicit unsaved warning.
4. Check process restoration, token refresh, logout, same-account new login and
   account replacement against generation-bound consent. A different generation
   must require explicit consent again.
5. Prove 401/403/429/network errors do not clear sessions or retry reports. Check
   report logs contain only the documented fields and approved server envelope.
6. Review log access/retention and alert delivery. Do not infer native crash,
   background-isolate or crash-free-user coverage from these checks. Physical
   Android/iOS secure-storage and device checks remain the later device gate.

### Verification And Remaining Gates

Reviewed runtime source: `301f9395d44ac96b7283b3b101e35eed3f2c462f`.
The exact committed tree passed all 811 local tests on C: in 74 seconds and full
analysis with no issues. This includes all 77 new cases and the 734-test baseline.
Final source includes consent-first admission (zero session reads when default
off), coalescing before I/O, bounded consent parsing and no cached authentication
session in preferences. Backup privacy passed 25 negative probes; iOS flavor
consistency passed. No pre-existing test was edited, removed, skipped or disabled.

An independent read-only review of that exact runtime commit found no present
privacy, session-isolation or concurrency blocker within the approved limits.
The final documentation commit must leave runtime/tests identical to that
reviewed commit; exact-head CI remains mandatory, not inferred from this review.

Initial PR #229 CI `38539680857` passed on `ac3ffd5` with Ubuntu APK, release
lint and signing/environment regressions. That older head is not final proof:
the unchanged complete CI lane must pass on the final reviewed PR head before
merge. The PR checks and final review comment carry that immutable run/head proof.

Local native attempts are not passed. F: builds encountered Windows C:/F:
Kotlin incremental-cache errors and slow I/O; a process-only retry did not complete.
A fresh same-drive C: validation checkout resolved test speed, but guarded APK
attempts ran out of disk headroom. The single-worker attempt stopped at
995,098,624 free bytes after 57 seconds, with the full default ABI targets still
enabled. Owned processes were stopped; no native/dependency/CI file was changed,
no test was dropped and no artifact is described as a valid release candidate.
Kotlin cache logs remain local/untracked; tooling policy blocked cleanup.
More local headroom and actual signed release-candidate/device proof remain open.

No provider acceptance, deployment or production-readiness completion is claimed.
The next source slice after this PR merges is APP-READY-064, the approved
English/Nigerian locale policy; backend currency/time authority must not change.
Dependencies remain unchanged. Payments remain the final explicitly approved
provider gate; no cloud service was started for this work.
