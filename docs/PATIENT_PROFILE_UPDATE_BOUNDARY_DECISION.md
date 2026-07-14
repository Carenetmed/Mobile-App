# Patient Profile Update Boundary Decision

Task: 52.65

Status: Accepted decision

## Context

Task `52.63` wired Settings/Profile to read patient profile data through
`ProfileRepository.patientMe`. Task `52.64` regression-proved success,
empty-profile, safe failure, local-save preservation, and no accidental
`updatePatientMe` mutation.

This decision chooses whether the next slice should add patient profile update
behavior or move to another backend-completed surface.

## Current Facts

Backend patient profile update route:

- `PUT /patients/me`
- authenticated `PATIENT`
- allowed fields: `name`, `age`, `location`
- first profile creation requires `name`
- frontend must not send user id, patient profile id, role, email, phone,
  password, verification state, audit data, scheduling data, or public profile
  fields

Current Settings/Profile fields:

- first name
- last name
- username
- email
- bio

Already wired:

- `ProfileRepository.patientMe`
- read-only backend name/age/location display
- local save to `AccountLocalStore`

Still not present in UI:

- editable age field
- editable location field

## Decision

Proceed with a constrained patient profile name update as the next runtime
slice.

Do not wire age or location update yet because the current Settings/Profile UI
does not have explicit editable fields for those backend-owned values.

Do not make username, email, bio, phone, auth/security, verification,
scheduling, or destructive account behavior part of the patient profile update
payload.

## Next Runtime Boundary

Queue `52.66 - Wire Patient Profile Name Update From Settings Profile`.

The implementation should:

- call `ProfileRepository.updatePatientMe` only from Settings/Profile
- combine first name and last name into backend `name`
- trim the combined name before sending
- require at least one non-empty backend name value
- keep username, email, and bio out of the backend payload
- keep age and location out of the payload until explicit editable UI exists
- show safe loading, success, and error states for the backend name update
- preserve the existing local save behavior for username/email/bio
- avoid sending user id, patient profile id, role, phone, password,
  verification state, scheduling data, public profile data, or destructive
  account data

## Failure Behavior

If patient profile name update fails:

- show a safe backend/profile error
- do not claim backend profile was saved
- do not hide the local-only nature of username/email/bio

The next implementation may either:

- keep local save separate from backend name update, or
- run backend name update before local save while making the mixed boundary
  explicit in UI/tests

It must not silently treat a failed backend update as success.

## Why Not Move To Another Surface

Patient profile read is already wired and regression-proven. The next smallest
backend-completed improvement is to prove the matching update boundary for the
only editable backend-supported field currently present in the UI: name.

Other candidates remain less ready:

- scheduling smoke is blocked on deliberate staging data
- verification upload/list is blocked on storage readiness and upload UX
- admin verification dashboard is outside the mobile milestone
- phone/OTP and MFA remain backend-deferred
- public professional detail lacks a documented detail route

## Explicitly Out Of Scope

- age update
- location update
- username persistence
- email mutation or verification
- bio persistence
- phone/OTP
- MFA/PIN/security changes
- logout/delete/deactivate backend behavior
- professional profile mutation
- verification upload/list
- admin verification dashboard
- scheduling smoke data
- public profile detail
- payments, notifications, reviews, calls, calendar sync, notes,
  prescriptions, or medical records

## Non-Claims

This decision does not claim:

- patient profile mutation is implemented yet
- username/email/bio persistence is ready
- age/location editable UI exists
- account/security settings are backend-complete
- the app is production-ready or Play Store-ready
