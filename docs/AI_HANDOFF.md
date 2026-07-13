# AI handoff - read this first

**Mandatory:** `docs/WORKING_AGREEMENT.md` before writing code.
**Also mandatory:** `docs/ARCHITECTURE_RULES.md` + `docs/TASK_TEMPLATE.md` before implementation.

**No old chat.** Read `docs/README.md` for doc index.

| Path | Role |
|------|------|
| Project | `C:\Users\asd\Music\Mobile-App-master` |
| Blueprint | `C:\Users\asd\Music\project-blueprint\project-blueprint\` |

---

## Active phase

**Phase 22 - Backend contract integration**

---

## Task queue (only ONE may be NEXT)

| ID | Task | Size | Status |
|----|------|------|--------|
| 1.1 | Add `lib/core/tokens/` from blueprint `color-palette` (purple `#7000DA` scale + neutrals); document in `COMPONENTS.md` | S | **DONE** |
| 1.2 | `CarenetButton` with Primary/Outline/Disabled/Large per blueprint `buttons/` | M | **DONE** |
| 1.3 | `CarenetTextField` per blueprint `inputfield` | M | **DONE** |
| 1.4 | Refactor onboarding + sign-up phone/email to use 1.2 + 1.3 (no behavior change yet) | M | **DONE** |
| 2.1 | Wire sign-up phone/email Continue -> `finishSignUp` with client-side validation | M | **DONE** |
| 2.2 | Make `finishSignUp` respect its form validation before routing to `communityAgreement` | M | **DONE** |
| 2.3 | Replace sign-up social auth no-op buttons with explicit disabled state and document backend dependency | S | **DONE** |
| 2.4 | Wire "Already have an account? Sign in" from sign-up phone/email to the correct sign-in entry screens | S | **DONE** |
| 3.1 | Wire sign-in phone/email Continue actions to dashboard with local validation (no backend yet) | M | **DONE** |
| 3.2 | Define and wire the `Forgot Password?` path once the target screen/route is confirmed from blueprint or product decision | S | **DONE** |
| 4.1 | Replace dashboard tabs 1-4 `Placeholder()` content with named scaffold screens while preserving bottom-nav switching | M | **DONE** |
| 4.2 | Replace Home tab `Messages` and `Articles` placeholders with real screen content or routed shells | M | **DONE** |
| 4.3 | Fix the bottom-nav Notifications icon and align Home inner tabs with routed feature screens where appropriate | M | **DONE** |
| 5.1 | Integrate dashboard/Home entry points with the dedicated messaging and notifications feature screens without duplicate UI paths | M | **DONE** |
| 5.2 | Wire the dedicated messages list into chat and remove fake secondary navigation inside messaging/notifications where it conflicts with the app shell | M | **DONE** |
| 5.3 | Route actionable notification cards into their dedicated feature destinations and document any remaining non-actionable notification states | M | **DONE** |
| 5.4 | Replace the remaining placeholder-style notification categories with real filtered states or explicit disabled states that match the current feature surface | M | **DONE** |
| 5.5 | Clean up legacy duplicate messaging screens (`Message.dart` vs `Chat.dart` / `Chat_2.dart`) and choose the single route structure we will keep building on | M | **DONE** |
| 5.6 | Start the dedicated appointments/health destination shells needed by remaining notification cards, or explicitly document which cards stay read-only until later phases | M | **DONE** |
| 5.7 | Decide the next notification-backed feature lane (`articles`, `emergency`, or `podcast`) and add its first honest destination shell before wiring more notification cards | M | **DONE** |
| 5.8 | Choose between `emergency` and `podcast` as the next notification-backed destination, and add the first honest shell for the winner | M | **DONE** |
| 5.9 | Decide whether to unlock `podcast` next or intentionally freeze it as read-only until a later content phase; document the decision and, if chosen, add its first destination shell | M | **DONE** |
| 6.1 | Promote the existing readings surface into the first deliberate Phase 6 flow: wire a real path from `readings` to `manage_readings`, and clean up any no-op actions inside that slice | M | **DONE** |
| 6.2 | Decide the next honest improvement inside the readings slice: either make `Download Readings` a real export flow or mark it explicitly deferred and move to device/add-reading onboarding | M | **DONE** |
| 6.3 | Start the add-reading/device onboarding lane from the readings slice using the blueprint `/add-device` and `/blood-sug` references, without inventing fake data export yet | M | **DONE** |
| 6.4 | Decide the next honest readings slice: deepen the `bloodSug` lane with its first entry form/state, or formalize another reading type only if the blueprint gives a real destination to build toward | M | **DONE** |
| 6.5 | Decide whether to persist the saved `bloodSug` entry back into the `readings` dashboard card, or intentionally keep it local until a broader readings-state slice begins | M | **DONE** |
| 6.6 | Decide the next honest readings-state slice: generalize the local store for additional vitals, or keep Phase 6 focused on deepening blood sugar history/trends before broadening | M | **DONE** |
| 6.7 | Decide whether Phase 6 should next add simple edit/delete behavior to the blood sugar history, or stop and move to another blueprint-backed health route | M | **DONE** |
| 7.1 | Start the next blueprint-backed health route after readings, likely appointments, by turning its shell into the first real frontend-ready slice instead of broadening more vitals at once | M | **DONE** |
| 7.2 | Turn `bookAppointment` into the first real booking form/state slice instead of leaving it as a route-only handoff | M | **DONE** |
| 7.3 | Decide the next honest appointments slice: add local confirmation/cancel behavior to the booking draft, or stop and move to the next blueprint-backed route | M | **DONE** |
| 8.1 | Start the next blueprint-backed health/emergency route after appointments by turning its shell into the first real frontend-ready slice | M | **DONE** |
| 8.2 | Decide the next honest emergency slice: add a local dispatch/escalation confirmation step to the distress flow, or stop and move to the next blueprint-backed route | M | **DONE** |
| 9.1 | Start the next blueprint-backed route after emergency by turning its existing shell into the first real frontend-ready slice | M | **DONE** |
| 9.2 | Decide the next honest content slice: deepen articles with local saved/read state, or stop and move to the next blueprint-backed route | M | **DONE** |
| 9.3 | Decide whether to keep deepening articles with local reader actions, or stop the content lane here and move to the next blueprint-backed route | M | **DONE** |
| 10.1 | Start the next blueprint-backed route after articles, likely communities, by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 10.2 | Decide the next honest communities slice: add local joined-community state back into the main Circles view, or stop and move to the next blueprint-backed route | M | **DONE** |
| 10.3 | Decide whether to stop the communities lane here and move to the next blueprint-backed route, or add a real local community detail/posts slice only if it is blueprint-backed | M | **DONE** |
| 10.4 | Decide whether to stop the communities lane here and move to the next blueprint-backed route, or add a blueprint-backed `create-a-community` / owner-management slice only if it can stay honest without backend posting flows | M | **DONE** |
| 10.5 | Decide whether to stop the communities lane here and move to the next blueprint-backed route, or add another communities slice only if it can stay honest without inventing posts, media upload, or moderation backends | M | **DONE** |
| 11.1 | Start the next blueprint-backed route after communities, likely Q&A, by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 11.2 | Decide the next honest Q&A slice: add a blueprint-backed local detail/answer handoff only if it can stay honest without fake matching or moderation logic, or stop and move to the next blueprint-backed route | M | **DONE** |
| 11.3 | Decide whether to stop the Q&A lane here and move to the next blueprint-backed route, or add another Q&A slice only if the blueprint-backed `q-a-post` path can stay honest without inventing backend distribution or mixed feed logic | M | **DONE** |
| 12.1 | Start the next blueprint-backed route after Q&A, likely account/profile, by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 12.2 | Decide the next honest account slice: deepen account/settings/profile management only if the next blueprint-backed path can stay honest without backend auth-change or destructive account APIs, or stop and move to the next blueprint-backed route | M | **DONE** |
| 12.3 | Decide whether to stop the account lane here and move to the next blueprint-backed route, or add another account/profile slice only if it can stay honest without backend auth, support, scheduling, or creator-tool dependencies | M | **DONE** |
| 13.1 | Start the next blueprint-backed route after account/profile by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 13.2 | Decide the next honest podcast slice: deepen podcast only if the next blueprint-backed behavior can stay honest without streaming/upload/comment backends, or stop and move to the next blueprint-backed route | M | **DONE** |
| 14.1 | Start the next blueprint-backed route after podcast by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 14.2 | Decide the next honest search slice: deepen consultant discovery only if it can stay honest without live availability/payment/provider-profile APIs, or stop and move to the next blueprint-backed route | M | **DONE** |
| 15.1 | Start the next blueprint-backed route after search by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 15.2 | Decide the next honest health-record slice: deepen health record only if it can stay honest without export/backend history APIs, or stop and move to the next blueprint-backed route | M | **DONE** |
| 16.1 | Start the next blueprint-backed route after health record by turning its existing shell or route target into the first real frontend-ready slice | M | **DONE** |
| 16.2 | Decide the next honest saved/content-library slice: deepen saved/published content only if it can stay honest without creator publishing/content APIs, or stop and move to the next blueprint-backed route | M | **DONE** |
| 17.1 | Start the next blueprint-backed route after saved/content-library by turning its existing shell or route target into the first honest frontend-ready slice | M | **DONE** |
| 17.2 | Decide the next honest case-studies/content slice: deepen only if it can stay local and backend-ready, or stop before content API/comment/sharing dependencies | M | **DONE** |
| 18.1 | Start the next blueprint-backed route after case studies by turning its existing shell or route target into the first honest frontend-ready slice | M | **DONE** |
| 18.2 | Decide the next honest public-profile slice: deepen only if it stays local/backend-ready, or stop before creator portfolio/media/share/profile API dependencies | M | **DONE** |
| 19.1 | Start the next blueprint-backed route after public profile by turning its existing shell or route target into the first honest frontend-ready slice | M | **DONE** |
| 19.2 | Decide the next honest owner-circle slice: deepen owner management only if it can stay local/backend-ready, or stop before permissions/invites/moderation/destructive community APIs | M | **DONE** |
| 20.1 | Start the next unresolved blueprint-backed route after owner circle profile: `/manage-profile`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 20.2 | Decide the next honest manage-profile slice: deepen only if it can stay local/backend-ready, or stop before scheduling/payment/media/share/profile/community-management APIs | M | **DONE** |
| 21.1 | Start the next unresolved blueprint-backed route after manage profile: `/manage-portfolio`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 21.2 | Decide the next honest manage-portfolio slice: deepen creator portfolio only if it can stay local/backend-ready, or stop before publishing/media/payment/subscription/moderation APIs | M | **DONE** |
| 22.1 | Start the next unresolved blueprint-backed route after the deferred creator/payment portfolio cluster: `/change-authentication`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 22.2 | Decide the next honest change-authentication slice: deepen only if it can stay local/backend-ready, or stop before PIN creation, disable-2FA, secure storage, and auth backend dependencies | M | **DONE** |
| 23.1 | Start the next unresolved blueprint-backed account/security route after change-authentication: `/add-phone-number`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 23.2 | Decide the next honest add-phone slice: deepen only if it can stay local/backend-ready, or stop before OTP delivery, code verification, phone uniqueness, and auth-session update dependencies | M | **DONE** |
| 24.1 | Start the next unresolved blueprint-backed account/security route after add-phone-number: `/password`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 24.2 | Decide the next honest password slice: deepen only if it can stay local/backend-ready, or stop before password change, current-password verification, session invalidation, and auth backend dependencies | M | **DONE** |
| 25.1 | Start the next unresolved blueprint-backed account/security route after password: `/add-email`, by turning its route target into the first honest frontend-ready slice | M | **DONE** |
| 25.2 | Decide the next honest add-email slice: deepen only if it can stay local/backend-ready, or stop before email verification, uniqueness checks, auth-session update, and account persistence dependencies | M | **DONE** |
| 26.1 | Start the next unresolved blueprint-backed account/security route after add-email: `/change-email`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake verification/account persistence | M | **DONE** |
| 26.2 | Decide the next honest change-email slice: deepen only if it can stay local/backend-ready, or stop before verification-code delivery, code confirmation, account save, and auth-session dependencies | M | **DONE** |
| 27.1 | Start the next unresolved blueprint-backed account/security route after change-email: `/edit-email`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake removal/verification/account persistence | M | **DONE** |
| 27.2 | Decide the next honest edit-email slice: deepen only if it can stay local/backend-ready, or stop before email removal, re-authentication, recovery rules, and account persistence dependencies | M | **DONE** |
| 28.1 | Start the next unresolved blueprint-backed account/security route after edit-email: `/enter-password-to-save`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake re-authentication/account persistence | M | **DONE** |
| 28.2 | Decide the next honest enter-password-to-save slice: deepen only if it can stay local/backend-ready, or stop before password verification, session checks, audit, and account persistence dependencies | M | **DONE** |
| 29.1 | Start the next unresolved blueprint-backed account/security route after enter-password-to-save: `/confirm-phone-number`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake OTP/code verification/account persistence | M | **DONE** |
| 29.2 | Decide the next honest confirm-phone-number slice: deepen only if it can stay local/backend-ready, or stop before OTP delivery, code confirmation, phone uniqueness, session updates, audit, and account persistence dependencies | M | **DONE** |
| 30.1 | Start the next unresolved blueprint-backed account/security route after confirm-phone-number: `/turn-on-authentication`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake 2FA/PIN/session behavior | M | **DONE** |
| 30.2 | Decide the next honest turn-on-authentication slice: deepen only if it can stay local/backend-ready, or stop before PIN creation, secure storage, session checks, audit, and account persistence dependencies | M | **DONE** |
| 31.1 | Start the next unresolved blueprint-backed account/security route after turn-on-authentication: `/create-pin`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake secure PIN storage/session behavior | M | **DONE** |
| 31.2 | Decide the next honest create-pin slice: deepen only if it can stay local/backend-ready, or stop before PIN confirmation, secure storage, session checks, audit, and account persistence dependencies | M | **DONE** |
| 32.1 | Start the next unresolved blueprint-backed account/security route after create-pin: `/confirm-pin-save`, by turning its route target into the first honest frontend-ready slice only if it can avoid fake secure PIN storage/session behavior | M | **DONE** |
| 32.2 | Decide the next honest confirm-pin-save slice: deepen only if it can stay local/backend-ready, or stop before secure PIN storage, session checks, audit, account persistence, and enabling 2FA | S | **DONE** |
| 33.1 | Start `/reminder`, the next meaningful unresolved blueprint-backed route after the account/security cluster, only if it can become an honest frontend-ready slice without fake notification/backend scheduling behavior | M | **DONE** |
| 33.2 | Decide the next honest reminder slice: deepen only if persistence/delivery rules exist, or stop before fake reminder records, alarms, push scheduling, permissions, and backend state | S | **DONE** |
| 34.1 | Start `/schedules`, the next unresolved blueprint-backed scheduling route after reminder, only if it can become an honest frontend-ready slice without fake backend availability or persistence | M | **DONE** |
| 34.2 | Decide the next honest schedules slice: deepen only if CRUD/persistence/delivery rules exist, or stop before fake schedule mutation, recurrence, countdown, sharing, and notification behavior | S | **DONE** |
| 35.1 | Inspect and start `/selected-dates`, the next unresolved blueprint-backed scheduling route, only if its role and interactions can be implemented without inventing schedule persistence | M | **DONE** |
| 35.2 | Decide the next honest selected-dates slice: deepen only if profile-hours persistence/product rules exist, or stop before fake saved availability, multiple hour sets, upgrades, and server conflict behavior | S | **DONE** |
| 36.1 | Inspect `/community-invitations-discover` against the existing communities flow and implement only the missing blueprint-backed behavior without duplicating current discover/join state | M | **DONE** |
| 36.2 | Decide the next honest community-invitations slice: deepen only if delivery/approval/moderation contracts exist, or stop before fake invite backend behavior | S | **DONE** |
| 37.1 | Inspect the next meaningful unresolved blueprint-backed route after community invitations, skipping design-system-only frames unless they map to an app feature | M | **DONE** |
| 37.2 | Decide the next honest find-mentor slice: deepen only if live availability/profile/payment contracts exist, or stop before fake booking confirmation/provider backend behavior | S | **DONE** |
| 38.1 | Start `/specialist-details`, the next unresolved provider route after find-mentor, without inventing live availability, payments, or backend booking confirmation | M | **DONE** |
| 38.2 | Decide the next honest specialist-details slice: deepen only if live availability/reviews/payment contracts exist, or stop before fake confirmed booking/provider backend behavior | S | **DONE** |
| 39.1 | Inspect the remaining blueprint routes after specialist-details and choose the next real app feature, skipping component/demo/marketing-only frames unless they map to current product scope | M | **DONE** |
| 40.1 | Start `/published-articles` as the next creator/content route, building only an honest frontend-ready read/list/detail surface without fake publishing APIs | M | **DONE** |
| 40.2 | Decide the next honest published-articles slice: deepen only if creator publishing/content contracts exist, or stop before fake drafts, analytics, subscribers, comments, or publishing APIs | S | **DONE** |
| 41.1 | Inspect the remaining blueprint routes after the creator/content cluster and choose the next real app feature, skipping creator/payment/media/backend-only frames unless they can be implemented honestly | M | **DONE** |
| 42.1 | Start `/edit-your-name` as the next Manage Profile basic-info route, building only a local validated draft surface without fake profile persistence | M | **DONE** |
| 42.2 | Decide the next honest edit-your-name/basic-info slice: deepen only if profile persistence contracts exist, or stop before fake saved profile updates/account sync | S | **DONE** |
| 43.1 | Start `/edit-your-website` as the next Manage Profile basic-info route, building only a local validated draft surface without fake profile persistence | M | **DONE** |
| 43.2 | Decide the next honest edit-your-website/basic-info slice: deepen only if profile persistence contracts exist, or stop before fake saved website/account sync | S | **DONE** |
| 44.1 | Start `/add-desicription` as the next Manage Profile About route, building only a local validated description draft without fake profile persistence | M | **DONE** |
| 44.2 | Decide the next honest add-description/About slice: deepen only if profile-copy persistence and moderation contracts exist, or stop before fake publishing/profile updates | S | **DONE** |
| 45.1 | Inspect the remaining Manage Profile basic-info blueprint routes after `/add-desicription`, skipping account/email or scheduling duplicates unless they can stay honest, and choose the next frontend-ready route | S | **DONE** |
| 46.1 | Start `/set-address` as the next Manage Profile Basic route, building only a local validated address draft without fake profile persistence or location services | M | **DONE** |
| 46.2 | Decide the next honest set-address/Basic slice: deepen only if profile-address persistence and location-service contracts exist, or stop before fake saved address/maps behavior | S | **DONE** |
| 47.1 | Inspect the remaining blueprint routes after the Manage Profile basic-info cluster, skipping ads/payments/media/account duplicates unless they can stay honest, and choose the next frontend-ready route | S | **DONE** |
| 48.1 | Run a frontend coverage audit across docs, routes, and deferred work to identify any remaining honest frontend-only gaps before backend/product contracts are needed | S | **DONE** |
| 49.1 | Prepare the backend/product readiness handoff: group deferred seams by required contract so backend work can start without losing the frontend replacement paths | S | **DONE** |
| 50.1 | Run the final handoff review across docs and route status, then mark frontend route coverage ready for backend/product contract selection if no drift is found | S | **DONE** |
| 51.1 | Choose the first backend/product contract group to integrate, using `DEFERRED_WORK.md` readiness buckets and keeping locked controls disabled until real contracts exist | S | **DONE** |
| 51.2 | Define the auth/session/account backend contract before implementation: API style, environment/base URL rules, session storage, auth/account models, validation/error states, OTP/email-code provider boundaries, and repository replacement plan | M | **DONE** |
| 52.1 | Implement the auth/session/account infrastructure boundary: environment API config, safe auth API client, session store, auth/account models, repository interfaces, and focused tests without wiring screens to backend yet | M | **DONE** |
| 52.2 | Wire the first auth screen to the repository boundary, starting with email sign-in only: preserve local validation, require backend config for backend success, show safe loading/error states, and keep phone/social/security flows deferred | M | **DONE** |
| 52.3 | Wire email sign-up to the repository boundary only: preserve current validation, submit backend registration through `AuthRepository`, show safe loading/error states, and keep social/phone/security flows deferred | M | **DONE** |
| 52.4 | Add session restore/app launch guard: restore stored auth session through `AuthRepository`, route authenticated users to dashboard, route missing/invalid sessions to onboarding/auth, and keep refresh/staging smoke separate if not fully scoped | M | **DONE** |
| 52.5 | Add a real logout/session-clear action from the authenticated app shell: call `AuthRepository.logout`, clear stored session, return to onboarding/auth, and keep destructive account deletion, MFA, phone, and password-reset flows deferred | M | **DONE** |
| 52.6 | Wire password reset screens to the auth repository boundary: request reset from email entry, confirm reset from password entry only if the existing flow can pass the required token honestly; otherwise document the missing token/email-link boundary and stop before fake reset success | M | **DONE** |
| 52.7 | Define and wire the current-account read boundary for the Account shell: use `AccountRepository.currentAccount` only where it can safely replace local account display, keep profile editing/deletion/security mutations deferred, and document any remaining local profile seams | M | **DONE** |
| 52.8 | Wire the email verification request/confirmation boundary only where token handling is honest: allow requesting verification for the current account if session-backed, but do not fake confirmation without a secure token/deep-link or code-entry path | M | **DONE** |
| 52.9 | Run an auth/session/account frontend integration regression pass: cover sign-in, sign-up, restore, logout, password reset request boundary, current account read, and email verification request boundary; document any remaining gaps before starting another feature lane | M | **DONE** |
| 52.10 | Decide the next backend-integration lane after the auth/session/account regression pass: either close Phase 22 for now, continue remaining auth/account backend wiring, or select the next contract group from `DEFERRED_WORK.md` without implementing runtime behavior in the decision slice | S | **DONE** |
| 52.11 | Restore the missing workflow guardrail docs referenced by `README.md`, `AI_HANDOFF.md`, and `DOC_SYNC.md`: recreate `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` from the active rules without changing runtime code | S | **DONE** |
| 52.12 | Decide where backend-integration frontend work resumes after guardrails are restored: remaining auth/account token-confirmation flows, another contract group from `DEFERRED_WORK.md`, or a stop-and-handoff checkpoint | S | **DONE** |
| 52.13 | Create a frontend/backend integration checkpoint handoff: summarize the auth/session/account frontend wiring that is complete, list the exact remaining frontend blockers, and state what backend/deep-link contracts are needed before more runtime wiring | S | **DONE** |
| 52.14 | Decide the next frontend/backend runtime target after the checkpoint: define password reset/email verification deep-link contract, define phone OTP/MFA contract, pick another backend contract group, or pause frontend integration until backend contracts are ready | S | **DONE** |
| 52.15 | Define the password reset and email verification deep-link/code contract before runtime wiring: route ownership, token/code source, backend request/response fields, expired-token behavior, current-account refresh, and explicit out-of-scope items | M | **DONE** |
| 52.16 | Implement reset and email verification token-confirm route wiring from the confirmed backend contract, or stop if platform deep-link setup is required first | M | **DONE** |
| 52.17 | Decide the next backend-integration lane after reset/verification token-confirm wiring: production app-link setup, phone OTP/MFA contract, auth/account regression checkpoint, another contract group, or pause | S | **DONE** |
| 52.18 | Run an auth/account staging smoke and remaining-backend checkpoint: verify the wired auth/session/account boundary against the backend bridge/proxy docs, decide whether Google sign-in/link is ready or deferred, and keep profile/verification/availability/appointment wiring queued behind this shared base | M | **DONE** |
| 52.19 | Replace placeholder Android/iOS app identifiers with the accepted `com.carenet.app` foundation before Google OAuth setup; document remaining Google credential/provider prerequisites without wiring Google UI yet | S | **DONE** |
| 52.20 | Define the next Google sign-in setup slice: create/collect OAuth client prerequisites for `com.carenet.app`, decide Flutter provider package/config, and enable backend readiness only when real client IDs/fingerprints are available; stop before fake Google UI success | M | **DONE** |
| 52.21 | Add Google OAuth client IDs to staging: create/collect Android/iOS OAuth client IDs for `com.carenet.app`, configure backend staging `GOOGLE_OAUTH_CLIENT_ID` without committing secrets, and verify `/health/ready` reports `googleAuth: ok` before Flutter Google UI wiring | M | **DONE** |
| 52.22 | Wire Flutter Google Sign-In provider for the now-ready Android debug/staging backend path: add provider package/config, obtain a real Google ID token, call `AuthRepository.googleSignIn`, preserve safe errors/loading, and keep linking/unlinking, phone/OTP, MFA, production OAuth, release signing, and profile wiring out of scope | L | **DONE** |
| 52.23 | Define the profile and public professional wiring contract: map patient self profile, professional self profile, and public verified professional listing into Flutter repository/screen boundaries before runtime wiring; keep verification upload, admin dashboard, availability, appointment lifecycle, payments, notifications, reviews, calls, calendar sync, notes, and prescriptions out of scope | M | **DONE** |
| 52.24 | Add the profile repository boundary for patient self profile, professional self profile, and public verified professional listing: API client, entities, repository, and focused tests only; do not wire screens, verification upload, availability, appointments, public detail, payments, reviews, calls, calendar sync, notes, or prescriptions | M | **DONE** |
| 52.25 | Wire professional self profile read to Manage Profile using `ProfileRepository.professionalMe`: show safe loading/error/empty-profile states and replace only matching allowed fields; keep profile mutations, patient profile, public listing, verification upload, availability, appointments, public detail, payments, reviews, calls, calendar sync, notes, and prescriptions out of scope | M | **DONE** |
| 52.26 | Decide the first safe profile mutation UI slice after Manage Profile read wiring: choose a constrained professional self update path for only backend-allowed fields, or defer mutations until the edit screens are redesigned around the contract; do not implement runtime mutations in this decision slice | S | **NEXT** |

**AI:** Work only on the **NEXT** row. When finished, mark it **DONE**, set the following row to **NEXT**, update test steps below, **stop**, ask user to continue.

---

## Phase 0 - DONE

Spine: routing, splash 800ms, docs, tests. See `CODEBASE_STATUS.md` for remaining app-wide stubs (fixed in later tasks).

## Phase 1 - DONE

Tokens, `CarenetButton`, `CarenetTextField`, and onboarding/sign-up phone/email screen refactors are complete.

---

## Manual test (last completed: task 52.25)

Task `52.25` wires professional self-profile read into Manage Profile only. It does not save profile edits or wire patient profile, public listing, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, or prescriptions.

1. `flutter test test/features/home/manage_profile_flow_test.dart test/features/home/profile_repository_test.dart` - passes
2. `flutter analyze lib/features/Home/presentation/pages/manage_profile_shell.dart test/features/home/manage_profile_flow_test.dart` - no issues
3. Confirm Manage Profile reads `ProfileRepository.professionalMe`, replaces only `displayName`, `category`, `specialty`, and `bio`, and keeps local fallback/deferred controls for fields outside the backend profile contract.
4. Confirm `AI_HANDOFF.md` has exactly one task-table `**NEXT**` row: `52.26`

## Previous runtime manual test baseline

1. `flutter test test/features/home/home_tab_shell_test.dart test/features/home/dashboard_shell_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/shared/widgets/auth_widget_test.dart test/shared/widgets/carenet_text_field_test.dart test/shared/widgets/carenet_button_test.dart test/core/tokens/carenet_colors_test.dart` - all pass
2. `flutter analyze lib/features/Home/presentation/pages/home_messages_tab.dart lib/features/Home/presentation/pages/dashboard.dart test/features/home/home_tab_shell_test.dart test/features/home/dashboard_shell_test.dart` - no issues
3. `flutter run` -> sign-up phone -> tap `Continue` with empty fields: country and phone show red error states and do not navigate
4. `flutter run` -> sign-up phone -> enter valid country + phone -> `Continue` routes to `finishSignUp`
5. `flutter run` -> sign-up email -> tap `Continue` empty/invalid: email shows red error state and does not navigate
6. `flutter run` -> sign-up email -> enter valid email -> `Continue` routes to `finishSignUp`
7. `flutter run` -> `finishSignUp` -> tap `Agree & continue` empty: first name, last name, birthday, email, password, and confirm password all block navigation with inline errors
8. `flutter run` -> `finishSignUp` -> enter valid birthday/email/password fields and matching passwords -> `Agree & continue` routes to `communityAgreement`
9. `flutter run` -> sign-up phone/email -> Google, Facebook, and Apple rows appear visibly disabled and do not react to taps
10. `flutter run` -> sign-up phone -> tap `Already have an account? Sign in` -> routes to `signInPhone`
11. `flutter run` -> sign-up email -> tap `Already have an account? Sign in` -> routes to `signInEmail`
12. `flutter run` -> sign-in phone -> tap `Continue` empty/invalid: country, phone, and password show inline errors and do not navigate
13. `flutter run` -> sign-in phone -> enter valid country + phone + password -> `Continue` routes to `dashboard`
14. `flutter run` -> sign-in email -> tap `Continue` empty/invalid: email and password show inline errors and do not navigate
15. `flutter run` -> sign-in email -> enter valid email + password -> `Continue` routes to `dashboard`
16. `flutter run` -> sign-in phone/email -> tap `Forgot Password?` -> routes to `enterEmail`
17. `flutter run` -> `enterEmail` -> invalid email blocks; valid email routes to `enterPassword`
18. `flutter run` -> `enterPassword` -> invalid or mismatched passwords block; valid values return to `signInEmail`
19. `flutter run` -> dashboard -> tap `Search` / `Post` / `Circles` in bottom nav -> each tab shows its own named shell screen instead of `Placeholder()`
20. `flutter run` -> dashboard -> Home tab -> tap `Messages` and `Articles` -> each inner tab shows real content instead of `Placeholder()`
21. `flutter run` -> dashboard -> bottom-nav Notifications uses a bell icon, not the phone icon
22. `flutter run` -> dashboard -> Home tab -> `Messages` -> tap `Open full inbox` or a message preview -> routes to the dedicated `messages` screen
23. `flutter run` -> dashboard -> tap `Notifications` in bottom nav -> the dedicated notifications screen opens directly and shows real notification content like "Your appointment is booked"
24. `flutter run` -> `messages` -> tap the conversation card -> routes to the dedicated `chat` screen
25. `flutter run` -> `notification` -> no fake bottom navigation row appears inside the page; only notification content remains
26. `flutter run` -> `notification` -> tap `Complete your profile` -> routes to `medicalEdit`
27. `flutter run` -> `notification` -> tap `Dr. Lagbaja has replied your message.` -> routes to `messages`
28. `flutter run` -> `notification` -> tap `You are missing updates` -> routes to `dashboard`
29. `flutter run` -> `notification` -> tap `Your appointment is booked` -> stays on notifications because appointments are not yet implemented
30. `flutter run` -> `notification` -> tap `Messages` tab -> only message-category notifications remain visible
31. `flutter run` -> `notification` -> tap `Appointment` tab -> only appointment-category notifications remain visible
32. `flutter run` -> `notification` -> tap `Events` tab -> only event-category notifications remain visible
33. `flutter run` -> `notification` -> tap `Payment` tab -> it stays visibly disabled and does not switch state
34. `flutter run` -> `messages` -> tap the conversation card -> `chat` opens with seeded conversation history, not an empty screen
35. `flutter run` -> navigate to route `message` -> it reuses the shared chat page structure as a compatibility alias with the unavailable notice instead of a separate legacy screen file
36. `flutter run` -> `notification` -> tap `Your appointment is booked` -> routes to the appointments shell screen
37. `flutter run` -> `notification` -> tap `Appointment` tab then `Update your reading, its been 5 days already` -> routes to the readings screen
38. `flutter run` -> `notification` -> `Your emergency request is approved.` still stays read-only because emergency does not have a real destination yet
39. `flutter run` -> `notification` -> tap `Events` then `Dr. Tamedu has published a new article` -> routes to the articles screen
40. Superseded by task `13.1`: podcast notifications no longer stay read-only; see step 82 for the current route behavior
41. `flutter run` -> `notification` -> tap `Your emergency request is approved.` -> routes to the emergency shell screen
42. Superseded by task `13.1`: podcast is no longer a read-only notification-backed content lane
43. Superseded by task `13.1`: the old Phase 5 deferral (`DECISIONS.md` D004) ended when the later podcast content phase added the real `podcast` route
44. `flutter run` -> route to `readings` -> tap `Add new Readings` -> routes to `manageReadings`
45. `flutter run` -> `manageReadings` -> tap `Done` -> returns to `readings`
46. `flutter run` -> `readings` -> menu icon and `Download Readings` remain visibly disabled instead of pretending to work
47. `flutter run` -> long-press or hover `Download Readings` on `readings` -> deferred export tooltip explains that export waits for the add-reading flow (`DECISIONS.md` D005)
48. `flutter run` -> `readings` -> `Add new Readings` -> select `Blood Sugar` -> `Done` routes to `addDevice`
49. `flutter run` -> `addDevice` -> tap `Continue to Blood Sugar` -> routes to `bloodSug`
50. `flutter run` -> `bloodSug` -> tap `Save reading` empty -> reading and context errors appear; nothing saves
51. `flutter run` -> `bloodSug` -> enter a numeric reading, choose a context, optionally add a note, tap `Save reading` -> `Latest local entry` summary appears with the captured values
52. `flutter run` -> after saving a blood sugar entry, back out to `readings` -> the `Blood Sugar` dashboard card updates to the saved value and a latest-entry summary appears below the grid
53. `flutter run` -> `bloodSug` -> save two readings with different values -> the history panel shows both entries and the trend text updates up/down against the previous reading
54. `flutter run` -> `bloodSug` -> delete the newest saved history row -> that row disappears, latest-entry falls back to the previous reading, and the trend summary resets if only one reading remains
55. `flutter run` -> `notification` -> tap `Your appointment is booked` -> routes to `appointments`, which shows real upcoming/recent sections
56. `flutter run` -> `appointments` -> tap `Book appointment` -> routes to `bookAppointment`
57. `flutter run` -> `bookAppointment` -> tap `Save booking request` empty -> clinician, visit type, preferred date, and reason all show validation errors
58. `flutter run` -> `bookAppointment` -> enter clinician, choose visit type, enter date and reason, tap `Save booking request` -> a latest booking draft summary appears
59. `flutter run` -> `bookAppointment` -> after saving a draft, tap `Confirm request` -> draft status becomes `Confirmed locally`; tap `Cancel draft` -> the draft summary disappears
60. `flutter run` -> `notification` -> tap `Your emergency request is approved.` -> routes to `emergency`, which shows current status and local update cards
61. `flutter run` -> `emergency` -> tap `Open distress call` -> routes to `distressCall`
62. `flutter run` -> `distressCall` -> tap `Save distress update` empty -> location and emergency details show validation errors
63. `flutter run` -> `distressCall` -> enter location and emergency details, tap `Save distress update` -> a latest distress update summary appears
64. `flutter run` -> `distressCall` -> after saving an update, tap `Send to dispatch` -> status changes to `Queued for dispatch`; tap `Clear update` -> the saved update summary disappears
65. `flutter run` -> `notification` -> tap `Dr. Tamedu has published a new article` -> routes to `articles`, which shows real article list content
66. `flutter run` -> `articles` -> tap `Open article` -> the route switches into a readable article detail view with local content seam note
67. `flutter run` -> `articles` -> open an article, tap `Save article`, go back -> the list shows `Saved` and the opened article label changes to `Read article`
68. No new runtime step for `9.3`: this task is a documented scope decision to stop the articles lane here and move to the next blueprint-backed route (`DECISIONS.md` D006)
69. `flutter run` -> dashboard -> tap `Circles` -> the route shows real local community content
70. `flutter run` -> `circles` -> tap `Discover communities` -> routes to `discoverCommunities`; tap `Join community` -> the button changes to `Joined locally`
71. `flutter run` -> `circles` -> tap `Discover communities` -> tap `Join community` -> go back -> the joined community appears under `My communities`
72. `flutter run` -> `circles` -> tap `Women in Medicine` -> the local community profile opens with description, member previews, articles, and event sections
73. `flutter run` -> `circles` -> tap `Create community` -> empty submit shows required-field errors; enter a name, description, and privacy -> tap `Create` -> a local owner profile opens and the new community is added into your communities state
74. No new runtime step for `10.5`: this task is the documented decision to stop the communities lane after create/view/join flows because the remaining invitation and moderation screens would require backend-backed workflows (`DECISIONS.md` D007)
75. `flutter run` -> dashboard -> tap `Post` in bottom nav -> the tab now shows a real local `Q&A feed` instead of a shell
76. `flutter run` -> `Post` / `Q&A feed` -> tap `Ask` -> empty `Send` shows validation, non-question text shows the prefix rule, valid `What/How/Why/Where` question returns to the feed and appears as `Saved locally`
77. `flutter run` -> `Post` / `Q&A feed` -> tap `Answer` -> `Answer requests` opens; tap `See tagged questions for you` -> tagged local questions list opens; tap `Answer` on a question -> `Comment` opens; submit text -> return and the answer appears under local answer drafts
78. No new runtime step for `11.3`: this task is the documented decision to stop the Q&A lane after local ask/answer flows because `q-a-post` would require real distribution and mixed feed rules (`DECISIONS.md` D008)
79. `flutter run` -> dashboard -> open drawer -> tap `Profile` -> routes to `Account`; tap `Delete account` -> empty submit shows required errors; tap `Deactivate your instead?` -> deactivation confirmation modal appears
80. `flutter run` -> dashboard -> open drawer -> tap `Profile` -> tap `Settings & Profile` -> invalid username/email show inline errors; valid edits enable `Save Changes`; save returns to `Account` and updated email/profile values appear locally
81. No new runtime step for `12.3`: this task is the documented decision to stop the account lane after local account/settings/delete flows because public profile, scheduling, auth-security, and creator-facing screens need their own backend-backed decisions (`DECISIONS.md` D009)
82. `flutter run` -> `notification` -> tap `Dr. Lakasegbe has published a new podcast` -> routes to `podcast`; tap `Watch` on an episode -> the button changes to `Watched locally`
83. No new runtime step for `13.2`: this task is the documented decision to stop the podcast lane after the local list/watch slice because creator upload, recording, comments, streaming, and content APIs need backend/media-backed workflows (`DECISIONS.md` D010)
84. `flutter run` -> dashboard -> tap `Search` -> the tab shows `Search specialists`; type `psychologist` -> results narrow to `Dr. Lakasegbe`; tap `Schedule` -> the button changes to `Requested locally`; tap `View profile` -> a local profile sheet opens
85. No new runtime step for `14.2`: this task is the documented decision to stop the search lane after local consultant discovery because the next blueprint depth enters live availability, appointment type, payment, and provider-profile API workflows (`DECISIONS.md` D011)
86. `flutter run` -> navigate to route `healthRecord` -> the screen shows `Health File`, `Your readings`, vitals cards, and the deferred `Download` button; save a blood sugar reading first and `Health Record` shows that latest local value
87. No new runtime step for `15.2`: this task is the documented decision to stop the health-record lane after the local readings summary because deeper history, report export, and synced vital types need backend/history APIs (`DECISIONS.md` D012)
88. `flutter run` -> navigate to route `savedArticles` -> the screen shows `Saved Articles`, `For you` / `Request` / `Drafts`, and `You have no saved articles`; save an article from `articles`, return to `savedArticles`, open `Read`, then `Remove saved` returns the route to the empty state
89. No new runtime step for `16.2`: this task is the documented decision to stop the saved/content-library lane after the local saved articles route because published articles, subscribers, article-story, drafts, creator publishing, account sync, analytics, comments, and content APIs need backend/content rules (`DECISIONS.md` D013)
90. `flutter run` -> navigate to route `caseStudies` -> the screen shows `Case Studies`, local case-study cards, and `All` / `Case studies` / `Best` filters; tap `Best` to narrow results; tap a case-study card to open the detail reader; back returns to the list and the card shows `Read`
91. No new runtime step for `17.2`: this task is the documented decision to stop the case-studies lane after local list/filter/detail/read-state behavior because content APIs, verified clinical review, author/publication records, comments, sharing, saved-to-account sync, and moderation need backend/content rules (`DECISIONS.md` D014)
92. `flutter run` -> navigate to route `publicProfile` -> the screen shows `Lagbaja Omo Tamedu`, professional details, articles, specializations, contact, and about sections; tap `Message` to open `messages`; return and tap `Schedule` to open `bookAppointment`; portfolio/podcast/share stay visibly disabled
93. No new runtime step for `18.2`: this task is the documented decision to stop the public-profile lane after local read-only profile content plus real message/schedule handoffs because profile APIs, creator portfolio, media/podcast profile content, sharing, provider scheduling, verified public identity, reviews/testimonies, and subscription/upgrade behavior need backend/product rules (`DECISIONS.md` D015)
94. `flutter run` -> navigate to route `ownerCircleProfile` -> the screen shows `Old People Circle`, `120 members`, owner-only `Settings`, and locked/deferred actions such as `Circle permissions`, `Add members`, `Edit circle details`, and `Delete Circle`
95. No new runtime step for `19.2`: this task is the documented decision to stop the owner-circle lane after the local owner profile and locked settings surface because permissions, member invitations, role changes, moderation, editing circle details, sharing, favourites sync, reporting, exiting, and destructive circle deletion need backend/community-management and product safety rules (`DECISIONS.md` D016)
96. `flutter run` -> navigate to route `manageProfile` -> the screen shows `Manage Profile`, `Old People Circle`, `Basic`, `About`, `Business`, and `Articles`; tap `Edit` to open `Settings & Profile`; return and tap `Message` to open `messages`; Events/Boost/Podcast/Share and Add members/Edit group details stay visibly disabled/deferred
97. No new runtime step for `20.2`: this task is the documented decision to stop the manage-profile lane after the local profile-management summary because profile update APIs, business schedule persistence, event management, ads/boosting, payment/ad-review rules, media/podcast management, sharing rules, member management, group-detail persistence, and creator verification need backend/product contracts (`DECISIONS.md` D017)
98. `flutter run` -> navigate to route `manageProfile` -> scroll to `Articles` -> tap `Manage` -> `managePortfolio` opens with `Old People Circle`, `Page` / `Circles` tabs, local portfolio content, and real `Edit` / `Message` handoffs; `Events`, `Boost`, `Podcast`, `Share`, `Add new article`, `Upload new podcast`, and `Upgrade` stay visibly disabled/deferred
99. No new runtime step for `21.2`: this task is the documented decision to stop the manage-portfolio lane after the local Page/Circles portfolio surface because article publishing, podcast upload/recording, media processing, creator portfolio APIs, ads/boosting, subscription upgrades, payment setup, moderation, analytics, and sharing need backend/product rules (`DECISIONS.md` D018)
100. `flutter run` -> dashboard -> drawer `Profile` -> tap `Authentication` -> `changeAuthentication` opens with two-step verification copy; `Change PIN`, `Turn off`, and `Learn more` stay visibly locked/deferred
101. No new runtime step for `22.2`: this task is the documented decision to stop the change-authentication lane after the local two-step verification information route because PIN creation/confirmation, disabling two-step verification, password re-authentication, secure PIN storage, device/session checks, audit logs, phone/email verification, and product-approved security help need backend/product rules (`DECISIONS.md` D019)
102. `flutter run` -> dashboard -> drawer `Profile` -> tap `Phone number` -> `addPhoneNumber` opens; empty `Prepare verification` shows a required error; valid phone shows a local ready-for-SMS-verification summary and returning to Account keeps the original phone number unchanged
103. No new runtime step for `23.2`: this task is the documented decision to stop the add-phone-number lane after the local phone-entry draft because OTP/SMS delivery, code verification, phone uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery rules, and account persistence need backend/provider contracts (`DECISIONS.md` D020)
104. `flutter run` -> dashboard -> drawer `Profile` -> tap `Password` -> `password` opens with the password security copy and local password hint; `Edit password` stays visibly locked/deferred
105. No new runtime step for `24.2`: this task is the documented decision to stop the password lane after the local password security information route because password editing, current-password verification, password policy enforcement, code confirmation, session invalidation, recovery/security notifications, and account persistence need backend/provider contracts (`DECISIONS.md` D021)
106. `flutter run` -> dashboard -> drawer `Profile` -> tap `Email address` -> `addEmail` opens; empty `Prepare verification` shows a required error; invalid email shows an inline validation error; valid email shows a local ready-for-email-verification summary and returning to Account keeps the original email address unchanged
107. No new runtime step for `25.2`: this task is the documented decision to stop the add-email lane after the local email-entry draft because verification email delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence need backend/provider contracts (`DECISIONS.md` D022)
108. `flutter run` -> dashboard -> drawer `Profile` -> tap `Email address` -> tap `Change existing email` -> `changeEmail` opens; empty/invalid/same email values show inline errors; a different valid email shows a local ready-for-code-verification summary and returning to Account keeps the original email address unchanged
109. No new runtime step for `26.2`: this task is the documented decision to stop the change-email lane after the local change-email draft because verification-code delivery, code confirmation, email uniqueness checks, password re-authentication, rate limiting, account-session updates, recovery/security notifications, and account persistence need backend/provider contracts (`DECISIONS.md` D023)
110. `flutter run` -> dashboard -> drawer `Profile` -> tap `Email address` -> tap `Review current email` -> `editEmail` opens with the current email, `Verified`, `Edit email`, locked `Remove email`, and `Edit email` hands off to `changeEmail`
111. No new runtime step for `27.2`: this task is the documented decision to stop the edit-email lane after the local current-email management route because email removal, password re-authentication, recovery rules, account-session updates, audit/security notifications, and account persistence need backend/provider contracts (`DECISIONS.md` D024)
112. `flutter run` -> dashboard -> drawer `Profile` -> tap `Email address` -> tap `Review current email` -> tap `Review password step` -> `enterPasswordToSave` opens; empty/short password values show inline errors; a valid-length password shows a local ready-for-backend-reauthentication summary without saving account changes
113. No new runtime step for `28.2`: this task is the documented decision to stop the enter-password-to-save lane after the local password-entry validation route because real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence need backend/provider contracts (`DECISIONS.md` D025)
114. `flutter run` -> dashboard -> drawer `Profile` -> tap `Phone number` -> enter a valid phone in `addPhoneNumber` -> tap `Open confirmation step` -> `confirmPhoneNumber` opens prefilled; empty/short values show validation; a valid phone shows a ready-for-backend-OTP-verification summary and returning to Account keeps the original phone unchanged
115. No new runtime step for `29.2`: this task is the documented decision to stop the confirm-phone-number lane after the local phone confirmation draft because OTP/SMS delivery, code confirmation, phone uniqueness checks, session updates, rate limiting, audit/security notifications, and account persistence need backend/provider contracts (`DECISIONS.md` D026)
116. `flutter run` -> dashboard -> drawer `Profile` -> tap `Authentication` -> tap `Review turn-on setup` -> `turnOnAuthentication` opens with two-step verification copy and a disabled `Turn on` action; no PIN/session state is created
117. No new runtime step for `30.2`: this task is the documented decision to stop the turn-on-authentication lane after the local two-step verification review route because PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence need backend/provider contracts (`DECISIONS.md` D027)
118. `flutter run` -> dashboard -> drawer `Profile` -> tap `Authentication` -> `Review turn-on setup` -> `Review PIN setup` -> `createPin` opens; empty/short PIN values show inline errors; a valid 6-digit PIN shows a ready-for-secure-backend-storage summary without saving the PIN or enabling 2FA
119. No new runtime step for `31.2`: this task is the documented decision to stop the create-pin lane after local PIN format validation because PIN confirmation, secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules need backend/provider contracts (`DECISIONS.md` D028)
120. `flutter run` -> dashboard -> drawer `Profile` -> tap `Authentication` -> `Review turn-on setup` -> `Review PIN setup` -> enter valid PIN -> `Review confirmation step` -> `confirmPinSave` opens; empty/short/mismatched values show inline errors; matching the route-local draft shows a ready-for-secure-backend-storage summary without saving the PIN or enabling 2FA
121. No new runtime step for `32.2`: this task is the documented decision to stop the confirm-pin-save lane after route-local confirmation because secure PIN storage, session/device checks, audit/security notifications, recovery rules, account persistence, and enabling 2FA need backend/provider contracts (`DECISIONS.md` D029)
122. `flutter run` -> dashboard -> Notifications -> tap the calendar icon in the app bar -> `reminder` opens; select another date -> the selected-date heading changes and the date-specific no-reminders state remains honest
123. No new runtime step for `33.2`: this task is the documented decision to stop the reminder lane before reminder records, persistence/API ownership, recurrence/timezone rules, notification delivery, permissions, edit/delete behavior, and failure states (`DECISIONS.md` D030)
124. `flutter run` -> dashboard -> open drawer -> tap `Schedule` -> `schedules` opens with calendar and Doctors Without Border Event for the current date; tap the event heading to collapse/expand its Frequency, Starts, and Ends details; select another date to see the honest no-local-schedule state; Add reminder and mutation actions remain disabled
125. No new runtime step for `34.2`: this task is the documented decision to stop schedules before schedule CRUD, recurrence/timezone calculations, live countdowns, persistence/API ownership, sharing/deep links, reminder delivery, permissions, and failure states (`DECISIONS.md` D031)
126. `flutter run` -> open Manage Profile -> scroll to Business -> tap `Edit hours` -> `selectedDates` opens; select a date, keep All day or choose a valid time range, tap `Prepare hours` -> a local draft-ready summary appears and explicitly says no profile schedule was saved
127. No new runtime step for `35.2`: this task is the documented decision to stop selected dates before profile/business-hours persistence, timezone/overlap rules, multiple hour sets, upgrades, server conflicts, and availability APIs (`DECISIONS.md` D032)
128. `flutter run` -> Circles -> Discover communities -> switch between `For you`, `Requests`, and `Drafts`; accept the `360 Health Club` request -> Requests becomes empty and returning to Circles shows `360 Health Club` in joined communities
129. No new runtime step for `36.2`: this task is the documented decision to stop community invitations before invitation delivery, rejection/approval workflows, draft persistence, invite permissions, moderation, and backend membership sync (`DECISIONS.md` D033)
130. `flutter run` -> dashboard drawer -> tap `Providers` -> `findMentor` opens with mentor cards and available-time chips; tap `Book Appointment` -> existing local booking form opens
131. No new runtime step for `37.2`: this task is the documented decision to stop find-mentor before live availability, mentor/profile APIs, detailed reviews, pricing/payment rules, booking confirmation, provider calendar sync, and cancellation policy (`DECISIONS.md` D034)
132. `flutter run` -> dashboard drawer -> `Providers` -> `View details` on a mentor -> `specialistDetails` opens; choose a day/time chip -> selected-slot summary updates; tap `Book appointment` -> existing local booking form opens
133. No new runtime step for `38.2`: this task is the documented decision to stop specialist-details before live availability, review details, payment/pricing enforcement, provider profile APIs, confirmed booking slots, calendar sync, and cancellation/error states (`DECISIONS.md` D035)
134. No runtime step for `39.1`: this is the documented route-triage decision after inspecting remaining blueprint routes; skip component/demo/grid/marketing routes after `/specialist-details` and resume product work at `/published-articles` (`DECISIONS.md` D036)
135. `flutter run` -> navigate to `managePortfolio` -> tap `Articles` -> `publishedArticles` opens with `Published Articles`, `For you` / `Request` / `Drafts`, local article cards, and `Open`; open an article -> detail view appears with locked Edit/Analytics/Comments/Delete controls; Request and Drafts tabs show honest deferred states
136. No new runtime step for `40.2`: this is the documented decision to stop the published-articles lane before subscribers, article-story, add-new-article, drafts, edit/publish/delete, comments, analytics, moderation, and content APIs (`DECISIONS.md` D038)
137. No runtime step for `41.1`: this is the documented route-triage decision after inspecting remaining blueprint routes; skip creator publishing, subscribers, article-story, subscription, ad, payment, media upload, and component/marketing routes, then resume product work at `/edit-your-name` (`DECISIONS.md` D039)
138. `flutter run` -> navigate to `manageProfile` -> tap `Edit` -> `editYourName` opens with `Edit your name`, `Enter a new name to continue`, and `Your name`; empty save shows `Name is required`; a valid value shows `Name draft prepared` and explicitly says no profile name was saved
139. No new runtime step for `42.2`: this is the documented decision to stop the edit-your-name lane before profile name persistence, account identity sync, verification, audit, conflict handling, and backend profile APIs (`DECISIONS.md` D041)
140. `flutter run` -> navigate to `manageProfile` -> tap `Edit website` in Basic -> `editYourWebsite` opens with `Edit your website`, `Add a website`, and `Your website`; invalid text shows `Enter a valid website`; a valid domain shows `Website draft prepared` and explicitly says no profile website was saved
141. No new runtime step for `43.2`: this is the documented decision to stop the edit-your-website lane before profile website persistence, verification, account sync, audit/security records, conflict handling, and backend profile APIs (`DECISIONS.md` D043)
142. `flutter run` -> navigate to `manageProfile` -> tap `Edit description` in About -> `addDescription` opens with `Add description`, a multiline `Description` field, and `Save`; empty/short copy shows inline errors; valid copy shows `Description draft prepared` and explicitly says no profile description was saved
143. No new runtime step for `44.2`: this is the documented decision to stop the add-description lane before profile-copy persistence, moderation/compliance review, public profile publishing, account sync, audit/security records, conflict handling, and backend profile APIs (`DECISIONS.md` D045)
144. No runtime step for `45.1`: this is the documented route-triage decision after inspecting the remaining Manage Profile blueprint routes; skip `/edit-your-email` because account/security email routes already own email verification/change behavior, skip `/add-time-and-day` because business-hours drafting is already covered by `selectedDates`, and resume product work at `/set-address` (`DECISIONS.md` D046)
145. `flutter run` -> navigate to `manageProfile` -> tap `Edit address` in Basic -> `setAddress` opens with `Set address`, `Your location`, and `Save`; empty/short address values show inline errors; valid address text shows `Address draft prepared` and explicitly says no profile address was saved
146. No new runtime step for `46.2`: this is the documented decision to stop the set-address lane before profile-address persistence, location/geocoding/map services, device-location permissions, verification, account sync, audit/security records, conflict handling, and backend profile APIs (`DECISIONS.md` D048)
147. No runtime step for `47.1`: this is the documented route-triage decision after inspecting the remaining blueprint tail; ads/payments/audience, podcast upload/recording, account verification/password/phone/email duplicates, feed/Q&A duplicates, schedule/reminder duplicates, and component/demo frames are skipped until backend/product contracts exist or are already covered (`DECISIONS.md` D049)
148. No runtime step for `48.1`: this is the documented frontend coverage audit; all non-`login` route constants have router cases, `ROUTES.md` records 68 wired routes, and remaining gaps are documented backend/product seams rather than honest frontend-only screens (`DECISIONS.md` D050)
149. No runtime step for `49.1`: this is the documented backend/product readiness handoff; deferred seams are grouped by contract in `DEFERRED_WORK.md` so backend work can replace local stores/repositories without rewriting completed frontend routes (`DECISIONS.md` D051)
150. No runtime step for `50.1`: this is the final frontend handoff review; docs/router status still show 68 wired routes, `login` remains the only reserved unwired route constant, and frontend route coverage is ready for backend/product contract selection (`DECISIONS.md` D052)

## Manual test (Phase 0 reference)

1. `flutter run`
2. Splash -> onboarding (~0.8s)

---

## Questions for product owner (BLOCKED tasks go here)

| ID | Question | Blocks |
|----|----------|--------|
| - | None open | - |

*(Auth backend, API URL, etc. go here when a task needs them - then `DECISIONS.md`.)*

---

## Session log (optional)

| Date | Task | Result |
|------|------|--------|
| 2026-05-15 | 0.5 | DONE - reliability hardening docs added: `ARCHITECTURE_RULES.md`, `TASK_TEMPLATE.md`; `flutter test` timed out after 5 minutes during docs-only baseline check |
| - | Phase 0 | DONE |
| 2026-05-15 | 1.1 | DONE - `CarenetColors` in `lib/core/tokens/` |
| 2026-05-15 | 1.2 | DONE - `CarenetButton` + legacy wrappers delegate |
| 2026-05-15 | 1.3 | DONE - `CarenetTextField`, semantic field colors, widget tests, focused analyze clean |
| 2026-05-15 | 1.4 | DONE - onboarding + sign-up phone/email refactored to shared button/text field components |
| 2026-05-15 | 2.1 | DONE - sign-up phone/email client-side validation + route to `finishSignUp` |
| 2026-05-15 | 2.2 | DONE - `finishSignUp` now validates required fields before routing; confirm password match enforced |
| 2026-05-15 | 2.3 | DONE - sign-up social auth rows now render explicit disabled state until backend/auth integration exists |
| 2026-05-15 | 2.4 | DONE - sign-up "Already have an account? Sign in" routes to sign-in phone/email entry screens |
| 2026-05-16 | 3.1 | DONE - sign-in phone/email validate locally and route to `dashboard` without backend auth |
| 2026-05-19 | 3.2 | DONE - password recovery flow wired: sign-in -> `enterEmail` -> `enterPassword` -> `signInEmail` |
| 2026-05-19 | 4.1 | DONE - dashboard bottom-nav placeholders replaced with named shell screens |
| 2026-05-19 | 4.2 | DONE - Home tab `Messages` and `Articles` placeholders replaced with real tab content |
| 2026-05-19 | 4.3 | DONE - dashboard Notifications icon fixed; Home Messages preview now hands off to `messages` route |
| 2026-05-19 | 5.1 | DONE - dashboard Notifications tab now uses the dedicated notifications feature screen directly |
| 2026-05-19 | 5.2 | DONE - messages list routes into chat; fake notifications bottom nav removed |
| 2026-05-19 | 5.3 | DONE - actionable notification cards now route only to real existing destinations; other cards stay read-only |
| 2026-05-19 | 5.4 | DONE - notification category tabs now use real filtering; Payment tab is explicitly disabled |
| 2026-05-19 | 5.5 | DONE - duplicate chat/message screen files consolidated into one canonical chat page; `message` route kept only as a compatibility alias |
| 2026-05-19 | 5.6 | DONE - appointments and readings notification cards now route to honest destination screens; remaining cards stay read-only |
| 2026-05-19 | 5.7 | DONE - article notifications now route to an articles destination shell; emergency and podcast remain read-only |
| 2026-05-19 | 5.8 | DONE - emergency notifications now route to an emergency destination shell; podcast remains read-only |
| 2026-05-19 | 5.9 | DONE - podcast notifications intentionally deferred to the later content phase; no shallow shell added in Phase 5 |
| 2026-05-19 | 6.1 | DONE - `readings` now routes to `manageReadings`; no-op actions in that slice were cleaned up or disabled honestly |
| 2026-05-19 | 6.2 | DONE - `Download Readings` now has an explicit deferred state; Phase 6 stays focused on add-reading/device onboarding before export |
| 2026-05-19 | 6.3 | DONE - the first guided readings lane is now wired: `manageReadings` -> `addDevice` -> `bloodSug` for Blood Sugar only |
| 2026-05-19 | 6.4 | DONE - `bloodSug` now has a real local entry form with validation, context selection, optional note, and saved-state summary |
| 2026-05-23 | 6.5 | DONE - saved `bloodSug` entries now flow back into the `readings` dashboard card and latest-entry summary |
| 2026-05-23 | 6.6 | DONE - `bloodSug` now keeps short local history and a simple trend summary based on saved readings |
| 2026-05-23 | 6.7 | DONE - blood sugar history rows can now be deleted and the local latest-entry/trend state stays consistent |
| 2026-05-23 | 7.1 | DONE - appointments now has a real frontend-ready slice with local upcoming/recent sections and a working `bookAppointment` handoff |
| 2026-05-23 | 7.2 | DONE - `bookAppointment` now has a real local form with validation and a saved booking draft summary |
| 2026-05-23 | 7.3 | DONE - appointment booking drafts now support local confirm/cancel behavior |
| 2026-05-23 | 8.1 | DONE - emergency now has a real frontend-ready slice with status/update content and a working `distressCall` form |
| 2026-05-23 | 8.2 | DONE - distress updates now support local dispatch/clear behavior as the explicit backend escalation seam |
| 2026-05-23 | 9.1 | DONE - articles now has a real local list/detail reader flow instead of a static shell |
| 2026-05-23 | 9.2 | DONE - articles now support local read/saved state on top of the reader flow |
| 2026-05-23 | 9.3 | DONE - article scope intentionally stops after local list/detail + saved/read state; next work moves to the next blueprint-backed route |
| 2026-05-23 | 10.1 | DONE - communities now has a real local circles/discover/join slice instead of a shell |
| 2026-05-27 | 10.2 | DONE - joined discovered communities now sync back into the main Circles view |
| 2026-05-27 | 10.3 | DONE - blueprint-backed local community profile route added from Circles |
| 2026-05-27 | 10.4 | DONE - blueprint-backed local create-community flow now creates owned communities and opens an owner profile handoff |
| 2026-05-27 | 10.5 | DONE - communities scope intentionally stops here before invitation acceptance and moderation workflows |
| 2026-05-27 | 11.1 | DONE - Post tab now hosts the first real local Q&A feed and ask flow |
| 2026-05-27 | 11.2 | DONE - Q&A now has a blueprint-backed local answer lane: requests -> tagged questions -> comment/answer |
| 2026-05-27 | 11.3 | DONE - Q&A scope intentionally stops before the mixed `q-a-post` composer/distribution lane |
| 2026-05-27 | 12.1 | DONE - drawer Profile now routes into a real local Account slice with delete/deactivate flow |
| 2026-05-27 | 12.2 | DONE - account now deepens into a real local Settings & Profile edit form with validation and local save |
| 2026-05-27 | 12.3 | DONE - account scope intentionally stops before public profile, scheduling, and auth-security lanes |
| 2026-05-27 | 13.1 | DONE - podcast notifications now route into a real local podcast list with watch state |
| 2026-05-27 | 13.2 | DONE - podcast scope intentionally stops before media playback/upload/comment/backend content workflows |
| 2026-05-27 | 14.1 | DONE - Search tab now has a real local consultant discovery slice with filters, profile sheet, and local request state |
| 2026-05-27 | 14.2 | DONE - search scope intentionally stops before live availability, payment, booking, and provider-profile workflows |
| 2026-05-27 | 15.1 | DONE - Health Record now has a real local readings summary route backed by the readings store |
| 2026-05-27 | 15.2 | DONE - health record scope intentionally stops before backend history/export/synced-vitals workflows |
| 2026-05-27 | 16.1 | DONE - Saved Articles now has a registered local route with empty/list/detail/remove behavior backed by the shared article store |
| 2026-05-30 | 16.2 | DONE - saved/content-library scope intentionally stops before creator publishing, subscribers, article-story, account sync, analytics, comments, and content APIs |
| 2026-05-30 | 17.1 | DONE - Case Studies now has a registered local route with list/filter/detail/read-state behavior backed by a local content store |
| 2026-05-30 | 17.2 | DONE - case studies scope intentionally stops before content APIs, verified review, author/publication records, comments, sharing, account sync, and moderation |
| 2026-05-30 | 18.1 | DONE - Public Profile now has a registered local route with read-only profile content, real message/schedule handoffs, and disabled deferred creator/media/share actions |
| 2026-05-30 | 18.2 | DONE - public profile scope intentionally stops before profile APIs, creator portfolio, media, sharing, provider scheduling, reviews, verified identity, and subscription/upgrade dependencies |
| 2026-05-30 | 19.1 | DONE - Owner Circle Profile now has a registered local route with owner content and locked/deferred owner settings actions |
| 2026-05-30 | 19.2 | DONE - owner-circle scope intentionally stops before permissions, invites, moderation, editing, sharing, reporting, exiting, and destructive community APIs |
| 2026-05-30 | 20.1 | DONE - Manage Profile now has a registered local route with profile-management sections, real settings/messages handoffs, and deferred backend-dependent controls |
| 2026-05-30 | 20.2 | DONE - manage-profile scope intentionally stops before profile update APIs, schedule persistence, events, ads/payment review, media, sharing, member management, group persistence, and creator verification |
| 2026-06-03 | 21.1 | DONE - Manage Portfolio now has a registered local route with Page/Circles tabs, local portfolio content behind a local store, real settings/messages handoffs, and deferred creator/media/payment controls |
| 2026-06-03 | 21.2 | DONE - manage-portfolio scope intentionally stops before article publishing, podcast upload/recording, media processing, creator portfolio APIs, ads/payment/subscription flows, moderation, analytics, and sharing |
| 2026-06-03 | 22.1 | DONE - Change Authentication now has a registered local two-step verification route from Account with locked/deferred PIN, disable, and help actions |
| 2026-06-03 | 22.2 | DONE - change-authentication scope intentionally stops before PIN creation, disable-2FA, password re-auth, secure storage, device/session checks, audit logs, phone/email verification, and security help copy |
| 2026-06-03 | 23.1 | DONE - Add Phone Number now has a registered local phone-entry draft route from Account with validation and a ready-for-SMS-verification summary that does not fake OTP delivery or account save |
| 2026-06-03 | 23.2 | DONE - add-phone-number scope intentionally stops before OTP/SMS delivery, code verification, phone uniqueness, password re-auth, rate limiting, auth-session updates, recovery rules, and account persistence |
| 2026-06-03 | 24.1 | DONE - Password now has a registered local security information route from Account with locked/deferred Edit password action |
| 2026-06-03 | 24.2 | DONE - password scope intentionally stops before password editing, current-password verification, password policy, code confirmation, session invalidation, recovery/security notifications, and account persistence |
| 2026-06-03 | 25.1 | DONE - Add Email now has a registered local email-entry draft route from Account with validation and a ready-for-email-verification summary that does not fake verification or account save |
| 2026-06-03 | 25.2 | DONE - add-email scope intentionally stops before verification email delivery, code confirmation, email uniqueness, password re-auth, rate limiting, auth-session updates, recovery/security notifications, and account persistence |
| 2026-06-03 | 26.1 | DONE - Change Email now has a registered local change-email draft route from Add Email with validation and a ready-for-code-verification summary that does not fake code delivery or account save |
| 2026-06-03 | 26.2 | DONE - change-email scope intentionally stops before verification-code delivery, code confirmation, email uniqueness, password re-auth, rate limiting, auth-session updates, recovery/security notifications, and account persistence |
| 2026-06-03 | 27.1 | DONE - Edit Email now has a registered local current-email management route from Add Email with verified status, change-email handoff, and locked remove-email action |
| 2026-06-03 | 27.2 | DONE - edit-email scope intentionally stops before email removal, password re-auth, recovery rules, auth-session updates, audit/security notifications, and account persistence |
| 2026-06-03 | 28.1 | DONE - Enter Password To Save now has a registered local password-entry route from Edit Email with validation and a ready-for-backend-reauthentication summary that does not fake verification or account save |
| 2026-06-03 | 28.2 | DONE - enter-password-to-save scope intentionally stops before real password verification, session/device checks, rate limiting, audit/security notifications, account mutation unlocks, and account persistence |
| 2026-06-03 | 29.1 | DONE - Confirm Phone Number now has a registered local phone confirmation route from Add Phone Number with validation and a ready-for-backend-OTP-verification summary that does not fake OTP delivery or account save |
| 2026-06-03 | 29.2 | DONE - confirm-phone-number scope intentionally stops before OTP/SMS delivery, code confirmation, phone uniqueness, session updates, rate limiting, audit/security notifications, and account persistence |
| 2026-06-03 | 30.1 | DONE - Turn On Authentication now has a registered local review route from Change Authentication with two-step verification copy and disabled backend-gated Turn on action |
| 2026-06-03 | 30.2 | DONE - turn-on-authentication scope intentionally stops before PIN creation, secure PIN storage, session/device checks, audit/security notifications, recovery rules, and account persistence |
| 2026-06-03 | 31.1 | DONE - Create PIN now has a registered local PIN-format route from Turn On Authentication with validation and a ready-for-secure-backend-storage summary that does not save PIN or enable 2FA |
| 2026-06-03 | 31.2 | DONE - create-pin scope intentionally stops before PIN confirmation, secure PIN storage, session/device checks, audit/security notifications, account persistence, and recovery rules |
| 2026-06-08 | 32.1 | DONE - Confirm PIN Save now has a registered local confirmation route from Create PIN with validation, route-local match checking, and no secure-storage/session mutation |
| 2026-06-08 | 32.2 | DONE - confirm-pin-save scope intentionally stops before secure PIN storage, session/device checks, audit/security notifications, recovery rules, account persistence, and enabling two-step verification |
| 2026-06-08 | 33.1 | DONE - Reminder now has a registered selectable-calendar route from Notifications with a date-specific empty state and no fake reminder persistence/delivery |
| 2026-06-08 | 33.2 | DONE - reminder scope intentionally stops before reminder records, persistence/API ownership, recurrence/timezone rules, notification delivery, permissions, edit/delete behavior, and failure states |
| 2026-06-08 | 34.1 | DONE - Schedules now has a registered drawer route with selectable calendar and expandable blueprint-backed read-only task-reminder details |
| 2026-06-08 | 34.2 | DONE - schedules scope intentionally stops before schedule CRUD, recurrence/timezone calculations, countdowns, persistence, sharing, reminder delivery, permissions, and failure states |
| 2026-06-08 | 35.1 | DONE - Selected Dates now has a registered Manage Profile business-hours route with date/all-day/time-range draft validation and no fake persistence |
| 2026-06-08 | 35.2 | DONE - selected-dates scope intentionally stops before profile-hours persistence, timezone/overlap rules, multiple hour sets, upgrades, server conflicts, and availability APIs |
| 2026-06-08 | 36.1 | DONE - community-invitations-discover tabs added to the existing Discover route with request acceptance feeding joined-community state |
| 2026-06-08 | 36.2 | DONE - community invitations scope intentionally stops before invitation delivery, approval/rejection, drafts persistence, permissions, moderation, and backend membership sync |
| 2026-06-08 | 37.1 | DONE - Find Mentor now has a registered drawer Providers route with local mentor cards and a real handoff to the booking form |
| 2026-06-08 | 37.2 | DONE - find-mentor scope intentionally stops before live availability, provider/profile APIs, reviews, pricing/payment, booking confirmation, calendar sync, and cancellation policy |
| 2026-06-08 | 38.1 | DONE - Specialist Details now has a registered route from Find Mentor with local provider info, day/time selection, and booking-form handoff |
| 2026-06-08 | 38.2 | DONE - specialist-details scope intentionally stops before live availability, reviews, pricing/payment enforcement, provider APIs, confirmed booking slots, calendar sync, and cancellation/error states |
| 2026-06-08 | 39.1 | DONE - remaining routes after specialist-details triaged; component/demo/grid/marketing routes skipped and `/published-articles` selected as the next product feature |
| 2026-06-08 | 40.1 | DONE - Published Articles route added from Manage Portfolio with local article list/detail review and locked creator controls |
| 2026-06-08 | 40.2 | DONE - published-articles scope intentionally stops before subscribers, article-story, add-new-article, drafts, analytics, comments, moderation, and creator content APIs |
| 2026-06-08 | 41.1 | DONE - remaining routes after the creator/content cluster triaged; backend-heavy creator/payment/media routes skipped and `/edit-your-name` selected next |
| 2026-06-08 | 42.1 | DONE - Edit Your Name route added from Manage Profile with local validation and draft-only no-persistence summary |
| 2026-06-08 | 42.2 | DONE - edit-your-name scope intentionally stops before profile persistence, account sync, verification, audit, conflict handling, and backend profile APIs |
| 2026-06-08 | 43.1 | DONE - Edit Your Website route added from Manage Profile Basic with local URL validation and draft-only no-persistence summary |
| 2026-06-08 | 43.2 | DONE - edit-your-website scope intentionally stops before profile persistence, verification, account sync, audit, conflict handling, and backend profile APIs |
| 2026-06-08 | 44.1 | DONE - Add Description route added from Manage Profile About with reusable multiline input, local validation, and draft-only no-persistence summary |
| 2026-06-09 | 44.2 | DONE - add-description scope intentionally stops before profile-copy persistence, moderation/compliance review, public profile publishing, account sync, audit, conflict handling, and backend profile APIs |
| 2026-06-09 | 45.1 | DONE - remaining Manage Profile routes triaged; account/email and scheduling duplicates skipped, `/set-address` selected as the next honest local profile-address draft |
| 2026-06-09 | 46.1 | DONE - Set Address route added from Manage Profile Basic with local address validation and draft-only no-persistence summary |
| 2026-06-09 | 46.2 | DONE - set-address scope intentionally stops before profile-address persistence, location/geocoding/maps, device-location permissions, verification, account sync, audit, conflict handling, and backend profile APIs |
| 2026-06-09 | 47.1 | DONE - remaining blueprint tail triaged; no new honest route implementation selected, frontend coverage audit queued next |
| 2026-06-09 | 48.1 | DONE - frontend coverage audit found no remaining honest frontend-only route gaps; backend/product readiness handoff queued next |
| 2026-06-09 | 49.1 | DONE - backend/product readiness handoff grouped deferred seams by contract and replacement path |
| 2026-06-09 | 50.1 | DONE - final frontend handoff review completed; route coverage is ready for backend/product contract selection |
| 2026-06-09 | 51.1 | DONE - first backend/product contract group selected: auth/session/account persistence |
| 2026-07-13 | 51.2 | DONE - auth/session/account backend contract defined before implementation; next work is infrastructure boundary only |
| 2026-07-13 | 52.1 | DONE - auth/session/account infrastructure boundary added with config, safe API client, session store, models, repositories, and focused tests; screens are not wired yet |
| 2026-07-13 | 52.2 | DONE - email sign-in now uses the auth repository boundary after local validation, with safe loading/error states and no broad auth wiring |
| 2026-07-13 | 52.3 | DONE - email sign-up completion now uses the auth repository boundary after local validation, with safe loading/error states and no broad auth wiring |
| 2026-07-13 | 52.4 | DONE - splash now restores stored sessions through the auth repository and routes usable sessions to dashboard, otherwise onboarding |
| 2026-07-13 | 52.5 | DONE - Account logout now clears the repository session and returns to onboarding while destructive account actions remain deferred |
| 2026-07-13 | 52.6 | DONE - password reset request now uses the auth repository, while final reset confirmation remains blocked until secure token/deep-link handling exists |
| 2026-07-13 | 52.7 | DONE - Account can read backend current-account display fields while local profile/security mutations remain deferred |
| 2026-07-13 | 52.8 | DONE - current-email verification request now uses the account repository, while final verification confirmation remains blocked until secure token/deep-link/code handling exists |
| 2026-07-13 | 52.9 | DONE - auth/session/account regression pass proved the integrated frontend boundary across sign-in, sign-up, restore, logout, password reset request, current account read, and email verification request |
| 2026-07-13 | 52.10 | DONE - next backend-integration lane selected: restore missing workflow guardrail docs before more runtime wiring |
| 2026-07-14 | 52.11 | DONE - missing workflow guardrail docs restored: `WORKING_AGREEMENT.md`, `TASK_TEMPLATE.md`, and `DEFINITION_OF_DONE.md` |
| 2026-07-14 | 52.12 | DONE - next integration lane selected: create a frontend/backend checkpoint before more runtime wiring |
| 2026-07-14 | 52.13 | DONE - frontend/backend integration checkpoint created with completed auth wiring, blocked items, and contract questions |
| 2026-07-14 | 52.14 | DONE - next runtime target selected: define password reset and email verification deep-link/code contract |
| 2026-07-14 | 52.15 | DONE - password reset and email verification token-confirm contract defined from backend bridge docs before runtime wiring |
| 2026-07-14 | 52.16 | DONE - reset and email verification token-confirm routes wired from the confirmed backend contract; production app-link setup remains deferred |
| 2026-07-14 | 52.17 | DONE - completed backend surface wiring map added; next lane selected as auth/account staging smoke and remaining-backend checkpoint before broader profile/verification/availability/appointment wiring |
| 2026-07-14 | 52.18 | DONE - auth/account staging checkpoint recorded developer-private proxy health/readiness evidence; Google and verification upload stay deferred; next lane is profile/public professional contract |
| 2026-07-14 | 52.19 | DONE - placeholder Android/iOS app identifiers replaced with `com.carenet.app` as the Google OAuth foundation; next lane is Google setup prerequisites |
| 2026-07-14 | 52.20 | DONE - Google OAuth prerequisites collected for `com.carenet.app`; debug SHA fingerprints recorded; next lane is staging OAuth client/config setup |
| 2026-07-14 | 52.21 | DONE - backend staging Google readiness enabled through Secret Manager/Cloud Run; `/health/ready` now reports `googleAuth: ok`; next lane is Flutter Google provider wiring |
| 2026-07-14 | 52.22 | DONE - Flutter Google provider wiring added for configured sign-in phone/email rows; backend staging now trusts the Web OAuth client ID; next lane is profile/public professional contract definition |
| 2026-07-14 | 52.23 | DONE - profile/public professional contract defined; next lane is a repository boundary without screen wiring |
| 2026-07-14 | 52.24 | DONE - profile repository/API boundary added with focused tests; next lane is professional self profile read wiring to Manage Profile |
| 2026-07-14 | 52.25 | DONE - Manage Profile now reads professional self profile through `ProfileRepository.professionalMe`, with safe loading/error/empty states and only allowed field replacement |

---

## Rules (short)

1. One task per session.
2. Functionality + interactions before pixel-perfect UI.
3. Ask user if not in `DECISIONS.md` - do not guess.
4. See `DEFINITION_OF_DONE.md` before marking DONE.
5. Use `TASK_TEMPLATE.md` for task scope before coding.
6. Update `DOC_SYNC.md` (NEXT task + last completed).
