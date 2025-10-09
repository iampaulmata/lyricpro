# LyricPro Architecture

## 1. Vision & Scope
- **Purpose**: Deliver an open-source, cross-platform lyric and chord management tool tailored for live performers who rely on dependable set list control, offline access, and rich editing in the ChordPro format.
- **Platforms**: iOS, Android, macOS, Windows, Linux (desktop and tablet/phone form factors).
- **Philosophy**: Local-first experience with optional sync, accessibility-ready UI, and extensible integrations for stage hardware.

## 2. Product Goals and Non-Goals
- **Goals**
  - Provide fast song discovery, set list navigation, and live presentation controls on any device.
  - Offer a native ChordPro editor with chord highlighting, transposition, tabs, sectional notes, and performance aids (teleprompter, auto-scroll, metronome).
  - Support asynchronous collaboration with detailed version history and the ability to revert.
  - Allow complete offline use, including library browsing, editing, and performance; sync resumes when connectivity returns.
  - Make importing from Google Drive/local storage simple, with export to PDF and desktop printing.
  - Encourage community contributions via transparent architecture and permissive licensing.
- **Non-Goals (initial release)**
  - Built-in audio/video recording or DAW integration.
  - Real-time collaborative editing (simultaneous cursors).
  - Rich analytics dashboards beyond version history metadata.
  - Direct mobile printing.

## 3. Target Users & Key Scenarios
- **Primary Persona**: Lead singer or band leader responsible for set flow and lyric management during live shows.
- **Secondary Persona**: Bandmates who prepare shared set lists and contribute edits asynchronously.
- **Typical Scenarios**
  - Pre-show: Import new songs from Google Drive, tag them, build set lists, rehearse with auto-scroll and metronome.
  - During show: Master device selects songs, secondary devices sync displays via Bluetooth or local network; performer uses pedal to advance sections.
  - Post-show: Review edits made by collaborators, accept/revert changes, sync updates once connected.

## 4. Functional Requirements
- **Organization**: Nested set lists, tag/genre filters, search-as-you-type, quick favorites.
- **Editing**: WYSIWYG ChordPro editor, chord transposition, capo adjustments, inline tabs, sectional notes, syntax validation, history timeline with diff view.
- **Performance Mode**: Teleprompter view, adjustable auto-scroll tempo, manual scroll, lyric zoom, high-contrast themes, on-screen metronome, configurable layout presets.
- **Collaboration**: Share songs/set lists with authenticated users, view change history (who/what/when), revert to prior versions, optional manual merge for conflicts.
- **Import/Export**: Google Drive picker, local file picker, bulk import with metadata prompts, PDF/DOC/TXT parsing to ChordPro (best-effort), export set list/song to PDF, desktop print support.
- **Master Device Sync**: Designate master session controller, broadcast current song/position to peers, allow quick takeover with confirmation.
- **Hands-Free Control**: Bluetooth pedal and MIDI command bindings for navigation, start/stop auto-scroll, toggle metronome.

## 5. Non-Functional Requirements
- **Offline-first**: Core features work without network; data sync queues changes and resolves conflicts when online.
- **Performance**: Instant song search (<150ms), set list load under 1s, smooth scrolling/rendering at 60 FPS on mid-tier tablets.
- **Accessibility**: Scalable typography, high-contrast and dark modes, screen reader labels, focus order for pedal-only control.
- **Security**: OAuth2 login (Google/Facebook) with optional local-only accounts in future; encrypted secrets at rest; secure diff sync.
- **Reliability**: Sync retries with exponential backoff, conflict alerts, transparent status indicators.
- **Extensibility**: Modular plugin architecture for new storage providers, hardware integrations, and community add-ons.

## 6. System Architecture Overview
LyricPro follows a **local-first, sync-later** model:
1. **Flutter client** runs on all platforms and contains UI, editing, and offline data store.
2. **Embedded database** (SQLite via Drift) stores songs, set lists, tags, user settings, and version history.
3. **Sync service** (self-hosted Supabase stack recommended) provides authentication, file/object storage, and delta sync APIs.
4. **Realtime channel** manages master-device coordination during shows, using WebRTC data channels when available with fallback to Supabase Realtime or local network (mDNS + WebSocket).

```
┌──────────────┐    OAuth/Supabase Auth     ┌─────────────┐
│  Flutter UI  │◀──────────────────────────▶│  Auth Edge  │
└──────┬───────┘                            └────┬────────┘
       │ Local DB CRUD                            │ JWT tokens
┌──────▼───────┐ Sync Queue    Realtime           │
│ Drift/SQLite │◀────────────▶ Channels ◀────────┘
└──────┬───────┘                │
       │                        ▼
       │             ┌────────────────────┐
       └────────────▶│ Supabase Services  │
                     │  (Postgres, S3)    │
                     └────────────────────┘
```

## 7. Client Application Architecture
- **Framework**: Flutter 3+ with Material 3 adaptive UI, supporting responsive layouts for phones/tablets/desktops.
- **State Management**: Riverpod for dependency injection and state, Freezed for immutable models, and GoRouter for navigation.
- **Feature Modules**
  - Library & Set List module (search, filters, tags).
  - Editor module (ChordPro parser, rich text editing, chord intelligence).
  - Performance module (teleprompter, auto-scroll, metronome).
  - Sync & Settings module (account, sync status, hardware bindings).
- **ChordPro Rendering**: Custom renderer built atop Flutter `SelectableText.rich`, with syntax tree generated by a dedicated parser package. Editor leverages `super_editor` for block-level editing with inline overlays for chords.
- **Hardware Integration**: Platform channels or federated plugins for Bluetooth pedal (HID), MIDI commands, and local network discovery.

## 8. Data & Domain Model
- **Core Entities**
  - `Song`: metadata (title, artist, key, tempo, tags), ChordPro document, attachments (PDF reference), version history references.
  - `SetList`: ordered list of songs with per-song overrides (key, capo, notes).
  - `ChangeLog`: per-entity history entries recording author, timestamp, diff summary, and revert pointer.
  - `UserProfile`: auth provider info, device settings, pedal mappings.
  - `SyncEnvelope`: queued mutations with causal metadata (vector clocks / lamport timestamps).
- **Database Technology**: Drift (SQLite) with SQLCipher or platform-secure storage on mobile for encryption. Use migrations managed via code generation.
- **Versioning**: Store immutable snapshots for major revisions and diffs for minor edits; maintain up to N recent snapshots locally with cloud archival.

## 9. Sync & Collaboration Strategy
- **Auth Flow**: OAuth2 (Google/Facebook/etc.) handled via Supabase. Tokens cached securely; offline login uses last valid session with refresh on reconnect.
- **Sync Protocol**
  - Client writes create/update/delete to local DB, appends to sync queue with vector clock.
  - Background worker uploads queued mutations when network available.
  - Server applies CRDT-inspired merge (per-field last-writer with merge rules for ordered lists). Conflicts flagged for manual resolution in-app.
  - Downloaded server diffs applied idempotently using revision IDs.
- **Master Device Sync**
  - Session host advertises via local network (mDNS) and Supabase channel.
  - Followers subscribe to host’s state (current song, section index, scroll position).
  - Commands transmitted at <100ms intervals; host fallback on disconnection with user prompt to promote a new master.
- **Security Considerations**: TLS for all network traffic, row-level security in Postgres ensuring users access only shared entities.

## 10. File Import & Export Pipeline
- **Import**
  - Google Drive integration through REST API using authenticated client; files downloaded and stored locally.
  - Parsers:
    - `.chordpro`: native support.
    - `.txt`/`.doc`: best-effort text extraction (use `flutter_tesseract_ocr` only for scans in later phase).
    - `.pdf`: embed as attachment; optional text extraction using Syncfusion PDF library or native platform services.
  - Metadata wizard prompts for missing tags, key, tempo.
- **Export**
  - Render ChordPro to PDF via `printing` package (desktop printing enabled).
  - Support zipped set list export containing ChordPro files and set manifest for external sharing.

## 11. Offline Behavior
- **Local Cache**: Entire library stored locally; background tasks periodically verify integrity and compact storage.
- **Sync Modes**: Automatic (default) adjusts to connectivity; Manual mode requires user confirmation to push/pull.
- **Conflict UI**: Users see pending conflicts with diff view; can choose remote, local, or merge result.
- **Resilience**: Pending queue stored durably; operations survive app restarts.

## 12. Performance & Telemetry
- **Performance Monitoring**: Optional Sentry integration (opt-in) for crash/perf reporting with anonymized data.
- **Metrics**: Track sync latency, render times, import success rates locally for diagnostics; export logs for support when needed.
- **Testing Strategy**: Unit tests for parser, widget tests for editor, integration tests for sync flows, platform channel tests for hardware.

## 13. Accessibility & UX Guidelines
- Provide large-text presets, customizable color themes, and screen reader labels for key controls.
- Ensure pedal-only navigation can trigger every performance action.
- Follow WCAG AA for contrast and focus indicators.
- Offer quick tutorial / onboarding emphasizing offline-first features and sync controls.

## 14. Deployment & Hosting
- **Backend Stack**: Supabase (open-source) with Postgres, Auth, Storage, Realtime. Provide Docker Compose for self-host or instructions for managed Supabase.
- **Hosting Options**
  - Self-hosted by bands on their infrastructure for full independence.
  - Community-hosted instance maintained by project maintainers (optional).
- **CI/CD**
  - GitHub Actions for lint/tests.
  - Fastlane workflows for mobile builds; desktop builds via Flutter tooling.
  - Infrastructure templates for deploying Supabase stack (Terraform/Ansible).

## 15. Security, Privacy, and Licensing
- Store minimal personal data (name, email).
- Encrypt sensitive data at rest (set list notes, attachments) when platform permits.
- License recommendation: Apache-2.0 to preserve patent rights and encourage adoption.
- Provide security policy document and responsible disclosure guidelines.

## 16. Open Source Strategy & Community
- Maintain roadmap and contribution guidelines.
- Modularize feature flags to allow community plugins (e.g., new storage providers).
- Encourage translation contributions once localization begins.
- Establish governance (core maintainers, PR review guidelines).

## 17. Future Enhancements
- Additional cloud providers (Dropbox, OneDrive, iCloud).
- Real-time co-editing with cursor presence.
- Advanced analytics for set performance and practice tracking.
- AI-assisted chord detection from audio or plain text.
- Native Apple Pencil/S Pen annotation overlays for tablets.

