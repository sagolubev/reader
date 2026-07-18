# reader-library Specification

## Purpose
Define local multi-book persistence, selection, progress preservation, and
deletion behavior.
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

### Requirement: Add book from library
The system SHALL expose an add-book action from the library that starts the
system file selection flow for importing a book file.

#### Scenario: Empty library add action
- **WHEN** the user opens the library and no books exist
- **THEN** the library shows a visible add-book action

#### Scenario: Populated library add action
- **WHEN** the user opens the library and one or more books exist
- **THEN** the library shows a visible add-book action without hiding existing
  books

#### Scenario: Start add-book flow
- **WHEN** the user taps the library add-book action
- **THEN** the system opens the document picker directly for supported book
  files
- **AND** the system does not present the `Load Content` sheet

#### Scenario: Cancel file selection
- **WHEN** the user cancels document picker selection from the library add-book
  action
- **THEN** the library remains open with its existing books unchanged

#### Scenario: Complete add-book flow
- **WHEN** the user selects a supported PDF or EPUB file from the library
  add-book flow
- **THEN** the system imports the file, persists the content as a new library
  book, and opens it in the reader
