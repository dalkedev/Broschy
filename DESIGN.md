---
name: Broschy
description: A modernist native companion at the top edge of the Mac.
colors:
  primary-light: "rgb(71% 23% 7%)"
  primary-dark: "rgb(100% 48% 25%)"
  action: "rgb(100% 40% 19%)"
  on-action: "rgb(10% 8% 7%)"
  camera: "#000000"
  surface-light: "rgb(96% 95% 92%)"
  surface-dark: "rgb(10.5% 11% 12%)"
  raised-light: "rgb(99.5% 99% 97%)"
  raised-dark: "rgb(16% 16.5% 17.5%)"
  text-light: "rgb(12% 13% 14%)"
  text-dark: "rgb(96% 95% 92%)"
  muted-light: "rgb(37% 37% 36%)"
  muted-dark: "rgb(68% 68% 66%)"
  success-light: "oklch(0.46 0.12 155)"
  success-dark: "oklch(0.82 0.15 155)"
  failure-light: "oklch(0.52 0.16 25)"
  failure-dark: "oklch(0.78 0.14 25)"
  selection-light: "rgb(0 0 0 / 0.075)"
  selection-dark: "rgb(255 255 255 / 0.10)"
  inset-light: "rgb(0 0 0 / 0.035)"
  inset-dark: "rgb(255 255 255 / 0.035)"
  separator-light: "rgb(0 0 0 / 0.08)"
  separator-dark: "rgb(255 255 255 / 0.10)"
  keycap-light: "rgb(0 0 0 / 0.045)"
  keycap-dark: "rgb(255 255 255 / 0.07)"
  editor-light: "rgb(255 255 255 / 0.24)"
  editor-dark: "rgb(0 0 0 / 0.12)"
typography:
  timer:
    fontFamily: "SF Pro"
    fontSize: "82pt"
    fontWeight: 500
    letterSpacing: "-3pt"
    fontFeature: "tabular-nums"
  task:
    fontFamily: "SF Pro"
    fontSize: "17pt"
    fontWeight: 500
  track:
    fontFamily: "SF Pro"
    fontSize: "19pt"
    fontWeight: 600
    letterSpacing: "-0.4pt"
  title:
    fontFamily: "SF Pro"
    fontSize: "20pt"
    fontWeight: 600
    letterSpacing: "-0.4pt"
  settings-title:
    fontFamily: "SF Pro"
    fontSize: "21pt"
    fontWeight: 600
    letterSpacing: "-0.5pt"
  body:
    fontFamily: "SF Pro"
    fontSize: "12pt"
    fontWeight: 400
  note:
    fontFamily: "SF Pro"
    fontSize: "13pt"
    fontWeight: 400
  button:
    fontFamily: "SF Pro"
    fontSize: "13pt"
    fontWeight: 600
  tab:
    fontFamily: "SF Pro"
    fontSize: "11pt"
    fontWeight: 500
  metadata:
    fontFamily: "SF Pro"
    fontSize: "10pt"
    fontWeight: 400
rounded:
  keycap: "4pt"
  duration: "6pt"
  control: "8pt"
  camera: "9pt"
  editor: "12pt"
  compact: "12pt"
  preview: "14pt"
  panel: "20pt"
spacing:
  tick-gap: "3pt"
  tight: "4pt"
  compact: "8pt"
  controls: "10pt"
  row: "12pt"
  section: "18pt"
  settings-inset: "20pt"
  panel-inset: "24pt"
components:
  button-primary:
    backgroundColor: "{colors.action}"
    textColor: "{colors.on-action}"
    typography: "{typography.button}"
    rounded: "{rounded.control}"
    height: "42pt"
  button-secondary-light:
    backgroundColor: "{colors.selection-light}"
    textColor: "{colors.text-light}"
    rounded: "{rounded.control}"
  button-secondary-dark:
    backgroundColor: "{colors.selection-dark}"
    textColor: "{colors.text-dark}"
    rounded: "{rounded.control}"
  duration:
    typography: "{typography.tab}"
    rounded: "{rounded.duration}"
    padding: "8pt 15pt"
  note-editor:
    typography: "{typography.note}"
    rounded: "{rounded.editor}"
    padding: "9pt"
  artwork:
    rounded: "{rounded.control}"
    size: "72pt"
---

# Design System: Broschy

## Overview

**Creative North Star: "Modernist notch companion"**

Broschy translates Ulm-era functional graphics into a native macOS utility: a calm opaque surface, strongly differentiated typography, precise dividers and orange actions. The panel keeps five existing tasks close at hand without becoming a full application window. Its English labels, native controls and camera-aware layout remain part of the product.

This system replaces the former translucent Liquid Glass treatment. Light and Dark appearances use the same layout and hierarchy; only the palette changes. Warm ivory and graphite provide stable contrast regardless of the desktop behind the panel.

**Key Characteristics:**
- Opaque, adaptive ivory and graphite surfaces.
- Orange actions and selection, with separate green success and red failure states.
- Left-aligned task content and a large tabular timer.
- A 30-segment elapsed-time ruler and baseline tab navigation.
- Native macOS interaction, accessibility and camera geometry.

Values are extracted from `Ink` in `Views.swift`, `DesignComponents.swift` and the native views. Dimensions are macOS points, not browser pixels. This document describes implementation; it does not establish physical-notch, live Spotify or multi-display verification.

## Colors

`Ink.adaptive` supplies dynamic `NSColor` values that resolve Light and Dark appearances at render time. Use these tokens rather than resolving a theme once at launch. RGB percentages preserve native source values; success and failure preserve their OKLCH source and convert to sRGB in the renderer.

**The Action Rule.** `action` and `on-action` form the primary button pair in both themes. `primary-light` and `primary-dark` are adaptive accents for progress, selected tabs, pins and activity; they are not interchangeable with the action fill.

The camera overlay stays black. Raised surfaces, selected controls, footer inset, editor and keycaps use corresponding theme values. Success and failure also have symbols and text labels; color alone does not communicate state.

## Typography

Use native SF system fonts. Focus uses an 82-point medium countdown, tabular digits and −3-point tracking; the editable task is 17-point medium. Music titles use 19-point semibold text and may occupy two lines. Later and connection headings use 20-point semibold; Settings uses 21-point semibold. Body copy is generally 12 points, notes 13, tabs 11 and metadata 10.

The header wordmark is 12-point bold with −0.3-point tracking. Compact timings use 11-point medium monospaced text; keycaps use 9-point rounded medium. Retain native typography and SF Symbols rather than introducing a separate display font or icon font. Long compact labels truncate and expose full content through help text.

## Layout

Expanded width is at most 480 points, clamped to screen width minus 32 points. Expanded content is **380 points high**, below a header following the measured camera safe area (28-point fallback). Shared horizontal content insets are 24 points; footer vertical padding is 12. Settings is a 320-point popover with 20-point padding.

The actual camera gap stays centered between brand and utilities. Without a measured camera, retain the 180-point gap fallback. Compact height follows the positive top safe-area inset or system menu-bar thickness; do not add a lip below that band. `PanelGeometry` preserves the top anchor and clamps horizontal placement, including displays with negative origins.

Compact wings share equal width. Normal compact width is camera gap plus 128 points, or plus 248 for wide content, capped 12 points below expanded width. Preview adds up to 12 points in width and 4 in height. Compact Music, Agents and Build Watch collapse secondary text below 28 points of height. The native animation canvas adds 4 points of clearance and remains expanded until closing settles.

## Elevation & Depth

The interface is flat and opaque. `PanelMaterial` is `Ink.surface`; there is no blur, glass effect or wallpaper-dependent tint. Reduce Transparency needs no alternative treatment. A 0.5-point outline defines the panel edge; internal separation uses tonal fills and one-point dividers. Do not add shadows to individual controls.

## Shapes

`NotchShape` has a straight top and rounded bottom corners: 20 points expanded, 14 during preview and 12 at rest. The camera overlay has 9-point bottom corners. Controls and artwork use continuous 8-point corners, duration selection uses 6, keycaps 4 and the note editor 12. The selected tab is a 2-point rectangle on a 1-point baseline. The elapsed-time ruler is 4 points high, with 30 equal segments separated by 3-point gaps.

## Components

**Navigation.** Visible tabs appear in Agents, Focus, Music, Signals, Later order. Symbols and labels share one row with an accent under the selected tab. Command-1 through Command-5 select the corresponding **visible position**, remaining contiguous when tabs are hidden. Selection has an accessibility selected trait. Header controls retain Settings, menu, pin and hide actions. Control-Option-N toggles the panel; Escape hides it; Command-comma opens Settings.

**Buttons.** Primary actions use orange with dark text; secondary actions use the adaptive selection fill. `FlowButtonStyle` uses 8-point corners, a 10%-white hover overlay, 0.98 pressed scale and 0.48 disabled opacity. Quiet controls use appearance-aware hover/pressed fills, 0.94 pressed scale and 0.55 disabled opacity. Reduce Motion removes scale animation. Focus actions are 42 points high; Music's primary transport is 68 × 48 points.

**Focus.** The task field precedes countdown, status, ruler, 25/50/90-minute choices and primary action. The ruler measures elapsed time, stays empty before starting and becomes green at completion. Duration selection uses a 6-point fill and is disabled during an active session. Pause, Resume and Reset retain their existing behavior.

**Music and status lists.** Music uses 72-point artwork, a larger title, native seek/volume sliders and explicit connection/error states. Agents and Signals retain scrollable rows, contextual actions and separate attention, review and failure states. Status text remains meaningful independently of color.

**Later and Settings.** Later uses a native 13-point text editor with 12-point corners; focus changes its text-colored border opacity from 0.12 to 0.28. A placeholder and save/status count communicate empty and storage-error states. Settings uses native switches for Quiet Focus and visible tabs, preventing an empty layout.

**Brand.** `Resources/AppIcon.png` is the generated graphite tile with an ivory geometric lowercase b and orange camera-notch accent. `Resources/Broschy.icns` supplies native sizes. `StatusBarIcon.makeImage()` draws a separate 18-point vector b template; macOS controls its light, dark and selected colors. The header uses the app icon at 18 points. Provenance and regeneration are documented in `docs/ICON.md`.

**Motion and activation.** Passive hover waits 220 ms and never takes keyboard focus. Preview lasts 140 ms. Opening uses spring response 0.34, damping 0.88 and blend 0.08; closing uses response 0.26 with the same damping/blend, allowing 360 ms to settle. Generation checks invalidate obsolete transitions. Selection uses a 260 ms cubic curve `(0.22, 1, 0.36, 1)`; feedback takes 140 ms and numeric transitions 240 ms. Reduce Motion skips preview growth and open/close animation while retaining hover intent. Compact playback bars stop when paused, hidden or reduced motion is active; they are not audio analysis.

## Do's and Don'ts

- **Do** use the shared adaptive `Ink` tokens and opaque panel material.
- **Do** preserve the measured camera gap, stable top edge and native focus behavior.
- **Do** keep status labels, symbols, help text and keyboard access alongside color.
- **Do** show actual native views in portfolio captures and label sample data honestly.
- **Don't** restore decorative glass, stacked translucent cards or wallpaper-dependent contrast.
- **Don't** map tab shortcuts to persistent IDs; map them to visible positions.
- **Don't** treat a ready agent response as successful task completion.
- **Don't** claim a screenshot verifies live integrations, physical-notch placement or multi-display behavior.
