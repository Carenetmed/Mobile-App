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

**APP-P1 - Phase 1 consultation marketplace narrowing**

## Current production-readiness continuation

The user approved the multi-slice Production-Readiness Completion Program.
Current work is `APP-P1-021` (active-route UX/accessibility closure). Payments
remain the final gated activity and require one explicit user confirmation
before any Paystack-side or payment deployment mutation. Physical-device
acceptance remains after the automated and cloud gates.

Current slice: `APP-P1-021D`, add accessible Back semantics to the active
professional profile editors without changing profile behavior. The focused
profile-flow tests, 621-test suite, and analyzer pass locally. The local Windows
APK build is blocked by a Kotlin/Gradle cross-drive cache issue; hosted CI must
prove the Android build before merge. `APP-P1-021A` merged in PR #172,
`APP-P1-021B` in PR #201, and `APP-P1-021C` in PR #202. Scope and limitations:
`PHASE_1_UX_ACCESSIBILITY.md`.

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
| 52.26 | Decide the first safe profile mutation UI slice after Manage Profile read wiring: choose a constrained professional self update path for only backend-allowed fields, or defer mutations until the edit screens are redesigned around the contract; do not implement runtime mutations in this decision slice | S | **DONE** |
| 52.27 | Wire professional bio update from `addDescription` for existing professional profiles only: read `professionalMe`, preserve existing `displayName`, `category`, and `specialty`, call `updateProfessionalMe` with the new `bio`, show safe loading/error/empty-profile states, and keep profile creation, name/category/specialty editing, website, address, patient profile, public listing, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, and prescriptions out of scope | M | **DONE** |
| 52.28 | Decide the next profile/public-professional runtime lane after professional bio update: choose public verified professional listing replacement, a constrained name/category/specialty profile-edit UI, or pause profile wiring; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.29 | Wire public verified professional listing to Search specialists using `ProfileRepository.publicProfessionals`: replace list-card name/category/specialty/bio data only, keep safe loading/error/empty states, do not send auth headers, and keep public detail, Find Mentor, Specialist Details, availability, appointments, booking, reviews, ratings, prices, payments, calls, calendar sync, verification upload/admin, patient profile, profile creation, name/category/specialty editing, website, address, notifications, notes, and prescriptions out of scope | M | **DONE** |
| 52.30 | Decide the next backend-integration lane after Search public listing: either continue profile/public-professional work only if a real backend contract exists, select another completed backend surface, or pause for regression; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.31 | Define the scheduling/availability/appointment frontend contract before runtime wiring: map completed backend availability and appointment routes into Flutter repository/entities/screen boundaries, preserve no-local-fallback behavior, and queue the first repository/runtime slice only after the contract is clear | M | **DONE** |
| 52.32 | Add the scheduling repository boundary for availability and appointment routes: entities, models, API client, repository, DI registration, and focused tests only; do not wire UI screens, booking success, public detail, payments, notifications, reviews, calls, calendar sync, notes, or prescriptions | M | **DONE** |
| 52.33 | Wire public availability read as the first scheduling UI surface: use `SchedulingRepository.publicAvailability` only for a selected public professional, show real loading/error/empty availability states, keep appointment request disabled/deferred, and do not reintroduce local specialist/slot fallback, public detail invention, payments, reviews, calls, calendar sync, notes, or prescriptions | M | **DONE** |
| 52.34 | Decide the first appointment request UI path after public availability read: choose whether to adapt the existing `bookAppointment` form, add a constrained request action from the Search availability sheet, or pause for professional availability management first; do not implement runtime booking in this decision slice | S | **DONE** |
| 52.35 | Remove local booking success from `bookAppointment`: keep the route available, remove `Confirmed locally` and fake booking completion behavior, show an honest deferred/backend-required state, update tests/docs, and do not call appointment request API yet | M | **DONE** |
| 52.36 | Define the concrete appointment request UX after local booking success removal: choose date/time selection from backend public availability, duration options, Search sheet vs rewritten `bookAppointment` route arguments, and backend `REQUESTED` success handling; do not implement runtime booking in this decision slice | S | **DONE** |
| 52.37 | Add appointment request time-option helper: convert returned `AvailabilityWindow` values into near-term concrete request options for the next seven days with focused tests; do not call `requestAppointment`, do not wire runtime booking UI, and keep payments/notifications/reviews/calls/calendar/notes/prescriptions out of scope | M | **DONE** |
| 52.38 | Wire appointment request from Search availability: add selectable generated time/duration options in the Search profile sheet, call `SchedulingRepository.requestAppointment` only after user selection, show backend `REQUESTED` success and safe errors, and keep own list/lifecycle/payments/notifications/reviews/calls/calendar/notes/prescriptions deferred | M | **DONE** |
| 52.39 | Wire own appointment list read: replace the local upcoming/recent appointment display where safe with `SchedulingRepository.ownAppointments`, show backend statuses and safe loading/error/empty states, and keep accept/decline/cancel/reschedule/complete UI, payments, notifications, reviews, calls, calendar sync, notes, and prescriptions deferred | M | **DONE** |
| 52.40 | Decide the next scheduling UI lane after request/list visibility: choose patient cancellation, professional availability management, professional appointment lifecycle, or regression checkpoint; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.41 | Wire patient appointment cancellation: add a cancel action only for eligible own appointment cards, call `SchedulingRepository.cancelAppointment`, show safe loading/success/error states, update visible status from backend response, and keep professional lifecycle/reschedule/complete/payments/notifications/calendar/notes deferred | M | **DONE** |
| 52.42 | Decide whether to pause scheduling for regression or continue to professional availability management: review request/list/cancel coverage, known gaps, and UI readiness before adding professional availability or lifecycle controls; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.43 | Run scheduling patient-path regression: strengthen focused tests and docs for Search listing/availability/request plus Appointments own-list/cancel behavior, prove no local fallback/fake success returned, and do not add professional availability/lifecycle runtime behavior | M | **DONE** |
| 52.44 | Decide Professional Availability Management UI Boundary: inspect Manage Profile business-hour/selected-date UI, scheduling repository own-availability read/replace contract, docs, and blueprint evidence before choosing the next narrow professional availability slice; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.45 | Wire Professional Availability Management: replace the selectedDates local draft with backend own-availability read/replace using SchedulingRepository, show safe loading/empty/error/success states, preserve existing windows where safe, and do not add profile mutation, appointment lifecycle UI, payments, notifications, calls, calendar, reviews, notes, or prescriptions | L | **DONE** |
| 52.46 | Decide Professional Appointment Lifecycle UI Boundary: inspect Appointments role assumptions, scheduling repository lifecycle methods, backend contract, and current professional workspace readiness before choosing accept/decline/reschedule/complete UI scope; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.47 | Wire Professional Appointment Accept Decline: make Appointments role-aware from authenticated session state, show Accept/Decline only for professional users on eligible REQUESTED appointments, call SchedulingRepository accept/decline, update visible status from backend response, and keep reschedule/complete/payments/notifications/calendar/notes deferred | L | **DONE** |
| 52.48 | Run Professional Appointment Lifecycle Regression: verify role-aware Appointments behavior for patient cancel, professional accept/decline, safe errors, terminal states, and no reschedule/complete/payment/calendar/notes UI before deciding any broader lifecycle action | M | **DONE** |
| 52.49 | Decide Appointment Reschedule Or Completion Boundary: inspect current lifecycle proof, backend rules, Appointments UI readiness, and deferred risks before choosing reschedule, completion, or another regression/fix pass; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.50 | Wire Professional Appointment Completion: show Complete only for professional users on accepted appointments whose scheduled end time has passed, call SchedulingRepository.completeAppointment, update visible status from backend response, and keep reschedule/payments/notifications/calendar/reviews/notes/prescriptions deferred | L | **DONE** |
| 52.51 | Run Appointment Completion Regression: verify professional completion role/timing/state/failure behavior, prove no reschedule/payment/calendar/review/notes/prescription UI slipped in, and decide whether reschedule needs a separate UX decision or the scheduling lane should pause for a broader regression checkpoint | M | **DONE** |
| 52.52 | Decide Post-Completion Scheduling Lane: review appointment request/list/cancel/accept/decline/availability/completion coverage, regression evidence, and remaining risks before choosing a broader scheduling regression checkpoint or a dedicated reschedule UX decision; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.53 | Run Scheduling Core Regression Checkpoint: strengthen focused tests/docs across Search public listing/availability/request, Appointments own-list/cancel/accept/decline/complete, selectedDates availability management, safe error/no-fallback behavior, and absence of reschedule/payment/notification/calendar/review/notes/prescription/call/admin UI; do not add runtime features | L | **DONE** |
| 52.54 | Decide Post-Regression Scheduling Lane: review the scheduling core regression checkpoint and choose reschedule UX boundary, another backend-completed surface, or real-device/staging smoke checkpoint; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.55 | Decide Appointment Reschedule UX Boundary: define whether patient/professional reschedule belongs in this milestone, actor/status/time-selection/duration/conflict rules, backend payload and safe error handling, and explicit deferrals before any runtime reschedule UI; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.56 | Wire Appointment Reschedule From Existing Scheduling Surfaces: show Reschedule only for known patient/professional sessions on upcoming REQUESTED/ACCEPTED appointments, load public availability for the appointment professional, reuse generated request options, call SchedulingRepository.rescheduleAppointment with selected time/duration, update visible status from backend response, and keep payments/notifications/calendar/reviews/calls/admin/notes/prescriptions deferred | L | **DONE** |
| 52.57 | Run Appointment Reschedule Regression: verify patient/professional reschedule role/status/time-option/failure behavior, backend REQUESTED response handling, safe no-fallback errors, terminal/recent hiding, and no payments/notifications/calendar/reviews/calls/admin/notes/prescriptions UI before deciding whether scheduling can pause for a broader checkpoint | M | **DONE** |
| 52.58 | Decide Scheduling Core Pause Or Smoke Checkpoint: review appointment request/list/cancel/accept/decline/complete/reschedule, availability management, regression evidence, and remaining backend/frontend risks before choosing pause, real-device/staging smoke, or a small QA/fix slice; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.59 | Run Scheduling Core Staging Smoke Checkpoint: use a staging-configured app/backend environment to prove the existing scheduling core where available, document exact unproven paths/blockers, and do not add runtime feature behavior or fake seed data | M | **DONE** |
| 52.60 | Decide Scheduling Smoke Data Setup Or Next Surface: review the staging smoke checkpoint blockers and choose whether to create deliberate staging scheduling test data/accounts or move to another backend-completed surface; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.61 | Decide Next Backend-Completed Flutter Surface After Scheduling Smoke Blocker: review the completed backend surface map, deferred-work register, profile/verification/auth/account status, and the scheduling staging-data blocker before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.62 | Define Patient Profile Settings Mapping: map the existing Settings/Profile UI to backend `GET/PUT /patients/me` fields before runtime wiring, separating patient profile fields from username, email, auth/security, public profile, verification, scheduling, and destructive account actions; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.63 | Wire Patient Profile Read To Settings Profile: call `ProfileRepository.patientMe` from Settings/Profile, show safe loading/error/empty-profile states, display backend patient name plus read-only age/location summary when available, keep local save for non-backend fields unchanged, and do not call `updatePatientMe` or create profile data | M | **DONE** |
| 52.64 | Run Patient Profile Read Regression Checkpoint: verify Settings/Profile patient profile read success, empty-profile, safe failure, no `updatePatientMe` call, local save preservation, docs/deferred-work accuracy, and absence of username/email/bio/security/verification/scheduling mutation before deciding any patient profile update slice | M | **DONE** |
| 52.65 | Decide Patient Profile Update Boundary Or Next Surface: review the patient profile read regression, Settings/Profile field mismatch, backend `PUT /patients/me` contract, and deferred account/security risks before choosing a constrained update UX or moving to another backend-completed surface; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.66 | Wire Patient Profile Name Update From Settings Profile: call `ProfileRepository.updatePatientMe` from Settings/Profile for combined first/last name only, show safe loading/success/error states, preserve local username/email/bio save behavior, and do not send age/location/user id/role/email/phone/password/security/verification/scheduling/public-profile data | M | **DONE** |
| 52.67 | Run Patient Profile Name Update Regression Checkpoint: verify name-only payload, safe failure/no false success, local username/email/bio preservation, docs/deferred-work accuracy, and absence of age/location/auth/security/verification/scheduling/destructive-account mutation before deciding the next backend-completed surface | M | **DONE** |
| 52.68 | Decide Next Backend-Completed Flutter Surface After Patient Profile Name Update: review the patient profile name update regression, completed backend surface map, deferred-work register, and current staging blockers before choosing one narrow next Flutter wiring lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.69 | Wire Specialist Details To Public Professional Availability: replace the local-only specialist details data path with backend public-professional/public-availability data where a backend professional id can be resolved honestly, show safe loading/error/empty states, keep the existing route, avoid local slot fallback, and do not invent a public detail endpoint, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, or staging data | M | **DONE** |
| 52.70 | Run Specialist Details Public Availability Regression Checkpoint: verify backend id resolution, safe loading/error/empty states, no local slot fallback, generated request payload, request failure behavior, Search handoff, dashboard local compatibility, docs/deferred-work accuracy, and absence of public-detail endpoint invention, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing the next surface | M | **DONE** |
| 52.71 | Decide Next Surface After Specialist Details Regression: review Specialist Details regression, Find Mentor remaining local seam, verification upload/list blockers, scheduling staging-data blocker, deferred-work map, and completed backend surfaces before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.72 | Wire Find Mentor To Public Professionals: replace the backend-capable Find Mentor path with public verified professionals from `ProfileRepository.publicProfessionals`, show safe loading/error/empty states, pass backend public professional ids into `specialistDetails`, keep local mentor behavior only for local-only test/dev navigation without a repository, and do not add public detail endpoint invention, local slot fallback, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims | M | **DONE** |
| 52.73 | Run Find Mentor Public Professionals Regression Checkpoint: verify backend public listing, safe loading/error/empty states, category filtering, no local slot fallback/direct fake booking in the backend path, backend id handoff to Specialist Details, dashboard local compatibility, docs/deferred-work accuracy, and absence of public-detail endpoint invention, verification/admin behavior, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing the next surface | M | **DONE** |
| 52.74 | Decide Next Backend-Completed Flutter Surface After Find Mentor Regression: review Find Mentor regression, completed backend surface map, deferred-work register, verification upload/list blockers, scheduling staging-data blocker, profile mutation gaps, and release/staging risks before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.75 | Define Professional Verification Upload/List UI Boundary: review backend verification upload-init, upload-complete, owner document list, storage-readiness, private-document rules, existing app entry points, and file-picker constraints before choosing the first runtime verification implementation shape; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.76 | Add Professional Verification Repository Boundary: add verification document/upload entities, API client, repository, signed upload PUT helper, and focused tests for owner document list, upload-init, upload-complete, safe errors, and no signed URL/object-key exposure in public entities; do not wire runtime screens or admin review UI | M | **DONE** |
| 52.77 | Wire Professional Verification Documents Shell: add a Manage Profile entry and professional-owned verification document screen using `VerificationRepository.documents`, show safe loading/empty/error/status states, keep upload action scoped for a follow-up if file-picker/runtime upload UX needs another slice, and do not expose signed URLs, object keys, local paths, file previews, admin review data, public document access, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims | M | **DONE** |
| 52.78 | Decide Professional Verification Upload UI And File Picker Boundary: review the existing `image_picker` dependency, PDF/JPEG/PNG requirement, upload-init/signed PUT/upload-complete repository boundary, platform implications, validation/error/progress needs, and choose the narrow next upload implementation shape; do not add runtime upload behavior or package dependencies in this decision slice | S | **DONE** |
| 52.79 | Wire Professional Verification Upload Flow: add the selected PDF-capable file picker dependency, let professionals choose `LICENSE`/`IDENTITY`/`CERTIFICATION`, select one PDF/JPEG/PNG file, enforce safe type and 10 MB size validation, call `VerificationRepository.uploadDocument`, show loading/success/safe-error states, reload owner documents after success, and do not expose signed URLs, object keys, local full paths, file previews, raw checksums, admin review data, public document access, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims | M | **DONE** |
| 52.80 | Run Professional Verification Upload Regression Checkpoint: verify document list loading/empty/error, upload success with list reload, picker cancellation, invalid type, 10 MB size guard, safe backend upload failure, no signed URL/object-key/local path/raw checksum/admin/public exposure, docs/deferred-work accuracy, and absence of previews, admin review, rejection reasons, scanning claims, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing the next surface | M | **DONE** |
| 52.81 | Decide Next Backend-Completed Flutter Surface After Verification Regression: review the verification upload regression, completed backend surface map, deferred-work register, scheduling staging-data blocker, remaining profile/account gaps, and release/staging risks before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.82 | Define Professional Basic Profile Edit Boundary: decide whether the next runtime slice should update professional `displayName` only or `displayName`/`category`/`specialty` together, how existing professional profile fields and `bio` are preserved, whether empty-profile creation is allowed, and how `editYourName`/Manage Profile should stay separate from website, address, verification, availability, appointments, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.83 | Wire Professional Display Name Update From Edit Your Name: update the existing `editYourName` route to read an existing professional self profile, prefill backend `displayName`, save only the changed `displayName` through `ProfileRepository.updateProfessionalMe` while preserving existing `category`, `specialty`, and `bio`, block empty-profile saves, keep validation/loading/safe-error states honest, and do not create a profile or send website, address, account, verification, availability, appointment, payment, review, call, calendar, note, prescription, staging, or production data | M | **DONE** |
| 52.84 | Run Professional Display Name Update Regression Checkpoint: verify backend displayName prefill, display-name-only save, preservation of category/specialty/bio, empty-profile blocking, validation failure without repository update, safe backend failure without false success, docs/deferred-work accuracy, and absence of category/specialty editing, profile creation, website/address persistence, verification, availability, appointments, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing any broader profile-editing surface | M | **DONE** |
| 52.85 | Decide Next Backend-Completed Flutter Surface After Display Name Regression: review the display-name regression, professional profile contract, remaining category/specialty/profile-creation gaps, patient/account gaps, verification/admin deferrals, scheduling staging-data blocker, and release/staging risks before choosing one narrow next lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.86 | Define Professional Category Specialty Edit Boundary: decide whether category and specialty should be edited together or separately, whether to adapt an existing route or add a constrained profile-details edit route, what validation/options apply, how existing `displayName` and `bio` are preserved, how empty professional profiles are blocked, and how this stays separate from website, address, account identity, verification, availability, appointments, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.87 | Wire Professional Category Specialty Update: add a constrained Manage Profile Basic edit entry/screen for professional `category` and optional `specialty`, read an existing professional self profile, prefill category/specialty, save new category and specialty through `ProfileRepository.updateProfessionalMe` while preserving existing `displayName` and `bio`, send cleared specialty as null, block empty-profile/profile-creation and empty category saves, keep validation/loading/safe-error states honest, and do not send website, address, account, verification, availability, appointment, payment, review, call, calendar, note, prescription, staging, or production data | M | **DONE** |
| 52.88 | Run Professional Category Specialty Update Regression Checkpoint: verify Manage Profile entry separation from display-name edit, backend category/specialty prefill, category-required validation, save preserving displayName/bio, clearing specialty as null, empty-profile blocking, safe backend failure, docs/deferred-work accuracy, and absence of profile creation, website/address, verification, availability, appointments, account identity, payments, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing any broader profile surface | M | **DONE** |
| 52.89 | Decide Next Backend-Completed Flutter Surface After Category Specialty Regression: review the category/specialty regression, completed backend surface map, deferred-work register, scheduling staging-data blocker, remaining profile/account gaps, verification/admin deferrals, and release/staging risks before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.90 | Define Google Account Linking UI Boundary: decide where protected Google account linking belongs in the app, how it uses configured Google ID-token acquisition and `AuthRepository.googleLink`, when the action is visible/disabled, what safe errors/success states are allowed, and why Google sign-up role selection, unlinking, cross-email linking, recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin verification, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, and production claims remain out of scope; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.91 | Wire Google Account Linking From Account: add a constrained Account screen Google account linking entry below Authentication, require configured `GoogleIdTokenProvider`, obtain a real Google ID token, call `AuthRepository.googleLink`, show loading/success/safe-error states, keep session/user role/status/email backend-owned, and do not add Google sign-up role selection, unlinking, cross-email linking, recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin verification, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims | M | **DONE** |
| 52.92 | Run Google Account Linking Regression Checkpoint: verify Account placement below Authentication, disabled missing-config behavior, configured provider token to `AuthRepository.googleLink`, success only after repository success, provider cancellation/unavailable safe error with no repository call, backend validation/unauthorized safe errors without raw text, no session/user role/status/email mutation, docs/deferred-work accuracy, and absence of Google sign-up role selection, unlinking, cross-email/recovery linking, recent re-auth, phone/OTP, MFA, production OAuth, release signing, iOS proof, profile creation, admin verification, payments, notifications, reviews, calls, calendar sync, notes, prescriptions, staging data, or production claims before choosing any broader account/provider surface | M | **DONE** |
| 52.93 | Decide Next Backend-Completed Flutter Surface After Google Linking Regression: review the Google linking regression, completed backend surface map, deferred-work register, auth/account gaps, verification/admin deferrals, staging-data blockers, and release risks before choosing one narrow next Flutter lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.94 | Define Admin Verification Review Surface Boundary: decide whether the backend-completed admin verification queue, private signed-read, and approve/reject routes belong in this Flutter app, a separate admin dashboard, or another frontend surface; define role/access expectations, safe document metadata, signed-read handling, approve/reject state/error boundaries, rejection-reason deferral, and evidence required before any runtime admin UI; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.95 | Run Final Backend-Completed Mobile Surface Checkpoint: review all completed backend routes already wired or intentionally excluded from this Flutter app, verify no mobile-facing backend-completed surface is being missed, update the completed-surface map if stale, and decide whether the next mobile-app lane is milestone stabilization/regression or another scoped mobile-facing backend surface; do not implement runtime behavior in this decision/checkpoint slice | S | **DONE** |
| 52.96 | Define Mobile Backend Integration Stabilization Plan: create a focused stabilization/regression plan for the already-wired backend mobile milestone, choose grouped test suites/manual smoke checks/docs consistency checks, identify release/staging blockers, and decide whether the next slice should be grouped regression execution or targeted cleanup; do not implement runtime behavior in this planning slice | S | **DONE** |
| 52.97 | Execute Mobile Backend Integration Regression Pass: run the grouped stabilization suites for auth/session/account, profile/verification, discovery/booking, and scheduling lifecycle from `MOBILE_BACKEND_INTEGRATION_STABILIZATION_PLAN.md`, run focused analyze/docs checks, record pass/fail evidence and any targeted cleanup slices, and do not add new runtime feature behavior unless fixing a verified regression within the scoped surface | M | **DONE** |
| 52.98 | Define Mobile Milestone Handoff And Staging Data Boundary: review the passed mobile backend integration regression evidence, remaining staging-data/release/admin/product blockers, and decide whether the next lane is frontend milestone handoff package, staging seed-data/smoke setup, release-signing/app-link readiness, or another explicitly deferred product lane; do not implement runtime behavior in this decision slice | S | **DONE** |
| 52.99 | Create Mobile Backend Milestone Handoff Package: summarize the backend-completed mobile surfaces wired, grouped regression evidence, manual smoke/staging-data requirements, admin/release/deferred boundaries, and exact next-lane options so the milestone can be presented without production or full-product overclaiming; do not implement runtime behavior in this documentation slice | S | **DONE** |
| 53.1 | Define Staging Seed Data And Smoke Execution Plan: define the staging accounts, seeded verified professional/profile/availability/appointment data, verification upload storage access, cleanup/reset rules, API base URL/build configuration, and manual smoke commands needed to prove the regression-passed mobile milestone against a real backend environment; do not implement runtime app behavior in this planning slice | S | **DONE** |
| 53.2 | Execute Staging Seed Data And Mobile Smoke Pass: confirm required staging inputs from `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md`, build/run the app against staging, execute the manual smoke checklist for auth/account, profile/verification, discovery/booking, and scheduling lifecycle, record pass/fail evidence without secrets, and stop for project-lead input if required staging accounts/data/config are missing | M | **PAUSED** |
| APP-ID-003 | Backend Schema/API Alignment: add backend-owned Nigeria onboarding catalogs, readiness, account application status, duplicate professional registration guards, and profile setup validation for patient/professional onboarding | L | **DONE** |
| APP-ID-004 | Flutter Catalog And Readiness Repository: add Flutter entities/models/API client/repository/DI/tests for `GET /catalogs/onboarding` and `GET /account/readiness`; do not wire runtime onboarding screens yet | M | **DONE** |
| APP-ID-005 | Wire Onboarding Setup UI To Backend Catalogs And Readiness: consume backend catalogs/readiness in patient/professional setup, replace free-text country/state/profession/document choices with controlled backend-owned options, keep Google signup role flow and verification submission honest, and do not add unsupported admin/payment/review/call/note/prescription behavior | L | **DONE** |
| APP-ID-006 | Decide Onboarding Profile Payload Code Alignment: review backend APP-ID-003 profile fields, current Flutter `ProfileRepository.updatePatientMe`/`updateProfessionalMe` payload shape, catalog codes, and readiness requirements before deciding whether the next slice should send native `countryCode`/`professionCode`/`regulatorCode` fields or keep existing label-field compatibility; do not implement runtime behavior in this decision slice | S | **DONE** |
| APP-ID-007 | Align Onboarding Setup Payload Values To Backend Catalog Contract: update patient/professional setup wiring and tests so selected backend catalog values are the only values sent through the currently accepted profile DTO fields; do not invent unsupported `countryCode`/`professionCode`/`regulatorCode` request fields unless backend DTO/docs accept them | M | **DONE** |
| APP-ID-008 | Decide Production Onboarding Domain Hardening Boundary: define patient/professional onboarding UX and backend contract gaps for Nigeria launch, including role switching/duplicate account behavior, partial applications, state/city controls, profession/regulator/license requirements, required evidence guidance, profile readiness, and abuse-resistant validation before broader runtime redesign; do not implement runtime behavior in this decision slice | M | **DONE** |
| APP-ID-009 | Onboarding Readiness Resume And UX Hardening Plan: inspect current setup screens and backend readiness data, define the exact runtime UX changes for resume/progress/error handling, map backend next actions to Flutter destinations, and queue one narrow runtime slice; do not implement runtime behavior in this planning slice | M | **DONE** |
| APP-ID-010 | Add Onboarding Readiness Route Resolver: map backend `AccountReadiness.nextAction` plus role to Flutter destinations, use it after successful email/password and Google signup before choosing setup route, test every known action and safe fallback, and do not redesign setup forms or add new product modules | M | **DONE** |
| APP-ID-011 | Add Onboarding Progress And Required Evidence Guidance Plan: decide how patient/professional setup and verification screens should display backend readiness progress, required profile fields, required evidence, pending/rejected states, and safe retry copy before runtime UI implementation; do not implement runtime behavior in this planning slice | M | **DONE** |
| APP-ID-012 | Add Onboarding Readiness Progress Panel: add backend-readiness progress/status guidance to patient setup, professional setup, and professional verification documents; show required profile fields, required/missing evidence, status/retry copy, and focused tests without inventing local readiness or changing backend contracts | M | **DONE** |
| APP-ID-013 | Onboarding Regression And Phone Smoke Plan: define and run the focused proof path for the hardened onboarding/auth setup, including email/password and Google first-time signup, patient setup, professional setup, verification guidance display, safe backend failure states, and remaining blockers; do not add new product modules | M | **DONE** |
| APP-ID-014 | Onboarding Phone Smoke Execution: run the APP-ID-013 checklist against a staging-configured Android build, record pass/fail evidence and blockers, and do not add new onboarding features | M | **DONE - CHECKPOINT** |
| APP-ID-015 | Recover Auth Onboarding UX From APP-66-73: selectively restore the gateway and role-first signup UX without rolling back APP-ID backend catalog/readiness/profile/verification wiring; add regression proof | M | **DONE** |
| APP-ID-016 | Rebuild And Phone Smoke Recovered Auth Onboarding UX: install a staging-configured Android build and verify first launch, role-first signup, Google signup, email signup, and readiness routing on device | M | **DONE** |
| APP-ID-017 | Select Next Lane After PR #147 Review: after APP-ID-016 is reviewed/merged or explicitly superseded, decide the next narrow frontend/backend integration lane from current product priorities; do not start new onboarding behavior before that review | S | **DONE - Phase 1 consultation marketplace selected** |
| APP-P1-001 | Phase 1 Marketplace Scope Decision: inspect the committed broad UI, lock patient/professional navigation and product boundaries, classify every route/screen, map dependencies and preservation, define small implementation slices, and do not change runtime code | M | **DONE** |
| APP-P1-001A | Preserve Committed Broad UI Baseline: after explicit approval, create and verify `archive/pre-phase1-broad-ui-2026-07-22` and annotated tag `pre-phase1-broad-ui-2026-07-22` at exact commit `3e04d6e`; do not touch or claim to preserve existing dirty files | S | **DONE** |
| APP-P1-002 | Role-Aware Phase 1 Navigation Shell And Active Route Pruning: implement the approved four-destination patient/professional shell, header bell/avatar, active-nav pruning, and patient onboarding exit correction without deleting deferred source files | M | **DONE** |
| APP-P1-003 | Role-aware marketplace Home | M | **DONE** |
| APP-MAINT-003 | Flutter pull-request CI | S | **DONE** |
| APP-P1-004 | Canonical Find Care discovery | M | **DONE** |
| APP-P1-005 | Canonical professional detail and real booking | L | **DONE** |
| APP-P1-006 | Appointment experience and professional Schedule | L | **DONE** |
| MSG-P1-007 | Appointment-linked messaging | L | **DONE** |
| PAY-P1-008 | Paid-consultation financial authority and Flutter experience | L | **DONE** |
| CALL-P1-009 | Appointment-linked video/audio consultation | L | **DONE** |
| NOTIF-P1-010 | Durable transactional notifications | L | **DONE** |
| APP-P1-011 | Network and session startup foundation | L | **DONE** |
| APP-P1-012 | Authentication and onboarding readiness | L | **DONE** |
| APP-P1-013 | Firebase environment separation | L | **DONE** |
| APP-P1-014 | Account and route authority | L | **DONE** |
| APP-P1-015 | Backend-owned account deletion | M | **DONE** |
| APP-P1-016 | Production auth and onboarding | L | **DONE** |
| APP-P1-017 | Legal and authentication hosting links | M | **DONE** |
| APP-P1-018 | Bounded requestable-time loading | M | **DONE** |
| APP-P1-020 | Verification upload integrity | M | **DONE** |
| APP-P1-021A | Shared marketplace theme/accessibility foundation and route inventory | S | **DONE** |
| APP-P1-021B | Bounded active-route UX/accessibility repairs, focused regression tests, and recorded remaining audit limits | M+ | **DONE** |
| APP-P1-021C | Disconnect the obsolete `medicalEdit` route from seeded `UserEdit`; preserve source and prove fail-closed route plus canonical professional onboarding | S | **DONE** |
| APP-P1-021D | Add accessible Back semantics to professional name, details, and description editors with compact enlarged-text regression coverage | S | **IN PROGRESS** |

**AI:** Work only on the **NEXT** row. When finished, mark it **DONE**, set the following row to **NEXT**, update test steps below, **stop**, ask user to continue.

---

## Phase 0 - DONE

Spine: routing, splash 800ms, docs, tests. See `CODEBASE_STATUS.md` for remaining app-wide stubs (fixed in later tasks).

## Phase 1 - DONE

Tokens, `CarenetButton`, `CarenetTextField`, and onboarding/sign-up phone/email screen refactors are complete.

---

## Manual test (current: task 53.2 partial checkpoint)

Task `53.2` is still in progress. `STAGING_MOBILE_GATEWAY_PHONE_INSTALL_CHECKPOINT.md`
records the current staging checkpoint:

Product-owner interruption: APP-55 accepted
`ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md` from the PRD. Patient and professional
sign-up must branch before Google sign-up or broader auth expansion.
Professional onboarding must include profile/credential upload and manual
verification before public listing. This does not mark `53.2` complete and does
not change runtime behavior.

Product-owner interruption: APP-56 accepted
`ROLE_REGISTRATION_BACKEND_CONTRACT.md` defines the exact role-registration
frontend/backend contract. Backend already supports role-capable
`POST /auth/register` and `POST /auth/google/sign-in`, but the Flutter app must
add explicit patient/professional role selection before account creation is
treated as complete. Existing linked Google sign-in and authenticated Google
linking remain valid. First-time Google sign-up remains disabled until it can
send a real Google `idToken` plus the selected role and route into the correct
patient or professional onboarding destination. This does not mark `53.2`
complete and does not change runtime behavior.

Product-owner interruption: APP-57 accepted
`signUpRole` is now a registered runtime route between phone/email signup and
`finishSignUp`. Patient selection submits `PATIENT` to the backend and keeps the
existing community agreement destination. Professional selection submits
`PROFESSIONAL` and routes to the existing professional onboarding surface after
registration success. Google signup remains disabled until it can use the same
role branch with a real Google `idToken` plus selected role. This does not mark
`53.2` complete.

Product-owner interruption: APP-58 accepted
`PATIENT_PROFESSIONAL_ONBOARDING_UI_REQUIREMENTS.md` defines the next serious
patient/professional onboarding flow against backend `CAR-BE-119` fields.
Patient setup should collect backend-owned profile details, while professional
setup must collect legal name, public professional name, category, license,
licensing council/body, qualifications, experience, and practice fields before
profile creation. The current Flutter profile repository is still shallow, so
the next runtime slice should expand profile entities/models/API payloads before
building the polished multi-step onboarding UI.

Product-owner interruption: APP-59 accepted
`PROFILE_NIGERIA_ONBOARDING_CONTRACT_EXPANSION.md` records that Flutter
patient/professional profile entities, JSON models, API payloads, and
repository methods now support the backend `CAR-BE-119` onboarding fields.
Public professional listing remains limited to the safe public projection, and
the client still cannot send verification/admin/public-listing state. The next
runtime slice should build the polished patient/professional onboarding setup UI
against this expanded contract.

Product-owner interruption: APP-60 accepted
`PATIENT_PROFESSIONAL_ONBOARDING_SETUP_UI.md` records the runtime onboarding
setup implementation. Patient sign-up now routes through
`patientOnboardingSetup` to save backend patient profile fields before community
agreement. Professional sign-up now routes through a real professional
credential/practice setup form on `medicalProfessional`, saves backend
professional profile fields, and then opens verification documents. Google
sign-up, admin review, regulator validation, public listing approval, payments,
reviews, calls, notes, and prescriptions remain deferred.

Product-owner interruption: APP-61 accepted
`ONBOARDING_SETUP_REGRESSION_AND_PHONE_SMOKE.md` records the follow-up
regression checkpoint for the role-based signup and patient/professional setup
work. The grouped auth/onboarding/profile/account test run passed 116 tests,
focused analyze passed, and the staging-configured debug APK built. ADB reported
no connected Android device, so phone install/manual smoke was not completed in
APP-61 and must not be treated as passed evidence.

Product-owner interruption: APP-62 accepted
`AUTH_SIGNUP_STAGING_CONTRACT_FIX.md` records the staging contract correction
after professional setup returned `Please check details and try again`.
Backend staging was deployed to the `CAR-BE-119` Nigeria onboarding profile
schema/API, including migration `20260717143000_nigeria_onboarding_profile_schema`
and Cloud Run revision `carenet-backend-staging-00016-dw4`. Flutter
email/password signup now sends only `email`, `password`, and selected role to
registration, and local password validation matches the backend 15-character
minimum. Professional setup fields are accepted through the staging gateway.
Google first-time signup remains a real next gap and must not be treated as
fixed by APP-62; it needs a dedicated role-selection + real Google `idToken`
slice before sign-up Google is enabled.

Product-owner interruption: APP-63 accepted
`GOOGLE_FIRST_TIME_SIGNUP_ROLE_SELECTION.md` records the first-time Google
signup implementation. Configured signup Google rows now route to account-type
selection, then call backend Google auth with a real provider `idToken` plus the
selected `PATIENT` or `PROFESSIONAL` role. Patient Google signup routes to
`patientOnboardingSetup`; professional Google signup routes to
`medicalProfessional`. Google display names are not trusted as profile data, and
the setup screens remain authoritative for required patient/professional fields.
Facebook/Apple signup, Google unlink, iOS/release OAuth proof, production OAuth,
phone/OTP, MFA, admin review, payments, calls, reviews, notes, and prescriptions
remain deferred. Device/staging Google signup smoke is still pending because ADB
was not listing a connected phone after APP-62.

1. `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev` - passed.
2. `adb install -r build\app\outputs\flutter-apk\app-debug.apk` - passed on connected Android device `6tkvkvindaqogurk`.
3. Native Android `MainActivity` package mismatch fixed by moving it from `com.example.app_t` to `com.carenet.app`.
4. `adb shell am start -W -n com.carenet.app/.MainActivity` - returned `Status: ok` and launched `com.carenet.app/.MainActivity`.
5. `adb shell pidof com.carenet.app` - returned a running process id.
6. `flutter analyze android/app/src/main/java/com/carenet/app/MainActivity.java` - no issues found.
7. Staging-only patient/professional accounts were created through the real staging API Gateway.
8. Professional verification was seeded to `VERIFIED` through Cloud SQL Auth Proxy because the mobile app cannot approve professionals.
9. Public professional listing, public availability, and backend appointment request/accept/reschedule/cancel/complete proof passed through staging.
10. Passwords are stored only in the local file `C:\Users\asd\Desktop\carenet-staging-smoke-credentials-20260716092933.txt`; do not commit or paste them.
11. Phone UI smoke passed for patient sign-in, Account current-account display, Settings/Profile patient profile read, Search public professional listing, public availability display, real appointment request submission, patient Notifications -> Appointments own-list rendering, professional sign-in, and professional Notifications -> Appointments lifecycle actions.
12. Three phone-smoke issues were found and fixed:
    - public availability now parses the backend `availabilityWindows` envelope and treats omitted `active` as active while preserving explicit `active: false`
    - UTC availability windows now generate UTC appointment request instants instead of local instants that shift earlier when serialized with `toUtc()`
    - Android app backup/restore is disabled so stale restored secure-storage/auth state does not survive reinstall/test cycles
13. Additional phone-smoke issues were found and fixed:
    - own appointment list now parses the backend `appointments` envelope instead of treating real staging responses as empty
    - secure session save now writes fields in order before protected routes reread the session after login
14. Fresh patient phone request proof after reinstall passed:
    - rebuilt the staging APK
    - uninstalled the old app, installed the backup-disabled APK, cleared app data, and launched `com.carenet.app`
    - signed in as `app53-2-patient-20260716092933@staging.carenet.example`
    - opened Search -> `Staging Smoke Professional` -> public availability
    - selected the first generated option for `07/18 08:30`
    - observed `Request sent. Backend status: REQUESTED`
15. Fresh patient appointment-list proof passed after rebuilding with the appointment-list/session fixes:
    - cleared app data and signed in as `app53-2-patient-20260716092933@staging.carenet.example`
    - opened Notifications -> `Your appointment is booked`
    - observed `Upcoming`, `Appointment with cmrnd9w31000701s6tse0lyf1`, `REQUESTED`, `2026-07-21 - 09:30`, `Backend appointment request`, `Cancel appointment`, and `Reschedule`
    - tapping the row did not navigate to a separate detail screen, so separate appointment-detail proof remains open
16. Focused verification after the availability, UTC, appointment-list, and session-store fixes passed:
    - `flutter test test\features\home\scheduling_repository_test.dart`
    - `flutter test test\features\home\search_flow_test.dart test\features\home\specialist_details_flow_test.dart test\features\home\appointment_request_time_options_test.dart`
    - `flutter test test\features\authentication\auth_infrastructure_test.dart test\features\authentication\session_restore_guard_test.dart test\features\home\scheduling_repository_test.dart test\features\home\appointments_flow_test.dart`
    - `flutter analyze lib\features\Home\data\models\availability_window_model.dart lib\features\Home\data\services\scheduling_api_client.dart test\features\home\scheduling_repository_test.dart`
    - `flutter analyze lib\features\Home\domain\services\appointment_request_time_options.dart test\features\home\appointment_request_time_options_test.dart`
    - `flutter analyze lib\features\Authentication\data\storage\session_store.dart lib\features\Home\data\services\scheduling_api_client.dart test\features\home\scheduling_repository_test.dart lib\features\Home\presentation\pages\appointments_shell.dart test\features\home\appointments_flow_test.dart`
    - `flutter build apk --debug --dart-define=CARENET_API_BASE_URL=https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev`
17. Professional phone smoke passed:
    - cleared app data and signed in as `app53-2-professional-20260716092933@staging.carenet.example`
    - Account showed `PROFESSIONAL account - active`
    - Notifications -> `Your appointment is booked` opened Appointments with backend rows for `cmrnd9w31000701s6tse0lyf1`
    - requested rows exposed `Accept`, `Decline`, and `Reschedule`
    - accept updated a row to `ACCEPTED` with `Appointment updated. Backend status: ACCEPTED.`
    - decline updated a separate row to `DECLINED` with `Appointment updated. Backend status: DECLINED.`
    - reschedule on the accepted row loaded generated backend availability options and returned `Appointment rescheduled. Backend status: REQUESTED.`
    - recent terminal rows rendered `CANCELLED` and `COMPLETED`; the completed row did not expose duplicate `Complete`
18. Professional Account route access was fixed and proved on phone:
    - Account now shows professional-only `Manage Profile` and `Verification documents` entries for `PROFESSIONAL` current accounts
    - patient accounts do not expose those professional-only entries
    - Account -> `Manage Profile` opened `Staging Smoke Professional`, `Mental Health`, and `Stress Support`
    - Account -> `Verification documents` opened the backend-backed document screen with `Upload document`, `Choose file to upload`, and `No verification documents are submitted yet.`
19. Verification upload phone smoke is still open because staging upload-init fails server-side:
    - phone file selection returned `Service is unavailable. Please try again.`
    - direct staging API replay with the same seeded professional login succeeded for auth but failed at `POST /verification/documents/upload-init`
    - observed replay result: `upload-init=failed status=500 body={"statusCode":500,"message":"Internal server error"}`
    - signed file PUT and upload-complete were not reached
20. Full real-device phone UI smoke is not done yet. Separate appointment-detail screen proof, a fresh professional completion action if suitable accepted-past data exists, successful verification upload after backend/storage upload-init is fixed, and cleanup/reset proof remain open under 53.2.

## Manual test (last completed: APP-P1-001)

`APP-P1-001` is a docs-only product-boundary and implementation-planning slice.

1. Confirm the original checkout and unrelated dirty worktrees remain unchanged.
2. Confirm the slice branch started clean at committed baseline `3e04d6e`.
3. Confirm the Phase 1 boundary, complete route/screen classification,
   dependency map, archive plan, A-J implementation plan, unresolved decisions,
   and exactly one next runtime recommendation are recorded.
4. Run `git diff --check` for all changed docs.
5. Confirm `git diff --name-only` contains only `docs/` paths.
6. Confirm the archive branch and annotated tag resolve to exact committed
   baseline `3e04d6e`, not the APP-P1-001 documentation commit.
7. Confirm `AI_HANDOFF.md` contains exactly one `**NEXT**` task: `APP-P1-002`.

## Previous runtime manual test (APP-ID-016)

APP-ID-016 completed the recovered auth/onboarding phone-smoke checkpoint after
APP-ID-015 restored the role-first gateway UX.

1. `dart format ...` - passes.
2. `flutter test test/features/onboarding/onboarding_gateway_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart -r expanded` - passes.
3. `flutter analyze lib/core/constants/navigators/router.dart lib/features/Onboarding/presentation/pages/onboarding.dart lib/features/Authentication/presentation/pages/sign_up_arguments.dart lib/features/Authentication/presentation/pages/sign_up_email.dart lib/features/Authentication/presentation/pages/sign_up_phone.dart lib/features/Authentication/presentation/pages/sign_up_role_selection.dart test/features/onboarding/onboarding_gateway_test.dart test/features/authentication/sign_up_flow_test.dart` - no issues.
4. `git diff --check` - no whitespace errors.
5. APP-ID-016 phone smoke: staging APK rebuild/install passed on Android device
   `6tkvkvindaqogurk`, Google login succeeded after rebuilding with the corrected
   Web OAuth client ID, and controlled onboarding selectors loaded after backend
   staging was redeployed with `GET /catalogs/onboarding`.
6. Staging readiness recovery: public gateway `GET /health/ready` initially
   returned `503` because staging had one pending committed migration. After
   applying `20260719090000_identity_catalog_alignment` with
   `prisma migrate deploy`, `npx prisma migrate status` reported the database
   schema is up to date and public gateway `/health/ready` returned `200`.
7. Next work should start only after PR #147 is reviewed/merged or explicitly
   superseded.

## Manual test (historical: task 53.1)

Task `53.1` is a docs-only staging seed-data and smoke execution plan.

1. Confirm `STAGING_SEED_DATA_SMOKE_EXECUTION_PLAN.md` lists required environment, account, seeded domain data, verification upload, and cleanup/reset inputs.
2. Confirm the plan includes build/analyze/test commands, manual smoke checklist, evidence requirements, and blocker rules.
3. Confirm no secrets, passwords, tokens, or real client IDs are committed.
4. Confirm the staging smoke slice remains paused while the active product lane
   moves through backend-owned onboarding catalogs/readiness.
5. Confirm no runtime app code changed in task 53.1.
6. `git diff --check` - no whitespace errors.
7. Historical note only; the current `**NEXT**` row is `APP-ID-007`.

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
57. `flutter run` -> `bookAppointment` -> tap `Review request details` empty -> clinician, visit type, preferred date, and reason all show validation errors
58. `flutter run` -> `bookAppointment` -> enter clinician, choose visit type, enter date and reason, tap `Review request details` -> request details appear with `Backend request not sent`
59. `flutter run` -> `bookAppointment` -> after reviewing details, confirm there is no local confirm action; tap `Clear details` -> the request details disappear
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
148. Historical 2026-06 `48.1` snapshot: 68 wired routes at that time. Later routes superseded that count; current inventory is 79 constants / 78 cases. Backend/product seams remain documented (`DECISIONS.md` D050)
149. No runtime step for `49.1`: this is the documented backend/product readiness handoff; deferred seams are grouped by contract in `DEFERRED_WORK.md` so backend work can replace local stores/repositories without rewriting completed frontend routes (`DECISIONS.md` D051)
150. Historical 2026-06 `50.1` snapshot: 68 wired routes at that time and `login` reserved. Later route additions superseded the count; route UX/accessibility review continues under APP-P1-021 (`DECISIONS.md` D052)

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
| 2026-05-23 | 7.2 | DONE - `bookAppointment` originally gained a local form with validation and a saved booking draft summary; local booking success was later removed in 52.35 |
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
| 2026-07-14 | 52.26 | DONE - first safe profile mutation path selected: existing professional bio update from `addDescription` only, preserving backend-required profile fields |
| 2026-07-14 | 52.27 | DONE - Add Description now updates existing professional profile bio only, preserving required profile fields and refusing partial profile creation |
| 2026-07-14 | 52.28 | DONE - next profile/public-professional runtime lane selected: public verified professional listing into Search only |
| 2026-07-14 | 52.29 | DONE - Search now reads public verified professionals without local fallback, exposes real errors/empty states, and keeps booking/detail expansion deferred |
| 2026-07-14 | 52.30 | DONE - next backend-integration lane selected: scheduling availability and appointment contract definition before runtime wiring |
| 2026-07-14 | 52.31 | DONE - scheduling/availability/appointment frontend contract defined; next slice is repository boundary only |
| 2026-07-14 | 52.32 | DONE - scheduling repository boundary added for availability and appointment routes without UI wiring |
| 2026-07-14 | 52.33 | DONE - Search profile sheet now reads public availability without local slot fallback while booking remains deferred |
| 2026-07-14 | 52.34 | DONE - appointment request UI path selected: remove local booking success before real request wiring |
| 2026-07-14 | 52.35 | DONE - `bookAppointment` local confirmation removed; route now shows backend-required request details only |
| 2026-07-14 | 52.36 | DONE - concrete appointment request UX selected: Search availability sheet first, helper/test slice before runtime request |
| 2026-07-15 | 52.56 | DONE - Appointments now wires constrained patient/professional reschedule through generated public availability options; next slice is reschedule regression |
| 2026-07-15 | 52.57 | DONE - appointment reschedule regression strengthened terminal/empty-option proof and documented the remaining scheduling checkpoint decision |
| 2026-07-15 | 52.58 | DONE - scheduling feature expansion paused; next slice is a staging smoke checkpoint for the existing scheduling core |
| 2026-07-15 | 52.59 | DONE - scheduling staging smoke proved backend readiness, staging-configured APK build, protected route guards, and documented missing staging data blockers |
| 2026-07-15 | 52.60 | DONE - ad hoc Flutter-created scheduling staging data rejected; full scheduling smoke remains blocked on deliberate backend/staging test data setup, and the next slice will choose the next backend-completed Flutter surface |
| 2026-07-15 | 52.61 | DONE - patient self profile selected as the next backend-completed Flutter surface, with a required Settings/Profile mapping decision before runtime wiring |
| 2026-07-15 | 52.62 | DONE - Settings/Profile patient mapping defined as read-first: backend `name`, `age`, and `location` only; username, email, bio, auth/security, verification, scheduling, and destructive account actions remain separate |
| 2026-07-15 | 52.63 | DONE - Settings/Profile now reads patient profile through `ProfileRepository.patientMe`, displays backend name/age/location read-only, preserves local save, and does not call `updatePatientMe` |
| 2026-07-15 | 52.64 | DONE - patient profile read regression passed for success, empty-profile, safe failure, local save preservation, and no `updatePatientMe` mutation |
| 2026-07-15 | 52.65 | DONE - constrained patient profile update boundary selected: next runtime slice may update combined first/last name only, while username/email/bio/security/verification/scheduling data stay out of `/patients/me` |
| 2026-07-15 | 52.66 | DONE - Settings/Profile now updates backend patient profile name only, preserves local username/email/bio behavior, and blocks false success on backend name-save failure |
| 2026-07-15 | 52.67 | DONE - patient profile name update regression passed for name-only payload, safe failure/no false success, local-field preservation, and deferred-work accuracy |
| 2026-07-15 | 52.68 | DONE - selected Specialist Details public professional/availability wiring as the next narrow backend-completed Flutter surface while keeping verification/admin/staging/payments/reviews/calls/calendar out of scope |
| 2026-07-15 | 52.69 | DONE - Specialist Details can now render backend public professional detail, public availability, generated request options, and backend appointment request results without inventing a detail endpoint or falling back to local slots in the backend path |
| 2026-07-15 | 52.70 | DONE - Specialist Details public availability regression passed for backend id resolution, no local slot fallback, request payload/failure behavior, Search handoff, dashboard compatibility, and deferred-work accuracy |
| 2026-07-15 | 52.71 | DONE - selected Find Mentor public professional replacement as the next narrow surface while keeping verification/admin/staging/payments/reviews/calls/calendar out of scope |
| 2026-07-15 | 52.72 | DONE - Find Mentor now reads backend public professionals where available, routes backend ids to Specialist Details, and avoids local fallback/direct fake booking in the backend path |
| 2026-07-15 | 52.73 | DONE - Find Mentor public professionals regression passed for loading, empty, success, category filter, backend id handoff, safe failure, no local slot fallback, dashboard compatibility, and Specialist Details compatibility |
| 2026-07-15 | 52.74 | DONE - selected professional verification upload/list as the next backend-completed Flutter lane, with a required boundary decision before runtime upload/list wiring |
| 2026-07-15 | 52.75 | DONE - professional verification upload/list boundary accepted: Manage Profile entry, owner list/status plus controlled upload flow, private-document rules, and repository-boundary next |
| 2026-07-15 | 52.76 | DONE - professional verification repository/API boundary added with safe document entities, upload-init, internal signed PUT, upload-complete, bearer auth, safe error mapping, and focused tests |
| 2026-07-15 | 52.77 | DONE - Manage Profile now opens a backend-backed professional verification documents shell with safe list/status, empty/error states, and upload locked for file-picker boundary decision |
| 2026-07-15 | 52.78 | DONE - professional verification upload UI boundary selected a PDF-capable file picker path for the next runtime upload slice instead of using image-only picking |
| 2026-07-15 | 52.79 | DONE - professional verification upload flow wired with file picker, document type selection, PDF/JPEG/PNG validation, 10 MB guard, safe upload states, repository call, and list reload |
| 2026-07-15 | 52.80 | DONE - professional verification upload regression passed for list states, upload success/reload, cancellation, invalid type, size guard, safe failure, and private-data non-exposure |
| 2026-07-15 | 52.81 | DONE - selected professional basic profile field editing as the next backend-completed Flutter surface, with a required boundary decision before runtime name/category/specialty wiring |
| 2026-07-15 | 52.82 | DONE - accepted display-name-only professional profile edit boundary for `editYourName`, preserving existing category/specialty/bio and deferring profile creation plus broader profile fields |
| 2026-07-15 | 52.83 | DONE - `editYourName` now updates backend professional displayName only, preserves existing category/specialty/bio, blocks empty-profile creation, and keeps broader profile fields deferred |
| 2026-07-15 | 52.84 | DONE - professional display-name update regression passed for backend prefill, display-name-only save, category/specialty/bio preservation, empty-profile blocking, validation, safe failure, and deferred-work accuracy |
| 2026-07-15 | 52.85 | DONE - selected professional category/specialty editing as the next backend-completed Flutter surface, with a required boundary decision before runtime wiring |
| 2026-07-15 | 52.86 | DONE - accepted professional category/specialty edit boundary: new constrained edit surface, required category, optional specialty, preserve displayName/bio, and defer profile creation plus broader modules |
| 2026-07-15 | 52.87 | DONE - Manage Profile now opens a constrained category/specialty edit route that reads the existing professional profile, preserves displayName/bio, clears specialty as null, blocks empty-profile creation, and keeps broader fields deferred |
| 2026-07-15 | 52.88 | DONE - professional category/specialty update regression passed for entry separation, backend prefill, required category, displayName/bio preservation, specialty clearing as null, empty-profile blocking, safe backend failure, and deferred-work accuracy |
| 2026-07-15 | 52.89 | DONE - selected protected Google account linking as the next backend-completed Flutter surface, with a required UI boundary decision before runtime wiring |
| 2026-07-15 | 52.90 | DONE - accepted Google account linking UI boundary: Account placement, configured provider gate, `AuthRepository.googleLink`, safe states, backend-owned account/session data, and explicit deferrals |
| 2026-07-17 | APP-55 | DONE - role-based onboarding/auth boundary accepted from the PRD: patient and professional sign-up must branch before Google sign-up expansion; professional public listing requires profile, credential upload, and manual verification |
| 2026-07-17 | APP-56 | DONE - role-registration backend contract accepted: email/password and first-time Google-created accounts require explicit patient/professional role selection before runtime onboarding expansion |
| 2026-07-17 | APP-57 | DONE - role-selection onboarding wired before email/password account creation; selected patient/professional role now controls backend registration role |

---

## Rules (short)

1. One task per session.
2. Functionality + interactions before pixel-perfect UI.
3. Ask user if not in `DECISIONS.md` - do not guess.
4. See `DEFINITION_OF_DONE.md` before marking DONE.
5. Use `TASK_TEMPLATE.md` for task scope before coding.
6. Update `DOC_SYNC.md` (NEXT task + last completed).
