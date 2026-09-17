---
name: PackSense Bio-Intelligence
colors:
  surface: '#f8faf7'
  surface-dim: '#d8dbd8'
  surface-bright: '#f8faf7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f1'
  surface-container: '#eceeeb'
  surface-container-high: '#e7e9e6'
  surface-container-highest: '#e1e3e0'
  on-surface: '#191c1b'
  on-surface-variant: '#414844'
  inverse-surface: '#2e312f'
  inverse-on-surface: '#eff1ee'
  outline: '#717973'
  outline-variant: '#c1c8c2'
  surface-tint: '#3f6653'
  primary: '#012d1d'
  on-primary: '#ffffff'
  primary-container: '#1b4332'
  on-primary-container: '#86af99'
  inverse-primary: '#a5d0b9'
  secondary: '#116c4a'
  on-secondary: '#ffffff'
  secondary-container: '#a1f4c8'
  on-secondary-container: '#1b724f'
  tertiary: '#342300'
  on-tertiary: '#ffffff'
  tertiary-container: '#503700'
  on-tertiary-container: '#d49c2b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c1ecd4'
  primary-fixed-dim: '#a5d0b9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#274e3d'
  secondary-fixed: '#a1f4c8'
  secondary-fixed-dim: '#86d7ad'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdea9'
  tertiary-fixed-dim: '#f8bc49'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5e4100'
  background: '#f8faf7'
  on-background: '#191c1b'
  surface-variant: '#e1e3e0'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system blends **Organic Minimalism** with **Precision Bio-Tech**. It rejects the cold, sterile tropes of clinical laboratory dashboards in favor of an approachable, premium consumer-grade utility infused with agricultural science authority. 

### Target Audience & Emotional Intent
Designed for modern food producers, commercial kitchen operators, sustainability officers, and packaging engineers. The interface evokes:
- **Quiet Scientific Authority:** Trustworthy, precise, and empirical without cognitive overload.
- **Ecological Clarity:** Warm, breathable, and grounded in natural cycles rather than synthetic plastics.
- **Effortless Decision Confidence:** Clear separation between empirical ground-truth data and probabilistic AI recommendations.

### Visual Aesthetic & Principles
1. **Calm Precision (Progressive Disclosure):** Complex shelf-life metrics, barrier properties, and gas transmission dynamics remain dormant until relevant. High-level summaries guide the primary view; analytical depth unfolds on demand.
2. **Tactile Organic Planes:** White cards float effortlessly over soft oatmeal canvas foundations, defined by hair-thin organic borders rather than heavy drop shadows.
3. **Semantic Grounding:** Visuals prioritize scannability through explicit status cues—contrasting hard empirical measurements with gentle speculative estimations.

## Colors

The color palette establishes a grounded biological identity, using deep chlorophyll tones for brand authority and luminous botanical greens for interactive focus.

### Palette Roles & Usage Guidelines

- **Primary Canvas & Backgrounds:**
  - `Canvas / App Background`: `#F9FBF8` (warm, natural organic oatmeal).
  - `Surface Alt / Muted Container`: `#F3F6F2` (recessed inputs, inactive pill switches, list gutters).
  - `Card / Sheet Surface`: `#FFFFFF` (crisp white, creating gentle contrast against the canvas).
  - `Structural Border`: `#E3EAE1` (subtle organic contour lines).

- **Core Hierarchy:**
  - `Primary (#1B4332)`: Structural branding, high-priority navigation, and key headings.
  - `Primary Accent / CTA (#40916C)`: Primary action buttons, active progress rings, and focal interactive elements. Secondary states leverage `#52B788`.
  - `Text Primary (#1C2520)`: Deep charcoal with a hint of forest tone; avoids the harshness of pure `#000000`.
  - `Text Secondary (#526058)`: Deep sage-tinted slate for metadata, captions, and structural subheads.

- **Semantic & Epistemic Tags:**
  - `Measured / Verified Data`: `#2D6A4F` foreground on `#D8F3DC` container, paired with a solid leaf-green indicator dot (`#2D6A4F`). Indicates sensor verification, supplier-certified barrier specs, or lab testing.
  - `AI Estimated / Predictive`: `#B07D00` foreground on `#FFF3CD` container, paired with a gentle amber/honey indicator dot (`#B07D00`). Indicates AI shelf-life modeling, simulation, and predictive calculations.

## Typography

The type hierarchy uses **Plus Jakarta Sans** throughout all scales. Its humanist geometric proportions bring welcoming warmth while maintaining legibility in numerical readouts, barrier ratings, and packaging metrics.

### Typographic Hierarchy & Rules
- **Display & Large Headlines:** Reserved for primary card values, shelf-life forecasts (e.g., "+18 Days"), and onboarding greetings. Uses tight negative tracking (`-0.02em`) to maintain compositional compactness.
- **Body & Scientific Text:** Set with generous proportional line heights (`1.5x` minimum) to prevent dense text blocks from feeling like academic journals.
- **Tabular Figures & Metrics:** For all dynamic weights, shelf-life numbers, and oxygen/moisture transmission rates (OTR/WVTR), utilize OpenType tabular numbers (`tnum`) to eliminate layout jitter during recalculations.
- **Uppercase Labels:** Used strictly for micro-tags and status badges (`label-sm`), styled with `+0.04em` tracking for clarity at small sizes.

## Layout & Spacing

The layout is built for fluid touch interactions on mobile devices, optimized for standard Android viewports with a 4-column base structure transitioning to single-column stacking in compact contexts.

### Layout Philosophy & Touch Geometry
- **48dp Safe Touch Boundary:** All interactive targets (buttons, icon taps, pill switches, accordion headers) maintain a minimum hit area of `48px × 48px` to guarantee zero-miss usage in warehouse, kitchen, or lab environments.
- **Vertical Flow Rhythm:** Content blocks use `space-lg` (24px) vertical margins to ensure clarity between independent data domains.
- **Card Padding Interior:** Surface containers employ `space-md` (16px) or `space-lg` (24px) uniform interior padding, keeping edge tap zones clear of accidental activation.
- **Edge Margins:** Standard mobile canvas uses `1.25rem` (20px) horizontal margins, providing generous side gutters that frame packaging recommendation cards.

## Elevation & Depth

This system avoids dark, heavy skeuomorphic drops, relying instead on **Tonal Stratification** paired with **Organic Low-Contrast Outlines**.

### Elevation Tiers
1. **Level 0 (Canvas):** `#F9FBF8` oatmeal surface. Zero elevation.
2. **Level 1 (Default Cards, Data Containers):** Pure `#FFFFFF` surface bordered by a 1px solid `#E3EAE1` organic line. Soft ambient tint shadow: `0px 2px 8px rgba(27, 67, 50, 0.04)`.
3. **Level 2 (Interactive Floating / Active Selection):** Used for bottom sheets, contextual action bars, and selected packaging alternatives. Shadow: `0px 8px 24px rgba(27, 67, 50, 0.08)` accompanied by `#E3EAE1` border.
4. **Level 3 (Modal Dialogs & Decision Overlays):** Surface `#FFFFFF`, shadow `0px 16px 40px rgba(27, 67, 50, 0.12)`.

### Border Integrity
Every card, chip, and input uses a delicate outline (`1px solid #E3EAE1`). This ensures structural definition across displays varying in color calibration, daylight viewing, or contrast settings.

## Shapes

The shape language reflects natural curvature—clean, biological, and friendly without devolving into childish or exaggerated bubbles. 

### Corner Radius System
- **Base Components (`roundedness: 2` / 8px):** Checkboxes, form text inputs, small badges, and micro data chips.
- **Containers & Recommendation Cards (`rounded-lg` / 16px):** Primary packaging cards, metrics sections, and informational callouts.
- **Dialogs & Bottom Sheets (`rounded-xl` / 24px):** Slide-up configuration drawers, modal confirmations, and camera scanning overlays.
- **Pill Shapes (Full Radius):** Primary action buttons, category filter tags, and AI vs. Measured status indicators.

## Components

### Buttons
- **Primary Action (CTA):** Height 52px (exceeds 48px baseline). Background `#40916C`, text `#FFFFFF`, rounded pill shape (`999px`). Active state shifts to `#1B4332`. Shadow: `0 4px 12px rgba(64, 145, 108, 0.25)`.
- **Secondary / Ghost:** Height 52px. Background `#F3F6F2`, border 1px solid `#E3EAE1`, text `#1B4332`.
- **Destructive:** Soft light pink surface (`#FDF2F2`), border `#F8D7DA`, text `#B02A37`.

### Epistemic Data Tags & Chips
- **Measured Data Tag:** Pill container with `#D8F3DC` background and 1px `#B7E4C7` border. Leading 6px circular dot in `#2D6A4F`. Text reads `MEASURED` in `label-sm` bold uppercase, color `#2D6A4F`.
- **AI Estimated Tag:** Pill container with `#FFF3CD` background and 1px `#FFE69C` border. Leading 6px circular dot in `#B07D00`. Text reads `AI ESTIMATE` in `label-sm` bold uppercase, color `#B07D00`.
- **Filter Chips:** Height 36px. Unselected: `#FFFFFF` fill with `#E3EAE1` border, text `#526058`. Selected: `#1B4332` fill with white text.

### Cards & Recommendation Modules
- **Packaging Recommendation Card:** Crisp `#FFFFFF` surface with `16px` border-radius and `1px solid #E3EAE1`. Top row displays the Material Name and Sustainability Score pill. Middle section contains comparative barrier metrics (Moisture, O2, UV) represented as horizontal bar indicators. Bottom area houses cost and shelf-life impact with distinct epistemic tags.
- **Score Card:** Deep `#1B4332` container with white text and `#52B788` accent highlights, utilized for the overall "Eco-Match" summary score.

### Form Inputs & Selectors
- **Text Inputs:** Height 56px. Background `#FFFFFF`, border 1px solid `#E3EAE1`, border-radius 8px. Floating label uses `#526058`. Focused state: border 2px solid `#40916C`, zero glow, clean crisp transition.
- **Checkboxes & Radios:** Hit target 48px × 48px with visual control sized at 22px × 22px. Unchecked: 1.5px solid border `#526058`. Checked: solid `#1B4332` with crisp white checkmark/dot.

### Progressive Disclosure Drawer
- Pull-up sheet for granular packaging chemistry metrics (OTR, WVTR, tensile strength, compostability certifications). Smooth dragging affordance pill (`4px × 36px` in `#E3EAE1`), preserving context without navigating away from the scan result.