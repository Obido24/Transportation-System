# Design System Document: The Fluid Transit Authority

## 1. Overview & Creative North Star: "The Kinetic Sanctuary"

This design system moves beyond the rigid, utilitarian nature of traditional transit dashboards to create **The Kinetic Sanctuary**. While I-Metro handles the chaotic pulse of city movement, the admin interface must be the calm eye of the storm. 

Our North Star is **Soft Efficiency**. We reject the "spreadsheet-heavy" legacy of transit software in favor of a high-end editorial layout. By leveraging intentional asymmetry, expansive whitespace, and depth-based layering, we transform data management into a premium experience. We don't just display information; we curate a digital environment that feels as smooth as a high-speed rail line.

---

## 2. Colors: Tonal Depth & The "No-Line" Rule

The palette is anchored by a sophisticated, deep forest green (`primary: #00513f`), evoking stability and growth. 

### The "No-Line" Rule
To achieve a signature, high-end feel, **1px solid borders are strictly prohibited for sectioning.** Boundaries must be defined solely through background shifts. 
*   **Method:** Place a `surface_container_lowest` card atop a `surface_container_low` background to create a "ghost" boundary that is felt, not seen.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers.
*   **Base Layer:** `surface` (#f8f9fa) for the main application background.
*   **The Nav Layer:** `surface_container` (#edeeef) for sidebars to provide a grounded, structural feel.
*   **Content Cards:** `surface_container_lowest` (#ffffff) to make data "pop" against the gray background.
*   **Nesting:** High-priority modules (like a "Live Alerts" widget) should use `surface_container_high` to create a subtle recessed or elevated effect relative to their neighbors.

### The "Glass & Gradient" Rule
Avoid flat color blocks. Use a subtle linear gradient for main Action Buttons and Hero Cards, transitioning from `primary` (#00513f) to `primary_container` (#006b54) at a 135-degree angle. For floating overlays, apply a `backdrop-blur` (12px–20px) to semi-transparent versions of `surface_container_lowest` to create a premium frosted glass effect.

---

## 3. Typography: Editorial Authority

We use a dual-typeface system to balance character with readability.

*   **Display & Headlines (Manrope):** This geometric sans-serif provides the "Editorial" voice. Use `headline-lg` for dashboard summaries. The medium weight is our signature; it’s authoritative without being aggressive.
*   **Body & Labels (Inter):** The industry standard for legibility. Inter handles the heavy lifting of transit schedules and ticket IDs.
*   **Hierarchy Note:** Use `on_surface_variant` (#3e4944) for secondary metadata to create a "grayed-out" effect that reduces cognitive load, reserving the high-contrast `on_surface` (#191c1d) for primary data points.

---

## 4. Elevation & Depth: Tonal Layering

Traditional shadows are often a crutch for poor layout. In this system, depth is earned through **Tonal Layering**.

*   **The Layering Principle:** Instead of a shadow, place a `surface_container_lowest` element inside a `surface_container_highest` wrapper. This creates a soft, natural lift.
*   **Ambient Shadows:** For floating elements (Modals, Dropdowns), use "Ambient Shadows": `0px 10px 30px rgba(25, 28, 29, 0.05)`. The shadow color must be a tinted version of `on_surface`, never pure black.
*   **Ghost Borders:** If a boundary is required for accessibility in ticket previews, use a 1px border of `outline_variant` at **15% opacity**.

---

## 5. Components: The I-Metro Toolkit

### Buttons
*   **Primary:** Rounded (`DEFAULT: 0.5rem`), Gradient fill (`primary` to `primary_container`), `on_primary` text.
*   **Secondary:** No fill, `outline` border at 20% opacity, `primary` text.
*   **Tertiary:** No border, `primary` text, `surface_container_low` background on hover.

### Tables (The "Air" Table)
*   **Constraint:** Forbid horizontal divider lines between every row. 
*   **Alternative:** Use `body-md` with generous vertical padding (16px–24px). Every 2nd row can use a `surface_container_low` background (Zebra-striping) only if the data density is extreme. Headers should be `label-md` in `on_surface_variant`, all caps with 0.05em tracking.

### Cards
*   **The Container:** All cards must use `surface_container_lowest` with a corner radius of `lg` (1rem). 
*   **The Header:** Use a subtle `surface_container_low` header bar (top 48px) to separate the title from the content without using a line.

### Input Fields
*   Soft-filled states: Use `surface_container_highest` as the input background. On focus, transition the background to `surface_container_lowest` and add a 1px `primary` ghost border.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use white space as a structural element. If a section feels crowded, add 16px of padding rather than a divider line.
*   **Do** use `primary_fixed_dim` for "Success" states to maintain brand harmony rather than a generic bright green.
*   **Do** use Glassmorphism for the "Current Transit Map" overlay to allow the dashboard to feel interconnected.

### Don't:
*   **Don't** use 100% black text. Always use `on_surface` (#191c1d) for a softer, premium look.
*   **Don't** use sharp 0px corners. Transit is fluid; our UI should be too. Stick to the `DEFAULT` (0.5rem) or `lg` (1rem) tokens.
*   **Don't** use heavy drop shadows. If an element looks like it's "hovering" too high, lower the opacity of the shadow or use a background color shift instead.

---

## Director’s Final Note
Design for the *rhythm* of the user. An admin for I-Metro is managing movement. The design system should feel like a well-oiled machine—quiet, efficient, and sophisticated. Every pixel must have a reason to exist. If it doesn't serve the "Kinetic Sanctuary," remove it.