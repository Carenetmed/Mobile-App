# Phase 1 legal and authentication links

## Canonical origin

CareNet public pages and authentication links use
`https://project-a96784ee-811c-46ab-a7b.web.app`. Firebase project
`project-a96784ee-811c-46ab-a7b` is authoritative. Firebase configuration files
for any other project must not be installed.

## Public pages

- `/terms`
- `/privacy`
- `/support`
- `/account-deletion`

Terms and Privacy identify their published version and effective date. Signup
links to Terms and Privacy. Account links to Support, Privacy/legal, and account
deletion information. Account deletion itself remains an authenticated,
backend-owned operation requiring recent authentication.

The initial Support page deliberately does not invent an unverified support
mailbox. A monitored launch support channel and operating hours remain a release
gate.

## Authentication links

- `/verify-email?token=...`
- `/reset-password?token=...`

Android verified app links route these URLs into the existing confirmation
screens. Flutter accepts an absolute authentication URL only from the canonical
Hosting host; relative app-link paths are also supported. Missing tokens fail
closed in the confirmation screens. Hosting fallback pages never render or log
the token. The backend must set `PUBLIC_APP_BASE_URL` to the canonical Hosting
origin so new email messages issue these URLs.

## Android association

`/.well-known/assetlinks.json` declares `com.carenet.app.staging` and
`com.carenet.app`. The checked-in association contains only the SHA-256
certificate currently registered for debug/staging verification. Before a
production release, add the protected Android upload and Play App Signing
SHA-256 fingerprints to Firebase and Digital Asset Links, then prove association
with the signed release build.

## Deferred platform proof

iOS Universal Links, Apple identity, signing, and physical-device proof remain
blocked on Apple Developer credentials, a Mac, and an iPhone. No iOS readiness
claim follows from this Android slice.
