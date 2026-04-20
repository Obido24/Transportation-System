# Design System Document: The Fluid Transit Experience

## 1. Overview & Creative North Star
**The Creative North Star: "The Kinetic Sanctuary"**

Public transit is often chaotic, loud, and stressful. This design system reimagines the transit app not as a utility, but as a "Kinetic Sanctuary"—a calm, hyper-organized, and premium digital layer that sits over the physical city. 

We break the "standard app" mold by moving away from rigid boxes and heavy lines. Instead, we utilize **Tonal Layering** and **Intentional Asymmetry**. By prioritizing white space and sophisticated typographic contrast (the pairing of the geometric Manrope with the functional Inter), we create a high-end editorial feel that suggests reliability and modern intelligence. The UI doesn't just display data; it curates the journey.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a "Vibrant Trust" green, supported by a sophisticated range of cool grays and "paper-white" surfaces.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section off content.
Structure must be defined through **Background Shifts**. To separate a header from a list, or a card from a background, use the `surface-container` tiers. A `surface-container-low` card sitting on a `surface` background provides all the separation a modern eye needs without the "visual noise" of lines.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers.
*   **Base:** `surface` (#f7f9fb)
*   **Secondary Sections:** `surface-container-low` (#f2f4f6)
*   **Interactive Cards:** `surface-container-lowest` (#ffffff) — This creates a "lifted" effect.
*   **Overlays/Modals:** `surface-bright` (#f7f9fb) with high-diffusion ambient shadows.

### The "Glass & Gradient" Rule
To elevate the "Vibrant Green" (#006b47) beyond a flat brand color, use subtle linear gradients for hero actions:
*   **Primary CTA Gradient:** `primary` (#006b47) to `primary_container` (#00875a) at a 135° angle.
*   **Glassmorphism:** For floating navigation bars or ticket overlays, use `surface` at 80% opacity with a `20px` backdrop-blur. This integrates the component into the environment rather than cutting it off.

---

## 3. Typography
We use a dual-typeface system to balance editorial authority with high-density utility.

*   **Display & Headlines (Manrope):** Chosen for its wide stance and modern geometric terminals. Use `display-lg` through `headline-sm` to create "anchor points" on the screen. Large, bold headlines should be used to state the user's current status (e.g., "Your Train is Arriving").
*   **Body & UI Labels (Inter):** The workhorse. Inter is used for all functional data—timestamps, station names, and ticket prices. It provides maximum readability at small scales on moving vehicles.
*   **Intentional Contrast:** Pair a `headline-lg` (Manrope) with a `label-md` (Inter) in `on_surface_variant` (#3e4942) for a high-end, magazine-like hierarchy.

---

## 4. Elevation & Depth
In this system, depth is felt, not seen.

*   **The Layering Principle:** Avoid shadows for static elements. Stack `surface-container-lowest` on top of `surface-container-high` to create organic depth.
*   **Ambient Shadows:** For "floating" elements like a Quick-Buy FAB (Floating Action Button), use a shadow: `y-16, blur-40, color-on-surface @ 6%`. The shadow must never be pure gray; it should subtly pull the hue of the surface beneath it.
*   **The Ghost Border Fallback:** If a form field requires a container, use `outline_variant` (#bdcac0) at **20% opacity**. It should be a "whisper" of a line.

---

## 5. Components

### Buttons & CTAs
*   **Primary:** Uses the "Signature Gradient" (Primary to Primary-Container). `xl` roundedness (1.5rem/24px) for a friendly, pill-shaped feel.
*   **Secondary:** No background. Use `primary` text with a `surface-container-high` subtle hover state.

### Interactive Cards & Lists
*   **The No-Divider Rule:** Forbid the use of horizontal rules between list items. Use **Vertical White Space** (16px or 24px) to separate transit lines. 
*   **Visual Grouping:** Use a `surface-container-low` background "pill" to group related items (e.g., all stops on a specific line).

### Form Inputs
*   **Style:** Soft, `md` corners (0.75rem). Use `surface-container-lowest` as the fill color to pop against the `surface` background.
*   **Focus State:** A 2px "Ghost Border" of `primary` at 40% opacity. No harsh outlines.

### Transit-Specific Components
*   **The Live-Progress Track:** A vertical or horizontal bar using `primary_fixed_dim`. The "current location" indicator should be a `primary` pulse with a `10px` blur glow.
*   **Ticket QR Container:** Use a Glassmorphic "frosted" card that overlays the map, ensuring the user feels their ticket is "on top" of their journey.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical margins. A larger left-hand margin for headlines creates a sophisticated, editorial "gut" in the layout.
*   **Do** use `primary` green for success and "Go" actions, but rely on `tertiary` (#9b403e) for alerts to maintain a professional, balanced palette.
*   **Do** maximize touch targets. Every interactive element should have a minimum hit area of 48x48dp, even if the visual asset is smaller.

### Don't
*   **Don't** use 100% black text. Always use `on_surface` (#191c1e) to maintain a premium, softer contrast.
*   **Don't** use standard "drop shadows." If a card doesn't look separated enough through color alone, increase the background contrast before reaching for a shadow.
*   **Don't** cram information. If a screen feels full, use a "Surface Slide" (a nested scrolling container) to hide secondary data.

---

## 7. Roundedness Scale
*   **Default (0.5rem):** Standard UI elements (Tooltips).
*   **MD (0.75rem):** Form inputs and small cards.
*   **LG (1rem):** Main content cards and feature blocks.
*   **XL (1.5rem):** Primary Buttons and high-level containers (The "Friendly" signature).
*   **Full (9999px):** Status chips and badges.