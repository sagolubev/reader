## Summary

Move the native reader UI from a dark surface to a light reading surface with a
warm paper-like background.

## Motivation

The current reader uses black backgrounds and white text throughout the reader
and supporting sheets. The next iteration should feel closer to a comfortable
book-reading surface while preserving the existing RSVP layout, controls,
progress, bookmarks, and import/library behavior.

## Scope

- Add a shared warm light theme for reader-facing SwiftUI colors.
- Add a reader header button that switches between warm light and dark themes.
- Persist the selected theme locally.
- Apply the light theme to the main reader, RSVP word display, controls, header,
  library, bookmarks, load content, settings, jump, and legacy resume surfaces.
- Keep the red ORP/progress accent.
- Keep the existing layout and controls; no theme toggle in this change.

## Out Of Scope

- No typography or playback behavior changes.
