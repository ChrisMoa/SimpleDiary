# ADR-003: Feature Module Structure

## Status
Accepted

## Context
As SimpleDiary grew beyond a handful of screens, the codebase needed a clear organizational strategy to keep features isolated, dependencies manageable, and onboarding straightforward. Without explicit module boundaries, cross-feature imports tend to create circular dependencies and make changes risky.

The question was how to split the codebase: by technical layer (all models together, all widgets together) or by business domain (each feature owns its full stack).

## Decision
We chose a **feature-first module structure** inspired by Clean Architecture, with a shared `core/` layer for cross-cutting infrastructure.

### Directory layout

```
lib/
├── core/                          # Shared infrastructure (no business logic)
│   ├── authentication/            # Password hashing service
│   ├── database/                  # DbEntity, DbRepository, DbColumn, migrations
│   ├── encryption/                # AES encryptor
│   ├── provider/                  # Global providers (theme, locale)
│   ├── services/                  # BackupService, NotificationService, BiometricService
│   ├── settings/                  # SettingsContainer, user/backup/biometric settings
│   ├── widgets/                   # Shared UI kit (AppCard, AppDialog, AppSpacing)
│   └── utils/                     # Platform detection, date utilities
│
└── features/                      # Business domain modules
    ├── notes/
    │   ├── data/models/           # Note, NoteCategory, NoteAttachment (DbEntity)
    │   ├── data/repositories/     # Business logic (optional)
    │   ├── domain/providers/      # Riverpod providers
    │   └── presentation/          # Pages and widgets
    ├── day_rating/
    ├── dashboard/
    ├── goals/
    ├── habits/
    └── ...
```

### Layer responsibilities

| Layer | Contains | Depends on |
|-------|----------|------------|
| `data/models/` | DbEntity subclasses with schema, serialization, and value semantics | Core database types only |
| `data/repositories/` | Pure business logic functions (no state, no UI) | Models from same feature |
| `domain/providers/` | Riverpod providers wiring models to DbRepository | Core database, feature models |
| `presentation/pages/` | Full-screen widgets (ConsumerWidget/ConsumerStatefulWidget) | Feature providers, core widgets |
| `presentation/widgets/` | Reusable UI components scoped to the feature | Feature models, core widgets |

### Dependency rules

- **Features import core** — always allowed
- **Features may import other features' models and providers** — allowed for cross-feature data access (e.g., dashboard reads diary days from day_rating)
- **Core does not import features** — enforced to prevent circular dependencies

### When to create a new feature vs extend existing

A new feature directory is warranted when the domain concept has:
1. Its own data model(s) persisted to the database
2. Its own screen(s) or navigation entry
3. Independent lifecycle (can be developed/tested in isolation)

If the functionality is a sub-concern of an existing feature (e.g., note search within notes), it stays within the existing feature module.

## Consequences

### Benefits
- **Discoverability:** New developers find all note-related code under `features/notes/`, not scattered across `models/`, `widgets/`, `providers/` directories
- **Isolation:** Changes to goals don't risk breaking notes; each feature has clear boundaries
- **Testability:** Test files mirror the feature structure (`test/features/notes/`), making it obvious what's covered
- **Scalability:** New features follow a repeatable pattern — create directory, add model, add provider, add UI
- **Parallel development:** Multiple features can be worked on simultaneously with minimal merge conflicts

### Trade-offs
- **Cross-feature imports exist:** Dashboard, calendar, and synchronization features necessarily import models from day_rating and notes, creating a fan-in dependency pattern
- **Shared logic placement:** Some logic (e.g., date utilities) could arguably live in a feature but is placed in core for reuse — this boundary requires judgment
- **Repository layer is optional:** Simpler features skip `data/repositories/` entirely, leading to slight inconsistency in structure depth across features

## Alternatives Considered

### Layer-first organization
```
lib/
├── models/        # All models together
├── providers/     # All providers together
├── pages/         # All pages together
└── widgets/       # All widgets together
```
- Familiar from small projects but breaks down at scale
- Finding "all code related to notes" requires searching across 4+ directories
- No clear ownership boundaries; circular dependencies emerge easily

### Strict Clean Architecture (separate packages per layer)
- Maximum isolation via Dart packages with explicit `pubspec.yaml` dependencies
- Excessive boilerplate for a single-developer diary app
- Package-level boundaries are more appropriate for large team projects

### Feature-first without layers (flat feature directories)
```
features/notes/
├── note.dart
├── note_provider.dart
├── notes_page.dart
└── note_widget.dart
```
- Simpler for small features but loses the visual separation between data, logic, and UI
- Harder to enforce dependency direction (UI importing models is fine; models importing UI is not)

---

*Decided: Project inception*
*Last reviewed: 2026-02-27*
