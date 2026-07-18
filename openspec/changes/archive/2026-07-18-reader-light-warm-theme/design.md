## Context

Reader currently hard-codes dark colors in multiple SwiftUI files. Main reader
surfaces use `Color.black`, primary text uses `.white`, and modal sheets force
`.preferredColorScheme(.dark)`. A light theme needs to stay consistent across
all reader surfaces without scattering new hard-coded color values.

## Design

Introduce a small `ReaderTheme` type in `Reader/App/` with semantic color names:
background, primary/secondary text, accent, progress track, text input surface,
control fills, and control foregrounds. SwiftUI views consume these semantic
colors instead of direct black/white values.

Introduce `ReaderThemeMode` with `lightWarm` and `dark`. `ReaderView` stores the
selected mode with `@AppStorage`, applies the corresponding preferred color
scheme, and passes the current mode plus a toggle action to `ReaderHeaderView`.
The header exposes an icon-only theme toggle with accessibility identifier
`reader.toggle-theme`.

The default theme is light and warm:

- Background: warm off-white paper tone.
- Primary text: dark warm charcoal.
- Secondary text: muted brown-gray.
- Accent: existing reader red for ORP, progress, toggles, and active items.
- Controls: subtle warm filled circles for secondary actions and a dark primary
  circle for the play button.

Sheets keep their existing structure but switch to the same background and light
system color scheme. Lists keep transparent scroll backgrounds so the warm
surface remains visible.

## Decisions

### Header button instead of settings-only toggle

Theme switching is a frequent visual preference and should be reachable without
opening settings. The button lives with the existing reader header actions and
is hidden in focus mode with other nonessential header controls.

### Keep red reading accent

The red ORP marker is part of the reader's identity and remains high contrast
on the warm background. The same accent is used for progress and selected
settings controls.

### Centralize colors, not layout

This is a visual theme change. The existing layout is kept intact to reduce the
risk of reintroducing overlaps in the RSVP word, progress, and control stack.

## Risks

- Low-contrast text or controls on the warm background -> source guards and
  simulator screenshots check that primary text is dark and surfaces no longer
  force a dark scheme.
- Header crowding on smaller phones -> keep the icon compact and verify the
  reader surface on the simulator after the change.
- Missed hard-coded dark surfaces -> source tests cover app view files for
  `Color.black.ignoresSafeArea()` and forced dark color scheme.
