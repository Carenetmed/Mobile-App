# Phase 1 Doctor Education

## Android Staging Pilot Checkpoint (2026-11-13)

The user's immediate goal is a working Android staging pilot INCLUDING doctor
posts/shorts. Paystack is excluded/deferred until separate final approval;
existing payment eligibility and all product/safety guards remain unchanged.
APP-READY-082 is the sole NEXT task and full readiness remains partial.

Current mobile integration is `0406f53da7e5a7e53fcd31a1767226c1255bb545` after
PR #289, head `9155c58703d746bbd46827ee9ee25fd029848691`. PR CI `43309919222`
and exact-merge CI `43312643931` passed, verified through `gh`, with 1,424 tests
and configured Android gates. PR #289 changed four files with no dependency
or native changes; one date-only professional timezone formatter test in
`test/core/presentation/carenet_locale_test.dart` raised the suite from 1,423
to 1,424. No tests were removed, skipped, disabled, or weakened. Local debug APK
packaging was storage-blocked; CI built it. No Android device, playback or
reported freeze/ANR resolution is claimed by that performance change.

Pilot preparation provisioned private bucket
`project-a96784ee-811c-46ab-a7b-education-media-staging` in `ASIA-SOUTH1`, with
public access prevention enforced and uniform access true. The bucket-scoped
runtime role and exact scanned-main BE087 candidate are recorded in
`PHASE_1_OPERATIONAL_READINESS.md`. The candidate has zero traffic and
`EDUCATION_CONTENT_PUBLIC_ENABLED=false`, Ready=True, max instances 1 and no
minimum-instance floor. Postdeploy BE075 remains 100%, candidate 0%, SQL
STOPPED/NEVER. Synthetic private-MP4 storage/access proof passed; application
upload/playback and published shorts are not proved. No migration/public
content was activated. The earlier
three-bucket/no-education inventory predates this preparation.

Before posts/shorts can work in the pilot, verify runtime media access and
anonymous-read denial, safe reviewer video preview/publication, signed playback,
reporting, clinical safety, retention/appeals, abuse controls and explicit launch approval.
Android real-file upload and playback acceptance remain required. A staging
pilot does not waive these publication/media guards. See
`PHASE_1_OPERATIONAL_READINESS.md` for completed admin/notification evidence
versus remaining pilot proof and additional production assurance.

## Authoring Surface

The professional Account page links to `RouteName.educationStudio`. The
Education Studio uses authenticated `GET /education/content/mine` and the
backend-owned create, update, video-upload, submit, and archive operations. The
client obtains its bearer token from the persisted session and never supplies
an author or professional-profile ID. The backend remains authoritative for
active-account, verified medical-doctor eligibility and content ownership; a
professional navigation role alone does not grant authoring access.

Patient Home has a separate `Doctor-created health education` entry to
`RouteName.educationFeed`; it does not add a bottom-navigation destination. The
feed calls public `GET /education/content` with the backend cursor and page size,
and detail calls public `GET /education/content/:contentId`. The client renders
only the returned title, body/caption, published date and doctor display name,
category and optional specialty. The backend owns publication eligibility and
ordering. Empty API responses remain empty; failures never fall back to drafts,
fixtures or seeded posts. Reports use authenticated
`POST /education/content/:contentId/reports` and one of the backend's supported
reason codes.

Short videos are tap-to-play and do not autoplay. Detail reloads the post to
obtain a fresh private-media URL; the client accepts only HTTPS Google Storage
URLs with bounded expiry, pauses playback when the app is inactive, and offers
a detail refresh when the signed link expires or playback fails. `video_player`
is used for native playback (`^2.10.1` in the package constraint; the current
Flutter/Dart resolver selects 2.11.1). Its resolved AVFoundation plugin
requires Flutter 3.41 or newer, now declared by the app. Android's shipped
manifest includes internet access, which is required for both the existing API
and signed media requests.

Text drafts support a title up to 120 characters, body up to 3,000 characters,
and an optional caption up to 280 characters. Short-video drafts support an
optional caption up to 280 characters. Video selection is bounded to MP4, at most 60 seconds and 25 MiB
in the client; the backend additionally validates media format, duration,
resolution, metadata, and private storage. Client checks are convenience only.
An upload is described as complete only after the backend returns a valid
receipt. Failed uploads retain the server-owned draft for retry.

The author sees backend statuses as Draft, In review, Approved, Changes needed,
and Archived. Submitting changes content to `PENDING_REVIEW`; it does not
publish it. Editing published material returns it to backend review. Reviewers
use the protected web admin queue and revision-bound decisions. Reported video
items remain non-actionable until a safe media-review and report-dismissal
contract exists.

## Publication And Cost Gates

The public API flag `EDUCATION_CONTENT_PUBLIC_ENABLED` must remain off until an
approved launch gate explicitly enables it. Reviewer approval is not a promise
that public feed delivery is enabled. The reader is source-implemented, but a
disabled API currently returns an empty feed; this UI work does not change the
deployed flag or prove public publishing readiness.

Video upload requires a dedicated private `EDUCATION_MEDIA_BUCKET` with public
access prevention, uniform bucket-level access, minimal IAM, bounded Cloud Run
upload concurrency, and proven anonymous-read denial. The dedicated bucket is
now provisioned; runtime upload/playback acceptance remains open. If the backend
reports upload unavailable, the client retains the draft and gives a retryable error.

The current draft-create API has no idempotency key. If a create request has an
ambiguous network/server outcome, the app reloads the author's posts and reuses
a matching draft when found. If it cannot confirm the result, it blocks further
draft saves until the author refreshes or explicitly confirms a retry that may
create a duplicate.

The studio supports general health education only. It warns authors not to
include patient details, personal diagnoses, prescriptions, or emergency
guidance. It adds no comments, likes, direct messages, creator payments,
medical records, or automated claim approval. Backend review and operational
reviewer access remain necessary before public launch.

## Current Limitations

- The patient feed and detail reader are implemented, but public content
  delivery has not been enabled or operationally accepted.
- No authoring-side video preview or transcoding is included; human review is required.
- Private storage is provisioned; runtime video upload and playback remain
  unverified on the prepared candidate.
- Public publishing remains disabled until abuse controls, clinical policy,
  retention/appeal decisions, reviewer coverage, and launch approval are closed.
- The API currently has no edge/account read-rate limit; report admission and
  abuse monitoring require an operational review before public launch.
- The five-minute signed media URL depends on the deployed private bucket and
  its IAM configuration; the mobile reader does not provision or validate it.
- Physical-device playback, recording, and upload acceptance remain a separate test gate.
