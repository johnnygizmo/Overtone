# PROJECT.md

# Open Music Learning Platform
**Title**: Overtone
**Tagline**: More than the notes

**Status:** Initial technical planning document\
**Primary platform:** Flutter Web\
**Initial hosting target:** GitHub Pages\
**Content model:** Markdown notes with YAML frontmatter (authored in Obsidian) + external musical
assets\
**Monetization principle:** Core learning content and training remain
free. Version 1 offers a Patreon/donation link only; advertising is deferred (see 4.3). 
**License:** code under MIT or Apache-2.0; content under CC BY-SA (see section 14).

------------------------------------------------------------------------

## 1. Project vision

Build a web-based music learning application that helps people become
more capable, confident musicians. It should combine:

-   Music theory education
-   Aural skills and ear training
-   Practical instrument knowledge
-   Fretboard and keyboard understanding
-   Rhythm and time
-   Harmony, chords, scales, and progressions
-   Quizzes, flashcards, and focused practice
-   Progress tracking and adaptive recommendations

The product is an overall music-learning environment, not simply a
collection of quizzes or a drill toy. Lessons should explain musical
ideas, while practice tools help learners hear, recognize, understand,
and apply those ideas.

The app should accommodate beginners, intermediate learners, and
advanced musicians. Users should be able to explore topics according to
their interests rather than being forced through one fixed curriculum.
The application should offer sensible starting points and
recommendations based on a learner's current knowledge, goals, and
demonstrated strengths and weaknesses.

### Product principles

1.  **Accessible learning:** Essential lessons and training should not
    be hidden behind a paid tier.
2.  **Learning over engagement tricks:** Progress indicators and
    challenges should support genuine learning rather than encourage
    empty streak-chasing.
3.  **Flexible learning paths:** Users can choose what to study while
    receiving helpful suggestions.
4.  **Practice with context:** Drills should connect to concepts
    explained in lessons.
5.  **Content-driven architecture:** New lessons, examples, and exercise
    sets should be addable without recompiling the application.
6.  **Musical correctness:** Theory, notation, playback, and answer
    evaluation should be based on explicit musical models rather than ad
    hoc string comparisons.
7.  **Progressive complexity:** A concept should be teachable at a basic
    level and expandable to more advanced treatment.
8.  **Private:** Progress is stored locally in the user's browser and can be exported to a JSON file on their
    computer, not in the cloud

------------------------------------------------------------------------

## 2. Product scope

### 2.1 Initial subject areas

The content taxonomy should be extensible. Initial subject areas may
include:

  -----------------------------------------------------------------------
  Area                                Example topics
  ----------------------------------- -----------------------------------
  Fundamentals                        Pitch, notes, staff, clefs,
                                      accidentals, enharmonic spelling

  Intervals                           Interval names, qualities, sizes,
                                      inversion, melodic and harmonic
                                      intervals

  Scales and modes                    Major, natural minor, harmonic
                                      minor, melodic minor, modes,
                                      pentatonics

  Chords                              Triads, seventh chords, extensions,
                                      suspensions, inversions, voicings

  Harmony                             Diatonic harmony, Roman numerals,
                                      chord function,
                                      tonic/predominant/dominant

  Progressions                        Common progressions, cadences,
                                      harmonic analysis, progression
                                      recognition

  Rhythm                              Note values, rests, meter,
                                      subdivisions, syncopation,
                                      polyrhythm

  Ear training                        Interval, chord, inversion, scale,
                                      bass movement, cadence, and
                                      progression recognition

  Fretboard                           Note locations, intervals, scales,
                                      chord shapes, CAGED and other
                                      mapping systems

  Keyboard                            Note locations, intervals, scales,
                                      chord construction, inversions,
                                      voicings

  Reading                             Sight reading, rhythm reading,
                                      notation recognition

  Musicianship                        Transposition, harmonization,
                                      melodic dictation, improvisation
                                      concepts, practical application
  -----------------------------------------------------------------------

These are candidate areas, not a commitment to implement all of them in
the first release.

### 2.2 Learning modes

The application should support several complementary modes:

-   **Learn:** Structured explanations and examples.
-   **Explore:** Browse subjects and related concepts without following
    a prescribed sequence.
-   **Train:** Repeated skill practice, especially aural recognition.
    MIDI keyboard input is a future enhancement (Web MIDI is unavailable in Safari and iOS).
-   **Quiz:** Assess understanding across a topic or several topics.
-   **Flashcards:** Rapid recall of terminology, notation, chord
    formulas, functions, and other facts.
-   **Apply:** Connect theory to an instrument, score, keyboard,
    fretboard, or musical example.
-   **Review:** Revisit concepts that are weak, overdue, or recently
    missed.

### 2.3 User experience goals

A learner should be able to:

-   Identify their experience level and interests.
-   Receive suggested starting topics.
-   Browse the full subject catalogue.
-   Begin a lesson and move directly into relevant practice.
-   Launch a focused drill without taking a lesson first.
-   Adjust difficulty and exercise settings where appropriate.
-   See which skills are improving and which need more work.
-   Return to a previous lesson or practice session.

------------------------------------------------------------------------

## 3. Architectural direction

### 3.1 Core architecture principle

Treat the Flutter application as a **learning engine and renderer**, not
as a hard-coded collection of courses.

The application provides reusable capabilities:

-   Load and validate content.
-   Render lesson documents.
-   Render musical notation and diagrams.
-   Generate and play musical examples.
-   Run exercise types.
-   Evaluate responses.
-   Record skill evidence and progress.
-   Save users progress to a downloadable/uploadable file.
-   Recommend next steps.

Content files describe what to teach and what material to use. The app
interprets those files through known renderers and exercise engines.

Adding a new lesson, new question set, new chord example, or new
progression should normally require only adding or updating content
files and publishing the updated content. It should not require
recompiling the Flutter application.

Content is authored as an Obsidian vault of Markdown notes. Wikilinks and folder structure express relationships; the Dart content CLI (section 12) turns the vault into the
JSON index the app loads at runtime.

### 3.2 Separate content from application code

Keep these concerns separate:

1.  **Content data:** Subjects, lessons, exercise definitions, prompts,
    answers, explanations, metadata.
2.  **Musical domain model:** Notes, intervals, scales, chords, keys,
    meters, progressions, notation events.
3.  **Presentation:** Markdown, notation, fretboard, keyboard, audio
    controls, diagrams.
4.  **Exercise runtime:** Question generation, input handling,
    evaluation, feedback, session flow.
5.  **Learner model:** Skill evidence, mastery estimates, history,
    preferences, recommendations.
6.  **Infrastructure:** Hosting, content loading, persistence,
    analytics, and advertising.

Avoid putting lesson-specific rules or musical facts directly into
widgets.

### 3.3 Suggested high-level component layout

``` text
Flutter Application
|
+-- App Shell
|   +-- Navigation
|   +-- Dashboard
|   +-- Subject Browser
|   +-- Lesson View
|   +-- Practice View
|   +-- Progress View
|
+-- Content System
|   +-- Manifest Loader
|   +-- JSON Models
|   +-- Content Repository
|   +-- Content Validator
|   +-- Markdown Renderer
|   +-- Asset Resolver
|
+-- Music Domain
|   +-- Pitch and Note Model
|   +-- Interval Model
|   +-- Scale Model
|   +-- Chord Model
|   +-- Key and Harmony Model
|   +-- Rhythm Model
|   +-- Instrument Models
|
+-- Rendering
|   +-- Notation Renderer
|   +-- Chord Diagram Renderer
|   +-- Fretboard Renderer
|   +-- Keyboard Renderer
|   +-- Audio Player
|
+-- Exercise Runtime
|   +-- Exercise Registry
|   +-- Question Generator
|   +-- Response Input
|   +-- Answer Evaluators
|   +-- Feedback
|   +-- Session Manager
|
+-- Learner Model
    +-- Skill Registry
    +-- Attempt History
    +-- Mastery Estimator
    +-- Recommendation Engine
    +-- Progress Summaries
```

This is a conceptual separation. It does not require every component to
become its own package or service.

------------------------------------------------------------------------

## 4. Technology and platform considerations

### 4.1 Flutter and Dart

Flutter is the proposed application framework.

Benefits:

-   One primary codebase for web and potential mobile versions.
-   Reusable UI and exercise components.
-   Strong support for custom interactive widgets.
-   Dart can host the music theory domain model and exercise logic.
-   Potential future packaging for Android, iOS, and desktop.

Technical items to validate early:

-   Flutter Web audio playback and browser autoplay restrictions.
-   Low-latency audio scheduling and timing accuracy.
-   Browser support for Web Audio APIs and any required JavaScript
    interop.
-   Responsive layouts for desktop, tablet, and mobile.
-   Accessibility and keyboard navigation.
-   Deep links and refresh behavior when hosted on GitHub Pages.
-   Persistence behavior in private browsing and when browser storage is
    cleared.

Do not assume that audio timing on the web will be equivalent to native
audio. Prototype the intended exercises in actual target browsers.

### 4.2 Hosting: GitHub Pages

GitHub Pages is a reasonable initial static hosting option.

The application and its published content can be deployed as static
assets. A content update can be published by updating the repository and
triggering a deployment without changing application code, provided the
content schema and supported renderer types remain compatible.

Considerations:

-   Configure Flutter's web base path correctly for the GitHub Pages
    repository URL.
-   Ensure client-side routing works on refresh and direct navigation.
-   Prefer path-safe asset references relative to a known content root.
-   Configure caching so content updates do not leave users with stale
    JSON or media.
-   Keep content version information in the manifest.
-   Do not put secrets, private credentials, or privileged API keys in
    the client application or repository.
-   GitHub Pages is static hosting; it does not provide a database,
    authentication service, or server-side API.

A future backend may be needed for cross-device accounts, cloud
synchronization, shared classrooms, or server-side analytics. Do not
require one for the first usable version unless a concrete feature
demands it.

### 4.3 Monetization



The intended model is free access to the meaningful learning experience.

Initial versions should only have links to Patreon for donations, not
ads.

https://patreon.com/johnnymatthews


Deferred advertising approach (not part of version 1):

-   Use a small, unobtrusive ad placement in selected navigation or
    browsing areas.
-   Keep advertisements out of active listening, playback, quizzes, and
    timed exercises.
-   Avoid forced video ads and disruptive interstitials.
-   Do not make educational content or practice volume conditional on
    payment.
-   Revisit ad placement based on usability and actual revenue, not
    assumptions.
-   Donations via Patreon remain the primary support mechanism. 

Important platform distinction:

-   **Google AdSense** is the relevant Google advertising product to
    investigate for a web application.
-   **Google AdMob** is primarily intended for mobile applications. It
    may become relevant if native mobile versions are released.
-   Advertising eligibility, policy compliance, consent requirements,
    and revenue should be verified before implementation.
-   Do not make the application dependent on ad revenue to function.

------------------------------------------------------------------------

## 5. Content system

### 5.1 Content formats

Use different formats for different jobs:

  -----------------------------------------------------------------------
  Format                              Responsibility
  ----------------------------------- -----------------------------------
  Markdown + YAML frontmatter         All authored content: lessons,
                                      exercise sets, flashcard sets,
                                      skills, reference data, glossary,
                                      instruments. Frontmatter holds
                                      structured data; the body holds prose

  Generated JSON                      Build output only: manifest, search
                                      index, resolved links. Never
                                      hand-edited

  MusicXML                            Portable, structured musical
                                      notation

  MIDI                                Musical event and playback material
                                      where appropriate

  Audio files                         Recorded examples or reference
                                      audio when synthesis is not
                                      appropriate

  SVG, PNG, JPG, WebP                 Diagrams and illustrations embedded
                                      in lessons

  Instrument notes                    Fretboard, keyboard, and
  (Markdown + frontmatter)            instrument-specific layouts
  -----------------------------------------------------------------------

Authors write Markdown only. Structured data goes in YAML frontmatter,
prose goes in the note body, and JSON exists only as generated build
output. Complex exercise definitions stay in frontmatter rather than
being forced into prose.

### 5.2 Content manifest

The content CLI (section 12) generates `manifest.json` and index files
from the authored notes. Authors never edit them by hand.

Illustrative generated output:

``` json
{
  "schemaVersion": 1,
  "contentVersion": "0.1.0",
  "title": "Music Learning Content",
  "subjects": [
    {
      "id": "theory",
      "title": "Music Theory",
      "path": "theory/theory.md"
    },
    {
      "id": "ear-training",
      "title": "Ear Training",
      "path": "ear-training/ear-training.md"
    },
    {
      "id": "rhythm",
      "title": "Rhythm",
      "path": "rhythm/rhythm.md"
    }
  ]
}
```

The application loads the manifest first, then loads index entries and
note bodies on demand.

### 5.3 Content hierarchy

A possible hierarchy:

``` text
Content
  Subject
    Category
      Topic
        Lesson
        Exercise Sets
        Flashcard Sets
        Examples
```

Not every subject needs every level. Avoid making the hierarchy rigid if
it creates unnecessary nesting.

**Folder structure is the source of truth for hierarchy.** Each folder
of type subject, category, or topic contains exactly one note of the
matching `type` describing that folder. A lesson's subject, category, and
topic are derived from where it sits, so authors do not have to type
them. If a note does declare `subject`, `category`, or `topic` in
frontmatter, the value must match its folder; a mismatch is a validation
error.

Use stable IDs that do not depend on display names. Display names can
change; IDs should remain stable so references and learner progress do
not break.

### 5.4 Example directory structure

``` text
content/                              (Obsidian vault root)
  manifest.json                        generated
  index/                               generated (search index, link graph)

  _templates/                          Obsidian templates, one per note type
    lesson.md
    exercise-set.md
    flashcard-set.md
    skill.md

  skills/
    interval-recognition.md            type: skill
    chord-quality-recognition.md

  reference/
    interval-types.md                  type: reference
    chord-types.md
    glossary.md
    exercise-presets.md

  instruments/
    guitar.md                          type: instrument (tunings, layout)
    piano.md

  theory/
    theory.md                          type: subject
    harmony/
      harmony.md                       type: category
      triads/
        triads.md                      type: topic
        major-triads-introduction.md   type: lesson
        major-triad-identification.md  type: exercise-set
        triad-terms.md                 type: flashcard-set
        media/
          major-triad.musicxml
          c-major-triad.mp3
          triad-construction.svg

  ear-training/
    ear-training.md                    type: subject
    ear-intervals/
      ear-intervals.md                 type: topic
      interval-recognition-basic.md    type: exercise-set

  shared/
    notation/
    audio/
    images/
```

Rules:

-   **Filename equals ID.** `major-triads-introduction.md` has
    `id: major-triads-introduction`. The `type` field in frontmatter
    says what kind of note it is; there are no type suffixes in
    filenames.
-   **IDs are unique across the whole vault**, so `[[id]]` wikilinks
    resolve unambiguously in Obsidian and in the app.
-   **Folder notes.** Subject, category, and topic folders each contain
    one note, named the same as its ID, describing the folder.
-   **Folder names are free-form.** Only nesting matters for hierarchy,
    so folders can be renamed or reorganized without changing IDs.
-   **Media lives anywhere.** Keep media beside the content that owns it
    (for example in a `media/` folder) or in `shared/`. Embeds resolve by
    filename; two media files with the same name are a validation error.
-   **One file per item** is the canonical form: one lesson per file,
    one skill per file. Exercise sets and flashcard sets are a single
    file that groups many questions or cards.

### 5.5 Note metadata (frontmatter)

Every note begins with YAML frontmatter. Illustrative lesson
(`major-triads-introduction.md`):

``` markdown
---
type: lesson
id: major-triads-introduction
title: Introduction to Major Triads
description: Understand the construction and sound of major triads.
difficulty: beginner
estimatedMinutes: 6
objectives:
  - identify the root, third, and fifth
  - explain the major triad interval formula
  - recognize a major triad by sound
prerequisites:
  - understanding-pitch
  - understanding-intervals
exercises:
  - major-triad-identification
skills:
  - chord-quality-recognition
tags:
  - harmony
  - chords
  - triads
---

# Introduction to Major Triads

Lesson prose starts here.
```

Subject, category, and topic are not listed; they come from the folder
(see 5.3). References to other notes use plain IDs in frontmatter.
Wikilinks (`[[id]]`) are accepted in both frontmatter and body.

The content CLI reads this metadata to build the index used for
browsing, search, recommendations, prerequisites, and progress
summaries.

Each note type has an Obsidian template in `_templates/` with all
required properties pre-filled, so authors fill in values rather than
remembering field names.

### 5.6 Markdown lesson authoring

Markdown should support ordinary instructional formatting:

-   Headings
-   Paragraphs
-   Bold and italic emphasis
-   Ordered and unordered lists
-   Tables
-   Block quotes
-   Links
-   Wikilinks to other notes (`[[id]]`, `[[id|label]]`)
-   Obsidian callouts (`> [!note]`)
-   Inline code
-   Embedded images, SVG, and audio (see below)
-   Mathematical notation, if a suitable renderer is selected
-   Custom musical blocks

Obsidian-specific features outside this list (plugins, Dataview, canvas)
are not rendered by the app. The validator reports them as warnings so
authors know they will not appear.

#### Embedded media

Obsidian embed syntax is supported, as is standard Markdown image
syntax:

-   Images and SVG: `![[triad-construction.svg]]` or
    `![Triad construction](media/triad-construction.svg)` render inline.
-   Audio: `![[c-major-triad.mp3]]` renders an audio player. MP3 is the
    required format; other browser-supported formats (such as OGG and
    WAV) are optional.
-   Embeds resolve by filename anywhere in the vault, as in Obsidian.
    Ambiguous or missing files are validation errors.
-   Alt text or a caption is expected for images and audio, for
    accessibility.

#### Musical blocks

Musical blocks use fenced code blocks with a language tag and a YAML
body, so Obsidian shows them as readable code and the app renders them
as widgets:

```` markdown
# Building a Major Triad

A major triad contains a root, major third, and perfect fifth.

```notation
source: c-major-triad.musicxml
display: score
playback: true
```

```chord
root: C
quality: major
display: keyboard
```

```fretboard
instrument: guitar
tuning: standard
chord: C-major
```

![[c-major-triad.mp3]]

![[triad-construction.svg]]
````

The syntax above is illustrative. Select or implement a parser that can
safely recognize custom blocks and turn them into Flutter widgets.

Keep custom block types versioned and documented. Unknown block types
should fail gracefully, with a visible authoring warning in development
rather than crashing the lesson.

### 5.7 Content authoring workflow

The desired authoring workflow:

1.  Create a note from an Obsidian template (properties pre-filled).
2.  Write or revise the lesson body in Markdown.
3.  Create notation in MuseScore Studio.
4.  Export notation as MusicXML and drop it, with any images, SVG, or
    MP3 files, into the vault.
5.  Add or revise exercise sets and flashcard sets as notes with
    frontmatter.
6.  Run `overtone content build`, which validates the vault and
    regenerates the manifest and index.
7.  Preview the content in the application.
8.  Publish the updated content without recompiling the Flutter
    application, unless application code or renderer capabilities
    changed.

### 5.8 Authoring ease requirements

Adding content should require as few technical steps as possible:

-   Authors work only in Obsidian and run one command; no JSON, no
    manifest editing, no app rebuild.
-   New notes come from templates; there is no need to remember field
    names.
-   Hierarchy comes from folders; IDs come from filenames.
-   The CLI produces actionable messages (file, field, and a suggested
    fix, such as a did-you-mean for a mistyped skill or note ID).
-   `overtone content new <type> <id>` scaffolds a note for authors who
    prefer the command line.
-   Contributors can open a pull request containing only notes and
    media; CI runs the same validation.

A future content-authoring tool could provide forms, previews,
validation, and asset management. Do not make that tool a prerequisite
for the first version.

------------------------------------------------------------------------

## 6. Musical notation and MuseScore

### 6.1 Authoring

Use **MuseScore Studio** as the proposed notation authoring environment.

MuseScore can export MusicXML, which is a suitable interchange format
for notation intended to be rendered by another application.

Recommended workflow:

-   Author scores and examples in MuseScore.
-   Export MusicXML (`.musicxml` or `.xml`).
-   Store the MusicXML file alongside the lesson or example that uses
    it.
-   Reference the file from lesson metadata or a Markdown notation
    block.
-   Render the score in Flutter using a compatible notation renderer.

MuseScore's native `.mscz` files may also be retained as editable source
files for the author. The application should generally consume MusicXML
rather than depend on MuseScore's native project format.

### 6.2 Rendering options to investigate

Prototype these options rather than committing prematurely:

**Crisp Notation** - Flutter/Dart-oriented notation rendering. -
Potentially attractive because it may reduce the need for a separate
browser rendering layer. - Verify MusicXML import fidelity, maturity,
browser support, interaction features, and licensing.

**Verovio** - Music engraving toolkit with MusicXML and MEI support. -
Produces SVG and has web/WASM deployment options. - Could be integrated
through JavaScript interop or a web-specific rendering layer. - Verify
how rendered notation can communicate selection, highlighting, and
interaction back to Flutter.

**OpenSheetMusicDisplay** - Browser-based MusicXML rendering using
SVG. - Potentially useful for Flutter Web through a web integration. -
Verify integration complexity and whether it meets mobile/native future
requirements.

### 6.3 Notation requirements

The notation system should eventually support:

-   Treble and bass clefs, and other clefs as needed.
-   Key signatures and time signatures.
-   Notes, rests, accidentals, ties, and dots.
-   Chords and multiple voices.
-   Chord symbols and Roman numerals where supported.
-   Highlighting selected notes or measures.
-   Playback synchronization and playhead indication.
-   Click or tap selection of notes.
-   Exercises that ask users to identify or enter notes.
-   Optional guitar tablature.
-   Responsive rendering at different screen sizes.

Do not assume all MusicXML features will be supported by every renderer.
Create a small representative test suite of scores and evaluate each
renderer against it.

### 6.4 Interactive notation

Display-only notation is a useful first milestone. Design the notation
component API so interaction can be added later.

Potential interactions:

-   Tap a note to identify its pitch.
-   Select a note and hear it.
-   Identify an interval between two notes.
-   Fill in missing notes on a staff.
-   Construct a scale or chord on a staff.
-   Highlight notes that belong to a chord or key.
-   Compare written notation with a played audio example.

------------------------------------------------------------------------

## 7. Music domain model

A reliable music domain model is foundational. Avoid implementing theory
separately inside individual exercises.

### 7.1 Pitch and note representation

Represent pitch in a way that distinguishes sounding pitch from written
spelling.

For example, C-sharp and D-flat may sound the same in equal temperament
but can have different theoretical meanings. A model that stores only
MIDI note numbers cannot preserve that distinction.

Consider representing a written note with:

-   Letter name (A through G)
-   Accidental
-   Octave
-   Optional sounding pitch or MIDI value
-   Optional spelling/context information

The domain model should support enharmonic equivalence without erasing
spelling distinctions.

### 7.2 Intervals

Support:

-   Interval number
-   Interval quality
-   Semitone distance
-   Direction
-   Compound intervals
-   Inversion
-   Melodic and harmonic presentation

Keep interval naming and interval sound as related but distinct
concepts.

### 7.3 Scales and modes

Support:

-   Scale formulas
-   Degree names and numbers
-   Pitch collections
-   Note spelling in a key
-   Modes and parent-scale relationships
-   Scale comparison and transposition

### 7.4 Chords

Support:

-   Root
-   Quality
-   Interval formula
-   Chord tones
-   Extensions and alterations
-   Inversions
-   Voicings
-   Enharmonic spelling
-   Optional chord symbol representation

Do not treat a chord as only a list of MIDI pitches. Its theoretical
identity and voicing are separate pieces of information.

### 7.5 Harmony and progressions

Support:

-   Key context
-   Diatonic chord construction
-   Roman numeral analysis
-   Chord function
-   Cadences
-   Borrowed chords and mixture
-   Secondary dominants
-   Modulation concepts
-   Progression transposition
-   Bass movement and voice leading

Harmonic function should be represented in context. A chord symbol by
itself does not always determine a unique function.

### 7.6 Rhythm

Support:

-   Note and rest durations
-   Meter and beat grouping
-   Subdivision
-   Tempo
-   Tuplets
-   Syncopation
-   Ties
-   Accent patterns
-   Rhythm pattern generation and comparison

Use a duration representation that avoids floating-point rounding errors
where possible, such as rational beat fractions or integer ticks within
a defined resolution.

### 7.7 Instrument models

Keep instrument-specific presentation separate from abstract theory.

Potential initial instruments:

-   Piano/keyboard
-   Standard-tuned six-string guitar

Instrument definitions should include tunings, string or key ranges,
pitch mapping, and display configuration. Future instruments should be
addable through data where practical.

------------------------------------------------------------------------

## 8. Audio and ear-training engine

Audio is a core capability, not an optional decoration.

### 8.1 Exercise types

Initial ear-training candidates:

-   Interval recognition
-   Chord quality recognition
-   Chord inversion recognition
-   Chord type and extension recognition
-   Scale and mode recognition
-   Bass-note recognition
-   Chord progression recognition
-   Cadence recognition
-   Melodic dictation
-   Harmonic versus melodic interval comparison
-   Relative pitch exercises

### 8.2 Sound generation

Investigate a playback engine that can generate examples from structured
musical data.

Potential requirements:

-   Play single notes and note sequences.
-   Play simultaneous notes as chords.
-   Play progressions with configurable tempo and rhythm.
-   Select instrument timbre.
-   Control note duration, velocity, and articulation.
-   Support repeat and replay settings.
-   Avoid clipping and manage output levels.
-   Stop or replace playback cleanly when a new question begins.

A synthesizer or sample-based engine may be used. The architecture
should separate the requested musical event from the chosen sound
source.

### 8.3 Browser audio considerations

Prototype early:

-   Browser user-gesture requirements before audio starts.
-   AudioContext lifecycle and resume behavior.
-   Scheduling accuracy.
-   Latency and timing consistency.
-   Device and browser differences.
-   Mobile browser behavior.
-   Volume control and clipping prevention.
-   Accessibility alternatives for audio-only tasks.

Do not rely on ordinary UI timers for precise musical scheduling. Use an
audio scheduling mechanism designed for playback timing.

### 8.4 Exercise configuration

Exercise definitions should describe the musical problem, not hard-code
a particular screen.

Example (`interval-recognition-basic.md`, type `exercise-set`):

``` markdown
---
type: exercise-set
id: interval-recognition-basic
exerciseType: identify-interval
title: Recognize Intervals
difficulty: beginner
skills:
  - interval-recognition
  - relative-pitch
settings:
  presentation: [harmonic, melodic]
  directions: [ascending]
  intervals:
    - minor-second
    - major-second
    - minor-third
    - major-third
    - perfect-fourth
    - perfect-fifth
    - octave
  replayAllowed: true
questionCount: 10
feedback: after-each-question
---

Optional intro text shown before the session starts.
```

This is a proposed schema. Validate exact fields and allowed values
before adopting it.

### 8.5 Exercise engine design

Use a registry of supported exercise types.

Each exercise type should define:

-   Configuration schema.
-   Question generation.
-   Presentation requirements.
-   Accepted response format.
-   Answer evaluation.
-   Feedback generation.
-   Skill evidence emitted after an attempt.

A new content set should be creatable by configuring an existing
exercise type. A genuinely new interaction or evaluation mechanic may
require application code, but should not require rewriting unrelated
exercise screens.

------------------------------------------------------------------------

## 9. Learner model and adaptive recommendations

### 9.1 Track skills, not just scores

A raw overall percentage is not an adequate representation of musical
ability.

Track evidence against specific skills, for example:

-   Identify a perfect fifth by ear.
-   Distinguish major and minor triads.
-   Recognize diminished triads.
-   Identify chord inversions.
-   Recognize a dominant-to-tonic progression.
-   Read notes in treble clef.
-   Locate natural notes on the guitar fretboard.
-   Recognize syncopated rhythms.

A question may contribute evidence to one or several skills.

### 9.2 Skill registry

Maintain a stable skill ID and metadata for each measurable skill.

Illustrative record (`chord-quality-recognition.md`, type `skill`):

``` markdown
---
type: skill
id: chord-quality-recognition
title: Chord Quality Recognition
parentSkill: ear-training
relatedTopics:
  - major-triads
  - minor-triads
  - diminished-triads
---

Identify chord quality by listening.
```

Skills are declared once, one note per skill in `skills/`. Lessons and
exercise sets reference skill IDs in a `skills` list. Skill IDs are the
keys of stored learner history, so a typo must not silently create a
new skill: the validator rejects unknown skill IDs with a did-you-mean
suggestion, and `overtone content new skill <id>` creates the note in
one step.

### 9.3 Attempt records

An attempt may include:

-   User or local learner ID.
-   Exercise and question IDs.
-   Skill IDs.
-   Timestamp.
-   Correct/incorrect result.
-   Response time, where useful.
-   Number of replays or hints, where useful.
-   Difficulty.
-   Relevant exercise configuration.
-   Optional confidence rating.

Collect only what is useful. Avoid collecting unnecessary personal
information.

### 9.4 Mastery estimation

Begin with a transparent, understandable model rather than an elaborate
opaque algorithm.

Potential initial factors:

-   Recent accuracy.
-   Number of attempts.
-   Difficulty of questions.
-   Recency of practice.
-   Consistency over time.
-   Hint and replay usage.
-   Performance across different question variations.

Do not label a skill mastered based on a tiny number of repeated or
nearly identical questions.

### 9.5 Adaptive recommendations

Examples:

-   A learner consistently identifies major and minor triads but misses
    diminished triads. Recommend diminished-triad recognition and a
    related lesson.
-   A learner identifies intervals in isolation but struggles to hear
    them in a progression. Recommend contextual interval practice.
-   A learner understands chord formulas but cannot identify chord
    inversions by ear. Recommend inversion training.
-   A learner has not practiced a skill recently. Suggest a short
    review.

Recommendations should explain why they are being made and remain
dismissible. Users should be able to choose a different topic.

------------------------------------------------------------------------

## 10. Progress, persistence, and user identity

### 10.1 First release persistence

Browser storage (IndexedDB) is the primary store for learner data in the
first release. It holds:

-   Preferences.
-   Completed lessons.
-   Practice history.
-   Skill estimates.
-   Last visited topic.
-   Local learner profile.

Use IndexedDB for structured data. Do not rely on small key-value
storage for an indefinitely growing attempt history.

### 10.2 No-account-first approach

Learners start without creating an account (decided).

Benefits:

-   Low friction.
-   No account system required initially.
-   Reduced collection of personal information.
-   Easier static hosting.

Limitations:

-   Progress may be device/browser-specific.
-   Clearing browser data can erase progress.
-   Cross-device synchronization is unavailable.

A future optional account or export/import mechanism could address these
limitations.

### 10.3 Data portability

Export/import is required in the first release. Progress autosaves to
the browser, and the app periodically reminds users to export it as a
single versioned JSON file. Users should be able to
back up their progress and move it to another browser or device.

Use a versioned export format so stored progress can be migrated when
the application changes.

------------------------------------------------------------------------

## 11. User interface and navigation

### 11.1 Main navigation

Proposed primary destinations:

-   Home
-   Learn
-   Train
-   Explore
-   Progress
-   Settings

Keep navigation responsive and usable on small screens.

### 11.2 Dashboard

The dashboard may include:

-   Continue learning.
-   Suggested next lesson.
-   Suggested practice based on weak skills.
-   Recently studied topics.
-   A quick practice launch.
-   Progress overview.

Avoid filling the dashboard with so many cards and metrics that the
learner cannot identify what to do next.

### 11.3 Subject browser

Support:

-   Search.
-   Subject and category browsing.
-   Difficulty labels.
-   Skill and instrument filters.
-   Prerequisite information.
-   Related topics.
-   Lesson and exercise entry points.

Do not make difficulty the only way to browse. A musician may be
advanced in harmony but a beginner at reading notation.

### 11.4 Practice interface

Practice should prioritize:

-   Clear audio controls.
-   A readable prompt.
-   Large, accessible answer targets.
-   Fast response feedback.
-   Optional explanation after an answer.
-   Replay controls where appropriate.
-   Session progress without unnecessary distractions.

Do not display advertising during active practice.

### 11.5 Accessibility

Plan for:

-   Keyboard navigation.
-   Screen-reader labels.
-   Sufficient color contrast.
-   Text scaling.
-   Non-color-only feedback.
-   Clear audio controls.
-   Alternatives for visual-only and audio-only tasks where practical.

------------------------------------------------------------------------

## 12. Content validation and authoring quality

A content-driven system needs validation tools. Otherwise, a missing
file or typo in a JSON field can become a runtime failure for learners.

Build a content validation command or development tool that checks:

-   YAML frontmatter syntax and required fields per note type.
-   Required fields.
-   Schema versions.
-   Unique IDs.
-   Valid references between subjects, topics, lessons, and exercises.
-   Missing Markdown files.
-   Missing MusicXML, audio, image, and SVG assets, and unresolved
    `![[embeds]]` and `[[wikilinks]]`.
-   Ambiguous filenames (two media files or notes with the same name).
-   Filename not equal to `id`, or declared subject/category/topic that
    disagrees with folder placement.
-   Unsupported Obsidian syntax (warning only).
-   Unsupported custom Markdown blocks.
-   Invalid exercise types.
-   Invalid skill references, with did-you-mean suggestions.
-   Broken prerequisites.
-   Duplicate or conflicting IDs.
-   Unsupported renderer options.

Where practical, preview all content through the same rendering
components used by the app.

Add sample fixtures for each supported content type.

The validator is part of a single command-line tool, `overtone content`,
written in Dart so it shares the schemas and music domain model with the
app. Commands:

-   `overtone content validate`: check the vault and report problems.
-   `overtone content build`: validate, then generate `manifest.json` and
    the index files.
-   `overtone content new <type> <id>`: scaffold a note from a template.

CI runs `validate` on every pull request and `build` on deployment.

------------------------------------------------------------------------

## 13. Versioning and compatibility

Content and application code will evolve independently. Make this
explicit.

Recommended practices:

-   Include a `schemaVersion` in the manifest.
-   Version exercise definitions and other formats when their structure
    changes.
-   Give content stable IDs.
-   Add migrations for locally stored learner progress.
-   Define behavior for unsupported future schema versions.
-   Preserve backward compatibility when practical.
-   Document breaking changes.

If the app encounters content it cannot understand, it should show a
useful error for that item and continue loading other valid content.

------------------------------------------------------------------------

## 14. Security, privacy, and licensing

### Security

-   Treat downloaded or repository-hosted content as data, never
    executable code.
-   Do not evaluate arbitrary scripts from Markdown or frontmatter.
-   Sanitize or restrict HTML in Markdown.
-   Validate asset paths and prevent path traversal.
-   Do not embed privileged API keys in Flutter Web.
-   Avoid collecting sensitive user information without a clear need.
-   Keep dependencies current and review package licenses.

### Privacy

-   Explain what progress data is stored and where.
-   Prefer local-first progress storage initially.
-   Avoid unnecessary tracking.
-   Review advertising and analytics consent requirements for the
    intended audience and regions.
-   Provide a way to clear locally stored progress.

### Licensing

**Project licenses:**

-   App and CLI code: MIT or Apache-2.0 (choose one before the first
    public commit).
-   Lesson content: CC BY-SA.
-   Third-party assets keep their own licenses and are tracked
    individually.
-   Pull-request contributions of content are accepted under CC BY-SA.
    Document this in `CONTRIBUTING.md`.

**Third-party assets:**

Before using third-party notation renderers, sound libraries, samples,
fonts, or music datasets:

-   Verify their licenses.
-   Confirm whether commercial use is allowed, even if the app is free
    and ad-supported.
-   Preserve required attribution and notices.
-   Track the source and license of each bundled asset.
-   Do not assume a publicly accessible MusicXML or audio file is free
    to redistribute.

------------------------------------------------------------------------

## 15. Testing strategy

### Unit tests

Test the music domain model:

-   Note spelling and enharmonic relationships.
-   Interval calculation and naming.
-   Interval inversion.
-   Scale construction and transposition.
-   Chord construction and inversion.
-   Chord spelling.
-   Key and Roman numeral analysis.
-   Rhythm duration and meter calculations.

### Content tests

Test:

-   JSON schema validation.
-   Manifest loading.
-   Broken references.
-   Markdown custom blocks.
-   Asset resolution.
-   Content compatibility.

### Exercise tests

Test:

-   Question generation.
-   Randomization boundaries.
-   Answer evaluation.
-   Equivalent valid answers.
-   Difficulty configuration.
-   Skill evidence generation.
-   Session behavior.

### Integration tests

Test:

-   Content loading and navigation.
-   Lesson rendering.
-   MusicXML rendering.
-   Audio playback.
-   Exercise interaction.
-   Progress persistence.
-   Recommendations.

### Browser testing

At minimum, test current versions of:

-   Chrome (desktop and Android)
-   Firefox
-   Edge
-   Safari and iOS Safari: not supported in the first release. Known
    issues are documented but do not block release.

Audio, storage, and rendering behavior should be checked on actual
devices, not only in desktop emulation.

------------------------------------------------------------------------

## 16. Suggested development phases

These phases are intended to reduce risk. The exact order can change
after technical prototypes.

### Phase 0: Technical spikes

Build small experiments to answer the highest-risk questions:

1.  Can Flutter Web reliably load and render the generated JSON index and Markdown
    content?
2.  Which notation renderer handles the project's MusicXML examples
    best?
3.  Can the selected notation renderer support note highlighting and
    future interaction?
4.  Can browser audio generate and schedule notes, chords, and
    progressions reliably?
5.  Can the app host and resolve content correctly from GitHub Pages?
6.  Which browser storage approach is suitable for progress data?
    (IndexedDB is the working assumption; confirm it.)
7.  Can the Dart content CLI parse frontmatter, wikilinks, embeds, and
    fenced musical blocks, and can the app render the same syntax?

**Deliverable:** A small technical prototype, with renderer and audio
decisions documented.

### Phase 1: Content engine

Implement:

-   App shell and navigation.
-   Manifest loading.
-   Content models (generated index and note frontmatter).
-   Content repository.
-   Markdown rendering.
-   Asset resolution.
-   Content validation and the `overtone content` CLI.
-   Basic subject and lesson browsing.

**Deliverable:** Add and publish a new text-based lesson without
recompiling the app.

### Phase 2: Music rendering

Implement:

-   Music domain model foundations.
-   MusicXML rendering.
-   Chord diagrams.
-   Basic keyboard and fretboard diagrams.
-   Audio playback for notes and chords.

**Deliverable:** A lesson containing prose, notation, diagrams, and
playable musical examples.

### Phase 3: First exercise runtime

Implement a small number of reusable exercise types:

1.  Identify a single note.
2.  Identify an interval.
3.  Identify a triad quality.
4.  Identify a basic chord progression.
5.  Identify a rhythm pattern.

Add:

-   Question generation.
-   Response evaluation.
-   Immediate feedback.
-   Session scoring.
-   Attempt recording.

**Deliverable:** Complete practice sessions driven by exercise-set notes.

### Phase 4: Learner model

Implement:

-   Skill registry.
-   Skill evidence.
-   Basic mastery estimates.
-   Progress summaries.
-   Weak-skill identification.
-   Simple recommendations.

**Deliverable:** The app can suggest useful practice based on actual
learner performance.

### Phase 5: Broader content and instruments

Expand:

-   Lessons across beginner, intermediate, and advanced topics.
-   More chord and interval types.
-   More progression exercises.
-   Rhythm training.
-   Guitar fretboard.
-   Piano/keyboard.
-   More notation interactions.

**Deliverable:** A meaningful initial music-learning library.

### Phase 6: Publication and refinement

Implement:

-   GitHub Pages deployment.
-   Content publishing workflow.
-   Responsive design refinements.
-   Accessibility review.
-   Error reporting.
-   Privacy review.
-   Advertising, if approved and appropriate.
-   Backup/export of learner progress.

**Deliverable:** Public, free web application with a maintainable
content pipeline.

------------------------------------------------------------------------

## 17. Initial MVP recommendation

Resist the temptation to build every subject before releasing anything.

A useful first milestone would be a coherent learning path around
intervals and triads:

### Lessons

-   Understanding pitch and note names.
-   Understanding semitones and whole tones.
-   Understanding intervals.
-   Major and minor thirds.
-   Perfect fifths.
-   Constructing major and minor triads.
-   Understanding diminished triads.

### Training

-   Identify intervals by ear.
-   Compare harmonic and melodic intervals.
-   Identify major, minor, and diminished triads.
-   Identify notes in a written triad.
-   Construct a triad from a root and formula.

### Rendering

-   Markdown lesson.
-   MusicXML score.
-   Keyboard diagram.
-   Guitar fretboard diagram.
-   Generated audio examples.

### Progress

-   Track attempts by skill.
-   Identify the weakest skill.
-   Recommend a relevant lesson or exercise.
-   Persist progress locally.

This small slice exercises almost every important architectural
capability without requiring a huge content library.

------------------------------------------------------------------------

## 18. Decisions and open technical decisions

### 18.1 Decisions made

| Area | Decision |
|---|---|
| Repository | Single repo now; content kept in a `content/` vault that can be split out later |
| Content delivery | Fetched at runtime from a configurable content root URL |
| Content format | Markdown notes with YAML frontmatter only; JSON is generated build output |
| Hierarchy | Folder nesting defines subject, category, and topic; mismatches are errors |
| Filenames and IDs | Filename equals ID; IDs unique across the vault; no type suffixes |
| Granularity | One file per item; exercise and flashcard sets group many items in one file |
| Content tooling | Dart CLI `overtone content` (validate, build, new) |
| Authoring | Obsidian vault with templates; wikilinks, callouts, and embeds supported |
| Embedded media | Images, SVG, and MP3 via `![[file]]` or standard Markdown syntax |
| Musical blocks | Fenced code blocks with a language tag and YAML body |
| Skills | Registry of one note per skill; unknown skill IDs are validation errors |
| Reference data | Skills, interval/scale/chord types, instruments, glossary, and exercise presets are content, not code |
| Learner data | IndexedDB is primary; autosave plus export/import of a single versioned JSON file |
| Accounts | None in the first release |
| Platforms | Desktop, tablet, and phone browsers (Chrome, Firefox, Edge); Safari and iOS not supported initially |
| MIDI | Future enhancement; not in the first release |
| Monetization | Patreon link only in version 1; advertising deferred |
| Audience | Adults and teens, general audience |
| Licensing | Code: MIT or Apache-2.0; content: CC BY-SA |
| Localization | English only; keep UI strings extractable |
| Note names | English (C D E, major/minor) |
| Sound source | Synthesis for the MVP; samples later |
| Notation renderer | OpenSheetMusicDisplay preferred, subject to the Phase 0 spike |
| State management | Riverpod |
| Authorship | Solo now; pull requests welcome later |
| MVP | Intervals and triads slice (section 17) |

### 18.2 Still open

These should be researched or tested before the architecture is
considered settled.

  -----------------------------------------------------------------------
  Decision                            Options / question
  ----------------------------------- -----------------------------------
  Notation renderer                   Crisp Notation, Verovio,
                                      OpenSheetMusicDisplay, or another
                                      option

  MusicXML support                    Which notation features are
                                      required in the first release?

  Audio engine                        Synthesizer, sample-based playback,
                                      or hybrid

  Audio scheduling                    Best browser-compatible timing
                                      architecture

  Markdown                            Existing Flutter Markdown package
                                      extended for wikilinks, callouts,
                                      embeds, and fenced musical blocks,
                                      or a custom parser

  Math rendering                      Which math format and Flutter
                                      renderer should be supported?

  Content loading                     Load all metadata initially or load
                                      subjects and lessons on demand?

  Content updates                     Versioned manifest, cache
                                      invalidation, and refresh strategy

  Routing                             Flutter Router configuration
                                      compatible with GitHub Pages

  Search                              Client-side search initially or a
                                      generated search index

  Analytics                           Whether analytics are necessary and
                                      what minimal data is appropriate

  Advertising                         AdSense eligibility, placement,
                                      policy, and consent requirements

  Mobile                              Flutter native builds now or later
  -----------------------------------------------------------------------

Record the reasoning behind each decision. Avoid adding infrastructure
simply because it might be useful someday.

------------------------------------------------------------------------

## 19. Initial engineering principles

1.  Build reusable renderers and exercise types.
2.  Keep content separate from application code.
3.  Use stable IDs for content and skills.
4.  Keep musical theory calculations in a tested domain layer.
5.  Preserve theoretical note spelling as well as sounding pitch.
6.  Treat MusicXML as notation interchange data, not merely a source of
    images.
7.  Treat audio timing as a technical risk that deserves an early
    prototype.
8.  Make the content schema explicit and validate it.
9.  Support graceful failure for missing or unsupported content.
10. Keep the first release local-first and account-free unless a real
    requirement changes that decision.
11. Make the learning experience free and keep advertising away from
    active practice.
12. Prefer a small, complete vertical slice over a large collection of
    unfinished features.

------------------------------------------------------------------------

## 20. Immediate next steps

Recommended order:

1.  Create a Flutter Web project and publish a minimal build to GitHub
    Pages.
2.  Create a sample content vault, with Obsidian templates, containing one subject, one topic, and one
    Markdown lesson.
3.  Load and render the lesson from external content files.
4.  Create a representative MuseScore score and export it as MusicXML.
5.  Prototype at least two notation renderers against that same score.
6.  Generate and play a few notes, intervals, and triads in the browser.
7.  Define the first exercise schema and implement interval recognition.
8.  Add local attempt storage and a simple skill summary.
9.  Write the Dart content CLI (validate and build) before the content library grows.

The first architectural milestone is achieved when a learner can open a
published lesson, read it, view a real rendered score, hear the example,
complete a related exercise, and see their result---while the lesson and
exercise content remain independently editable files.

------------------------------------------------------------------------

## 21. Definition of success

The project is on the right track when:

-   A learner can enter at an appropriate level without being forced
    through a rigid course.
-   Theory, listening, rhythm, and instrument knowledge reinforce one
    another.
-   Lessons are understandable and connected to practical musical tasks.
-   Practice tools are useful independently as well as alongside
    lessons.
-   The app can identify specific weaknesses and recommend relevant
    work.
-   New content can be authored and published without recompiling the
    application.
-   Musical examples are rendered as real notation and can become
    interactive.
-   The experience remains accessible and genuinely useful without a
    subscription.
-   The architecture can grow without turning every new lesson into a
    software development task.

**The central idea:** Build a flexible music-learning engine whose
content can grow continuously, whose training adapts to the learner, and
whose essential educational value remains freely available.
