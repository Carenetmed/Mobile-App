# Reusable components

The shared token and canonical widget foundations were introduced during the
initial frontend phases.

## Design tokens (Phase 1 - tasks 1.1 + 1.3 DONE)

Import: `import 'package:app_t/core/tokens/tokens.dart';` (or `carenet_colors.dart`).

| File | Class | Purpose |
|------|-------|---------|
| `lib/core/tokens/carenet_colors.dart` | `CarenetColors` | Healthcare-green primary scale, neutral grey scale, and semantic status colors |
| `lib/core/tokens/tokens.dart` | - | Barrel export for tokens |

### `CarenetColors` (Phase 1 marketplace)

| Token | Hex | Blueprint name |
|-------|-----|----------------|
| `primary100` | `#E7F3EC` | light surface |
| `primary200` | `#C4E2D0` | accessible dark-theme primary |
| `primary300` | `#92C9AA` | primary/300 |
| `primary400` | `#4D9A70` | primary/400 |
| `primary500`, `brand` | `#054F31` | healthcare-green brand |
| `primary600` | `#043F27` | primary/600 |
| `primary700` | `#022D1B` | primary/700 |
| `neutral100` | `#e8e8e9` | grey/100 |
| `neutral200` | `#c1c0c4` | grey/200 |
| `neutral300` | `#9a999f` | grey/300 |
| `neutral400` | `#76747c` | grey/400 |
| `neutral500` | `#535159` | grey/500 |
| `neutral600` | `#323136` | grey/600 |
| `neutral700` | `#141416` | grey/700 |
| `success100` | `#176B45` | accessible success foreground |
| `success200` | `#E7F3EC` | success surface |
| `error100` | `#B3261E` | accessible error foreground |
| `error200` | `#FCE8E6` | error surface |
| `info100` | `#155E75` | accessible info foreground |
| `info200` | `#E6F4F6` | info surface |
| `white` | `#FFFFFF` | - |
| `black` | `#000000` | - |

**Migration:** `CarenetButton` and `CarenetTextField` now use `CarenetColors`. Other UI may still use `AppColors` until refactored.

## `CarenetButton` (task 1.2 DONE)

Import: `import 'package:app_t/shared/widgets/carenet_button.dart';`

| API | Values |
|-----|--------|
| `CarenetButtonType` | `primary`, `outline` (blueprint Secondary) |
| `CarenetButtonSize` | `large` only (48h, padding 12x16, radius 8) |
| Disabled | `onPressed: null` |

### Layout (blueprint `screens/buttons/`)

| Property | Value |
|----------|--------|
| Minimum height | 48 (`.h` via ScreenUtil); expands for larger text |
| Padding | 12 vertical, 16 horizontal |
| Corner radius | 8 |
| Label | 16sp Montserrat w400 |

### Colors (`CarenetColors` only)

| Variant | Enabled | Disabled (`onPressed == null`) |
|---------|---------|--------------------------------|
| Primary | bg `brand`, text `white` | bg `neutral100`, text `neutral300` |
| Outline | bg `white`, border `brand`, text `brand` | bg `white`, border `neutral200`, text `neutral300` |

Press/highlight uses `primary100` / `primary400` tints (hover N/A on mobile; ink feedback only). The control exposes one labelled button semantic with its tap action, and its hit target stays at least 48 logical pixels high.

### Legacy wrappers (still used by existing screens)

| Widget | File | Delegates to |
|--------|------|--------------|
| `CarenetButtonFilled` | `lib/shared/widgets/app_button.dart` | `CarenetButton` primary |
| `CarenetButtonOutline` | `lib/shared/widgets/app_button.dart` | `CarenetButton` outline |

Prefer `CarenetButton` directly in new code.

## `CarenetTextField` (task 1.3 DONE)

Import: `import 'package:app_t/shared/widgets/carenet_text_field.dart';`

| API | Values |
|-----|--------|
| `label` | Optional title above the field |
| `hintText` | Placeholder / entered preview text |
| `prefixIcon`, `suffixIcon` | Optional 24x24 widgets |
| `enabled` | `true` / `false` |
| `validationState` | `none`, `valid`, `invalid` |
| `errorText` | Optional error copy when `validationState` is `invalid` |
| Field behavior | Supports `controller`, `focusNode`, `keyboardType`, `textInputAction`, `validator`, `onChanged`, `onTap`, `onFieldSubmitted`, `readOnly`, `obscureText` |

### Layout (blueprint `screens/input-fields/` + `screens/input/`)

| Property | Value |
|----------|--------|
| Label spacing | 8 |
| Field min height | 48 |
| Padding | 12 vertical, 16 horizontal |
| Corner radius | 6 |
| Label / body text | 16sp Montserrat w400 |
| Error text | 10sp Montserrat w400 |
| Icon size | 24 |

### Colors (`CarenetColors` only)

| State | Border | Fill | Text/Icon |
|-------|--------|------|-----------|
| Default | `neutral200` | `white` | value `neutral700`, hint/icon `neutral300` |
| Hover / Focus | `info100` | `white` | value `neutral700`, hint `neutral300`, icon `info100` |
| Valid | `success100` | `white` | `success100` |
| Invalid | `error100` | `white` | `error100` |
| Disabled | `neutral200` | `neutral100` | text/hint `neutral300`, icon `neutral500` |

Use `validationState` for design-system previews or screen-level validation state. Screen refactors happen in task **1.4**.

## Other shared widgets

| Widget | File | Use for |
|--------|------|---------|
| `AuthWidget` | `lib/shared/widgets/auth_widget.dart` | Social / alt sign-in rows; rows with `btnAction: null` render in an explicit disabled state |
| `SvgImage` | `lib/shared/widgets/svg_image.dart` | SVG assets |
| `TextInput` / `BorderedTextInput` | auth widgets | Legacy auth form fields until task 1.4 refactor |

## Planned (Phase 1)

| Widget | Replaces | Spec source |
|--------|----------|-------------|
| `CarenetBottomNav` | raw `BottomNavigationBar` | blueprint `screens/mobile-nav/` |

## Rules

1. New screens must not create one-off `ElevatedButton` styles.
2. Colors: `CarenetColors` in `core/tokens/` for new shared components; legacy screens may still use `AppColors` until refactored.
3. Document new shared widgets (and token files) in this file before use.
