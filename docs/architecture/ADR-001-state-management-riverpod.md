# ADR-001: State Management with Riverpod

## Status
Accepted

## Context
SimpleDiary needs a state management solution that handles reactive UI updates, database-backed persistence, and multi-provider coordination (theme, locale, user session, diary data). The solution must support testability via provider overrides and compile-time type safety to catch errors early.

Flutter offers several state management options: Provider, BLoC, GetX, MobX, and Riverpod. Each has different trade-offs in terms of type safety, testability, boilerplate, and ecosystem maturity.

## Decision
We chose **flutter_riverpod** (^2.3.7) with the **StateNotifier** pattern as the primary state management solution.

### Provider types used

| Type | Purpose | Example |
|------|---------|---------|
| `StateNotifierProvider` | Core mutable state with custom logic | `ThemeProvider`, `UserDataProvider`, all `DbRepository` subclasses |
| `Provider` | Synchronous derived/computed state | `currentStreakProvider`, `defaultCategoryProvider` |
| `FutureProvider` | Async initialization | `dashboardStatsProvider`, `biometricAvailableProvider` |
| `StateProvider` | Simple atomic values | `skipBiometricProvider`, `isDemoModeProvider` |

### Key patterns

**1. DbRepository as StateNotifier:** All database-backed entities use `DbRepository<T> extends StateNotifier<List<T>>`, unifying CRUD operations with reactive state. Simple entities use the `createDbProvider<T>()` one-liner factory; entities with custom logic subclass `DbRepository` directly.

**2. Granular providers via `select()`:** Performance-critical UI (dashboard) uses `ref.watch(provider.select(...))` to rebuild only when specific fields change, not the entire state.

**3. Provider composition:** Providers depend on other providers through `ref.watch()` chains, enabling automatic cache invalidation when upstream state changes.

**4. Testable overrides:** `ProviderScope(overrides: [...])` allows swapping real providers with test doubles in both widget tests and integration tests.

## Consequences

### Benefits
- **Compile-time type safety:** `StateNotifierProvider<ThemeProvider, ThemeData>` enforces correct types; no string-based lookups or runtime casts
- **Unified persistence + state:** `DbRepository` combines SQLite CRUD with Riverpod's reactive updates in a single class, eliminating the gap between persistence and UI state
- **Testability:** All 850+ tests use `ProviderContainer` or `ProviderScope` overrides to inject test doubles without touching real databases
- **No context dependency:** Providers can be accessed via `ref` anywhere, not just inside `build()` methods, simplifying service-layer logic
- **Granular rebuilds:** `select()` and separate derived providers prevent unnecessary widget rebuilds

### Trade-offs
- **Learning curve:** Riverpod's provider types and `ref.watch` vs `ref.read` distinction require understanding
- **Legacy singleton coexistence:** The global `settingsContainer` singleton predates full Riverpod adoption and is now wrapped in a `settingsProvider` for gradual migration
- **Unused dependency:** The `provider` package (^6.0.5) remains in pubspec.yaml but is completely unused — a cleanup candidate

## Alternatives Considered

### Provider (package:provider)
- Simpler API but relies on `BuildContext` for access, making service-layer usage awkward
- No compile-time safety for provider types (runtime `ProviderNotFoundException`)
- Was originally used; fully migrated to Riverpod

### BLoC (flutter_bloc)
- Strong separation of events/states but introduces significant boilerplate (Event classes, State classes, Bloc classes per feature)
- Overkill for a diary app where most state is simple CRUD lists
- Stream-based architecture adds complexity without proportional benefit here

### GetX
- Minimal boilerplate but sacrifices type safety and testability
- Global state access pattern conflicts with modular architecture goals
- Less predictable rebuild behavior

---

*Decided: Project inception*
*Last reviewed: 2026-02-27*
