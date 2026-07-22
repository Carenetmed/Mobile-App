# Phase 1 Dependency Impact Map

Slice: `APP-P1-001`

Baseline: `3e04d6e`

This map prevents deferred-feature cleanup from deleting code that the Phase 1
marketplace still needs. It is an ownership map, not authorization to delete
anything in the decision slice.

## Architecture snapshot

- Runtime service location uses `get_it` in `lib/core/di/injection.dart`.
- Shared app theme state uses `ThemeBloc`/`flutter_bloc`.
- Feature pages mainly use `StatefulWidget` plus repositories from dependency injection.
- Legacy local feature state uses static `ValueNotifier` stores under
  `lib/features/Home/presentation/state`.
- There is no general Provider-based feature state layer to preserve.

## Protected Phase 1 dependency graph

| Layer | Protected files/types | Current Phase 1 consumers |
|---|---|---|
| App foundation | `main.dart`, `app.dart`, `CareNetApiConfig`, DI, router, unknown-route page, theme/tokens/fonts/colors | Every retained route |
| Auth/session | `AuthApiClient`, `AuthRepository`, `AccountRepository`, `SessionStore`, auth session/user/failure models, Google ID-token provider | Splash, sign-up/sign-in, reset/verification, account, readiness |
| Onboarding | `OnboardingApiClient`, `OnboardingRepository`, catalog/readiness models and entities, readiness route resolver | Role selection, patient setup, professional setup, verification progression |
| Profiles | `ProfileApiClient`, `ProfileRepository`, patient/professional/public-professional models and entities | Patient Profile, professional Profile, Find Care, onboarding setup |
| Verification | `VerificationApiClient`, `VerificationRepository`, verification document/upload entities | Professional onboarding/readiness and verification documents |
| Scheduling | `SchedulingApiClient`, `SchedulingRepository`, availability/appointment models and entities, appointment time-option service | Find Care, professional Schedule, appointment request/list/actions |
| Shared UI | `CarenetButton`, `CarenetTextField`, `AuthWidget`, `SvgImage`, shared themes/tokens | Auth, onboarding, profile, scheduling, verification |
| Routing | `RouteName`, `generateRoute` | All retained flows; prune only with caller and route-table proof |

## Screen and route ownership

### Exclusively deferred or obsolete after navigation pruning

| Product group | Screens/routes | State/models | Cleanup rule |
|---|---|---|---|
| Feed/post/Q&A | `feed_tab.dart`, `post_shell.dart`, `qa_shell.dart`; `qAAsk`, `qAAnswerRequests`, `qAAnswerForYou`, `commentAnswer` | `qa_local_store.dart` | Remove after Home/nav no longer imports Post and Q&A tests are retired |
| Communities | `circles_shell.dart`, `community_profile_page.dart`, `create_community_page.dart`; all community routes | `communities_local_store.dart`, route args | Router currently imports the store for owner fallback; remove case and import together |
| Articles/content | `articles_shell.dart`, `home_articles_tab.dart`, `saved_articles_shell.dart`, `published_articles_shell.dart`, `case_studies_shell.dart` | `articles_local_store.dart`, `case_studies_local_store.dart` | Preserve no content data in Phase 1; remove exclusive tests/assets after callers disappear |
| Podcast/media | `podcast_shell.dart`; `podcast` | `podcast_local_store.dart` | Remove list/watch state; media contracts remain future work |
| Health readings | `readings.dart`, `manage_readings.dart`, `add_device_shell.dart`, `blood_sug_shell.dart`, `health_record_shell.dart` | `readings_local_store.dart`, `core/model/vitalsModel.dart`, vitals widgets | Remove as one dependency cluster after dashboard/drawer no longer imports it |
| Emergency | `emergency_shell.dart`; `emergency`, `distressCall` | Route-local local state | Remove static/local dispatch claims and their tests together |
| Generic schedule/reminder | `reminder_shell.dart`, `schedules_shell.dart` | Route-local seeded schedule data | Do not confuse with retained backend availability in `selectedDates` |
| Creator portfolio | `manage_portfolio_shell.dart`; `managePortfolio` | `manage_portfolio_local_store.dart` | Remove creator-only Page/Circles/articles/promotion surface |
| Obsolete onboarding | `commitment_screen.dart`, onboarding `notification.dart`, `medical_agreement.dart`, `user_edit.dart`, `profession.dart`; agreement/edit routes | Image-picker-only local state | Remove only after patient/professional setup destinations are corrected and regression passes |

### Mixed dependencies that require extraction or adaptation

| Dependency | Current mixed responsibility | Phase 1 treatment |
|---|---|---|
| `dashboard.dart` | Home, Search, Post, Circles, Notifications bottom tabs | Rewrite shell around approved role destinations; preserve no deferred imports |
| `home.dart` | Feed, Messages, Articles inner tabs | Replace with role-aware Home; remove inner content tabs |
| `drawer.dart` | Profile plus readings, reminders, schedules, providers, role switch, articles, events, social metrics | Move retained account/support entries; remove broad-app drawer and fake identity metrics |
| `search_shell.dart` | Real public-professional/availability/request flow plus shared `DashboardShellScaffold` | Preserve backend path; rename destination to Find Care; extract shell only if still shared |
| `specialist_details_shell.dart` | Real backend detail/availability/request path plus `_LocalSpecialistDetails` | Keep backend path; delete local compatibility branch after callers always pass backend ids |
| `search_local_store.dart` | Legacy Find Mentor and specialist fallback | Delete after `findMentor` and local detail path are removed; do not reintroduce into Search |
| `appointments_shell.dart` | Real role-aware backend list/actions plus local `BookAppointmentShellPage` draft types | Preserve real list/actions; remove local booking route/classes |
| `selected_dates_shell.dart` | Real own-availability read/replace plus legacy presentation naming | Adapt into professional Schedule; preserve scheduling repository boundary |
| `account_shell.dart` | Real account/profile reads and logout mixed with `AccountLocalStore` mutations | Keep real reads/logout; replace or hide every local-only mutation before release |
| `account_local_store.dart` | Local identity, settings, deactivation, email/phone/security drafts | Remove incrementally after retained backend account/profile operations cover each field; never use as server truth |
| `manage_profile_shell.dart` | Real professional profile/verification reads mixed with creator articles, portfolio, local profile fields | Keep professional identity/readiness; remove creator content and local authority |
| `public_profile_local_store.dart` | Name/site/address/bio plus creator-style public profile | Replace retained profile edits with `ProfileRepository`; delete store when no retained consumer remains |
| `public_profile_shell.dart` | Local creator-style profile overlapping real `specialistDetails` | Delete route/screen after Find Care detail is canonical |
| `Messages.dart`, `Chat.dart` | Required Phase 1 destination implemented with seeded generic conversations | Keep route names temporarily; replace data and authorization after messaging decision; no seeded release state |
| Messaging models/entities | Generic chat/message/notification shapes with no repository/API service | Review against the future appointment-messaging contract; adapt rather than assume they are correct |
| `Notification.dart` | Static appointment plus social/content/emergency notifications | Preserve destination shell only; replace static data after notification contract and remove deferred categories |
| `call_professional.dart` and call/video assets | Unregistered local consultation presentation without appointment authorization or RTC contract | Preserve only as reference; future runtime entry belongs to Appointment Detail and external RTC transport remains behind a CareNet authorization/session boundary |
| `edit_your_name_shell.dart`, `add_description_shell.dart`, `edit_professional_details_shell.dart`, `set_address_shell.dart` | Some real profile writes mixed with local store/draft assumptions | Consolidate under role-aware Profile and backend-supported fields |

## Local-store disposition

| Local store | Classification | End state |
|---|---|---|
| `articles_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `case_studies_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `communities_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `manage_portfolio_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `podcast_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `qa_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `readings_local_store.dart` | DEFER-exclusive | Delete in dead-code cleanup |
| `search_local_store.dart` | Mixed legacy fallback | Delete after Find Care/specialist details no longer use local fallback |
| `public_profile_local_store.dart` | Mixed profile/creator state | Replace retained fields with profile repository; then delete |
| `account_local_store.dart` | Mixed account/profile/security state | Replace or hide local mutations field by field; then delete |

## Models and services

### Must not be removed

- All files under `features/Authentication/data` and
  `features/Authentication/domain` used by the real auth/session flow.
- All onboarding catalog/readiness, patient/professional/public-professional,
  verification, availability, and appointment models/entities/API clients/repositories.
- `OnboardingReadinessRouteResolver`.
- `AppointmentRequestTimeOptions` service and its entities.
- `CareNetApiConfig`, DI registrations, secure session storage, and safe API error mapping.

### Candidate deferred-only models

- `core/model/vitalsModel.dart` after readings removal.
- `core/model/drawer_item_model.dart` if the broad drawer is removed and no
  secondary menu reuses it.
- Messaging models/entities are not deletion candidates yet because Phase 1
  needs messaging, but they cannot be considered production contracts until the
  unresolved appointment-messaging decision is made.

## Assets

| Asset group | Examples | Disposition |
|---|---|---|
| Retained brand/auth | CareNet logos, onboarding images, Google, mail, phone, visible icons, launcher icon, Montserrat fonts | KEEP |
| Retained marketplace/navigation | home, search, person, calendar/schedule, message, settings, help, star where still used | KEEP/ADAPT after usage scan |
| Deferred health tracking | blood pressure, blood sugar, oxygen, steps, weight PNGs; heart-rate/content icons | Remove after health screens/tests are deleted |
| Deferred social/content | sunny/circle, notepad/article, live/mic/podcast, trophy/role-switch or promotion-specific uses | Remove only when usage scan shows no retained consumer |
| Mixed professional fallback | `professional_one.png`, `professional_two.png`, `professional_three.png`, `profile_pic.svg` | Remove if real public professional UI no longer uses local fallback; otherwise replace with an honest empty/avatar state |
| Deferred promotion/profile | `fire_place.png`, `upgrade_stock.png`, `profile_handle.png` | Remove after broad drawer/creator promotion is removed |
| Phase 1 consultation | call/video icons | Keep unexposed until external RTC and CareNet authorization/session contracts are approved; Join Consultation belongs to Appointment Detail |

Every asset removal must be supported by `rg` usage output after the code cleanup,
not by filename intuition.

## Packages

| Package | Baseline use | Phase 1 status |
|---|---|---|
| `dio` | Auth/profile/onboarding/scheduling/verification API clients | KEEP |
| `flutter_secure_storage` | Session storage | KEEP |
| `google_sign_in` | Google ID token | KEEP |
| `file_picker` | Professional verification upload | KEEP |
| `intl` | Specialist availability and deferred schedules | KEEP because specialist detail is retained |
| `get_it` | Dependency injection | KEEP |
| `flutter_bloc` + `bloc` | Theme state | KEEP unless separately redesigned |
| `flutter_screenutil` | Existing responsive layout | KEEP |
| `flutter_svg` | Shared asset rendering | KEEP |
| `image_picker` | Obsolete `user_edit.dart` and helper only | Removal candidate after obsolete onboarding cleanup unless a separately approved profile-photo flow uses it |
| `logger` | Image-picker helper only | Remove with unused helper if no retained consumer |
| `cached_network_image`, `google_fonts`, `get`, `http`, `image_cropper` | No `lib`/`test` imports found at baseline | Dependency-cleanup candidates; verify generated/platform use before removal |
| `cupertino_icons` | No direct baseline import found | Verify before dependency cleanup |
| `flutter_launcher_icons` | Build-time launcher generation | KEEP as dev tooling while app icon config remains active |

No package should be removed during navigation pruning. Package changes belong to
the dedicated dead-code/dependency cleanup slice after `flutter pub get`, analyze,
tests, and Android build proof can run together.

## Test impact

### Protected or adapted tests

- All authentication and session tests.
- Onboarding gateway, readiness resolver, and profile setup tests. Update them to
  prove patient setup no longer enters the obsolete agreement chain.
- Profile, onboarding repository, verification repository, scheduling repository,
  appointments, search, and specialist details tests.
- Account, manage profile, dashboard, and Home tests must be rewritten around the
  role-aware Phase 1 contract, not deleted wholesale.
- Messaging and notification tests remain but must lose seeded/social assumptions
  after their contracts are implemented.
- Shared widget and token tests remain.

### Deferred-feature tests removed with their feature code

- `articles_flow_test.dart`
- `case_studies_flow_test.dart`
- `communities_flow_test.dart`
- `emergency_flow_test.dart`
- `health_record_flow_test.dart`
- `podcast_flow_test.dart`
- `qa_flow_test.dart`
- `readings_flow_test.dart`
- `saved_articles_flow_test.dart`
- `manage_portfolio_flow_test.dart`

### Tests requiring classification-driven replacement

| Test | Required change |
|---|---|
| `dashboard_shell_test.dart` | Assert patient/professional five-tab contracts and header bell |
| `home_tab_shell_test.dart` | Replace Feed/Messages/Articles tab expectations with role-aware Home expectations |
| `find_mentor_flow_test.dart` | Remove after Find Mentor consolidation; move retained public-professional cases into Search/detail tests |
| `public_profile_flow_test.dart` | Remove creator/local profile expectations; preserve required professional-detail cases elsewhere |
| `messaging_flow_test.dart` | Replace generic seeded data with appointment-linked contract tests later |
| `chat_route_structure_test.dart` | Keep route safety coverage but remove `message` alias after callers migrate |
| `account_flow_test.dart` | Separate real repository behavior from `AccountLocalStore` mutation tests |

## Cleanup gate

An exclusive file is eligible for deletion only when all are true:

1. Its route is absent from active navigation and the canonical router.
2. `rg` finds no retained imports or route callers.
3. Any shared model/widget has been preserved or intentionally moved.
4. Its focused tests are either migrated to a retained owner or retired with a
   written reason.
5. Package and asset usage scans are recorded.
6. `flutter analyze`, retained tests, and Android debug build pass.
