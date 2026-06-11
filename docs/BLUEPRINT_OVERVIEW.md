# Figma blueprint overview

Reference summary for the Figma export used during frontend implementation.

---

## Export statistics

| Metric | Value |
|--------|--------|
| Screens detected in Figma | **545** |
| Unique folders exported | **240** |
| Files generated | **2,134** |
| Failed exports (`failed-screens.json`) | **0** |
| Export date (`diagnostics.json`) | 2026-05-11 |
| `screen.png` per folder | **232** (8 folders JSON/SVG only) |
| `screen.json` per folder | **240** |

Many of the 545 Figma frames are **variants** (same screen, different state). Do not build 545 separate routes—implement **one screen + states** (see `FLOW_MAP.md` and phases).

---

## How to use each blueprint file

| File | Role |
|------|------|
| `screen.png` | **Visual truth** — spacing, colors, layout |
| `screen.json` | **Structure** — width/height (often 430×932 mobile), text, Auto Layout, `variantProperties`, `reactions` |
| `screen.svg` | Optional vector reference |
| `routes.json` | Maps Figma names to paths like `/sign-up-with-phone` (duplicate keys exist; not valid strict JSON) |
| `README.md` per screen | Route path + export mode |

### Prototype reactions (`screen.json`)

Look for `reactions` on nodes:

| Trigger | Example | Implementation |
|---------|---------|----------------|
| `AFTER_TIMEOUT` | Splash → next in 0.8s | `Future.delayed` + `pushReplacementNamed` (done on splash) |
| `ON_CLICK` / tap | Button → screen | `Navigator.pushNamed` |
| `NAVIGATE` | Go to linked frame | Match `destinationId` to route (manual map) |
| `CHANGE_TO` | Hover/disabled variant | Widget state / `AnimatedContainer` |

---

## Mobile canvas

- Target frame: **430 × 932** (iPhone 14/15 class).
- App uses `ScreenUtilInit(designSize: Size(430, 932))` in `lib/app.dart`.

---

## Design tokens (from `screens/color-palette/screen.json`)

**In code:** `CarenetColors` in `lib/core/tokens/carenet_colors.dart` (task 1.1 — primary + neutral). App **screens** still use legacy `AppColors` until tasks 1.2–1.4. Semantic reds/blues on the palette page are not in `CarenetColors` yet.

### Primary purple scale

| Token | Hex |
|-------|-----|
| primary/100 | `#ebe5ff` |
| primary/200 | `#cab6ff` |
| primary/300 | `#ab84ff` |
| primary/400 | `#9148ff` |
| primary/500 (brand) | `#7000DA` |
| primary/600 | `#46008c` |
| primary/700 | `#1f0045` |

### Neutral scale (examples)

| Token | Hex |
|-------|-----|
| neutral/100 | `#e8e8e9` |
| neutral/500 | `#76747c` |
| neutral/700 | `#323136` |
| neutral/900 | `#141416` |

### Typography (Figma vs app)

| Source | Font |
|--------|------|
| Blueprint `typography` screen | **Inter** (spec reference) |
| This app `pubspec.yaml` | **Montserrat** (shipped assets) |

**Decision:** Keep Montserrat unless product owner requests Inter. Match **sizes/weights** from blueprint, not necessarily the font family.

### Buttons (from `screens/buttons/screen.json`)

Component set variants:

- **Type:** Primary, Secondary, …
- **State:** Enabled, Disabled, Hover
- **Size:** Large (height **48**, padding 12×16, radius **8**)

Build one `CarenetButton` widget with enums (Phase 1).

---

## Product domains (blueprint `routes.json` — grouped)

Implement in phase order at bottom—not all at once.

| Domain | Example blueprint paths | App phase |
|--------|---------------------------|-----------|
| Launch / auth | `/splash-screen`, `/onboarding`, `/sign-up-with-phone` | 0–3 |
| Agreements | `/community-agreement`, `/notification-agreement` | 2 |
| Main shell | `/dashboard`, `/home` | 4 |
| Messaging | `/messages`, `/chat`, `/notifications` | 5 |
| Health / vitals | `/readings`, `/blood-sug`, `/add-device` | 6 |
| Appointments | `/book-appointment`, `/appointments` | 7 |
| Emergency | `/distress-call`, `/call-emmergency` | 8 |
| Social / content | `/feed`, `/articles`, `/podcast`, `/q-a` | 9+ |
| Communities | `/my-communities`, `/discover` | 9+ |
| Creator / monetization | `/manage-profile`, `/subscribe-plan-1`, `/design-ad` | 10+ |
| Account / security | `/change-authentication`, `/create-pin` | 6–10 |
| Design system only | `/typography`, `/buttons`, `/color-palette` | 1 (not user routes) |
| Marketing web | `/desktop`, `/product-page`, `/who-we-are` | Optional later |

---

## Blueprint path ↔ app route (wired screens)

| Blueprint path | App `RouteName` |
|----------------|-----------------|
| `/splash-screen` | `splash` |
| `/onboarding` | `onboarding` |
| `/sign-up-with-phone` | `signUpPhone` |
| `/sign-up-with-email` | `signUpEmail` |
| `/community-agreement` | `communityAgreement` |
| `/notification-agreement` | `notificationAgreement` |
| `/sign-in-with-email` | `signInEmail` |
| `/sign-in-with-phone` | `signInPhone` |
| `/dashboard` | `dashboard` |

Full wired list: `ROUTES.md`. Figma has hundreds more paths not in the app yet.

---

## Export caveats

1. **`routes.json` duplicate keys** — e.g. `"Splash Screen"` and `"splash screen"` both map to `/splash-screen`. Use `ROUTES.md` in the app, not raw JSON parsing.
2. **`json-only` exports** — ~21 screens exported without PNG (e.g. some `Typography`, `Onboarding 2`). Use JSON + SVG or sibling exports.
3. **Placeholder copy** — Some JSON text is lorem (`"placerat"`). Prefer `screen.png` for real copy.
4. **Typos in Figma names** — `Manage Readingsr`, `Notofication`, `Sgn in` — use clear names in app code; map in comments only.

---

## Tech stack (this repo — no `project-manifest.json`)

From `pubspec.yaml`:

- Flutter SDK ^3.7.2, Dart
- `flutter_screenutil`, `flutter_bloc`, `get_it`, `get`, `dio`, `http`
- `flutter_svg`, `google_fonts`, `cached_network_image`
- Assets: Montserrat, SVG icons/images under `assets/`
