# Arrcade - Improvements & New Features Checklist

A prioritized checklist of improvements, new features, and technical debt items across all components of the Arrcade project.

---

## Table of Contents

1. [New Module Integrations](#1-new-module-integrations)
2. [Existing Module Enhancements](#2-existing-module-enhancements)
3. [App-Wide Features](#3-app-wide-features)
4. [UI/UX Improvements](#4-uiux-improvements)
5. [Notification Service](#5-notification-service)
6. [Cloud Functions & Backend](#6-cloud-functions--backend)
7. [Documentation](#7-documentation)
8. [Technical Debt & Architecture](#8-technical-debt--architecture)
9. [Testing & Quality](#9-testing--quality)
10. [Platform-Specific](#10-platform-specific)
11. [Security](#11-security)
12. [Performance](#12-performance)

---

## 1. New Module Integrations

- [ ] **Enable Overseerr module** - Module exists but is behind a disabled feature flag; complete implementation and enable it
- [ ] **Jellyfin integration** - Add support for Jellyfin media server management
- [ ] **Emby integration** - Add support for Emby media server management
- [ ] **Plex direct integration** - Manage Plex libraries directly (not just monitoring via Tautulli)
- [ ] **Prowlarr integration** - Replace/supplement Newznab search with Prowlarr indexer manager
- [ ] **Bazarr integration** - Subtitle management for Sonarr and Radarr
- [ ] **Readarr integration** - Book/audiobook management (completes the *arr suite)
- [ ] **Whisparr integration** - Adult content management (completes the *arr suite)
- [ ] **qBittorrent integration** - Torrent download client management
- [ ] **Transmission integration** - Torrent download client management
- [ ] **Deluge integration** - Torrent download client management
- [ ] **rTorrent/ruTorrent integration** - Torrent download client management
- [ ] **Jackett integration** - Alternative indexer proxy support
- [ ] **Requestrr integration** - Chat bot request management
- [ ] **Ombi integration** - Alternative request management to Overseerr
- [ ] **Unmanic integration** - Library file optimizer management
- [ ] **Nginx Proxy Manager integration** - Reverse proxy management

---

## 2. Existing Module Enhancements

### Sonarr

- [ ] **Interactive episode rename** - Rename episodes from within the app with preview
- [ ] **Bulk series editing** - Select multiple series for batch operations (quality profile, tags, monitored)
- [ ] **Season pack search** - Dedicated UI for season pack downloads
- [ ] **Custom format management** - View, create, and edit custom formats
- [ ] **Import list management** - Configure and manage import lists
- [ ] **Indexer management** - Configure indexers from within Arrcade
- [ ] **Download client management** - Configure download clients from within Arrcade
- [ ] **Blocklist management** - View and manage blocked releases
- [ ] **Series statistics** - Disk usage, episode counts, file quality breakdown per series
- [ ] **Episode file details** - View media info (codec, resolution, audio) for episode files

### Radarr

- [ ] **Bulk movie editing** - Select multiple movies for batch operations
- [ ] **Collection management** - View and manage movie collections
- [ ] **Custom format management** - View, create, and edit custom formats
- [ ] **Import list management** - Configure and manage import lists
- [ ] **Indexer management** - Configure indexers from within Arrcade
- [ ] **Download client management** - Configure download clients
- [ ] **Blocklist management** - View and manage blocked releases
- [ ] **Movie recommendations** - Show recommendations based on existing library
- [ ] **Availability calendar improvements** - Better visualization of upcoming movies with posters

### Lidarr

- [ ] **Album details view** - Detailed track listing with file info
- [ ] **Track-level management** - Monitor/unmonitor individual tracks
- [ ] **Wanted/Missing dashboard** - Dedicated view for missing and cutoff unmet albums
- [ ] **Queue management** - Add queue view similar to Sonarr/Radarr
- [ ] **History view** - Add history browsing similar to Sonarr/Radarr
- [ ] **Import list management** - Manage import lists
- [ ] **Parity with Sonarr/Radarr features** - Bring Lidarr module up to same feature depth

### SABnzbd

- [ ] **Server management** - View and configure news servers
- [ ] **Category management** - Create and edit categories
- [ ] **Scheduling** - Configure download schedules
- [ ] **RSS feed management** - Configure RSS feeds
- [ ] **NZB upload** - Upload NZB files directly from device
- [ ] **Speed limit controls** - Quick speed limit adjustments from main view
- [ ] **Post-processing scripts** - View and manage scripts

### NZBGet

- [ ] **Server configuration** - View and edit news server settings
- [ ] **Category management** - Create and edit categories
- [ ] **Extension/script management** - View and manage extensions
- [ ] **NZB upload** - Upload NZB files directly from device
- [ ] **Speed limit controls** - Quick speed limit adjustments
- [ ] **Log viewer** - View NZBGet server logs
- [ ] **Config editor** - Edit NZBGet configuration options

### Tautulli

- [ ] **User management** - View user details, restrict access
- [ ] **Library statistics** - Per-library stats and graphs
- [ ] **Media info** - Detailed media information for items
- [ ] **Notification agent management** - Configure notification agents
- [ ] **History browsing** - Full history search and filtering
- [ ] **Graphs and charts** - More detailed and interactive statistics visualizations
- [ ] **Newsletter management** - Configure and send newsletters
- [ ] **Export statistics** - Export stats to CSV/JSON

### Search (Newznab)

- [ ] **Torznab support** - Add torrent indexer searching alongside Newznab
- [ ] **Search history** - Persistent search history with recent/favorite queries
- [ ] **Batch download** - Select multiple results to send to download clients
- [ ] **Result previewing** - Preview NZB contents before downloading
- [ ] **Indexer health status** - Show indexer availability and response times
- [ ] **Advanced search filters** - Size range, age, poster, group filters
- [ ] **Auto-search** - Search as you type with debouncing

---

## 3. App-Wide Features

### Core Features

- [ ] **Unified search** - Global search across all modules from a single search bar
- [ ] **Widget support** - Home screen widgets for Android and iOS (queue status, now playing, calendar)
- [ ] **Dark/Light theme toggle** - Add light theme option alongside AMOLED dark
- [ ] **Custom accent colors** - Allow users to customize the color scheme beyond module defaults
- [ ] **Biometric authentication** - Fingerprint/Face ID to lock the app
- [ ] **PIN lock** - Simple PIN protection for app access
- [ ] **Multi-language support** - Add translations beyond English (framework already in place)
- [ ] **Offline mode** - Cache recent data for viewing when servers are unreachable
- [ ] **Server status dashboard** - Combined health view of all configured services
- [ ] **Activity log** - Unified timeline of actions taken across all modules
- [ ] **Background sync** - Periodic background data refresh
- [ ] **Drag-and-drop** - Reorder queue items via drag-and-drop (desktop/tablet)

### Notifications

- [ ] **In-app notification center** - Persistent notification inbox within the app
- [ ] **Notification filtering** - Filter/mute specific event types per module
- [ ] **Notification grouping** - Group notifications by module or event type
- [ ] **Notification actions** - Quick actions from notifications (approve request, pause download)
- [ ] **Notification sound customization** - Custom sounds per module/event type
- [ ] **Scheduled quiet hours** - Suppress notifications during set time periods
- [ ] **Notification history** - Browse past notifications within the app

### Data & Sync

- [ ] **Cloud sync** - Sync settings and profiles across devices via Firebase
- [ ] **Import from other apps** - Import configurations from nzb360, Arrcade backups, etc.
- [ ] **Scheduled backups** - Automatic periodic cloud backups
- [ ] **Backup versioning** - Keep multiple backup versions with timestamps
- [ ] **Selective backup/restore** - Choose which modules/profiles to backup or restore

---

## 4. UI/UX Improvements

### Navigation & Layout

- [ ] **Tablet/landscape layout** - Responsive master-detail layout for tablets and landscape mode
- [ ] **Split-view on iPad** - Proper multitasking support with split view
- [ ] **Customizable dashboard** - Drag-and-drop dashboard tiles with configurable widgets
- [ ] **Bottom sheet actions** - Replace popup menus with bottom sheets on mobile for easier reach
- [ ] **Swipe actions on list items** - Swipe to delete, edit, or perform quick actions
- [ ] **Pull-to-refresh everywhere** - Ensure all data views support pull-to-refresh
- [ ] **Infinite scroll pagination** - Replace "load more" buttons with seamless infinite scroll where missing
- [ ] **Breadcrumb navigation** - Show navigation path for deeply nested screens

### Visual

- [ ] **Poster grid improvements** - Larger poster art, lazy loading, zoom/detail on tap
- [ ] **Skeleton loading states** - Replace spinners with skeleton/shimmer loading placeholders
- [ ] **Animation improvements** - Smoother page transitions, hero animations for content cards
- [ ] **Adaptive icons** - Themed icons matching Android 13+ theming
- [ ] **Image gallery** - Full-screen image viewer for posters, fanart, screenshots
- [ ] **Rich media cards** - Show poster/backdrop art in list views, not just grid views

### Content Display

- [ ] **Content ratings** - Show IMDb, TMDB, Rotten Tomatoes scores where available
- [ ] **Trailer playback** - Watch trailers in-app for movies and series
- [ ] **Similar/recommended content** - Show related content suggestions
- [ ] **Content description expansion** - Expandable synopsis/overview sections
- [ ] **File size formatting** - Consistent human-readable file sizes everywhere
- [ ] **Relative timestamps** - "2 hours ago" instead of absolute timestamps where appropriate

---

## 5. Notification Service

### Features

- [ ] **Rate limiting** - Per-user rate limiting to prevent webhook spam
- [ ] **Webhook signature verification** - Validate webhook payloads with HMAC signatures
- [ ] **Basic Auth password validation** - Currently password is not validated (TODO in code)
- [ ] **Notification templates** - User-customizable notification title/body templates
- [ ] **Notification batching** - Batch rapid-fire notifications into digest summaries
- [ ] **Webhook retry mechanism** - Retry failed FCM deliveries with exponential backoff
- [ ] **Dead device cleanup** - Remove stale/invalid FCM tokens from Firestore
- [ ] **Delivery receipts** - Track whether notifications were delivered and opened
- [ ] **Email fallback** - Optional email delivery when push notification fails
- [ ] **Web push support** - Browser push notifications for web users
- [ ] **Telegram integration** - Send notifications to Telegram bots/channels
- [ ] **Discord integration** - Send notifications to Discord webhooks
- [ ] **Slack integration** - Send notifications to Slack channels

### Infrastructure

- [ ] **Health check improvements** - Add dependency health (Redis, Firebase) to health endpoint
- [ ] **Metrics/monitoring** - Prometheus metrics for notification volume, latency, failures
- [ ] **Request validation** - Stricter JSON schema validation for incoming webhooks
- [ ] **API versioning** - Support v2 API alongside v1 for breaking changes
- [ ] **OpenAPI/Swagger documentation** - Auto-generated API documentation
- [ ] **Horizontal scaling** - Stateless design improvements for multi-instance deployment
- [ ] **Message queue** - Replace async fire-and-forget with a proper queue (Bull, RabbitMQ)
- [ ] **Structured logging improvements** - Add request ID correlation across the pipeline
- [ ] **Docker Compose** - Provide docker-compose.yml with Redis included

---

## 6. Cloud Functions & Backend

- [ ] **User data export** - Cloud function to export all user data (GDPR compliance)
- [ ] **Scheduled cleanup** - Periodic cleanup of orphaned data and expired tokens
- [ ] **Usage analytics** - Anonymous aggregate usage statistics (opt-in)
- [ ] **Firebase Functions v2 migration** - Upgrade from v1 to v2 Cloud Functions runtime
- [ ] **Node.js version upgrade** - Upgrade from Node 14 to Node 18/20
- [ ] **Error reporting** - Integrate Cloud Error Reporting for function failures
- [ ] **Account merge** - Function to merge two user accounts
- [ ] **Data migration tools** - Functions to handle schema changes in user data
- [ ] **Firestore security rules audit** - Review and tighten Firestore security rules
- [ ] **Cloud Storage lifecycle rules** - Auto-expire old backups after configurable period

---

## 7. Documentation

### Missing Documentation

- [ ] **Complete Tautulli setup guide** - Currently "Coming Soon"
- [ ] **Complete SABnzbd setup guide** - Currently "Coming Soon"
- [ ] **Complete NZBGet setup guide** - Currently "Coming Soon"
- [ ] **Complete Overseerr setup guide** - Currently "Coming Soon"
- [ ] **Complete Wake on LAN setup guide** - Currently "Coming Soon"
- [ ] **API documentation** - Document the notification service API with examples
- [ ] **Self-hosting notification service guide** - Step-by-step Docker deployment guide
- [ ] **Reverse proxy configuration examples** - Nginx, Caddy, Traefik examples
- [ ] **Troubleshooting guide** - Common issues and solutions
- [ ] **Contributing guide** - How to contribute to the project
- [ ] **Architecture overview** - Technical architecture documentation for developers

### Documentation Improvements

- [ ] **Migrate from GitBook** - Consider migrating to Docusaurus or MkDocs for better customization
- [ ] **Video tutorials** - Screen recordings for setup and configuration
- [ ] **Screenshots** - Add current app screenshots for all modules
- [ ] **Changelog** - Maintain a detailed changelog in documentation
- [ ] **Search functionality** - Ensure docs site has working search
- [ ] **Version-specific docs** - Documentation versioned to match app releases

---

## 8. Technical Debt & Architecture

### Flutter App

- [ ] **Migrate from Hive to Isar** - Hive is less actively maintained; Isar offers better performance and query support
- [ ] **Migrate from Provider to Riverpod** - Better testability, compile-time safety, and less boilerplate
- [ ] **Code generation cleanup** - Ensure all Retrofit/Hive code generation is up to date
- [ ] **Modularize into packages** - Split modules into separate Dart packages for build isolation
- [ ] **Remove disabled Overseerr feature flag** - Either complete or remove the Overseerr code
- [ ] **Consistent API client patterns** - Sonarr and Radarr use Retrofit; Lidarr/SABnzbd/NZBGet use raw Dio; standardize approach
- [ ] **Error handling standardization** - Create unified error types and handling patterns across all modules
- [ ] **Dependency injection** - Replace direct Provider access with proper DI (get_it or injectable)
- [ ] **Route type safety** - Add typed route parameters instead of string-based query params
- [ ] **Remove deprecated APIs** - Audit and remove usage of deprecated Flutter/Dart APIs
- [ ] **Null safety audit** - Ensure full null safety compliance across all files
- [ ] **Dead code removal** - Audit and remove unused models, widgets, and utility code

### Notification Service

- [ ] **Upgrade Firebase Admin SDK** - Currently on v10; upgrade to latest
- [ ] **Upgrade Firebase Functions SDK** - Currently on v3.16; upgrade to latest
- [ ] **TypeScript strict mode** - Enable stricter TypeScript compiler options
- [ ] **Input validation library** - Add Joi or Zod for request body validation
- [ ] **Unit test coverage** - No tests currently exist
- [ ] **Error handling improvements** - More granular error types and responses
- [ ] **Environment variable validation** - Use a library like envalid for env var validation

### Cloud Functions

- [ ] **Upgrade to Firebase Functions v2** - Significant performance and configuration improvements
- [ ] **Add error handling** - Current recursive deletion has minimal error recovery
- [ ] **Upgrade Node.js runtime** - Move from Node 14 to 18 or 20
- [ ] **Add retry logic** - Handle transient Firestore/Storage failures

---

## 9. Testing & Quality

### Flutter App

- [ ] **Unit tests for API clients** - Test all Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli API wrappers
- [ ] **Unit tests for state management** - Test all ChangeNotifier state classes
- [ ] **Widget tests** - Test key UI components and screens
- [ ] **Integration tests** - End-to-end tests for critical user flows
- [ ] **Golden tests** - Visual regression tests for UI consistency
- [ ] **Mock server for development** - Mock API server for developing without real services
- [ ] **CI/CD pipeline** - Automated build, test, and release pipeline
- [ ] **Static analysis** - Configure and enforce Dart analysis rules
- [ ] **Code coverage tracking** - Set up coverage reporting and minimum thresholds

### Notification Service

- [ ] **Unit tests** - Test all controllers, middleware, and payload generators
- [ ] **Integration tests** - Test webhook processing end-to-end with mock Firebase
- [ ] **Load testing** - Verify performance under high webhook volume
- [ ] **CI/CD pipeline** - Automated testing and Docker image publishing

### Cloud Functions

- [ ] **Unit tests** - Test Firestore and Storage cleanup functions
- [ ] **Emulator-based integration tests** - Test with Firebase Local Emulator Suite

---

## 10. Platform-Specific

### Android

- [ ] **Material You / Dynamic Color** - Support Android 12+ dynamic theming
- [ ] **Predictive back gesture** - Android 14 predictive back animation
- [ ] **Per-app language** - Android 13+ per-app language preferences
- [ ] **Monochrome icon** - Themed icon for Android 13+
- [ ] **Notification channels** - Separate Android notification channels per module
- [ ] **App shortcuts** - Extend quick actions with more options

### iOS

- [ ] **Live Activities** - Show download progress on lock screen / Dynamic Island
- [ ] **Focus filters** - Integrate with iOS Focus modes
- [ ] **Lock screen widgets** - iOS 16+ lock screen widgets
- [ ] **Home screen widgets** - WidgetKit widgets for queue, calendar, now playing
- [ ] **Shortcuts app integration** - Siri Shortcuts for common actions
- [ ] **Share extension** - Share URLs to Arrcade for adding content
- [ ] **StoreKit 2 migration** - Modernize in-app purchase handling

### Desktop (macOS/Windows/Linux)

- [ ] **System tray** - Minimize to system tray with status indicator
- [ ] **Keyboard shortcuts** - Full keyboard navigation and shortcuts
- [ ] **Native menu bar** - macOS menu bar integration
- [ ] **Notification center integration** - Native OS notification support
- [ ] **Auto-launch on startup** - Option to start with OS
- [ ] **Multiple windows** - Open modules in separate windows
- [ ] **CLI companion** - Command-line tool for quick actions

### Web

- [ ] **PWA improvements** - Better offline support, install prompts, caching
- [ ] **Service worker** - Background sync and push notifications
- [ ] **Responsive design** - Full responsive layout for all screen sizes
- [ ] **Keyboard shortcuts** - Full keyboard navigation for web
- [ ] **URL-based deep linking** - Shareable URLs for specific content

---

## 11. Security

- [ ] **Encrypted database** - Encrypt Hive boxes at rest (API keys are stored in plaintext)
- [ ] **Certificate pinning** - Optional SSL certificate pinning for paranoid users
- [ ] **API key obfuscation** - Mask API keys in UI and logs
- [ ] **Secure storage** - Use platform keychain/keystore instead of Hive for credentials
- [ ] **Session management** - Token refresh and session timeout for cloud accounts
- [ ] **Audit logging** - Log security-relevant actions (profile changes, backup/restore)
- [ ] **Content Security Policy** - Implement CSP headers for web version
- [ ] **Dependency vulnerability scanning** - Automated dependency audit in CI
- [ ] **Webhook HMAC validation** - Verify webhook authenticity with signatures
- [ ] **Rate limiting in notification service** - Prevent abuse of notification endpoints

---

## 12. Performance

- [ ] **Lazy loading modules** - Only load module code when navigated to
- [ ] **Image optimization** - Resize and compress poster images for thumbnails
- [ ] **Pagination everywhere** - Ensure all large lists use pagination, not full loads
- [ ] **Connection pooling** - Reuse HTTP connections across API calls
- [ ] **Response caching** - Cache API responses with configurable TTL
- [ ] **Reduce app size** - Tree-shake unused assets, compress images, split per-ABI APKs
- [ ] **Startup time optimization** - Profile and optimize cold start time
- [ ] **Memory profiling** - Audit memory usage on low-end devices
- [ ] **Redis connection pooling** - Pool Redis connections in notification service
- [ ] **FCM batch sending** - Batch multiple notifications into single FCM calls where possible
