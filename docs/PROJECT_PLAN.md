# CareNet — master plan

**All context lives in this repo.** You do not need prior chat history.

Start here: `docs/README.md` → then `docs/AI_HANDOFF.md` for the current task.

---

## What this project is

**CareNet** — mobile healthcare + professional community app (Flutter).
UI spec from Figma export: `C:\Users\asd\Music\project-blueprint\project-blueprint\`
Implementation repo: this folder (`Mobile-App-master`).

See `BLUEPRINT_OVERVIEW.md` for export size, colors, and domains.
See `CODEBASE_STATUS.md` for what is already coded.

---

## Principles

1. **Flow before pixels** — navigation and buttons must match `FLOW_MAP.md`.
2. **One vertical slice at a time** — finish Flow A before Flow B.
3. **One AI task per session** — only the task in `AI_HANDOFF.md`.
4. **Reuse components** — rules in `COMPONENTS.md`; no one-off buttons.
5. **UI can be tweaked later**; broken flow cannot.

---

## Phases

| Phase | Goal | Status |
|-------|------|--------|
| **0** | App spine, routing, docs, tests | **Done** |
| **1** | Tokens from blueprint + `CarenetButton` + `CarenetTextField` | **Done** |
| **2** | Flow A: sign-up path fully wired (every button) | **Done** |
| **3** | Flow B: sign-in → dashboard | **Done** |
| **4** | Dashboard + Home tabs (each tab = real screen; no `Placeholder()` widget) | **Done** |
| **5** | Messaging: tokens + list → chat navigation | **Done** |
| **6** | Health readings / vitals | **Done** |
| **7** | Appointments / calendar | **Done** |
| **8** | Emergency / distress | **Done** |
| **9+** | Feed, articles, communities, Q&A, profile, saved content, ads, … | **In progress - see `AI_HANDOFF.md` for the exact NEXT task** |

---

## Repo layout

```
lib/
  main.dart              → entry only
  app.dart               → MaterialApp + routing
  core/
    di/                  → get_it (register services in Phase 2+)
    routing/             → unknown route page
    constants/navigators/ → RouteName + generateRoute
    tokens/              → Phase 1 (colors, spacing, typography)
    theme/
  shared/widgets/        → reusable UI only
  features/              → splash, onboarding, auth, home, messaging, …
docs/                    → source of truth (read README.md first)
```

---

## For non-developers using AI

Paste into any new chat (full version in `WORKING_AGREEMENT.md`):

```
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\
Read docs/WORKING_AGREEMENT.md, docs/AI_HANDOFF.md (NEXT task only).
Follow FLOW_MAP.md, ROUTES.md, DEFINITION_OF_DONE.md, DECISIONS.md.
Do not use old chat. Do not start the next task without my approval.
```

Do not ask AI to "build the whole app from Figma" in one go. One task per session.

---

## Phase 1 breakdown (historical)

| Task | Deliverable | Status |
|------|-------------|--------|
| 1.1 | `lib/core/tokens/` — purple + neutral from `color-palette` | **Done** |
| 1.2 | `CarenetButton` — variants from blueprint `buttons/` | **Done** |
| 1.3 | `CarenetTextField` — from `inputfield` / `input-fields` | **Done** |
| 1.4 | Refactor onboarding + auth to use 1.2–1.3 | **Done** |

Update `AI_HANDOFF.md` after each task.
