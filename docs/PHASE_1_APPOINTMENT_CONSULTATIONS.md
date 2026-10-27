# Phase 1 Appointment-Linked Consultations

## APP-READY-082H Task Spec

Status: IN PROGRESS within sole NEXT task APP-READY-082.
Base: `09138624c64c87f327c17f4ca8a43db2c3187daf`, 1,153 passing tests.
Branch: `slice/APP-READY-082H-consultation-audio-permissions`.

Goal: stop requesting an unnecessary Android Bluetooth grant during ordinary
media preparation, and represent speaker preference without claiming an observed
output device. Existing backend join authority and SDK-owned routing stay intact.

Installed LiveKit2.9.0 owns Android audio-session management and its pinned
AudioSwitch implementation uses AudioManager routing APIs. Ordinary phone audio
does not require the removed unconditional Bluetooth permission prompt. The exposed
WebRTC output-list/selection path is disabled by LiveKit's audio ownership; do
not invent devices, add a competing audio manager or build a false chooser.
Existing native declarations and SDK policy remain unchanged. If a future
feature genuinely invokes protected Bluetooth APIs, require contextual permission
and handle denial/API-level semantics before that operation, not on every join.

Allowed files: consultation_permission_service.dart, consultation_shell.dart,
direct permission-channel and existing controller/widget tests, canonical docs.
Do not change RTC adapter, controller/lifecycle, backend, native manifests,
dependencies, routes, payments, notifications or message behavior. Reuse existing
controls, tokens, responsive wrapping and accessible tap actions.

Behavior: request/check microphone, and camera only for VIDEO; preserve denial,
restriction and settings behavior. Use compact Preferred / Automatic captions;
expose a stable Prefer speaker semantics label with its true
preference toggle state. A preference is not observed routing or forced output.
Keep the current non-forced SDK setter and automatic headset priority.

Largest-text validation exposed overflow in the active audio stage. The active
view now separates scrollable status and control bands from the remaining media
area. Captions wrap in bounded control widths; enlarged controls remain reachable
by scrolling, without reducing text scale. The local video preview stays inside
the media area and is omitted when that area is too small. This is presentation
repair only, not a change to tracks, participant authority or SDK audio policy.

Host coverage adds14 permission-channel tests and2 role-specific widget tests
(both AUDIO and VIDEO), retaining the existing compact control regression. The
new tests exercise pointer and semantics preference actions at3.2x text and
assert non-overlapping status/media/control bounds. These tests do not prove
physical audio output, Android permission dialogs or Bluetooth headset behavior.

Acceptance: direct method-channel request/check/status/settings tests; patient
and professional preference toggle/semantics/compact enlarged-text tests; preserve
all existing permission, RTC adapter, lifecycle and authority regressions. Run
targeted/full suite, analyzer, Android debug/signed artifacts, release lint/signing/
environment/static gates, diff/inventory review and applicable PR/integration CI.
No deleted/skipped/weakened tests. Normal merge only unchanged reviewed green
head. Physical API-level, denial, headset/hot-plug and actual audio proof stays
in the approved final device session; host tests do not claim Android dialogs.

APP-READY-082G delivered through PR254 at this base, reviewed `1751ca8`; PR and
integration CI passed with1,153 tests. Its source recovery gap is repaired, not
permission/provider/device acceptance or completion of the full readiness program.

`CALL-P1-009` adds paid appointment-linked VIDEO and AUDIO consultations
without creating a separate Calls destination. CareNet remains the authority
for appointment eligibility, payment, participant role, timing, admission,
session state, attendance, incidents, and completion. LiveKit Cloud owns only
media transport, codecs, TURN/STUN, adaptive networking, and room
infrastructure.

## Product contract

- VIDEO and AUDIO use the same professional consultation price.
- Join opens 10 minutes before the appointment.
- First join closes 15 minutes after the scheduled start.
- The scheduled room end is the appointment end, with a final 10-minute grace.
- Join grants live for five minutes and are never persisted or logged.
- The patient enters a CareNet waiting room and receives no RTC grant before
  professional admission.
- Rejoin uses the same consultation session with a fresh backend grant.
- A later authorized device replaces the earlier connection.
- Leaving or ending media does not complete the appointment.
- Recording, transcription, screenshots, and automatic compensation are not
  implemented.

The backend authority was merged at
`42c595b5a34c8e203f411180fb76ef4ce25f4036`. It exposes participant-only
consultation projection, waiting-room, admission, join-grant, end, and incident
routes under `/appointments/:appointmentId/consultation`.

## Flutter boundary

`RouteName.consultation` requires typed `ConsultationRouteArgs` containing the
exact appointment ID. Appointment Detail reads the backend consultation
projection and opens the consultation only when the projection permits waiting,
joining, rejoining, admission, review, or other legitimate session access.
Malformed or missing route arguments fail closed.

The Flutter implementation keeps three boundaries:

- `ConsultationRepository` performs authenticated CareNet consultation calls.
- `RtcRoomAdapter` hides provider rooms, participants, tracks, and device APIs
  from the rest of the app.
- `ConsultationController` combines backend-owned durable authority with
  transient media and presentation state.

Backend projection booleans control all waiting, admission, join, rejoin, and
end actions. Navigation state never grants authority. The controller binds to
the authenticated account and role, fails closed for unknown roles or account
changes, serializes actions, rejects expired grants, and reloads backend state
after relevant transitions.

## Appointment mode

Specialist Details presents VIDEO and AUDIO as a segmented choice. Both show
the same backend price. The selected mode is stored in the persisted booking
intent and sent with the existing appointment request. Changing mode produces a
new booking retry identity. Existing intents without a mode read as VIDEO for
backward compatibility.

Appointment summaries parse and display the backend `consultationMode` when it
is present. No provider or room details are exposed during booking.

## Consultation experience

The prejoin view provides:

- VIDEO camera preview, camera toggle, microphone toggle, and camera switch;
- AUDIO microphone and output-route preparation with camera publishing off;
- permission status, retry, settings access, and a camera-denied audio
  continuation for VIDEO;
- backend timing and eligibility state without connecting to consultation
  media.

Patient waiting uses the application-level backend waiting state. The patient
receives no LiveKit token until admitted. The professional can see waiting
state and admit through the backend. Polling refreshes this authority while no
RTC connection is active.

The active view provides remote media, local VIDEO preview, microphone, camera,
camera switch, speaker or earpiece control, connection and reconnect state,
remote mute/camera-off state, scheduled-end/grace timing, incident reporting,
patient leave, and professional end confirmation. A full disconnect returns to
backend projection and requires an explicit rejoin with a fresh short-lived
grant. Transient LiveKit reconnect remains in the active view.

The app rechecks the account and media permissions on foreground return.
Microphone revocation disconnects the room and requires permission before
rejoin. Camera revocation stops camera publishing while preserving the
documented audio fallback. Disposal removes listeners, cancels polling and
countdown timers, and releases room, camera, and microphone resources.

## LiveKit integration

Flutter uses the official `livekit_client` package at `2.9.0`. CareNet wraps it
instead of spreading provider types through repositories or appointment
screens. The room enables adaptive stream, dynacast, simulcast, moderate
640x360 capture at up to 24 fps, native reconnect, and platform audio routing.
No custom WebRTC transport, TURN selection, room code, or client-minted token
exists.

`connectivity_plus` is pinned to `7.0.0`, which satisfies LiveKit's supported
range while remaining compatible with the repository's Android Gradle Plugin
8.7 baseline. Version 7.3.1 introduces AndroidX Core 1.18 and requires Android
Gradle Plugin 8.9.1, so accepting it would force an unrelated native-toolchain
upgrade.

The official component package was inspected but not adopted. Its broad UI
surface did not fit the appointment-owned CareNet shell; the official SDK track
renderer and room APIs are wrapped directly instead. No donor source or test
code was copied.

Provider and donor references:

| Repository | Commit | Licence | Use |
| --- | --- | --- | --- |
| `livekit/client-sdk-flutter` | `d3c53f20f1c0330449ef88cf8b3ec6114c5346bb` | Apache-2.0 | Official Flutter room, media and reconnect APIs |
| `livekit/components-flutter` | `eb7cd99cf5625a9a2900b382662d689eb3396edc` | Apache-2.0 | State patterns studied; no copied app shell |
| `livekit-examples/meet` | `665e1cb7841ab872de0d8e5c310744009a763b08` | Apache-2.0 | Controls/reconnect studied; public-room authority rejected |
| `livekit-examples/flutter-examples` | `d5936bfc541e60e305e8686aa4147a861ea1b2be` | No root licence found | Study only; nothing copied |

Daily remains the first provider fallback candidate and Agora the second.
Neither is implemented.

## Native permissions

Android declares camera, microphone, audio-settings, and current Bluetooth
permissions, while camera and microphone remain optional hardware features.
iOS declares clear camera and microphone usage descriptions. Flutter uses
`permission_handler` for denied, permanently denied, restricted, unavailable,
retry, and settings behavior. No native incoming-call experience is included.

## Security and privacy

- LiveKit API credentials exist only in the backend environment.
- The app receives an opaque WSS URL and short-lived room-scoped token.
- Tokens, room identifiers, SDP, ICE candidates, network addresses, and
  medical content are not logged or persisted by Flutter.
- AUDIO never publishes camera.
- Unknown session states and malformed provider grants fail closed.
- Generic network incidents are mapped to patient or professional categories
  from the persisted authenticated role, not from UI input.
- Incident descriptions warn against medical information and remain bounded by
  backend validation.
- Recording, transcription, egress, media persistence, and client-submitted
  attendance remain absent.

## Failure and operations

`401`, `403`, `404`, and `409` map to distinct safe consultation messages.
Provider/network failures do not create appointment, payment, completion,
refund, or compensation state. The backend projection is refreshed after full
disconnect, foreground return, leave, end, and authority changes.

Production uses LiveKit Cloud. The backend requires `RTC_PROVIDER=livekit`,
`LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, and
`RTC_INTERNAL_JOB_SECRET`; Flutter contains none of these secrets. Staging must
preserve raw signed webhook bodies and run reconciliation. If non-production
LiveKit credentials are unavailable, deterministic provider tests and the
staging APK remain valid proof, but real VIDEO/AUDIO and two-participant proof
must be reported as blocked.

Provider-outage handling is fail closed: preserve appointment and payment
authority, do not issue a grant when provider authority cannot be established,
retain incident evidence, and leave refund/reschedule decisions to support.

## Deferred

The following remain outside `CALL-P1-009`:

- recording, transcription, screenshots, livestreaming, and media export;
- native incoming-call UX and push-notification delivery;
- automatic refund, compensation, extension, or no-show blame;
- medical notes, prescriptions, reviews, and consultation attachments;
- advanced call analytics and a second live RTC provider;
- a backend leave-waiting-room mutation and audio visualizer;
- broad appointment, messaging, payment, or navigation redesign.
