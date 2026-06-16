## MODIFIED Requirements

### Requirement: Main reader surface
The system SHALL present a light SwiftUI reader surface with a warm background,
centered word display, red ORP highlight, red center marker, progress, playback
controls, library navigation, and bookmark controls.

#### Scenario: Initial reader screen
- **WHEN** the app launches without an open book
- **THEN** the reader surface shows the default empty-library state on a warm
  light background with dark readable text
- **AND** the screen provides an obvious way to add or open a book

#### Scenario: ORP remains centered
- **WHEN** displayed words change during playback
- **THEN** the highlighted ORP character remains aligned to the center marker
  without layout shift

#### Scenario: Warm light reader theme
- **WHEN** the reader, controls, or supporting sheets are displayed
- **THEN** they use the shared warm light theme instead of forcing black
  backgrounds or a dark color scheme
- **AND** the red ORP/progress accent remains visible on the light surface

#### Scenario: Toggle reader theme
- **WHEN** the user taps the theme toggle in the reader header
- **THEN** the reader switches between warm light and dark themes
- **AND** the selected theme is persisted for subsequent launches
