# native-reader-ui Specification

## Purpose
Define the native reader surface, themes, controls, navigation, accessibility,
and lifecycle behavior.
## Requirements
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

### Requirement: Focus mode
The system SHALL enter focus mode while playing or paused and hide nonessential header controls.

#### Scenario: Enter focus mode
- **WHEN** playback starts
- **THEN** nonessential header controls are hidden and reading controls remain available

#### Scenario: Exit focus mode
- **WHEN** the user exits focus mode
- **THEN** playback stops advancing and the current position is preserved

### Requirement: Settings UI
The system SHALL provide settings controls for WPM, fade, fade duration, punctuation pauses, punctuation multiplier, long-word multiplier, periodic pause, pause duration, and frame word count.

#### Scenario: Change WPM
- **WHEN** the user changes WPM in settings
- **THEN** subsequent word delays use the new WPM

#### Scenario: Change frame word count
- **WHEN** the user changes frame word count to an odd value greater than 1
- **THEN** the display uses multi-word frame mode

### Requirement: Touch and keyboard controls
The system SHALL support touch controls and hardware keyboard shortcuts for play/pause/resume, exit, speed adjustment, word stepping, jump, and save.

#### Scenario: Touch playback
- **WHEN** the user taps play, pause, resume, stop, or restart
- **THEN** the corresponding playback action is performed

#### Scenario: Hardware keyboard
- **WHEN** a hardware keyboard sends Space, Escape, Arrow Up, Arrow Down, Arrow Left, Arrow Right, `G`, or Command-S
- **THEN** the reader performs the matching source shortcut action

### Requirement: Progress interaction
The system SHALL allow seeking through the progress control when playback is not actively advancing.

#### Scenario: Seek while stopped
- **WHEN** playback is stopped and the user taps the progress control at 75%
- **THEN** the current word index moves to approximately 75% of total words

#### Scenario: Seek while playing
- **WHEN** playback is active
- **THEN** direct progress seeking is disabled

### Requirement: iOS lifecycle and accessibility
The system SHALL provide iOS-appropriate accessibility labels, respect Reduce Motion for fade effects, and pause playback when the app backgrounds.

#### Scenario: Reduce Motion
- **WHEN** Reduce Motion is enabled
- **THEN** word fade animation is disabled

#### Scenario: App backgrounding
- **WHEN** the app moves to the background during playback
- **THEN** playback pauses without losing the current position

#### Scenario: Accessible icon controls
- **WHEN** VoiceOver focuses an icon-only control
- **THEN** the control exposes a meaningful accessibility label

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

### Requirement: Add book from reader header
The system SHALL expose an add-book action from the main reader header that
starts the system file selection flow for importing a book file.

#### Scenario: Start reader add-book flow
- **WHEN** the user taps the main reader add-book action
- **THEN** the system opens the document picker directly for supported book
  files
- **AND** the system does not present the `Load Content` sheet

#### Scenario: Cancel reader file selection
- **WHEN** the user cancels document picker selection from the main reader
  add-book action
- **THEN** the active reader content and library remain unchanged

#### Scenario: Complete reader add-book flow
- **WHEN** the user selects a supported PDF or EPUB file from the main reader
  add-book flow
- **THEN** the system imports the file, persists the content as a new library
  book, and opens it in the reader

### Requirement: App branding
The system SHALL present the app as `Быстрочиталка` on iOS and use the approved
RSVP icon.

#### Scenario: iOS app identity
- **WHEN** the app is installed on iOS
- **THEN** the home screen display name is `Быстрочиталка`
- **AND** the app icon uses the warm graphite/paper RSVP mark with a red ORP
  letter and separated red vertical guide segments
