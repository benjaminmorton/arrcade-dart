# Known Issues, Quirks & Technical Notes

Gotchas, workarounds, and quirks discovered in the codebase that anyone working on this project should be aware of.

---

## Table of Contents

1. [Project Status](#project-status)
2. [Dependency Issues](#dependency-issues)
3. [Silent Error Handling](#silent-error-handling)
4. [Platform Stubs](#platform-stubs)
5. [Disabled / Hidden Features](#disabled--hidden-features)
6. [Legacy Database Adapters](#legacy-database-adapters)
7. [Lint Rules Disabled](#lint-rules-disabled)
8. [Notification Service Gaps](#notification-service-gaps)
9. [Build Pipeline Quirks](#build-pipeline-quirks)
10. [Hardcoded Values](#hardcoded-values)

---

## Project Status

**The original project is abandoned.** The CHANGELOG.md header for v11.0.0 states:

> **This is the final release of Arrcade.**

Release date: 2025-04-03. No further development from the original author is expected.

---

## Dependency Issues

### Pre-Release Dependency

`modal_bottom_sheet: ^3.0.0-pre` is pinned to a pre-release version. This was required for Flutter 3.7+ compatibility (noted in CHANGELOG v10.2.3). Monitor for official 3.0.0 release or consider replacing with an alternative.

### Dependency Overrides

`pubspec.yaml` has two dependency overrides:

```yaml
dependency_overrides:
  intl: ^0.18.1
  http: ^1.0.0
```

These exist because transitive dependencies pull in conflicting versions. The overrides force resolution but may mask compatibility issues. When upgrading dependencies, check if these overrides are still needed.

### Retrofit: In pubspec but Underused

`retrofit: ^4.0.1` and `retrofit_generator: ^9.1.9` are listed as dependencies, and `build.yaml` has Retrofit code generation enabled. However, the main API clients (Sonarr, Radarr) use manually-written Dio controllers rather than Retrofit-generated code. It's unclear which modules actually use Retrofit codegen vs. manual Dio — this needs auditing. The dependency may be partially dead weight.

### Abandoned Hive

Hive (`^2.2.3`) is no longer actively maintained. The original author (Simon Leier) moved on to Isar. Hive still works but receives no bug fixes or updates. See `docs/stack-improvements.md` for migration options.

### supercharged Package

`supercharged: ^2.1.1` provides convenience extensions on Dart collections and strings. This package is no longer maintained. Its features can be replaced with Dart 3 built-in collection methods and extension methods.

### tuple Package

`tuple: ^2.0.2` is used for simple tuple types. Dart 3 has records (`(String, int)`) which are a native replacement. This dependency can be removed.

---

## Silent Error Handling

Several locations swallow errors silently with empty catch blocks. These are intentional (graceful degradation for parsing failures) but worth knowing about:

### Search Result Date Parsing

**File**: `lib/modules/search/core/models/result.dart` (line 32)
```dart
get dateObject {
  try { return DateTime.parse(date); }
  catch (e) {}  // ignore: empty_catches
  return null;
}
```
Returns `null` if date string is unparseable. This is intentional — search results from Newznab indexers can have inconsistent date formats.

### Tautulli Timestamp Parsing

**File**: `lib/api/tautulli/utilities.dart` (lines 168, 192, 216)
```dart
// millisecondsDateTimeFromJson
try { return DateTime.fromMillisecondsSinceEpoch(v); }
catch (_) {}  // Returns null

// millisecondsDurationFromJson
try { return Duration(milliseconds: v); }
catch (_) {}  // Returns null

// secondsDurationFromJson
try { return Duration(seconds: v); }
catch (_) {}  // Returns null
```
All are type-conversion utilities for Tautulli API responses where the upstream data format isn't always consistent.

---

## Platform Stubs

For unsupported platforms, the app uses conditional imports with stub implementations that throw `UnsupportedError`. Each has a companion `isPlatformSupported()` method.

| Feature | Stub File | Supported Platforms |
|---------|-----------|-------------------|
| Window Manager | `system/window_manager/platform/window_manager_stub.dart` | macOS, Windows, Linux |
| File System | `system/filesystem/platform/filesystem_stub.dart` | All except web (limited) |
| Network Config | `system/network/platform/network_stub.dart` | Mobile, Desktop |
| Quick Actions | `system/quick_actions/platform/quick_actions_stub.dart` | iOS, Android |
| Wake on LAN | `api/wake_on_lan/platform/wake_on_lan_stub.dart` | All except web |
| Image Cache | `system/cache/image/platform/image_cache_stub.dart` | All (platform-specific impl) |

**Pattern**: Each feature has three files:
- `*_stub.dart` — throws UnsupportedError (default/web fallback)
- `*_io.dart` — mobile/desktop implementation (dart:io)
- `*_html.dart` — web implementation (dart:html)

Conditional imports select the right file at compile time:
```dart
import 'platform/network_stub.dart'
    if (dart.library.io) 'platform/network_io.dart'
    if (dart.library.html) 'platform/network_html.dart';
```

If you add a new platform-dependent feature, follow this same pattern.

---

## Disabled / Hidden Features

### Overseerr Module (Disabled via Feature Flag)

Overseerr is defined in `lib/modules.dart` but disabled. The module enum entry exists, route definitions exist, but the feature flag prevents it from appearing in the UI. The notification service fully supports Overseerr webhooks. To enable, the feature flag needs to be set to true and the module UI needs to be completed.

### Adult Content Filtering

`lib/database/tables/search.dart` has a `HIDE_XXX<bool>(false)` database field. This filters adult content categories from Newznab search results. Used in `lib/modules/search/routes/categories/route.dart`.

### Recovery Mode

If the app bootstrap fails (database corruption, etc.), a recovery mode UI is displayed (`lib/system/recovery_mode/main.dart`) with two options:
- **Bootstrap**: Reset to defaults and retry
- **Clear Database**: Nuke all Hive boxes and restart

This is a last-resort escape hatch. Normal users should never see it, but it's important to know it exists.

### Device Preview

`device_preview: ^1.1.0` is included as a dependency. This is a development tool for previewing the app on different device sizes/orientations. It's likely toggled on/off in debug mode but always shipped in the dependency tree.

---

## Legacy Database Adapters

**File**: `lib/database/models/deprecated.dart`

Contains empty Hive adapter classes (`_Deprecated02` through `_Deprecated07` and `_Deprecated11`) registered at app startup. These exist for **backward compatibility** — if a user upgrades from an older version, Hive needs to know about these type adapters to read (and discard) old data without crashing.

```dart
// These are empty classes that exist solely to prevent Hive
// deserialization errors when upgrading from older versions.
// DO NOT REMOVE unless you're sure no users have old data.
```

If you change the database system (e.g., migrate to Drift), you'll need to handle migrating data from these old Hive boxes, including boxes that may reference these deprecated types.

---

## Lint Rules Disabled

These disabled lint rules in `analysis_options.yaml` are worth noting because they suppress real issues:

| Rule | Risk | Why It Matters |
|------|------|---------------|
| `use_build_context_synchronously: false` | **High** | Using BuildContext after an async gap can crash the app if the widget has been disposed. This rule exists for a reason. |
| `avoid_catches_without_on_clauses: false` | **Medium** | Bare `catch` blocks catch `Error` types (StackOverflowError, OutOfMemoryError) that should never be caught. |
| `depend_on_referenced_packages: false` | **Medium** | Allows using transitive dependencies without declaring them. Can break on `pub upgrade`. |
| `curly_braces_in_flow_control_structures: false` | **Low** | Allows braceless if/for/while. Style preference but can cause bugs when adding lines. |

---

## Notification Service Gaps

### No Password Validation

**File**: `arrcade-notification-service/src/server/middleware.ts`

Basic Auth extracts the username (used as profile name) but **does not validate the password**. Any password is accepted. This was flagged with a TODO in the original code. Anyone who knows the webhook URL can send notifications.

### No Request Validation

Incoming webhook payloads from Sonarr/Radarr/etc. are not validated against a schema. Malformed payloads may cause unhandled exceptions or send garbled notifications rather than being rejected with a 400 error.

### No Rate Limiting

The notification service has no rate limiting. A misconfigured webhook or malicious actor could flood a user's devices with notifications.

### Stale FCM Token Handling

When Firebase Cloud Messaging returns errors for invalid/expired device tokens, the service logs the error but does not clean up the stale token from Firestore. Over time, the device list for a user can accumulate dead tokens.

---

## Build Pipeline Quirks

### Ruby Version Pinning

`.ruby-version` specifies Ruby 2.7.6, which is EOL. Fastlane and CocoaPods should work with Ruby 3.x. If you encounter issues, try updating this file to `3.2.0` or later.

### CocoaPods Reset Script

If iOS/macOS builds fail with pod-related errors, the project includes a nuclear option:

```bash
npm run cocoapods:nuke
```

This completely clears the CocoaPods cache and reinstalls from scratch. It's aggressive but effective.

### Build Number Base

Build numbers start at 1,000,000,000 + commit count. This is presumably to ensure the build number is always higher than any previous app store submission. If you fork with a fresh Git history, your build numbers will reset — you may need to adjust the base if you're taking over an existing app store listing.

### Windows MSIX Config

The MSIX configuration in `pubspec.yaml` has `store: false` and `install_certificate: false`. This means the MSIX is not configured for Microsoft Store distribution and doesn't bundle a certificate. Users need to manually trust the certificate or install via sideloading.

### Web Dockerfile Multi-Stage

The web Dockerfile uses `$BUILDPLATFORM` and `$TARGETPLATFORM` for multi-architecture support. The build stage runs on the host architecture (fast), and the runtime stage targets the deployment architecture. This is correct but can be confusing if you're not familiar with Docker buildx.

---

## Hardcoded Values

These magic numbers are used throughout the UI and are worth documenting:

### UI Constants (`lib/widgets/ui.dart`)

| Constant | Value | Purpose |
|----------|-------|---------|
| Font size H1 | (check file) | Heading sizes |
| Font size H2-H5 | (check file) | Sub-heading sizes |
| Icon size | 24.0 | Default icon dimension |
| Animation speed | 250ms | Default animation duration |
| Border radius | 10.0 | Default card/container radius |

### Layout Constants

| Constant | Value | File |
|----------|-------|------|
| `MAX_CROSS_AXIS_EXTENT` | 180.0 | `widgets/ui/block/grid_block.dart` |
| `CHILD_ASPECT_RATIO` | 7/12 | `widgets/ui/block/grid_block.dart` |
| `INITIAL_WINDOW_SIZE` | 700 | `system/window_manager/window_manager.dart` |
| `MINIMUM_WINDOW_SIZE` | 500 | `system/window_manager/window_manager.dart` |

### API Configuration

| Value | Location | Purpose |
|-------|----------|---------|
| `api/v3/` | Sonarr/Radarr API clients | API version path appended to host |
| Port 9000 | Notification service default | HTTP listen port |
| 30 seconds | Redis device cache TTL | How long device lists are cached |
| 7 days (604800s) | Redis image cache TTL | How long poster URLs are cached |
| 50 | Logger compaction limit | Max log entries before compaction |

---

## Null Safety Patterns

The codebase is fully null-safe (Dart 3.0+) but uses aggressive force-unwrapping (`!`) in many places rather than safer alternatives:

```dart
// Common pattern (risky):
_series = _api!.series.getAll(...);
(await _series)![seriesId] = series;

// Safer alternative:
final api = _api;
if (api == null) return;
_series = api.series.getAll(...);
```

This is a source of potential runtime crashes. The Riverpod migration (see `stack-improvements.md`) would eliminate most of these by replacing nullable state with `AsyncValue`.

---

## Localization Quirk

The localization generation script (`scripts/generate_localization.dart`) merges per-module translation files into consolidated language files. If a module has translations for a language variant (e.g., `zh-Hans`) but not the base language (e.g., `zh`), the script creates a **stub primary language file** to prevent asset loading failures at runtime. This means some base language files may exist but be empty or incomplete — this is intentional.
