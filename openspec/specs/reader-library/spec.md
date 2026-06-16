# reader-library Specification

## Purpose
TBD - created by archiving change reader-library-bookmarks. Update Purpose after archive.
## Requirements
### Requirement: Local book library
The system SHALL persist multiple imported books locally and expose them as a
library.

#### Scenario: Import creates library book
- **WHEN** the user imports or loads readable content
- **THEN** the system creates a persisted book with title, source type, text,
  word count, reading position, settings, and timestamps

#### Scenario: Library lists books
- **WHEN** persisted books exist
- **THEN** the library shows each book with title, word count, and reading
  progress

### Requirement: Open book from library
The system SHALL allow users to open any persisted book from the library.

#### Scenario: Open saved book
- **WHEN** the user selects a book in the library
- **THEN** the reader loads that book text, saved position, and saved settings

#### Scenario: Switch books preserves progress
- **WHEN** the user switches from one book to another
- **THEN** the previous book progress and settings are saved before the selected
  book opens

### Requirement: Last opened book
The system SHALL remember the most recently opened book.

#### Scenario: Launch with books
- **WHEN** the app launches and a last-opened book exists
- **THEN** the reader opens that book at its saved position

#### Scenario: Launch without books
- **WHEN** the app launches with an empty library
- **THEN** the app shows the default reader state and makes adding a first book
  available

### Requirement: Book deletion
The system SHALL allow deleting a persisted book from the library.

#### Scenario: Delete book
- **WHEN** the user deletes a book with the row swipe action or long-press
  context menu
- **THEN** the book, its saved progress, settings, and bookmarks are removed
  from the library

#### Scenario: Delete active book
- **WHEN** the active book is deleted
- **THEN** the reader opens the next most recently opened book or returns to the
  default empty-library state
