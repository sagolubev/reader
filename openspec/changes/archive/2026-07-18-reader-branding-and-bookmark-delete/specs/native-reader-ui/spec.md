## MODIFIED Requirements

### Requirement: Main reader surface
The system SHALL present a SwiftUI reader surface with warm light and dark
themes, a centered word display, red ORP highlight, red center marker, progress,
playback controls, library navigation, and bookmark controls.

#### Scenario: Initial reader screen
- **WHEN** the app launches without an open book
- **THEN** the reader surface shows the default empty-library state with an
  obvious way to add or open a book

#### Scenario: ORP remains centered
- **WHEN** displayed words change during playback
- **THEN** the highlighted ORP character remains aligned to the center marker
  without layout shift

#### Scenario: Switch theme
- **WHEN** the user toggles the theme control
- **THEN** the reader switches between warm light and dark themes and persists
  the selected mode

## ADDED Requirements

### Requirement: App branding
The system SHALL present the app as `Быстрочиталка` on iOS and use the approved
RSVP icon.

#### Scenario: iOS app identity
- **WHEN** the app is installed on iOS
- **THEN** the home screen display name is `Быстрочиталка`
- **AND** the app icon uses the warm graphite/paper RSVP mark with a red ORP
  letter and separated red vertical guide segments
