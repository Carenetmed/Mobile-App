# Glossary (plain language)

| Term | Meaning in this project |
|------|-------------------------|
| **Screen** | One full page (e.g. Sign up with phone). |
| **Flow** | Ordered screens + what each button does (see `FLOW_MAP.md`). |
| **Route** | Internal name for a screen (`RouteName.signUpPhone` → string `signUpPhone`). |
| **Router** | Code in `lib/core/constants/navigators/router.dart` that picks which widget to show. |
| **Component** | Reusable UI piece (button, text field) built once and shared. |
| **Reuse** | Same `CarenetButton` on every screen instead of new button code each time. |
| **Token** | Named design value (`primaryPurple = #7000DA`) used everywhere. |
| **Vertical slice** | One journey done end-to-end (e.g. splash → dashboard signup path). |
| **Stub** | Button or screen intentionally not finished; listed in `AI_HANDOFF.md`. |
| **Blueprint** | Figma export folder with PNG + JSON per screen. |
| **Phase** | Block of work (0 = spine, 1 = design system, 2 = signup flow, …). |
| **Definition of Done** | Checklist in `DEFINITION_OF_DONE.md` before marking work complete. |
