# Patient Profile Settings Mapping Decision

Task: 52.62

Status: Accepted decision

## Context

Task `52.61` selected patient self profile as the next backend-completed Flutter
surface. The backend profile contract already exists in the Flutter repository
through `ProfileRepository.patientMe` and `ProfileRepository.updatePatientMe`.

Before runtime wiring, the existing Settings/Profile UI needs a clear field
mapping because it was built as a local account/profile draft screen.

## Backend Contract

Patient self routes:

| Route | Auth | Purpose |
| --- | --- | --- |
| `GET /patients/me` | `PATIENT` JWT | Read the current user's own patient profile |
| `PUT /patients/me` | `PATIENT` JWT | Create/update allowed patient profile fields |

Allowed patient profile fields:

- `name`
- `age`
- `location`

Backend rules:

- the app must not send user id, patient profile id, role, auth status, email,
  phone, password, verification state, audit data, or public profile fields
- `404` on read means the patient profile does not exist yet, not a broken
  account
- first profile creation requires `name`

## Current UI Surface

Existing route:

- `settings` / `SettingsProfilePage`

Current local fields:

- first name
- last name
- username
- email
- bio

Current local behavior:

- validates all fields locally
- writes to `AccountLocalStore`
- shows a local-save snackbar
- does not call patient profile backend routes

## Mapping Decision

The first runtime patient profile slice should be read-first and should not
replace the whole Settings/Profile save flow.

Use this mapping:

| Existing/current field | Backend mapping | Decision |
| --- | --- | --- |
| First name + last name | `name` | May read from backend `name` for display by splitting into first token and remaining text; do not claim perfect legal-name parsing |
| Username | None | Keep local/deferred; do not send to `/patients/me` |
| Email | Auth/account identity | Keep owned by `AccountRepository` and email-verification routes; do not send to `/patients/me` |
| Bio | None for patient profile | Keep local/deferred; do not send to `/patients/me` |
| Age | `age` | Not present in the current UI; defer editable age until a later UI slice or add a read-only summary if present |
| Location | `location` | Not present in the current UI; defer editable location until a later UI slice or add a read-only summary if present |

## Next Runtime Boundary

Queue `52.63 - Wire Patient Profile Read To Settings Profile`.

The first runtime slice should:

- call `ProfileRepository.patientMe` from `SettingsProfilePage`
- show safe loading, error, and empty-profile states
- display backend patient `name` where it can safely replace local first/last
  display
- display backend `age` and `location` only as a read-only summary if returned
- keep the existing local save flow unchanged for fields not owned by the
  patient profile backend
- not call `updatePatientMe`
- not create a patient profile
- not send username, email, bio, role, user id, patient profile id, phone,
  auth/security data, verification data, scheduling data, or public profile data

## Why Read First

A read-first slice proves session/auth headers, patient ownership, 404
empty-profile handling, safe errors, and basic UI integration without risking a
bad mutation contract.

Updating patient profile should be a later slice after the UI either:

- adds explicit `name`, `age`, and `location` fields, or
- defines a constrained save rule for combining first/last name into backend
  `name` while leaving username, email, and bio out of the payload.

## Explicitly Out Of Scope

- runtime implementation in this decision slice
- `PUT /patients/me`
- patient profile creation
- username persistence
- email mutation or verification
- phone/OTP
- MFA/PIN/security changes
- logout/delete/deactivate behavior
- professional profile mutation
- verification upload/list
- admin verification dashboard
- scheduling data creation or appointment smoke
- public profile detail
- payments, notifications, reviews, calls, calendar sync, notes,
  prescriptions, or medical records

## Non-Claims

This decision does not claim:

- Settings/Profile is backend-wired yet
- patient profile mutation is ready
- account identity fields can be saved through patient profile routes
- age/location editable UI exists
- the app is production-ready or Play Store-ready
