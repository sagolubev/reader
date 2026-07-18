## MODIFIED Requirements

### Requirement: Word display frame
The system SHALL support one-word display and odd-number multi-word display
frames where the active word is centered within the frame whenever surrounding
words exist, and SHALL bound malformed frame settings to supported frame sizes.

#### Scenario: Single word mode
- **WHEN** frame word count is `1`
- **THEN** only the active word is displayed

#### Scenario: Multi-word mode
- **WHEN** frame word count is `5` and the active word has enough neighboring words
- **THEN** two preceding words, the active word, and two following words are displayed with the active word highlighted

#### Scenario: Extreme frame setting
- **WHEN** a session receives an integer-extreme frame word count
- **THEN** frame selection uses the nearest supported odd frame size
- **AND** frame calculation does not overflow or expand to the entire book

### Requirement: Reading speed and word delay
The system SHALL calculate a base word delay as `60000 / wordsPerMinute`
milliseconds, support WPM values from 50 through 1000 in 25 WPM increments, and
perform speed adjustment without integer overflow.

#### Scenario: Base delay
- **WHEN** WPM is `300` and the word is `hello`
- **THEN** the delay is `200` milliseconds

#### Scenario: Fast delay
- **WHEN** WPM is `600` and the word is `hello`
- **THEN** the delay is `100` milliseconds

#### Scenario: Adjust extreme restored speed
- **WHEN** a session contains an integer-extreme WPM value and the user changes
  speed
- **THEN** WPM becomes the nearest supported value after applying the requested
  direction
- **AND** adjustment does not overflow

### Requirement: Punctuation and long-word pauses
The system SHALL optionally extend word delay for sentence-ending punctuation,
commas, and long words using reader settings, and SHALL return a finite delay
safe for playback scheduling.

#### Scenario: Sentence punctuation pause
- **WHEN** WPM is `300`, punctuation pauses are enabled, multiplier is `2`, and the word is `word.`
- **THEN** the delay is `400` milliseconds

#### Scenario: Comma pause
- **WHEN** WPM is `300`, punctuation pauses are enabled, and the word is `word,`
- **THEN** the delay is `300` milliseconds

#### Scenario: Punctuation disabled
- **WHEN** punctuation pauses are disabled and the word is `word.`
- **THEN** punctuation does not change the base delay

#### Scenario: Long word multiplier
- **WHEN** WPM is `300`, long-word multiplier is `10`, and the word is `extraordinary`
- **THEN** the delay is approximately `220` milliseconds

#### Scenario: Extreme restored timing multiplier
- **WHEN** a session contains an extreme or non-finite punctuation or long-word
  multiplier
- **THEN** playback uses a finite delay derived from supported settings
- **AND** conversion to the scheduler duration does not trap
