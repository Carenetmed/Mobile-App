# CareNet project documentation

**You do not need any old chat.** Everything required to continue this project lives in this `docs/` folder and in the codebase.

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
| 23 | **AUTH_ONBOARDING_PRODUCTION_FLOW_PROPOSAL.md** | Product-level auth/onboarding decision proposal before redesign implementation |
| 24 | **AUTH_ONBOARDING_EXPERIENCE_CONTRACT.md** | Screen/state/field/recovery/visual contract for the production auth/onboarding redesign |
| 25 | **AUTH_GATEWAY_ROLE_FIRST_ENTRY.md** | APP-66 runtime entry slice: healthcare gateway and role-first signup method choice |
| 26 | **AUTH_FORM_CLEANUP_METHOD_CONVERGENCE.md** | APP-67 runtime signup cleanup: auth collects credentials/role only, profile fields move to role-specific setup |
| 27 | **ONBOARDING_READINESS_RESOLVER_SHELL.md** | APP-68 runtime resolver shell: session-producing auth paths route through a conservative readiness boundary |
| 28 | **PATIENT_SETUP_BOOKING_GATE_UI.md** | APP-69 runtime patient setup UI: real profile save, honest skip for browsing, booking readiness deferred |

Current implementation policy:
- Build frontend-complete, backend-ready slices.
- Use mock/local state only when needed, and keep it behind a clean boundary.
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
