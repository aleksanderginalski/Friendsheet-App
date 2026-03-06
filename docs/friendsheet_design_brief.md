# Friendsheet — Design Brief

**Version:** 1.0  
**Created:** March 2026  
**Purpose:** Foundation for Figma work and Midjourney asset generation

---

## 1. Visual Identity

### Personality
Friendsheet is a warm, human app about social connections.  
The design should feel like **a friend's handwritten journal** — personal, inviting, alive.  
Not corporate. Not clinical. Not cold.

**Three words that describe the visual tone:**
- Warm
- Playful
- Trustworthy

**Inspiration:** Duolingo — character-driven, friendly illustrations, strong primary color, generous whitespace.

---

## 2. Color System

### Chart Color System

Independent palette for statistics bar charts — not constrained by app UI palette.
Reference: `lib/core/theme/chart_colors.dart`

**Gradient style:** Horizontal 4-stop cylinder/glass effect
**Stops:** 0% edge → 30% reflection → 70% reflection → 100% edge
**Reflection color:** `#F5F0E8` (Warm Off-White) — same for all bars
**Stroke:** 1.5px center, edge color @ 60% opacity, corner radius 4dp

| Index | Name | Edge color |
|-------|------|------------|
| 0 | Forest Green | `#2E7D32` |
| 1 | Lime Green | `#558B2F` |
| 2 | Mint Green | `#00796B` |
| 3 | Deep Orange | `#E65100` |
| 4 | Warm Amber | `#F57F17` |
| 5 | Burnt Orange | `#BF360C` |
| 6 | Coral | `#C62828` |
| 7 | Sky | `#1565C0` |

### Primary Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary | Friendly Green | `#43A047` | Buttons, active states, FAB |
| Primary Light | Soft Green | `#76D275` | Backgrounds, chips, highlights |
| Primary Dark | Deep Green | `#2E7D32` | Pressed states, text on light |
| Secondary | Warm Amber | `#FFB300` | Accents, badges, empty state highlights |
| Surface | Warm White | `#FAFAF7` | Screen backgrounds (slightly warm, not pure white) |
| On Surface | Charcoal | `#1C1B1F` | Body text |
| Subtle | Warm Gray | `#F0EDE8` | Card backgrounds, dividers |
| Error | Coral | `#E53935` | Error states |

> **Why Warm White instead of #FFFFFF?**  
> Pure white feels cold and clinical. `#FAFAF7` adds warmth consistent with the friendly character.

### Do Not Use
- Pure black `#000000` — use Charcoal `#1C1B1F` instead
- Pure white `#FFFFFF` — use Warm White `#FAFAF7` instead
- Cool grays (e.g. `#9E9E9E`) as primary text — use warm-tinted grays

---

## 3. Typography

### Font Pairing

| Role | Font | Weight | Size |
|------|------|--------|------|
| Display / App Name | **Nunito** | ExtraBold 800 | 28–32sp |
| Headings | **Nunito** | Bold 700 | 20–24sp |
| Body | **Nunito** | Regular 400 | 14–16sp |
| Caption / Labels | **Nunito** | SemiBold 600 | 11–12sp |

> **Why Nunito?**  
> Rounded letterforms = friendly and approachable. Used by apps like Duolingo and many lifestyle products. Works beautifully at all sizes on mobile.

**Google Fonts link:** https://fonts.google.com/specimen/Nunito

### Typography Rules
- Line height: 1.4–1.5x for body, 1.2x for headings
- Letter spacing: slightly loose (+0.2–0.5) for labels and captions
- Never use ALL CAPS for long strings — only short labels (2–3 words max)

---

## 4. Illustration Style

### Style Definition
**Flat 2D character illustrations** — rounded shapes, bold outlines (2–3px), limited color palette (3–4 colors per illustration), expressive faces.

Think: Duolingo owl energy, but applied to human characters representing friendships, meetings, social moments.

### Character Guidelines
- Simple, abstract human figures (not realistic)
- Always warm skin tones — diverse representation
- Expressive poses and gestures (waving, hugging, sitting together)
- Consistent outline weight across all illustrations

### Where Illustrations Are Used
| Location | Description |
|----------|-------------|
| App Icon | Single character or symbol representing friendship |
| Login Screen | Welcoming illustration above Google Sign-In button |
| Empty States | Small character illustration when list is empty |
| Onboarding (future) | Scene per step showing app value |

### What to Avoid
- Photorealistic images
- Overly complex compositions
- Characters with detailed facial features
- Dark or desaturated tones

---

## 5. Iconography

### Style
**Rounded, filled icons** — consistent with Nunito's rounded personality.

### Recommended Sets (free)
- **Phosphor Icons** — https://phosphoricons.com (available as Flutter package)
- **Material Symbols Rounded** — already in Flutter, switch to `rounded` variant

### Icon Sizes
| Context | Size |
|---------|------|
| Bottom navigation | 24dp |
| List items | 20dp |
| FAB | 24dp |
| Inline / labels | 16dp |

---

## 6. Spacing & Shape

### Border Radius
| Element | Radius |
|---------|--------|
| Cards | 16dp |
| Buttons | 12dp |
| Chips / Tags | 8dp |
| Bottom sheet | 24dp top corners |
| Dialogs | 20dp |

> **Rule:** Generous rounding = friendly feel. Avoid sharp 0dp corners everywhere.

### Spacing Scale
Base unit: **8dp**

| Name | Value | Usage |
|------|-------|-------|
| XS | 4dp | Icon gaps, tight pairs |
| S | 8dp | Within components |
| M | 16dp | Standard padding |
| L | 24dp | Section spacing |
| XL | 32dp | Screen top padding |

---

## 7. Elevation & Shadows

Minimal shadows — this is a flat-friendly design.

| Level | Usage | Shadow |
|-------|-------|--------|
| 0 | Flat cards on warm gray bg | None |
| 1 | Cards on white surface | `0 2px 8px rgba(0,0,0,0.08)` |
| 2 | FAB, bottom sheet | `0 4px 16px rgba(0,0,0,0.12)` |

---

## 8. Midjourney Prompt Templates

### App Icon
```
friendly mobile app icon, two cartoon characters hugging or waving, 
flat 2D illustration, rounded shapes, bold outlines, 
warm green #43A047 and amber #FFB300 color palette, 
white background, simple geometric style, duolingo-inspired, 
app store icon format, square composition, --ar 1:1 --style raw --v 6
```

### Empty State — No Meetings
```
small flat illustration, two cartoon friends sitting at a cafe table, 
smiling and talking, simple rounded characters, warm colors,
green and amber palette, white background, minimal detail,
mobile app empty state style, duolingo character energy,
--ar 4:3 --style raw --v 6
```

### Empty State — No Friends Added
```
flat 2D illustration, single cartoon character waving hello,
friendly pose, simple rounded shapes, bold outline, 
warm green color scheme, white background, minimal,
mobile app illustration, --ar 1:1 --style raw --v 6
```

### Login Screen Hero
```
flat illustration, group of 3-4 diverse cartoon friends,
laughing and spending time together, warm and joyful scene,
rounded character style, green and amber color palette,
white background, simple geometric shapes, duolingo-inspired style,
horizontal composition, mobile app onboarding illustration,
--ar 16:9 --style raw --v 6
```

---

## 9. Figma Setup Checklist

Before starting any screen design in Figma:

- [ ] Set up **Color Styles** using the palette from Section 2
- [ ] Import **Nunito** font (Google Fonts plugin in Figma)
- [ ] Create **Text Styles** for Display, H1, H2, Body, Caption
- [ ] Set **8dp grid** on all frames
- [ ] Create **component** for primary button, card, chip
- [ ] Set frame size to **390 × 844** (iPhone 14 / standard Android)

---

## 10. Flutter Implementation Notes

When translating this design to Flutter:

```dart
// ThemeData setup
ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFF43A047),
    secondary: Color(0xFFFFB300),
    surface: Color(0xFFFAFAF7),
    error: Color(0xFFE53935),
  ),
  fontFamily: 'Nunito',
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

**Google Fonts package:**
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```

---

*This brief is a living document — update when design decisions evolve.*
