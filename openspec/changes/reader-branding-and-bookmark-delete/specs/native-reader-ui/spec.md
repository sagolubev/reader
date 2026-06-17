## MODIFIED Requirements

### Requirement: Main reader surface
The system SHALL present a warm SwiftUI reader surface with a centered word
display, red ORP highlight, progress, playback controls, library navigation,
bookmark controls, and branded default empty-library content.

#### Scenario: Initial reader screen
- **WHEN** the app launches without an open book
- **THEN** the reader surface shows the Russian RSVP default text and an obvious
  way to add or open a book

### Requirement: App branding
The system SHALL present the app as `Быстрочиталка` on iOS and use the approved
RSVP icon.

#### Scenario: iOS app identity
- **WHEN** the app is installed on iOS
- **THEN** the home screen display name is `Быстрочиталка`
- **AND** the app icon uses the warm graphite/paper RSVP mark with a red ORP
  letter and separated red vertical guide segments
