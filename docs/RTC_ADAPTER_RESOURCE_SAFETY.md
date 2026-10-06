# RTC Adapter Resource Safety

APP-READY-042 keeps each LiveKit room, listener and captured track attached to
the operation that created it. Injected typed factories let tests exercise
production sequencing without media devices or provider credentials.

## Ownership And Cleanup

- Generation and captured-session checks reject stale preview, connection,
  media-control and room-event completions.
- Repeated connects are serialized. Reconnect waits until prior room cleanup
  completes, including a disconnect that interrupted an in-flight connect.
- The join grant's microphone/camera capabilities are retained for the session;
  later controls cannot enable media the grant disallows. Controls cannot start
  new preview or media work while disconnect cleanup is in progress.
- Microphone and camera commands each have a serial queue; enabling again after
  disable creates a fresh owned capture.
- The adapter creates and owns audio/video tracks before publishing through
  the public SDK APIs. Failed publication cannot hide an allocated track.
- Revocation detaches listeners, stops visible and owned capture, and interrupts
  the room connection. Final cleanup drains accepted operations, removes late
  publications, stops capture again and disposes the captured room.
- Repeated release shares one future. Cleanup errors reject explicit release;
  successful operation-error recovery does not falsely poison later cleanup.
- Disposal contains release errors and reports only a fixed redacted diagnostic.
  It never forwards the SDK exception, stack, token, room URL or identifiers.
  Reporting failure does not certify successful media release.

The adapter preserves existing room options, capture resolution/frame rate,
simulcast and backend-grant media restrictions. There is no provider, backend,
dependency or consultation-lifecycle contract change.

## Verification

The new adapter test file has 51 focused cases. The full Flutter suite passes
with 674 tests against the 623-test integration baseline: exactly 51 additive
tests. No existing test was deleted, skipped, disabled, or weakened. Flutter
analysis is clean. It covers event
ownership, held factory/connect/publication completions, grant capability
enforcement, cleanup failures, published tracks outside the adapter capture
registry, disconnect/reconnect races, capture replacement, queued audio
reactivation, serialized controls and disposal diagnostics. Debug APK, CI,
signed-native, and device gates remain separate. Fake resource counts are not
hardware acceptance evidence.

## Remaining Limits

Native getUserMedia creation cannot be cancelled through this SDK interface.
A pending creation may activate briefly after revocation and is disposed when
it returns. An unresolved SDK future can keep release pending; no bounded or
instantaneous native shutdown guarantee is claimed.

SDK-internal reconnect republishing is outside adapter-tracked operations.
Its cleanup and actual hardware microphone/camera shutdown remain explicit
acceptance gates. Continuous account/session observation, authoritative access
denial, full call-state widgets and two-device checks remain separate readiness
work. Provider control-plane and signed-webhook proof do not prove media transport.
