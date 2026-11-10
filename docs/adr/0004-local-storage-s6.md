# ADR 0004: Local storage (spike S6)

Status: accepted for the MVP

## Decision

Use `sembast_web` (IndexedDB) behind the `AttemptStore` interface. Keep
attempt records small (about 310 bytes each in the benchmark) and plan
roll-ups of old attempts if a profile grows past roughly 20,000 records.

## Evidence

Release build, Chromium, records shaped like the planned `AttemptRecord`.

| Attempts | Bulk insert (1000/batch) | Single append | Query one skill | Export to JSON | Reopen from IndexedDB | Import into a fresh DB |
|---|---|---|---|---|---|---|
| 5,000 | 3.4 s | about 1.3 ms | 9 ms | 66 ms (1.6 MB) | 0.27 s | 2.3 s |
| 10,000 | 4.6 s | about 1.6 ms | 16 ms | 125 ms (3.1 MB) | 0.47 s | 4.6 s |
| 50,000 | 15 to 37 s | about 2.9 ms | 60 to 80 ms | 0.7 s (15 MB) | 2.5 s | 27 to 44 s |

- Batches of 5,000 were faster than 1,000 for bulk work.
- Clearing a store and re-inserting 50,000 records took 86 s; importing into
  a freshly created database took 27 to 44 s. Import must create a new
  database rather than clear the existing one.
- sembast keeps the data set in memory and filters in Dart, so query time
  grows with the number of attempts.

## Consequences

- Normal use (a few thousand attempts, one write per answer) is fast.
- The import path needs a progress indicator for large files.
- Roll up attempts older than N days into per-skill summaries and keep the
  export format able to carry both.
- Revisit (for example `idb_shim` with indexes) if real profiles exceed 50,000
  attempts.
