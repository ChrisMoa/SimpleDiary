# ADR-002: Local-First Architecture with Optional Supabase Sync

## Status
Accepted

## Context
A personal diary application requires high reliability and privacy. Users expect their journal entries to be available instantly, work without internet, and remain private. At the same time, some users want multi-device access and cloud backup as an optional convenience.

The key tension is between a cloud-first approach (simpler sync but requires connectivity) and a local-first approach (always available but sync is more complex).

## Decision
We chose a **local-first architecture with SQLite as the primary datastore and optional Supabase sync**.

### Core design

- **All reads and writes go to local SQLite first.** The app is fully functional offline.
- **Supabase sync is optional and on-demand.** Users explicitly trigger sync from the Synchronization page; there is no automatic background sync.
- **Per-user database files:** Each user profile gets an isolated `${userId}.db` file, providing complete data separation.
- **Last-write-wins conflict resolution:** Supabase `upsert()` replaces records by primary key. No timestamp-based versioning or three-way merge.

### Sync flow

**Upload:** Local diary days, notes, and templates are batch-upserted to Supabase (batch size: 50, retry with exponential backoff up to 3 attempts).

**Download:** All records for the authenticated user are fetched and inserted locally via `addElement()` with `ConflictAlgorithm.ignore` (skips existing duplicates).

### Additional data portability

| Format | Use case |
|--------|----------|
| JSON export/import | Full data portability with optional AES-256 encryption |
| ICS export/import | Calendar app integration via iCalendar format |
| PDF export | Printable diary reports with date range filtering |
| Scheduled backups | Automatic local backups (daily/weekly/monthly) with pruning |

## Consequences

### Benefits
- **Always available:** No network dependency for daily use; the app works identically offline
- **Privacy by default:** Data stays on-device unless the user explicitly configures Supabase
- **Simple mental model:** Users understand "my data is on my phone/computer" without cloud complexity
- **Platform resilience:** Desktop platforms (Linux/Windows) work without Google/Apple cloud services
- **Data ownership:** JSON export means users can always extract their data

### Trade-offs
- **No real-time sync:** Changes on one device don't automatically appear on another; users must manually trigger sync
- **Last-write-wins can lose edits:** If the same entry is modified on two devices between syncs, the last sync overwrites the other
- **Full sync (not incremental):** Each sync operation processes all records, which is acceptable for personal diary volumes (<10K entries) but wouldn't scale to larger datasets
- **Backup scheduling differs by platform:** Android uses WorkManager for true background scheduling; desktop only checks on app startup

## Alternatives Considered

### Cloud-first (Supabase only, no local SQLite)
- Simpler sync (single source of truth) but requires constant connectivity
- Unacceptable for a diary app where users expect immediate, private access
- Would exclude offline desktop usage entirely

### CRDTs (Conflict-free Replicated Data Types)
- Elegant conflict resolution without server coordination
- Significant implementation complexity for a diary app where conflicts are rare (single-user, sequential entries)
- Library ecosystem for Dart/Flutter is immature

### Firebase / Firestore
- Mature real-time sync with offline support built in
- Vendor lock-in to Google ecosystem; conflicts with privacy-first goals
- Pricing model scales with reads/writes, unpredictable for heavy journaling

### Local-only (no sync at all)
- Simplest implementation but leaves users without any multi-device or backup option
- Adding sync later would require more architectural changes than building it optionally from the start

---

*Decided: Project inception*
*Last reviewed: 2026-02-27*
