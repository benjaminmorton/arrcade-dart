# Stack Improvements & Technology Modernization

An assessment of the current technology stack with recommended upgrades, ranked by impact. The codebase has solid bones but several dependencies are outdated or abandoned, and some architecture patterns could be modernized for better developer experience, testability, and reliability.

---

## Table of Contents

1. [Current Stack Summary](#current-stack-summary)
2. [High Impact Changes](#high-impact-changes)
3. [Medium Impact Changes](#medium-impact-changes)
4. [Lower Priority / Nice to Have](#lower-priority--nice-to-have)
5. [Strategic Decision: Firebase vs Supabase](#strategic-decision-firebase-vs-supabase)
6. [Priority Order](#priority-order)
7. [Migration Notes](#migration-notes)

---

## Current Stack Summary

### Flutter App

| Layer | Current | Version | Status |
|-------|---------|---------|--------|
| Language | Dart | >=3.0.0 <4.0.0 | OK |
| Framework | Flutter | Latest | OK |
| State Management | Provider + ChangeNotifier | ^6.x | Outdated pattern |
| DI Container | None (direct instantiation) | N/A | Missing |
| Navigation | go_router | ^14.8.1 | OK |
| HTTP Client | Dio (manual controllers) | ^5.3.2 | OK, but messy |
| REST Codegen | Retrofit (in pubspec but underused) | ^4.0.1 | Dead weight |
| Local Database | Hive | ^2.2.3 | Abandoned |
| Localization | easy_localization | ^3.0.2 | OK |
| Data Models | json_serializable (manual) | ^6.9.0 | Verbose |
| Linting | flutter_lints (permissive) | ^5.0.0 | Weak |
| Charts | fl_chart | ^0.70.2 | OK |
| Caching | stash_memory + flutter_cache_manager | Various | OK |

### Notification Service

| Layer | Current | Version | Status |
|-------|---------|---------|--------|
| Runtime | Node.js | 14+ (implied) | EOL |
| Framework | Express | ^4.18.2 | Maintenance mode |
| Language | TypeScript | ^5.2.2 | OK |
| Build | tsc (raw) | N/A | Slow |
| Runtime runner | ts-node (in production) | ^10.9.1 | Not recommended |
| HTTP Client | Axios | ^1.5.1 | OK |
| Cache | ioredis | ^5.3.2 | OK |
| Firebase | firebase-admin | ^11.11.0 | One major behind |
| Validation | None | N/A | Missing |
| Logging | Pino | ^8.15.4 | OK |

### Cloud Functions

| Layer | Current | Version | Status |
|-------|---------|---------|--------|
| Runtime | Node.js | 14 | EOL since Apr 2023 |
| SDK | Firebase Functions v1 | ^3.16.0 | Legacy |
| Admin SDK | firebase-admin | ^10.0.0 | Two majors behind |
| Language | TypeScript | ^4.5.2 | Outdated |

---

## High Impact Changes

### 1. Cloud Functions v1 → v2 + Node 20

**Problem**: Firebase Functions v1 SDK is legacy. Node 14 has been EOL since April 2023 — no security patches. TypeScript 4.5 is two major versions behind.

**Current code** (`arrcade-cloud-functions/functions/package.json`):
```json
{
  "engines": { "node": "14" },
  "dependencies": {
    "firebase-admin": "^10.0.0",
    "firebase-functions": "^3.16.0"
  }
}
```

**Recommended**:
```json
{
  "engines": { "node": "20" },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0"
  }
}
```

**What changes**:
- Import path: `firebase-functions` → `firebase-functions/v2`
- Auth trigger syntax is slightly different in v2
- Better cold start performance
- Configurable CPU/memory per function
- Cloud Run under the hood (can containerize if needed later)

**Effort**: Low. There is literally one function (`deleteUserController`). This is a quick win.

---

### 2. Hive → Drift (SQLite) or Isar

**Problem**: Hive is effectively abandoned — the author (Isar team) stopped maintaining it. It has no query support, no schema migrations, no versioning. The codebase works around this with an unusual enum-based table pattern (`LunaBox`, `LunaTableMixin`) that is clever but fragile. Any schema change risks data loss since there's no migration system.

**Current pattern** (`lib/database/box.dart`):
```dart
enum LunaBox<T> {
  alerts<dynamic>('alerts'),
  profiles<LunaProfile>('profiles'),
  // ...
  T? read(dynamic key, {T? fallback}) => _instance.get(key, defaultValue: fallback);
  Future<void> update(dynamic key, T value) => _instance.put(key, value);
}
```

**Option A — Drift (recommended)**:
- SQLite-based, battle-tested, actively maintained
- Typed queries, joins, aggregations
- Built-in schema migrations with versioning
- Reactive streams (watch queries)
- Code generation for type-safe tables
- Works on all platforms including web (via sql.js)
- Most mature option in the Flutter ecosystem

**Option B — Isar 4.x**:
- Closest migration path from Hive (same author, similar key-value API)
- NoSQL with indexing and queries
- But: Isar's maintenance has been inconsistent — evaluate current status before committing

**Option C — ObjectBox**:
- High-performance NoSQL with ACID transactions
- Actively maintained by a funded company
- Good query support and reactive data observers
- Simpler than Drift if you don't need relational queries

**Effort**: Medium-high. Every `LunaBox` enum, `LunaTableMixin`, and Hive adapter needs rewriting. Can be done one box at a time.

---

### 3. Provider → Riverpod

**Problem**: The current Provider + ChangeNotifier pattern has several weaknesses visible in the codebase:

- **No compile-time safety** — `Provider.of<T>()` throws `ProviderNotFoundException` at runtime if you forget to register a provider
- **Coarse rebuilds** — `ChangeNotifier` triggers rebuilds for the entire listening subtree, even if only one field changed
- **Nullable everything** — State classes hold `Future?` fields that require `!` force-unwrapping everywhere
- **No DI** — API clients are instantiated directly inside state classes, making testing impossible without a real server
- **Manual async handling** — Every module manually manages loading/error/data states with nullable futures and FutureBuilders

**Current pattern** (`lib/modules/sonarr/core/state.dart`):
```dart
class SonarrState extends LunaModuleState {
  SonarrAPI? _api;
  Future<Map<int, SonarrSeries>>? _series;

  void fetchAllSeries() {
    if (_api != null) {
      _series = _api!.series.getAll(...);  // Force unwrap
    }
  }
}
```

**Riverpod equivalent**:
```dart
@riverpod
Future<Map<int, SonarrSeries>> sonarrSeries(SonarrSeriesRef ref) async {
  final api = ref.watch(sonarrApiProvider);
  return api.series.getAll(...);
}

// In widget — no null checks, no force unwraps, automatic loading/error states:
final series = ref.watch(sonarrSeriesProvider);
return series.when(
  data: (data) => SeriesList(data),
  loading: () => LoadingIndicator(),
  error: (e, s) => ErrorMessage(e),
);
```

**What Riverpod gives you**:
- Compile-time provider resolution (no runtime crashes)
- `AsyncValue<T>` replaces `Future<T>?` + manual null checks + FutureBuilder
- Built-in DI (providers can depend on other providers)
- Auto-dispose (clean up when widgets unmount)
- Family providers (parameterized state per module/ID)
- `ref.invalidate()` replaces the manual `reset()` pattern
- Testable — override any provider in tests

**Effort**: High, but incremental. Provider and Riverpod can coexist. Migrate one module at a time starting with the simplest (e.g., Wake on LAN or External Modules) and work toward the complex ones (Sonarr, Radarr).

---

### 4. Notification Service: Express → Hono + Node 20 + Zod

**Problem**: Multiple issues compound:
- Express 4 is in maintenance mode — no new features, infrequent patches
- `ts-node` runs in production (compiles TypeScript at runtime — slow cold starts)
- Zero request validation — all incoming webhook payloads are trusted blindly, which is a security risk
- Node 14 is EOL
- Manual middleware chaining is verbose and hard to follow

**Current server setup** (`src/server/server.ts`):
```typescript
const app = express();
app.use(express.json());
app.post('/v1/radarr/user/:id',
  startNewRequest,
  extractNotificationOptions,
  extractProfile,
  pullUserTokens,
  validateUser,
  radarrController
);
```

**Recommended: Hono + Zod**

Hono is TypeScript-first, lightweight, and runs on Node, Bun, Deno, or Cloudflare Workers. Zod adds runtime type validation for webhook payloads.

```typescript
import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

const radarrSchema = z.object({
  eventType: z.enum(['Download', 'Grab', 'Health', ...]),
  movie: z.object({ title: z.string(), tmdbId: z.number() }).optional(),
  // ...
});

const app = new Hono();
app.post('/v1/radarr/user/:id',
  zValidator('json', radarrSchema),
  async (c) => { ... }
);
```

**Also change**:
- Build with **`tsup`** or **`esbuild`** instead of raw `tsc` — single-file output, tree-shaking, 10-50x faster builds
- Run compiled JS in production (not `ts-node`)
- Upgrade to **Node 20 LTS** (or 22)
- Upgrade `firebase-admin` to **v12+**

**Alternative**: **Fastify** if you prefer staying closer to Express patterns. Fastify has built-in JSON schema validation and is 2-3x faster than Express. Larger ecosystem than Hono.

**Effort**: Medium. The notification service is small (~30 source files). A focused rewrite could be done in a few days.

---

## Medium Impact Changes

### 5. Add Freezed for Data Models

**Problem**: The codebase has 50+ data model classes for Sonarr, 45+ for Radarr, etc. These use `json_serializable` with manually written `copyWith`, equality, and `toString` methods (or more commonly, they're missing entirely). Models are mutable when they shouldn't be.

**Current pattern**:
```dart
@JsonSerializable()
class SonarrSeries {
  int? id;
  String? title;
  // ... 20+ fields, all mutable, no copyWith, no equality

  factory SonarrSeries.fromJson(Map<String, dynamic> json) =>
      _$SonarrSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SonarrSeriesToJson(this);
}
```

**With Freezed**:
```dart
@freezed
class SonarrSeries with _$SonarrSeries {
  const factory SonarrSeries({
    int? id,
    String? title,
    // ... same fields
  }) = _SonarrSeries;

  factory SonarrSeries.fromJson(Map<String, dynamic> json) =>
      _$SonarrSeriesFromJson(json);
}
// Auto-generates: copyWith, ==, hashCode, toString, immutability
```

**Benefits**:
- Immutable by default (prevents accidental mutation bugs)
- Auto-generated `copyWith` (useful for state updates)
- Auto-generated `==` and `hashCode` (correct list/map behavior)
- Union types for sealed class patterns (e.g., `SonarrEvent.grab()` | `SonarrEvent.download()`)
- Works with `json_serializable` — just add `@freezed` annotation

**Effort**: Medium. Can be adopted incrementally per module. Start with the most-used models.

---

### 6. Stricter Lint Rules

**Problem**: The current `analysis_options.yaml` uses `flutter_lints` with many rules disabled, including dangerous ones:

```yaml
# Currently disabled — these are risky:
use_build_context_synchronously: false   # Can cause crashes if context used after async gap
avoid_catches_without_on_clauses: false  # Catches Error types you should never catch
depend_on_referenced_packages: false     # Implicit deps can break on pub upgrade
```

**Recommendation**: Switch to **`very_good_analysis`** (from Very Good Ventures, used by the Flutter team's preferred agency) or **`lints: ^4.0.0`** (official Dart team).

At minimum, re-enable these critical rules:
```yaml
linter:
  rules:
    use_build_context_synchronously: true   # Prevents real crashes
    avoid_catches_without_on_clauses: true  # Don't catch StackOverflow/OutOfMemory
    depend_on_referenced_packages: true     # Explicit dependencies
    prefer_const_constructors: true         # Performance
    avoid_print: true                       # Use logger instead
```

**Effort**: Low to change the config. Medium to fix existing violations (run `dart fix --apply` for auto-fixable ones first).

---

### 7. Retrofit — Commit or Remove

**Problem**: `retrofit: ^4.0.1` and `retrofit_generator: ^9.1.9` are in `pubspec.yaml`, but the actual API clients (Sonarr, Radarr, etc.) are manually wired with raw Dio. Retrofit's code generation doesn't appear to be used. This is dead weight in the dependency tree.

**Current approach** — manual Dio controllers:
```dart
class SonarrControllerCalendar {
  final Dio _dio;
  SonarrControllerCalendar(this._dio);

  Future<List<SonarrCalendar>> get({...}) async {
    final response = await _dio.get('/calendar', queryParameters: {...});
    return (response.data as List).map((e) => SonarrCalendar.fromJson(e)).toList();
  }
}
```

**Option A — Commit to Retrofit** (recommended if staying with Dio):
```dart
@RestApi()
abstract class SonarrApi {
  factory SonarrApi(Dio dio) = _SonarrApi;

  @GET('/calendar')
  Future<List<SonarrCalendar>> getCalendar({
    @Query('start') required String start,
    @Query('end') required String end,
  });
}
// Run: dart run build_runner build
```

Benefits: Type-safe API definitions, automatic serialization, less boilerplate, self-documenting endpoints.

**Option B — Remove Retrofit, clean up Dio**:
Remove `retrofit` and `retrofit_generator` from pubspec. Keep the manual Dio approach but add a Dio interceptor for consistent error handling, logging, and auth header injection.

**Effort**: Low if removing. Medium-high if adopting across all API clients.

---

## Lower Priority — Nice to Have

### 8. go_router → AutoRoute (Optional)

**Current**: go_router 14.8 with string-based routes and untyped parameters.

go_router is fine and actively maintained by the Flutter team. However, **AutoRoute** offers:
- Type-safe route arguments (compile-time checked)
- Code-generated route definitions
- Nested navigation with less boilerplate
- Guards/middleware as first-class concepts

**Verdict**: Only worth switching if you find yourself fighting go_router. Not a priority.

---

### 9. easy_localization → slang (Optional)

**Current**: `easy_localization` with JSON files and string-key lookups:
```dart
'arrcade.Dashboard'.tr()  // Runtime string lookup, typos cause silent failures
```

**slang** generates type-safe translation accessors:
```dart
t.arrcade.dashboard  // Compile-time checked, autocomplete in IDE
```

**Verdict**: Nice for catching typo bugs, but low priority. The current setup works.

---

### 10. Consider Bun Instead of Node (Notification Service)

If you're rewriting the notification service anyway, **Bun** is a drop-in Node.js replacement that's significantly faster:
- 3-5x faster HTTP serving than Node
- Built-in TypeScript support (no compilation step)
- Built-in test runner
- Compatible with most npm packages
- Hono has first-class Bun support

**Verdict**: Worth trying if you're already doing a rewrite. Not worth switching to alone.

---

## Strategic Decision: Firebase vs Supabase

Since you're setting up fresh infrastructure for the rebrand, this is the right time to evaluate whether Firebase is the best fit.

### Firebase (Stay)

| Pros | Cons |
|------|------|
| Already integrated in the codebase | Vendor lock-in (Google) |
| FCM is best-in-class for push notifications | Firestore pricing can spike unpredictably |
| Generous free tier | Firestore is NoSQL — no joins, limited queries |
| Cloud Functions built-in | Not self-hostable |
| Auth is mature and easy | Users of self-hosted media servers may distrust Google |

### Supabase (Switch)

| Pros | Cons |
|------|------|
| Self-hostable (aligns with self-hosted app philosophy) | Migration effort is significant |
| PostgreSQL (real SQL, joins, migrations) | Push notifications need a separate service (e.g., OneSignal, FCM still) |
| Built-in auth, storage, real-time, edge functions | Smaller ecosystem than Firebase |
| Predictable pricing | Edge functions are Deno-based (different runtime) |
| Open source | Less mature than Firebase |
| Row-level security | |

### Recommendation

**Stay with Firebase** if:
- You want the fastest path to a working rebrand
- Push notifications are a core feature (FCM has no real competitor for mobile)
- You're a solo developer and want managed infrastructure

**Switch to Supabase** if:
- You want to self-host the entire backend (appeals to your user base)
- You plan to add features that need relational queries
- You're uncomfortable with Google vendor lock-in
- You're willing to invest the upfront migration time

**Hybrid option**: Use Supabase for auth/database/storage but keep FCM for push notifications. Supabase can trigger webhooks to your notification service, which still uses FCM for delivery. This gives you the best of both worlds.

---

## Priority Order

| # | Change | Impact | Effort | Notes |
|---|--------|--------|--------|-------|
| 1 | Cloud Functions v1 → v2 + Node 20 | High | Low | One function, quick win, eliminates EOL runtime |
| 2 | Stricter lint rules | High | Low | Prevents real bugs, mostly auto-fixable |
| 3 | Notification service → Hono/Fastify + Zod + Node 20 | High | Medium | Security (validation), performance, modern DX |
| 4 | Provider → Riverpod | High | High | Incremental migration, one module at a time |
| 5 | Hive → Drift | High | Medium-High | Reliability, migrations, queries |
| 6 | Add Freezed for data models | Medium | Medium | Incremental, one module at a time |
| 7 | Commit to or remove Retrofit | Medium | Low-Medium | Clean up dead weight |
| 8 | Firebase vs Supabase decision | Strategic | High | Decide before setting up rebrand infrastructure |
| 9 | go_router → AutoRoute | Low | Medium | Only if pain points arise |
| 10 | easy_localization → slang | Low | Medium | Polish, not critical |
| 11 | Consider Bun runtime | Low | Low | Only if rewriting notification service |

### Suggested Phases

**Phase 1 — Quick wins (1-2 days)**:
- Cloud Functions v2 + Node 20
- Stricter lint rules + `dart fix --apply`
- Remove unused Retrofit dependency (or commit to using it)

**Phase 2 — Notification service rewrite (3-5 days)**:
- Hono or Fastify + Zod validation
- tsup build pipeline
- Node 20, firebase-admin v12
- Docker image update

**Phase 3 — Database migration (1-2 weeks)**:
- Hive → Drift, one box at a time
- Add schema versioning and migrations
- Data migration path for existing users

**Phase 4 — State management migration (2-4 weeks, incremental)**:
- Start with smallest module (External Modules or Wake on LAN)
- Migrate to Riverpod + AsyncValue pattern
- Add Freezed to models as you touch them
- Work through modules: Search → SABnzbd → NZBGet → Lidarr → Tautulli → Radarr → Sonarr

---

## Migration Notes

### Coexistence During Migration

These technologies can coexist during incremental migration:

| Old | New | Can Coexist? |
|-----|-----|-------------|
| Provider | Riverpod | Yes — use `ProviderScope` at root, migrate widget by widget |
| Hive | Drift | Yes — run both databases, migrate data on first launch |
| json_serializable | Freezed | Yes — Freezed uses json_serializable under the hood |
| Express | Hono/Fastify | No — full rewrite (but service is small) |
| Flutter Lints | very_good_analysis | No — swap in place, fix violations |

### Data Migration Strategy (Hive → Drift)

For existing users upgrading from the old database:

1. On first launch after update, check if Hive boxes exist
2. Read all data from Hive boxes
3. Write to new Drift tables
4. Delete old Hive boxes
5. Set a flag so migration only runs once

```dart
Future<void> migrateFromHive() async {
  final migrated = prefs.getBool('hive_migrated') ?? false;
  if (migrated) return;

  // Read from Hive
  final profiles = LunaBox.profiles.readAll();

  // Write to Drift
  await database.profilesDao.insertAll(profiles.map(toDriftModel));

  // Cleanup
  await Hive.deleteBoxFromDisk('profiles');
  prefs.setBool('hive_migrated', true);
}
```

### Riverpod Migration Pattern

For each module, the migration follows this pattern:

1. Create Riverpod providers that wrap the existing state class
2. Update widgets to use `ref.watch()` instead of `Provider.of()`
3. Once all widgets are migrated, refactor the state class into pure Riverpod providers
4. Remove the old ChangeNotifier class

This lets you migrate one widget at a time without breaking anything.
