# Arrcade - Complete Functionality Overview

> **Version**: 11.0.0
> **Platforms**: Android, iOS, macOS, Windows, Linux, Web
> **Architecture**: Flutter/Dart multi-module app with Firebase backend services

Arrcade is a self-hosted media server companion app that provides a unified interface for managing Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli, and Newznab indexers. It includes a notification relay service, Firebase cloud functions, and a GitBook documentation site.

---

## Table of Contents

1. [Flutter Mobile/Desktop App](#1-flutter-mobiledesktop-app)
2. [Notification Service](#2-notification-service)
3. [Cloud Functions](#3-cloud-functions)
4. [Documentation Site](#4-documentation-site)

---

## 1. Flutter Mobile/Desktop App

### 1.1 Core Architecture

- **State Management**: Provider pattern with ChangeNotifier
- **Navigation**: GoRouter with deep linking support
- **Database**: Hive key-value store (boxes: alerts, externalModules, indexers, logs, arrcade, profiles)
- **HTTP Client**: Dio + Retrofit for REST API calls
- **Caching**: Stash library (memory) + platform-specific image cache (filesystem)
- **Localization**: easy_localization with English language support
- **Theming**: Material Design 3 dark theme with AMOLED mode, border effects, background opacity

### 1.2 Profile System

- Multiple connection profiles (default: "default")
- Per-profile service configuration (host, API key, custom headers, enabled/disabled)
- Profile switching resets all module states
- Profiles support: Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli, Wake on LAN, Overseerr (disabled)
- Backup/restore profiles to JSON files

### 1.3 Bootstrap & Recovery

- Guarded zone error handling for crash capture
- Sequential initialization: database → logger → theme → window manager → network → image cache → router → memory store
- Recovery mode fallback if bootstrap fails (reset to default or clear all data)

---

### 1.4 Modules

#### Dashboard

- Aggregated calendar view of upcoming releases from Sonarr and Radarr
- Schedule view (list format) of upcoming content
- Calendar customization (starting day, view type, size)
- Module overview tiles for quick status

#### Sonarr (TV Series Management)

| Feature | Description |
|---------|-------------|
| Series Catalogue | Browse, search, sort, and filter series in grid/list view |
| Add Series | Search for new series, configure quality profile, language, root folder, monitored state |
| Series Details | View seasons, episodes, monitored status, quality profile |
| Season/Episode Management | Monitor/unmonitor seasons and individual episodes |
| Edit Series | Modify series settings (quality profile, path, monitoring, tags) |
| Download Queue | View active downloads with progress |
| Release Search | Search for and manually select releases for episodes |
| History | Browse download/grab/import history with filtering |
| Tag Management | Create, edit, delete organizational tags |
| Webhooks | Push notification support via Arrcade notification service |

**API**: Full Sonarr API v3/v4 support via Retrofit with 50+ data models and 13+ endpoint groups.

#### Radarr (Movie Management)

| Feature | Description |
|---------|-------------|
| Movie Catalogue | Browse, search, sort, filter movies in grid/list view |
| Add Movie | Search TMDb, configure quality profile, root folder, monitored state |
| Movie Details | View files, cast, crew, media info, extra files |
| Edit Movie | Modify quality profile, path, monitoring, tags, availability |
| Manual Import | Import and rename existing files on disk |
| Download Queue | View active downloads with progress |
| Release Search | Search for and manually select releases |
| History | Browse download/grab/import/rename history |
| System Status | System health checks, disk space monitoring |
| Tag Management | Create, edit, delete tags |
| Webhooks | Push notification support |

**API**: Full Radarr API v3/v4 support with 45+ data models and 20+ endpoint groups.

#### Lidarr (Music Management)

| Feature | Description |
|---------|-------------|
| Artist Catalogue | Browse and search artists |
| Artist Details | View discography, albums, missing tracks |
| Add Artist | Search and add new artists with configuration |
| Edit Artist | Modify quality profiles, root folder, monitoring |
| Missing Albums | Identify and search for missing content |
| Release Search | Search for and select releases |
| Webhooks | Push notification support |

#### SABnzbd (Usenet Download Client)

| Feature | Description |
|---------|-------------|
| Queue Management | View, pause, resume, delete active downloads |
| Priority Control | Adjust download priority |
| Category Management | Filter by download category |
| History | View completed/failed downloads |
| History Stages | Detailed stage logs per download |
| Statistics | Download speed graphs and statistics |
| Server Information | Server status and health |

#### NZBGet (Usenet Download Client)

| Feature | Description |
|---------|-------------|
| Queue Management | View, pause, resume, delete downloads |
| Priority Control | Adjust download priority |
| History | Completed download tracking |
| Statistics | Download statistics visualization |
| Server Health | Real-time status monitoring |

#### Tautulli (Plex Media Server Monitoring)

| Feature | Description |
|---------|-------------|
| Activity Monitoring | Real-time Plex playback activity |
| User/Session Tracking | Active users and stream details |
| Statistics | Historical graphs (plays, bandwidth, duration) with time range filtering |
| Transcode Monitoring | Current transcode sessions |
| Recently Added | New media additions to Plex |
| Webhooks | Push notification support |

#### Search (Newznab Indexer Search)

| Feature | Description |
|---------|-------------|
| Multi-Indexer Search | Search across multiple configured Newznab indexers |
| Category Filtering | Filter by category and subcategory |
| Indexer Management | Add, edit, delete indexers with API keys and custom headers |
| Direct Download | Send results to SABnzbd or NZBGet |
| Result Sorting | Sort and filter search results |

**Supported Indexers**: DOGnzb, DrunkenSlug, NZB.su, NZBCat, NZBFinder, NZBGeek, NZBPlanet, omgwtfnzbs, OZnzb, SimplyNZBs, Usenet Crawler, and any Newznab-compatible indexer.

#### External Modules

- Add custom web service links with display name and URL
- Quick-launch to any web UI
- Stored persistently in Hive database

#### Wake on LAN

- Send magic packets to wake computers remotely
- Configure MAC address and broadcast address
- Platform-specific implementations (IO socket for mobile/desktop, HTML for web)

#### Settings

| Section | Features |
|---------|----------|
| General | Theme (AMOLED, borders, opacity), language, time format (12/24h), TLS validation, network config |
| Dashboard | Calendar customization |
| Drawer | Module ordering (manual/automatic), module visibility |
| Quick Actions | Configure home screen shortcuts per module |
| Per-Service Config | Host, API key, custom headers, default pages, default profiles |
| Profiles | Create, edit, delete, switch connection profiles |
| System Logs | View, filter, search, export, clear application logs |
| Backup/Restore | Export/import configuration to/from JSON |

---

### 1.5 Navigation & Routing

- GoRouter-based navigation with named routes and deep linking
- Per-module route groups with query and path parameter support
- Module enablement checking with fallback to "Not Enabled" page
- Top-level routes: BIOS, Dashboard, Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Search, Settings, Tautulli, External Modules

### 1.6 UI Framework

- `LunaScaffold` - App shell with drawer/navbar
- `LunaDrawer` - Sidebar navigation with configurable module ordering
- `LunaNavigationBar` - Bottom navigation bar
- `LunaFloatingActionButton` - Animated FAB
- `LunaRefreshIndicator` - Pull-to-refresh
- `LunaListTile` / `LunaExpandableListTile` - List items
- `LunaPopupMenuButton` - Context menus
- `LunaActionBar` - Bottom action bar
- `LunaBadge` - Badge indicators
- `LunaMessage` - Toast/snackbar messages
- Module-specific color schemes

### 1.7 Platform-Specific Features

| Feature | Android | iOS | macOS | Windows | Linux | Web |
|---------|---------|-----|-------|---------|-------|-----|
| Quick Actions | Yes | Yes (13+) | No | No | No | No |
| Window Management | No | No | Yes | Yes | Yes | No |
| Wake on LAN | Yes | Yes | Yes | Yes | Yes | No (UDP limitation) |
| Cloud Account | Yes | Yes | Yes | No | No | Hosted only |
| Notifications | Yes | Yes | Yes | No | No | Hosted only |
| File Picker | Yes | Yes | Yes | Yes | Yes | Limited |

### 1.8 Logging

- Four levels: DEBUG, WARNING, ERROR, CRITICAL
- Hive-based storage with automatic compaction (50 most recent)
- Stack trace parsing, class/method extraction
- Export to JSON, view/filter/clear in Settings UI

---

## 2. Notification Service

**Stack**: Node.js + Express.js + TypeScript, Firebase Cloud Messaging, Redis
**Version**: 1.5.5
**Deployment**: Docker container (`ghcr.io/jagandeepbrar/arrcade-notification-service`)

### 2.1 Architecture

```
Webhook from App → Express Router → Middleware Pipeline → Module Controller → Firebase Cloud Messaging → User Devices
```

**Middleware Pipeline**:
1. `startNewRequest` - Request logging
2. `extractNotificationOptions` - Parse query params (sound, interruption_level)
3. `extractProfile` - Extract profile from Basic Auth username
4. `extractDeviceToken` or `pullUserTokens` - Resolve target devices
5. `validateUser` - Verify user exists in Firebase (user endpoints only)

### 2.2 API Endpoints

All endpoints accept POST with module-specific JSON payloads:

| Path | Description |
|------|-------------|
| `POST /v1/radarr/user/:id` | Radarr webhook → user's devices |
| `POST /v1/radarr/device/:id` | Radarr webhook → specific device |
| `POST /v1/sonarr/user/:id` | Sonarr webhook → user's devices |
| `POST /v1/sonarr/device/:id` | Sonarr webhook → specific device |
| `POST /v1/lidarr/user/:id` | Lidarr webhook → user's devices |
| `POST /v1/lidarr/device/:id` | Lidarr webhook → specific device |
| `POST /v1/tautulli/user/:id` | Tautulli webhook → user's devices |
| `POST /v1/tautulli/device/:id` | Tautulli webhook → specific device |
| `POST /v1/overseerr/user/:id` | Overseerr webhook → user's devices |
| `POST /v1/overseerr/device/:id` | Overseerr webhook → specific device |
| `POST /v1/custom/user/:id` | Custom webhook → user's devices |
| `POST /v1/custom/device/:id` | Custom webhook → specific device |
| `GET /health` | Health check (returns status + version) |
| `GET /` | Redirects to documentation |

**Query Parameters**:
- `sound` - Enable/disable notification sound (default: true)
- `interruption_level` - iOS interruption level: passive, active, time-sensitive

### 2.3 Supported Notification Events

**Radarr** (7 events): Download, Grab, Health, MovieDelete, MovieFileDelete, Rename, Test

**Sonarr** (7 events): Download, Grab, Health, EpisodeFileDelete, SeriesDelete, Rename, Test

**Lidarr** (5 events): Download, Grab, Rename, Retag, Test

**Tautulli** (17 events): PlaybackStart, PlaybackStop, PlaybackPause, PlaybackResume, PlaybackError, BufferWarning, PlexServerUp, PlexServerDown, PlexRemoteAccessUp, PlexRemoteAccessDown, PlexUpdateAvailable, TautulliUpdateAvailable, TautulliDatabaseCorruption, RecentlyAdded, Watched, TranscodeDecisionChange, UserNewDevice, UserConcurrentStreams

**Overseerr** (11 events): MEDIA_PENDING, MEDIA_APPROVED, MEDIA_AUTO_APPROVED, MEDIA_AVAILABLE, MEDIA_DECLINED, MEDIA_FAILED, ISSUE_CREATED, ISSUE_RESOLVED, ISSUE_REOPENED, ISSUE_COMMENT, TEST_NOTIFICATION

**Custom**: Arbitrary title, body, image, and data fields

### 2.4 External API Integrations

| Service | Purpose | Cache TTL |
|---------|---------|-----------|
| Firebase Firestore | User device token storage | 30s (Redis) |
| Firebase Cloud Messaging | Push notification delivery | N/A |
| TMDB (The Movie Database) | Movie/TV poster art for notifications | 7 days |
| Fanart.tv | Music artist/album artwork for notifications | 7 days |
| Redis | Caching layer for devices and images | Varies |

### 2.5 Configuration

**Required Environment Variables**: `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_DATABASE_URL`, `FIREBASE_PRIVATE_KEY`, `THEMOVIEDB_API_KEY`, `FANART_TV_API_KEY`, `REDIS_HOST`, `REDIS_PORT`

**Optional**: `REDIS_USER`, `REDIS_PASS`, `REDIS_USE_TLS`, `PORT` (default 9000), `NODE_ENV`

---

## 3. Cloud Functions

**Stack**: Firebase Cloud Functions (TypeScript), Node.js 14
**Firebase Project**: `comettools-arrcade`

### 3.1 Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `deleteUserController` | Firebase Auth `onDelete` | Cleans up all user data when account is deleted |

### 3.2 Cleanup Flow

When a user is deleted from Firebase Auth:
1. **Firestore cleanup**: Deletes `users/{uid}` document and all nested subcollections recursively
2. **Storage cleanup**: Deletes all files in `backup.arrcade.app` bucket with prefix `{uid}/`

### 3.3 Data Structure

- **Firestore**: `users/{uid}` with nested subcollections (device registrations, settings, etc.)
- **Cloud Storage**: `backup.arrcade.app/{uid}/*` (encrypted configuration backups)

---

## 4. Documentation Site

**Platform**: GitBook
**Files**: 32 markdown documents, 13 image assets

### 4.1 Documentation Coverage

| Section | Status |
|---------|--------|
| Getting Started (build channels, donations, FAQ, platform restrictions) | Complete |
| Cloud Account & Backups | Complete |
| Profiles & Logging | Complete |
| Notification Setup (Radarr, Sonarr, Lidarr, Tautulli, Overseerr, Custom) | Complete |
| Sonarr Setup | Complete |
| Radarr Setup | Complete |
| Lidarr Setup | Complete |
| Newznab Search Setup | Complete |
| Platform Installation (Android, iOS, macOS, Windows, Linux, Web) | Complete |
| Tautulli Setup | Placeholder ("Coming Soon") |
| SABnzbd Setup | Placeholder ("Coming Soon") |
| NZBGet Setup | Placeholder ("Coming Soon") |
| Overseerr Setup | Placeholder ("Coming Soon") |
| Wake on LAN Setup | Placeholder ("Coming Soon") |

### 4.2 Key Documentation Topics

- Network configuration (finding local IP, bind addresses)
- API key retrieval per service
- Custom headers for reverse proxies
- Webhook URL format: `https://notify.arrcade.app/v1/{module}/user/{token}` or `/device/{token}`
- Platform support matrix (modules × platforms)
- Build channel descriptions (Stable, Beta, Edge)
- Donation/sponsorship options (in-app purchases, Ko-Fi, GitHub Sponsors)

---

## 5. Cross-Cutting Concerns

### Authentication & Security

- Per-profile API key storage in Hive database
- Custom HTTP headers for reverse proxy auth
- TLS validation toggle for self-signed certificates
- Basic Auth username extraction for profile identification (notification service)
- Firebase Auth for cloud account features
- End-to-end encryption for cloud backups

### Webhook Token System

- User-based tokens: `https://notify.arrcade.app/v1/{module}/user/{firebaseUID}`
- Device-based tokens: `https://notify.arrcade.app/v1/{module}/device/{fcmToken}`
- Profile identification via Basic Auth username in webhook URL

### Data Flow

```
Media Server (Sonarr/Radarr/etc.)
    → Webhook POST to Notification Service
    → Firebase Cloud Messaging
    → Arrcade App on User's Device(s)
    → Deep-link to relevant module/content
```
