## MODIFIED Requirements

### Requirement: Resume session
The system SHALL detect the most recently opened library book at app launch and
open it automatically, and SHALL normalize persisted reader settings before
restoring or migrating them into an active session.

#### Scenario: Resume saved session
- **WHEN** the app launches with a persisted last-opened book
- **THEN** the active text, current word index, progress, and valid settings are
  restored from that book

#### Scenario: Resume book with malformed settings
- **WHEN** a persisted book contains settings outside supported reader ranges
- **THEN** each malformed setting is replaced with the nearest supported value
  before the book becomes active
- **AND** valid settings and reading progress remain intact

#### Scenario: Migrate legacy saved session
- **WHEN** the app launches with an old single-session save
- **THEN** the save is converted into a library book or merged into the matching
  existing book
- **AND** the restored library book opens at the legacy word index with
  normalized legacy settings

#### Scenario: Malformed legacy settings payload
- **WHEN** a legacy session contains settings values outside supported ranges
- **THEN** migration uses normalized settings without crashing

#### Scenario: Start fresh
- **WHEN** the library is empty
- **THEN** the default reader state remains active and no resume prompt is shown

### Requirement: Settings persistence in session
The system SHALL persist all reader settings per book needed to reproduce
playback timing and display after reopening that book, and SHALL expose only
supported finite values to session and UI consumers.

#### Scenario: Restore settings
- **WHEN** a book saved at 450 WPM with punctuation pauses disabled is reopened
- **THEN** the reader uses 450 WPM and punctuation pauses remain disabled for
  that book

#### Scenario: Restore extreme numeric settings
- **WHEN** persisted settings contain integer extrema or non-finite or
  out-of-range floating-point values
- **THEN** the restored settings use supported finite control values
- **AND** rendering, normalization, and playback do not trap
