# CareNet project documentation

Current: APP-READY-075 merged as PR #240 at `0e0a65b268d7561f2376c846b24a52045cbf2854`.
Final-head and integration CI passed all 930 tests, analyzer, Android debug APK,
release lint, signing, and environment gates. APP-READY-073 is also merged; see
`AI_HANDOFF.md`, `CODEBASE_STATUS.md`, and `DOC_SYNC.md` for exact proof.
APP-READY-076 reconciled the current readiness handoff. APP-READY-077 is next:
staging verification-admin hosting/operator readiness,
which requires explicit user choices before any cloud mutation. Production
OAuth/release signing, live provider proof, admin staging operation, final
Paystack activation, and physical-device acceptance remain separate gates.
Historical checkpoint notes below do not supersede the current handoff.

**You do not need any old chat.** Everything required to continue this project lives in this `docs/` folder and in the codebase.

Current: APP-READY-064 locale source passes 821 tests and analyzer; see
`PHASE_1_LOCALE_POLICY.md`. PR #229 merged at `5955616`; final CI `38549558633`
and integration CI `38552538855` passed 811 tests and native CI gates. Earlier
pending-merge wording below is historical. Source proof is not deployment,
signed release-candidate, device acceptance or full-program completion.

APP-READY-063 source is in PR #229. See PHASE_1_RELEASE_HEALTH for the approved
default-off sanitized backend diagnostics contract and remaining native,
deployment, retention and alerting gates. Backend PR #141 is merged. Runtime
`301f939` passed 811 tests/analyzer; final exact-head CI is a merge gate. Local
native builds hit cache/disk limits, not a pass. No payments or device acceptance.

APP-READY-062 reconciles merged notification authority/execution and admin
preview-confirmation proof. See AI_HANDOFF, CODEBASE_STATUS and DOC_SYNC for exact
source/CI evidence and operational limits. After PR #229 merges, APP-READY-064
locale is next; deployment/alerts/provider acceptance and final device gates remain
open. No payments activate before final explicit user confirmation.

If you use a new IDE or a new AI tool, paste this:

```
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\

Read docs/WORKING_AGREEMENT.md (mandatory).
Read docs/README.md, then docs/AI_HANDOFF.md - complete ONLY the task marked NEXT.
Read docs/ARCHITECTURE_RULES.md and docs/TASK_TEMPLATE.md before coding.
Follow docs/FLOW_MAP.md, docs/ROUTES.md, docs/DEFINITION_OF_DONE.md.
Context: docs/BLUEPRINT_OVERVIEW.md, docs/CODEBASE_STATUS.md, docs/DECISIONS.md.
Do not use old chat history. Do not start the next task without my approval.
```

---

## Read order (first time)

| Order | File | Purpose |
|-------|------|---------|
| 1 | **WORKING_AGREEMENT.md** | **Strict rules:** one task/session, no placeholders, when to ask you |
| 2 | **AI_HANDOFF.md** | The **one** task marked NEXT + task queue |
| 3 | **ARCHITECTURE_RULES.md** | Folder, routing, state, testing, and handoff rules |
| 4 | **TASK_TEMPLATE.md** | Required task shape before any implementation |
| 5 | **DECISIONS.md** | Your answers (auth, API, etc.) so AI never re-guesses |
| 6 | **PROJECT_PLAN.md** | Phases, principles, folder layout |
| 7 | **FLOW_MAP.md** | Screen order and button navigation (logic) |
| 8 | **ROUTES.md** | Route names to Dart files |
| 9 | **BLUEPRINT_OVERVIEW.md** | Figma export: scale, colors, domains, limits |
| 10 | **CODEBASE_STATUS.md** | What is already built vs stub vs wrong |
| 11 | **DEFERRED_WORK.md** | One table of skipped/backend replacement work |
| 12 | **COMPONENTS.md** | Reusable widgets rules |
| 13 | **DEFINITION_OF_DONE.md** | Checklist before marking DONE |
| 14 | **GLOSSARY.md** | Plain-language dev terms |
| 15 | **DOC_SYNC.md** | Which doc wins if confused; last audit |
| 16 | **AUTH_SESSION_ACCOUNT_CONTRACT.md** | Auth/session/account backend contract for Phase 22 integration |
| 17 | **BACKEND_COMPLETED_SURFACE_WIRING_MAP.md** | Completed backend surfaces and remaining frontend wiring order |
| 18 | **AUTH_ACCOUNT_STAGING_CHECKPOINT.md** | Developer-private staging proxy/auth checkpoint for Phase 22 |
| 19 | **GOOGLE_SIGN_IN_FOUNDATION.md** | Real app identifiers required before Google OAuth setup |
| 20 | **GOOGLE_SIGN_IN_SETUP_PREREQUISITES.md** | Google OAuth client prerequisites and fingerprints |
| 21 | **ROLE_BASED_ONBOARDING_AUTH_BOUNDARY.md** | PRD-backed patient/professional onboarding and Google sign-up boundary |
| 22 | **ROLE_REGISTRATION_BACKEND_CONTRACT.md** | Exact frontend/backend contract for patient/professional registration and Google sign-up role handling |
| 23 | **PHASE_1_MARKETPLACE_BOUNDARY.md** | Current product scope, approved role navigation, Git/archive safety, unresolved blockers |
| 24 | **PHASE_1_ROUTE_SCREEN_CLASSIFICATION.md** | Complete route/screen KEEP-ADAPT-DEFER-DELETE inventory |
| 25 | **PHASE_1_DEPENDENCY_IMPACT_MAP.md** | Shared versus deferred files, state, models, services, assets, packages, and tests |
| 26 | **PHASE_1_IMPLEMENTATION_PLAN.md** | Ordered A-J slice plan, verification, risks, stop conditions, and non-goals |
| 27 | **PHASE_1_APPOINTMENT_CONSULTATIONS.md** | Paid appointment-linked VIDEO/AUDIO authority, LiveKit boundary, Flutter lifecycle, privacy, operations, and deferred scope |

Current implementation policy:
- Build only the approved Phase 1 consultation marketplace surface.
- Preserve and extend real auth/onboarding, profile/verification, discovery,
  availability, and appointment repository boundaries.
- Do not expose local/mock fallback as real retained Phase 1 behavior.
- Treat broad Figma/social/content/readings/emergency/creator screens as archive
  references, not active product scope.
- Avoid dummy widget logic that would force screen rewrites later.

---

## External inputs (not in git)

| Input | Path |
|-------|------|
| Figma blueprint export | `C:\Users\asd\Music\project-blueprint\project-blueprint\` |
| Flutter app (this repo) | `C:\Users\asd\Music\Mobile-App-master\` |

Inside the blueprint folder:

| File / folder | Use |
|---------------|-----|
| `routes.json` | Figma screen name -> URL path (reference; app uses `ROUTES.md`) |
| `screens/<name>/screen.png` | Visual truth for layout |
| `screens/<name>/screen.json` | Sizes, text, components, prototype `reactions` |
| `screens/<name>/README.md` | Route path for that export |
| `diagnostics.json` | Export stats |
| `failed-screens.json` | Failed exports (currently empty) |

**Note:** `project-manifest.json` was not in the export. Tech stack is defined by this repo's `pubspec.yaml` (Flutter).

---

## What "100% precision" means here

| Covered by docs + code | Still needs blueprint / judgment |
|------------------------|----------------------------------|
| App structure, routing, phases | Exact pixel spacing per screen |
| User flows A-D order | ~300 screens not yet in app (prioritize by phase) |
| Route table for wired screens | Duplicate Figma frames (implement once, use states) |
| Design tokens to extract in Phase 1 | API contracts (no backend spec yet) |
| Stubs list (what not to fake as done) | Copy text where JSON has placeholders |

No chat history is required for any row in the left column.

Confused? Read `DOC_SYNC.md` - already in the read-order table.
