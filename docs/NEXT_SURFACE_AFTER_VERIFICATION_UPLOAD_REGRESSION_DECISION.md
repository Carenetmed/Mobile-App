# Next Surface After Verification Upload Regression Decision

Task: 52.81

Status: Accepted decision

## Context

The professional verification upload/list lane is regression-proven for the
current frontend milestone boundary. The current backend-completed Flutter map
already has focused coverage for:

- auth/session/account read and scoped auth actions
- patient profile read and name-only update
- professional self-profile read and bio-only update
- public professional Search, Specialist Details, and Find Mentor paths
- public availability, appointment request, own list, cancellation,
  accept/decline, completion, reschedule, and professional availability
- professional verification owner document list and controlled upload

Scheduling staging smoke remains blocked on deliberate backend/staging data.
Admin verification review remains a separate role surface. Verification upload
follow-ups such as checksum, previews, rejection reasons, and scanning claims
remain deferred until their contracts are explicit.

## Reviewed Options

| Option | Decision | Reason |
| --- | --- | --- |
| Scheduling staging smoke | Defer | The blocker is deliberate backend-owned staging data, not another Flutter UI slice |
| More appointment lifecycle features | Defer | The current appointment/availability core is broad enough for this milestone and should not expand into no-show, disputes, payments, notifications, or notes |
| Verification admin/rejection UI | Defer | Admin review, signed-read, approval, rejection reasons, and appeal behavior are separate admin/product surfaces |
| Verification upload enhancements | Defer | Checksum, preview/download, multi-file/background upload, camera capture, and scanning claims need separate provider/security decisions |
| Patient profile expansion | Defer | Age/location mutation needs field UX and product rules; current safe patient name update is already regression-proven |
| Google link/unlink/sign-up | Defer | Sign-in is already scoped; link/unlink and role-selection sign-up rules are separate auth/product decisions |
| Professional website/address | Defer | The current professional profile backend contract does not accept website or address fields |
| Professional basic profile fields | Select boundary decision next | `PUT /professionals/me` already accepts `displayName`, `category`, `specialty`, and `bio`; bio is wired, but name/category/specialty edit UX still needs a safe boundary |

## Decision

Select professional basic profile field editing as the next backend-completed
Flutter surface, but start with a boundary decision before runtime wiring.

Queue:

`52.82 - Define Professional Basic Profile Edit Boundary`

The next slice should decide how existing Manage Profile / Edit Your Name UI can
honestly update professional `displayName`, `category`, and `specialty` without
creating partial profiles, mixing account identity, or pretending website and
address are supported backend fields.

## Required Boundary Questions For 52.82

- Should the first runtime edit update only `displayName`, or update
  `displayName`, `category`, and `specialty` together?
- Does the existing `editYourName` route have enough UI to represent a
  professional display name, or does it need a constrained professional profile
  edit mode?
- How should the app preserve existing backend `category`, `specialty`, and
  `bio` when changing only one field?
- What happens if `GET /professionals/me` returns an empty profile?
- Should the app allow professional profile creation, or require an existing
  professional profile first like the bio update path?
- Which validation rules should be local before calling `PUT /professionals/me`?
- What safe loading/error/success states are required?
- Which focused tests prove no website, address, account email, verification,
  availability, appointment, payment, review, note, or prescription data is
  mixed into the update?

## Explicit Boundaries

The next slice must not implement runtime behavior. It should only define the
safe UI/repository boundary and choose the following implementation slice.

Future runtime work must not:

- send website or address to `PUT /professionals/me`
- create a professional profile from incomplete UI unless a decision explicitly
  accepts that creation behavior
- modify verification status, documents, availability, appointment state,
  account email, account role/status, phone, MFA, password, payment, review,
  media, note, prescription, or calendar data
- invent a public professional detail endpoint
- claim staging or production readiness

## Next

Run `52.82` as a decision-only boundary slice for professional basic profile
editing. Runtime wiring should only follow after that boundary is accepted.

