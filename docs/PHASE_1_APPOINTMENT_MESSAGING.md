# Phase 1 Appointment-Linked Messaging

**Capability:** `MSG-P1-007`
**Backend authority:** `4e3e49df6490798374b245d6061f849ca02e6b4f`
**Flutter base:** `0f6b6109a7bc9cb305edc636fb447dc0add9b771`

## Product boundary

Messaging belongs to an eligible appointment and its current patient and
professional. It is not generic social messaging. Both roles reach
conversations through the primary Messages destination and through eligible
Appointment Detail screens.

The backend owns conversation membership, appointment linkage, lifecycle
writability, unread counts, read cursors, sequence ordering, text validation,
idempotency, and current account authority. Flutter never creates a
conversation, participant, appointment state, or message from local data.

## HTTP contract

- `GET /conversations` returns stable `lastActivityAt` ordering, unread data,
  counterpart identity, appointment status, last preview, and an opaque cursor.
- `GET /conversations/:id` returns current participants, lifecycle writability,
  read cursors, and the latest committed sequence.
- `GET /conversations/:id/messages` uses `beforeSequence` for older history and
  `afterSequence` for missed-message catch-up.
- `POST /conversations/:id/messages` accepts plain `text` plus one
  `clientMessageId`.
- `POST /conversations/:id/read` advances a monotonic read cursor through a
  committed visible sequence.

All routes require the existing bearer session. Decimal sequence strings are
parsed as `BigInt`; the client does not coerce them through JavaScript-safe
integers.

## Flutter adapter

`MessagingRepository` reads the current secure session for each request.
`ConversationListController` serializes initial loads and cursor pages,
preserves valid content during refresh failure, rejects stale completions, and
orders by `lastActivityAt` then conversation ID. Unread is a badge and never
changes list ordering.

`AppointmentChatController` loads current conversation metadata and the newest
message page, projects committed messages into Flyer's
`InMemoryChatController`, and keeps that controller transient. Older pages,
after-sequence catch-up, POST responses, optimistic projections, and realtime
hints deduplicate by committed message ID and per-author client message ID.
Numeric sequence remains the committed ordering authority.

One explicit send creates one secure UUID-style `clientMessageId`. Ambiguous
retry reuses that ID. A successful response replaces the pending projection.
Plain text is limited locally to 4,000 Unicode code points while the backend
remains authoritative. Attachments, markdown, HTML, reactions, replies,
editing, deletion, typing, and presence are absent.

Read state advances only after committed messages have been projected and a
Flutter frame has rendered. The UI presents `seenByOther` as Seen and does not
display or invent `seenAt`.

## Realtime and recovery

The WebSocket endpoint is derived from `CARENET_API_BASE_URL` as
`ws(s)://host/messaging`. Tokens never appear in the URL. After connection the
client sends exactly:

```json
{"type":"auth","accessToken":"<current access token>"}
```

No `resume` field is sent. Protocol-version-1 events are body-free hints only:

- `message.created` triggers HTTP after-sequence catch-up;
- `conversation.read_advanced` refreshes authoritative read state;
- `conversation.state_changed` refreshes lifecycle metadata.

Reconnect uses bounded exponential backoff with jitter and one reconnect timer.
While the open thread is disconnected, a 15-second HTTP poll recovers missed
state. A healthy socket stops polling. App resume refreshes the list and catches
up the open thread. Malformed, unknown-version, duplicate, and unrelated hints
fail safely.

## Lifecycle and privacy

Accepted appointments are writable while the backend says they are writable.
Completed appointments remain writable only through the backend-defined
window. Requested/rescheduled, cancelled, expired, or otherwise closed
conversations remain readable and show an honest read-only reason.

Appointment Detail exposes messaging only for accepted or completed
appointments. The destination still resolves the exact conversation through
backend-owned `appointmentId` data. Missing IDs, requested appointments with no
conversation, declined appointments, and unauthorized accounts fail closed.

Message bodies are not written to SharedPreferences, secure key-value storage,
analytics, logs, crash metadata, route arguments, or WebSocket fan-out. They
remain only in private in-memory state and are reloaded from HTTP after restart.
Logout/navigation disposal closes subscriptions, timers, socket transport, and
the Flyer controller. Account changes clear prior private state before another
request is accepted.

## Adopted dependencies and provenance

- `flutter_chat_ui: 2.11.1` - adopted through Pub.
- `flutter_chat_core: 2.9.0` - adopted through Pub.
- `web_socket_channel: 3.0.3` - adopted through Pub.
- Flyer Chat inspected at
  `7e743f4649ba6e15ac4ac8fdcd4dd0b4bc0f633c`.
- Rocket.Chat inspected at
  `6dc66fbe33b7dae6e386e51dadb56b0a70994e80` as Translate/Study.
- Chatwoot inspected at
  `19c96fcc07be8b48594aa1eaa9e7613eb47d899f` as Translate/Study.
- Zulip inspected at
  `4b8e7735751082d9d262e4088ae7640840d025ad` as Translate/Study.

No donor source was copied. Rocket.Chat and Chatwoot enterprise paths were
excluded.

## Verification

- 41 focused messaging tests pass, including 37 tests added by this milestone.
- The full Flutter suite passes with 393 tests, up from the 356-test base with
  no removed, skipped, disabled, or weakened tests.
- `flutter analyze` reports no issues.
- `flutter build apk --debug` produces the debug Android APK.
- Dependency resolution succeeds with `flutter pub get --enforce-lockfile`.
- `git diff --check` passes.

## Explicit limits

- No push provider or lock-screen message delivery.
- No attachments or media.
- No calls or RTC.
- No payments, refunds, or payouts.
- No generic chat, contacts, new-chat action, group chat, search, moderation,
  medical-record designation, retention purge, export, erasure, or legal hold.
- Staging HTTP/WSS proof requires the established staging URL, deployment
  identity when protected, and disposable patient/professional appointment
  data.
