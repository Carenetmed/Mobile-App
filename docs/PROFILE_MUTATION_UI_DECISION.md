# Profile mutation UI decision

**Task:** 52.26
**Status:** Accepted decision; first bio mutation path implemented in 52.27

Purpose: decide the first safe profile update UI slice after Manage Profile
professional self-read wiring without turning local draft screens into fake or
overbroad backend saves.

---

## Current Backend Contract

Professional self profile updates use:

`PUT /professionals/me`

Allowed fields:

- `displayName` - required by backend update payload
- `category` - required by backend update payload
- `specialty`
- `bio`

Not currently accepted by the professional profile backend contract:

- website
- address/location
- phone number
- email address
- business hours/availability
- verification status/documents
- public profile media/portfolio
- payments, reviews, calls, notes, prescriptions

---

## Current Flutter Screens Reviewed

| Screen | Current local field | Backend fit |
| --- | --- | --- |
| `editYourName` | name/display label draft | Partial fit as `displayName`, but backend update also requires `category` |
| `addDescription` | profile description draft | Good fit as `bio`, but backend update also requires current `displayName` and `category` |
| `editYourWebsite` | website draft | No current backend field |
| `setAddress` | address/location draft | No current professional profile field; may belong to future location/profile-address contract |
| `manageProfile` Basic | category is displayed after read | No category edit UI exists yet |

---

## Decision

Do not wire all profile edit screens at once.

The first safe mutation slice should wire only the existing professional bio
update path from `addDescription`, and only when an existing professional
profile can be read first.

Implementation rule for the next slice:

1. Read `ProfileRepository.professionalMe`.
2. If no professional profile exists, show a safe empty-profile message and do
   not create a partial profile from only a bio.
3. When saving a valid description, call `updateProfessionalMe` using:
   - existing `displayName`
   - existing `category`
   - existing `specialty`
   - new `bio`
4. Do not trust client-supplied role, user id, profile id, verification status,
   email, phone, address, website, availability, payment, review, media, or
   appointment state.

Reason: this proves the profile update boundary with the smallest existing UI
surface and avoids inventing missing category/name/profile-creation behavior.

---

## Explicitly Deferred

- creating a professional profile from the app when none exists
- editing `displayName` until category/source rules are defined
- editing `category` and `specialty` until UI exists
- website persistence
- address/location persistence
- patient profile UI
- public professional listing or detail replacement
- verification upload/list
- availability/business-hours mutation
- appointments
- payments, payouts, refunds
- reviews/ratings
- calls/video/audio
- notifications/reminders
- calendar sync
- consultation notes, prescriptions, medical records
- profile moderation/compliance workflow

---

## Recommended Next Slice

`52.27 - Wire Professional Bio Update From Add Description`

Implemented:

- inject/use `ProfileRepository` in `AddDescriptionShellPage`
- read existing professional self profile before save
- preserve existing `displayName`, `category`, and `specialty`
- send only the new `bio` as the changed field through `updateProfessionalMe`
- show safe loading/error/empty-profile states
- update focused `manage_profile_flow_test`
- keep name/category/specialty/website/address/patient/public listing and all
  wider product areas deferred

Recommended follow-up:

`52.28 - Decide Next Profile/Public-Professional Runtime Lane`

Choose deliberately between public verified professional listing replacement,
constrained name/category/specialty profile-edit UI, or pausing profile wiring.
Do not start broader runtime work from this document without a new slice.
