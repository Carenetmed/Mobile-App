# Working agreement (mandatory for humans and AI)

**This project is serious.** Do not optimize for speed. Optimize for **one finished slice** per session.

You do **not** need old chat history. You **do** need this file + `AI_HANDOFF.md`.

---

## What you paste at the start of every new AI session

```
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\

Read docs/WORKING_AGREEMENT.md (this file).
Read docs/README.md, then docs/AI_HANDOFF.md — complete ONLY the task marked **NEXT**.
Read docs/ARCHITECTURE_RULES.md and docs/TASK_TEMPLATE.md before coding.
Follow docs/FLOW_MAP.md, docs/ROUTES.md, docs/DEFINITION_OF_DONE.md.
Context: docs/BLUEPRINT_OVERVIEW.md, docs/CODEBASE_STATUS.md, docs/DECISIONS.md.
Do not use old chat history. Do not start the next task without my approval.
```

---

## Priority order (non-negotiable)

| Priority | Requirement |
|----------|-------------|
| **1** | **Functionality 100%** — real navigation, real button outcomes, real state (loading/error/success where applicable) |
| **2** | **Interactions 100%** — matches `FLOW_MAP.md` and blueprint `reactions` for that slice |
| **3** | **Structure** — follow `ARCHITECTURE_RULES.md`, shared components, routes in `ROUTES.md`, no duplicate `main()` |
| **4** | **UI fidelity** — match Figma (`screen.png` + `screen.json`) as closely as practical; manual pixel tweaks OK later |

**Forbidden:** `Placeholder()`, `onPressed: () {}`, `// TODO later`, “we’ll wire this in Phase X” **inside the current task’s scope**.

**Allowed compromise:** spacing/color/icon off by small amount if flow and components are correct.

**Required policy from Phase 4 onward:** build frontend-complete, backend-ready slices.
That means no throwaway dummy code inside widgets, no fake success actions that bypass the real screen flow, and no raw placeholders in important user paths. If backend is missing, use honest local/mock state behind a clean boundary so later backend integration is mostly replacement, not screen rewrites.

---

## When the AI must STOP and ask you (do not guess)

If the task needs any of these and they are **not** already written in `docs/DECISIONS.md`, the AI **must ask you** and **not code forward**:

- Authentication backend (Firebase, custom API, Auth0, none/mock for now, etc.)
- API base URL, environment, keys
- Payment provider
- Push notification provider
- Required legal copy / compliance behavior
- User roles (patient vs professional paths)
- Data model fields not visible in blueprint
- Whether a Figma variant is a separate screen or one screen with state

After you answer, the AI adds a row to `docs/DECISIONS.md` so the next session never re-asks.

---

## One session = one task (safe limit)

| Rule | Detail |
|------|--------|
| **Read** | `AI_HANDOFF.md` → only the task marked **IN PROGRESS** or **NEXT** |
| **Do** | That task only, using `TASK_TEMPLATE.md`, to full Definition of Done |
| **Do not** | Start the following task “while we’re here” |
| **End** | Update docs (see checklist below), then **stop** and ask: “Task X complete. Start task Y?” |

### Safe task sizes (pick one per session)

| Size | Example | OK for one session? |
|------|---------|---------------------|
| **S** | Fix splash timing + routing only | Yes |
| **M** | One screen: all buttons wired, all states | Yes (preferred) |
| **M+** | One screen + its shared component | Yes if component is small (e.g. one button variant) |
| **L** | Entire Flow A (all signup screens) | **No** — split per screen or per 2–3 linked screens |
| **XL** | “Build onboarding” or “do auth” | **Never** |

**Your standard:** “2 days for one screen is fine” = aim for **M** tasks (one screen or one small flow link fully done).

---

## Task lifecycle (how work is tracked)

Statuses in `AI_HANDOFF.md`:

| Status | Meaning |
|--------|---------|
| **NEXT** | The only task AI should start |
| **IN PROGRESS** | Started this session (optional) |
| **DONE** | Passed `DEFINITION_OF_DONE.md` + manual test steps in handoff |
| **BLOCKED** | Waiting on your answer — listed under “Questions for product owner” |

**Rule:** Only **one** task may be `NEXT` at a time.

---

## End-of-session checklist (AI must do before saying “done”)

- [ ] Task works on device/emulator (steps written in `AI_HANDOFF.md`)
- [ ] No new placeholders in scope of this task
- [ ] `ROUTES.md` updated if routes added
- [ ] `FLOW_MAP.md` updated if navigation changed
- [ ] `CODEBASE_STATUS.md` updated if stubs removed or new debt added
- [ ] `DOC_SYNC.md` — NEXT task + last completed (see `DOC_SYNC.md`)
- [ ] `DECISIONS.md` updated if you answered a question
- [ ] `flutter test` passes (or note why a new test was added)
- [ ] Previous task marked **DONE**; next single task marked **NEXT**
- [ ] AI asks permission before starting the next task

---

## What “101% complete” means for a screen task

For the screen(s) in scope:

1. Every button/link does the correct thing or opens a defined dialog.
2. Every field has validation rules **or** you explicitly chose “no validation yet” in `DECISIONS.md`.
3. Back navigation works.
4. Error/empty/loading states exist if the screen can fetch data.
5. Registered in router + `ROUTES.md`.
6. Uses shared components from `COMPONENTS.md` (or adds one and documents it).
7. Blueprint `reactions` for that screen implemented or listed as N/A with reason.

**Not required in same task:** screens downstream outside the task scope.

---

## If something is incomplete

- **Do not** mark task DONE.
- **Do not** start the next phase.
- Set status **BLOCKED** or leave **IN PROGRESS** with a short list of what’s missing.
- Ask the user clearly (numbered questions).

---

## UI vs functionality (your compromise)

| Must be exact | Can tweak later |
|---------------|-----------------|
| Button exists and works | ± few px padding |
| All controls present | Exact hex if token exists |
| Navigation bar items and labels | Font size ±1sp |
| Critical layouts (forms, lists) | Illustration quality |

Use `screen.png` side-by-side when implementing; note in handoff if a visual mismatch remains.
