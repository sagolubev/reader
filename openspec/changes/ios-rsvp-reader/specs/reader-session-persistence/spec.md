## ADDED Requirements

### Requirement: Save session
The system SHALL save the active reading text, current word index, total word count, reader settings, and save timestamp locally on device.

#### Scenario: Save active session
- **WHEN** the user invokes save while words are loaded
- **THEN** a local saved session is written with text, position, settings, and timestamp

#### Scenario: Save without content
- **WHEN** the user invokes save without loaded words
- **THEN** no saved session is written

### Requirement: Resume session
The system SHALL detect an existing saved session at app launch and let the user resume it.

#### Scenario: Resume saved session
- **WHEN** the user chooses resume from the saved session prompt
- **THEN** the active text, current word index, progress, and settings are restored

#### Scenario: Start fresh
- **WHEN** the user chooses start fresh from the saved session prompt
- **THEN** the saved session is cleared and the default reader state remains active

### Requirement: Clear session
The system SHALL allow clearing a saved session.

#### Scenario: Clear saved session
- **WHEN** the saved session is cleared
- **THEN** the next app launch does not show a resume prompt

### Requirement: Settings persistence in session
The system SHALL persist all reader settings needed to reproduce playback timing and display after resume.

#### Scenario: Restore settings
- **WHEN** a session saved at 450 WPM with punctuation pauses disabled is resumed
- **THEN** the reader uses 450 WPM and punctuation pauses remain disabled
