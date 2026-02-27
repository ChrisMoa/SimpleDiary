# ADR-005: Multi-Platform Support

## Status
Accepted

## Context
SimpleDiary targets users who journal on their phone (Android) and their desktop (Linux, Windows). Flutter enables a single codebase across platforms, but several subsystems require platform-specific handling: database initialization, background task scheduling, biometric authentication, file storage paths, and native permissions.

The question was how to manage these platform differences: conditional imports (compile-time), runtime platform checks, or separate platform packages.

## Decision
We chose **runtime platform detection via a global singleton** with platform-specific code paths gated by simple `if` checks.

### Platform detection

```dart
// lib/core/utils/platform_utils.dart
enum ActivePlatform { android, ios, linux, windows, macOS, web }

final activePlatform = ActivePlatformClass();  // Global singleton
```

All platform-specific behavior branches on `activePlatform.platform` at runtime. No conditional imports or separate platform packages are used.

### Platform-specific code paths

| Subsystem | Android | Linux / Windows |
|-----------|---------|-----------------|
| **Database** | `sqflite` (native wrapper) | `sqflite_common_ffi` (FFI binding, initialized in `main.dart`) |
| **Background backups** | WorkManager for periodic scheduling | Overdue check on app startup only |
| **Biometric auth** | `local_auth` + `flutter_secure_storage` | Unavailable (returns `unsupportedPlatform`) |
| **File storage** | `/storage/emulated/0/{projectName}` | App documents directory via `path_provider` |
| **Permissions** | Runtime `manageExternalStorage` request | Not required |
| **Notifications** | Android-specific initialization settings | Linux-specific initialization settings |

### CI/CD builds

Each platform has a dedicated CI job with its own OS runner and toolchain:
- **Test:** ubuntu-latest (all platforms share unit tests)
- **Android:** ubuntu-latest + Java 17 (APK + App Bundle)
- **Linux:** ubuntu-latest + GTK3/libsecret dependencies
- **Windows:** windows-latest + MSVC toolchain

## Consequences

### Benefits
- **Single codebase:** One Dart codebase serves all three platforms; no platform-specific forks or packages to maintain
- **Simple branching:** `if (activePlatform.platform == ActivePlatform.android)` is immediately understandable; no metaprogramming or build configuration
- **Unified dependency tree:** All platform dependencies are bundled; unused ones are tree-shaken by the compiler for each target
- **Shared test suite:** All 850+ unit tests run on a single platform (ubuntu) and verify logic that applies across all targets
- **Feature degradation over failure:** Desktop gracefully reports "biometric unavailable" instead of crashing on unsupported API calls

### Trade-offs
- **Runtime overhead (negligible):** Platform checks happen at runtime rather than compile-time, but the cost is trivial for infrequent initialization-time checks
- **Unused dependencies bundled:** Packages like `local_auth` and `workmanager` are included in desktop builds even though their features are gated off; this slightly increases binary size
- **Desktop backup gap:** Linux/Windows cannot schedule true background backups; the startup-check approach misses overdue backups if the app isn't launched
- **No iOS/macOS/Web builds:** While the enum includes these platforms, CI/CD only builds Android, Linux, and Windows. iOS/macOS support would require additional CI runners and entitlements

## Alternatives Considered

### Conditional imports (compile-time platform split)
```dart
import 'database_mobile.dart' if (dart.library.ffi) 'database_desktop.dart';
```
- Eliminates unused code at compile time
- Adds complexity with paired implementation files for each platform difference
- Overkill when platform differences are limited to ~5 initialization-time checks

### Separate platform packages (federated plugins)
- Maximum isolation; each platform is its own Dart package
- Appropriate for published plugins but excessive for an application with minor platform differences
- Would fragment the codebase and complicate cross-platform debugging

### Web-first with PWA
- Single deployment target, no app store requirements
- Cannot access SQLite, biometric hardware, or filesystem directly
- Incompatible with the local-first, privacy-focused architecture (see ADR-002)

### Platform-specific native modules
- Could unlock platform capabilities (e.g., Windows Hello for biometrics)
- Requires maintaining Kotlin/Swift/C++ code alongside Dart
- Current Flutter plugin ecosystem (`local_auth`, `sqflite`) already abstracts most platform differences adequately

---

*Decided: Project inception*
*Last reviewed: 2026-02-27*
