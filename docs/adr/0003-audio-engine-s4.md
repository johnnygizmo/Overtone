# ADR 0003: Audio engine (spike S4)

Status: accepted; manual listening and device checks still open

## Decision

A small custom Web Audio engine (`web/js/overtone_audio.js`) behind a Dart
`WebAudioEngine` that follows the `SoundSource` interface in PLAN.md 8.1.

- Whole sequences are scheduled at once on the audio clock (`start + t`).
  No Dart timers are used for note timing.
- Voice: five sine partials, 6 ms attack, slow decay, 50 ms release.
- Output chain: group gain, master gain, dynamics compressor, soft clipper
  (output is always below 1.0).
- `stop(id, {at, fadeMs})` fades a group out (default 15 ms) and stops its
  oscillators, so a new question can replace playback cleanly.
- `unlock()` creates/resumes the context; call it from a user gesture.

## Evidence (offline render at 44.1 kHz, `OvertoneAudio.selfTest()`)

| Check | Result |
|---|---|
| Pitch of A4 | 440.0 Hz |
| Harmonic fifth | C4 and G4 present; 63x stronger than E-flat4 |
| Four-note loud chord peak | 0.66 |
| Sixteen-note pile-up peak | 0.79 |
| Max sample step, replacement with 15 ms fade | 0.016 |
| Max sample step, hard cut at a waveform peak | 0.069 (the click we avoid) |
| Max sample step, steady note | 0.022 |
| Groups left after stop | 0 |
| Onset error | +6.0 ms, constant |

The constant 6 ms is the compressor's built-in lookahead delay. It does not
vary between notes, so intervals and rhythm are unaffected. Allow for it if
audio must line up with a visual cue, or drop the compressor if the soft
clipper alone proves sufficient.

Real-time context in Electron Chromium: `baseLatency` 10 ms, `outputLatency`
40 ms, sample rate 44.1 kHz, clock advanced in step with wall time.

## Not verified here

- Whether the sound is pleasant. Listen with the buttons on the S4 page.
- Autoplay policy behaviour in real Chrome, Firefox, and Edge (the test
  browser permitted autoplay).
- Android Chrome latency and any glitches on phones.
- Safari/iOS (out of scope for v1).

## Follow-ups

- `Interval` and `Chord` need to produce `PlaybackEvent` lists that the
  scheduler turns into this engine's note arrays (M3).
- Decide whether to keep the compressor once real chord voicings are in.
