## MODIFIED Requirements

### Requirement: Main reader surface
The system SHALL present a dark SwiftUI reader surface with a centered word
display, red ORP highlight, red center marker, progress, playback controls,
library navigation, and bookmark controls.

#### Scenario: Initial reader screen
- **WHEN** the app launches without an open book
- **THEN** the reader surface shows the default empty-library state with an
  obvious way to add or open a book

#### Scenario: ORP remains centered
- **WHEN** displayed words change during playback
- **THEN** the highlighted ORP character remains aligned to the center marker
  without layout shift

## ADDED Requirements

### Requirement: Library navigation
The system SHALL provide a library entry point from the reader header.

#### Scenario: Open library
- **WHEN** the user taps the library control
- **THEN** the system presents the library list without losing the active
  book's progress

#### Scenario: Select library book
- **WHEN** the user selects a book from the library
- **THEN** the library closes and the selected book opens in the reader

### Requirement: Bookmark controls
The system SHALL expose bookmark controls on the reader surface.

#### Scenario: Toggle bookmark from reader
- **WHEN** a book is open and the user taps the bookmark control
- **THEN** the current word position bookmark state toggles from a control below
  the speed controls
- **AND** the bookmark control is visually sized like the primary play control

#### Scenario: Open bookmarks from reader
- **WHEN** a book is open and the user opens the bookmarks list
- **THEN** the system presents bookmarks for the active book
