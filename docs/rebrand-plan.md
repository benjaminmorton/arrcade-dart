# Arrcade — Rebrand & Migration Plan

A step-by-step guide to rebranding the Arrcade fork as **Arrcade** — your self-hosted media server companion app.

> **License**: The project is GPL v3. You may rename, modify, and redistribute freely as long as your fork remains GPL v3, source code is available, and you note that changes were made from the original.

---

## Table of Contents

1. [Prerequisites](#phase-0-prerequisites)
2. [Phase 1: Infrastructure Setup](#phase-1-infrastructure-setup)
3. [Phase 2: Core Identity (Dart Package)](#phase-2-core-identity)
4. [Phase 3: Platform Configs](#phase-3-platform-configs)
5. [Phase 4: Domain & URL References](#phase-4-domain--url-references)
6. [Phase 5: Branding Assets](#phase-5-branding-assets)
7. [Phase 6: Author & Funding References](#phase-6-author--funding-references)
8. [Phase 7: CI/CD & Build Pipeline](#phase-7-cicd--build-pipeline)
9. [Phase 8: Notification Service](#phase-8-notification-service)
10. [Phase 9: Cloud Functions](#phase-9-cloud-functions)
11. [Phase 10: Documentation](#phase-10-documentation)
12. [Phase 11: Legal Compliance](#phase-11-legal-compliance)
13. [Phase 12: Verification](#phase-12-verification)

---

## Naming Convention Used in This Guide

Concrete values for the Arrcade rebrand:

| Placeholder | Value |
|-------------|-------|
| `Arrcade` | `Arrcade` |
| `arrcade` | `arrcade` |
| `Arc` | `Arc` (class prefix replacing `Luna`) |
| `app.arrcade.arrcade` | `app.arrcade.arrcade` |
| `getarrcade.app` | `getarrcade.app` |
| your GitHub username | Your GitHub username |
| `{GITHUB_REPO}` | `arrcade` |
| `{YOUR_NAME}` | Your name for copyright |
| `{YOUR_EMAIL}` | Your contact email |
| your Firebase project ID | Your Firebase project ID |

---

## Phase 0: Prerequisites

Before starting, set up these external services:

- [ ] **Firebase Project** — Create a new project at [console.firebase.google.com](https://console.firebase.google.com)
  - Enable Authentication (Email/Password)
  - Enable Firestore Database
  - Enable Cloud Storage
  - Enable Cloud Messaging (FCM)
  - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS/macOS)
- [ ] **Domain** — Register `getarrcade.app` (and optionally `arrcade.com`, `arrcade.io`)
- [ ] **Apple Developer Account** — Required for iOS/macOS builds ($99/year)
- [ ] **Google Play Developer Account** — Required for Android distribution ($25 one-time)
- [ ] **Redis Instance** — Required for the notification service (can use Docker)
- [ ] **TMDB API Key** — Register at [themoviedb.org](https://www.themoviedb.org/settings/api)
- [ ] **Fanart.tv API Key** — Register at [fanart.tv](https://fanart.tv/get-an-api-key/)
- [ ] **Server/VPS** — To host the notification service (any Docker-capable host)

---

## Phase 1: Infrastructure Setup

### 1.1 Firebase Configuration

- [ ] Create Firebase project (e.g., `arrcade` or `arrcade-app`)
- [ ] Enable Authentication, Firestore, Cloud Storage, Cloud Messaging
- [ ] Create a Cloud Storage bucket named `backup.getarrcade.app` (or any name you choose)
- [ ] Generate a service account key for the notification service
- [ ] Download platform config files:
  - `google-services.json` → `arrcade/android/app/`
  - `GoogleService-Info.plist` → `arrcade/ios/Runner/` and `arrcade/macos/Runner/`

### 1.2 Update Firebase Project References

| File | Change |
|------|--------|
| `arrcade/.firebaserc` | `"default": "comettools-arrcade"` → `"default": "<your-firebase-project>"` |
| `arrcade-cloud-functions/.firebaserc` | `"default": "comettools-arrcade"` → `"default": "<your-firebase-project>"` |

### 1.3 Set Up Code Signing (Apple)

- [ ] Create a new Fastlane Match repo on your GitHub for certificate storage
- [ ] Generate new signing certificates and provisioning profiles
- [ ] Update Matchfiles (see Phase 3)

---

## Phase 2: Core Identity

This is the largest phase — renaming the Dart package and all class prefixes.

### 2.1 Rename Dart Package

| File | Change |
|------|--------|
| `arrcade/pubspec.yaml` | Line 1: `name: arrcade` → `name: arrcade` |

Then **find and replace** across ALL `.dart` files in `arrcade/lib/`:

```
package:arrcade  →  package:arrcade
```

This affects **every single Dart file** (~1300+ files). Use your IDE's project-wide find/replace.

### 2.2 Rename Directory Structure

- [ ] Rename top-level folder: `arrcade/` → `arrcade/` (optional, but consistent)
- [ ] Rename Android Kotlin directory: `android/app/src/main/kotlin/app/arrcade/arrcade/` → `android/app/src/main/kotlin/app/arrcade/arrcade/`

### 2.3 Rename Class Prefixes (Optional but Recommended)

All classes use the `Luna` prefix. To fully rebrand the code:

```
class Luna  →  class Arc
```

For example: `LunaState` → `ArcState`, `LunaDatabase` → `ArcDatabase`, `LunaModule` → `ArcModule`.

**Major classes to rename** (85+ files):

| Class | File |
|-------|------|
| `LunaBIOS` | `lib/system/bios.dart` |
| `LunaState` | `lib/system/state.dart` |
| `LunaModuleState` | `lib/system/state.dart` |
| `LunaLogger` | `lib/system/logger.dart` |
| `LunaDatabase` | `lib/database/database.dart` |
| `LunaConfig` | `lib/database/config.dart` |
| `LunaProfile` | `lib/database/models/profile.dart` |
| `LunaIndexer` | `lib/database/models/indexer.dart` |
| `LunaExternalModule` | `lib/database/models/external_module.dart` |
| `LunaLog` | `lib/database/models/log.dart` |
| `LunaWebhooks` | `lib/system/webhooks.dart` |
| `LunaQuickActions` | `lib/system/quick_actions/quick_actions.dart` |
| `LunaFileSystem` | `lib/system/filesystem/filesystem.dart` |
| `LunaFile` | `lib/system/filesystem/file.dart` |
| `LunaImageCache` | `lib/system/cache/image/image_cache.dart` |
| `LunaMemoryCache` | `lib/system/cache/memory/memory_cache.dart` |
| `LunaMemoryStore` | `lib/system/cache/memory/memory_store.dart` |
| `LunaNetwork` | `lib/system/network/network.dart` |
| `LunaWindowManager` | `lib/system/window_manager/window_manager.dart` |
| `LunaRecoveryMode` | `lib/system/recovery_mode/main.dart` |
| `LunaWakeOnLAN` | `lib/api/wake_on_lan/wake_on_lan.dart` |
| `LunaException` | `lib/types/exception.dart` |
| `LunaParser` | `lib/utils/parser.dart` |
| `LunaUUID` | `lib/utils/uuid.dart` |
| `LunaDialogs` | `lib/utils/dialogs.dart` |
| `LunaProfileTools` | `lib/utils/profile_tools.dart` |
| `LunaValidator` | `lib/utils/validator.dart` |
| `LunaLinkedContent` | `lib/utils/links.dart` |
| `LunaFlavor` | `lib/system/flavor.dart` |
| `LunaBottomNavigationBar` | `lib/widgets/ui/bottom_bar/navigation_bar.dart` |
| `LunaNavigationBarBadge` | `lib/widgets/ui/bottom_bar/badge.dart` |
| `LunaScaffold` | `lib/widgets/ui/scaffold/scaffold.dart` |
| `LunaDrawer` | `lib/widgets/ui/drawer/drawer.dart` |
| `LunaFloatingActionButton` | `lib/widgets/ui/buttons/floating_action_button.dart` |
| `LunaRefreshIndicator` | `lib/widgets/ui/indicators/refresh_indicator.dart` |
| `LunaListTile` | `lib/widgets/ui/list_tile/list_tile.dart` |
| `LunaExpandableListTile` | `lib/widgets/ui/list_tile/expandable_list_tile.dart` |
| `LunaPopupMenuButton` | `lib/widgets/ui/popup_menu/popup_menu_button.dart` |
| `LunaActionBar` | `lib/widgets/ui/action_bar/action_bar.dart` |
| `LunaBadge` | `lib/widgets/ui/badge/badge.dart` |
| `LunaMessage` | `lib/widgets/ui/messages/message.dart` |
| `LunaColours` | `lib/widgets/ui/colours/colours.dart` |
| `LunaModule` | `lib/modules.dart` |
| All widget classes starting with `Luna*` | `lib/widgets/ui/**/*.dart` |

> **Tip**: The class prefix rename is optional for a first pass. You can ship with `Luna*` prefixes internally and just change user-visible names. The package import rename (`package:arrcade`) is mandatory.

### 2.4 Rename Localization Namespace

All localization JSON files use `"arrcade.*"` keys:

| File Pattern | Change |
|-------------|--------|
| `arrcade/assets/localization/*.json` (18+ files) | `"arrcade.Foo"` → `"arrcade.Foo"` keys |
| `arrcade/localization/arrcade/*.json` | Rename directory to `localization/arrcade/` and update key prefixes |

All `.tr()` calls in Dart reference these keys (e.g., `'arrcade.Dashboard'.tr()` → `'arrcade.Dashboard'.tr()`). These must match.

### 2.5 Rename Custom Font

| File | Change |
|------|--------|
| `arrcade/assets/LunaBrandIcons.ttf` | Rename file to `ArcBrandIcons.ttf` |
| `arrcade/pubspec.yaml` | Lines 74-76: `family: LunaBrandIcons` → `family: ArcBrandIcons` |
| `arrcade/lib/widgets/ui/icons/icon.dart` | Update font family reference |

---

## Phase 3: Platform Configs

### 3.1 Android

| File | What to Change |
|------|---------------|
| `android/app/build.gradle` | Line 32: `namespace = "app.arrcade.arrcade"` → `"app.arrcade.arrcade"` |
| `android/app/build.gradle` | Line 49: `applicationId "app.arrcade.arrcade"` → `"app.arrcade.arrcade"` |
| `android/app/src/main/AndroidManifest.xml` | Line 2: `package="app.arrcade.arrcade"` → `"app.arrcade.arrcade"` |
| `android/app/src/main/AndroidManifest.xml` | Line 6: `android:label="Arrcade"` → `"Arrcade"` |
| `android/app/src/debug/AndroidManifest.xml` | Line 3: package → `"app.arrcade.arrcade"` |
| `android/app/src/debug/AndroidManifest.xml` | Line 4: label → `"Arrcade Dev"` |
| `android/app/src/profile/AndroidManifest.xml` | Line 2: package → `"app.arrcade.arrcade"` |
| `android/app/src/main/res/values/strings.xml` | Line 2: `arrcade.app` → `getarrcade.app` |
| `android/app/src/main/kotlin/app/arrcade/arrcade/MainActivity.kt` | Line 1: `package app.arrcade.arrcade` → `package app.arrcade.arrcade` |
| `android/fastlane/Appfile` | `package_name("app.arrcade.arrcade")` → `package_name("app.arrcade.arrcade")` |
| `android/fastlane/Fastfile` | Output filenames: `arrcade-android.*` → `arrcade-android.*` |

- [ ] Move `MainActivity.kt` to match new package path (`kotlin/app/arrcade/arrcade/`)
- [ ] Place your new `google-services.json` in `android/app/`

### 3.2 iOS

| File | What to Change |
|------|---------------|
| `ios/Runner.xcodeproj/project.pbxproj` | All `PRODUCT_BUNDLE_IDENTIFIER = app.arrcade.arrcade` → `app.arrcade.arrcade` |
| `ios/Runner.xcodeproj/project.pbxproj` | All `PROVISIONING_PROFILE_SPECIFIER` → your profiles |
| `ios/Runner/Info.plist` | Line 16: `<string>Arrcade</string>` → `<string>Arrcade</string>` (CFBundleName) |
| `ios/Runner/Runner.entitlements` | Line 7: `webcredentials:www.arrcade.app` → `webcredentials:www.getarrcade.app` |
| `ios/fastlane/Appfile` | `app_identifier("app.arrcade.arrcade")` → `"app.arrcade.arrcade"` |
| `ios/fastlane/Matchfile` | Line 1: git_url → your match repo |
| `ios/fastlane/Matchfile` | Line 3: app_identifier → `"app.arrcade.arrcade"` |

- [ ] Place your new `GoogleService-Info.plist` in `ios/Runner/`

### 3.3 macOS

| File | What to Change |
|------|---------------|
| `macos/Runner/Configs/AppInfo.xcconfig` | Line 1: `PRODUCT_NAME = Arrcade` → `Arrcade` |
| `macos/Runner/Configs/AppInfo.xcconfig` | Line 2: `PRODUCT_BUNDLE_IDENTIFIER = app.arrcade.arrcade` → `app.arrcade.arrcade` |
| `macos/Runner/Configs/AppInfo.xcconfig` | Line 3: `PRODUCT_COPYRIGHT = Copyright © 2023 Jagandeep Brar...` → `Copyright © 2026 {YOUR_NAME}...` |
| `macos/Runner.xcodeproj/project.pbxproj` | All bundle ID and provisioning profile references |
| `macos/Runner/Info.plist` | CFBundleName: `Arrcade` → `Arrcade` |
| `macos/Runner/DebugProfile.entitlements` | Line 17: `app.arrcade.arrcade` → `app.arrcade.arrcade` |
| `macos/Runner/Release.entitlements` | Line 15: `app.arrcade.arrcade` → `app.arrcade.arrcade` |
| `macos/fastlane/Appfile` | `app_identifier("app.arrcade.arrcade")` → `"app.arrcade.arrcade"` |
| `macos/fastlane/Matchfile` | Line 1: git_url → your match repo |
| `macos/fastlane/Matchfile` | Line 3: app_identifier → `"app.arrcade.arrcade"` |

- [ ] Place your new `GoogleService-Info.plist` in `macos/Runner/`

### 3.4 Windows

| File | What to Change |
|------|---------------|
| `pubspec.yaml` | Line 89: `display_name: Arrcade` → `Arrcade` |
| `pubspec.yaml` | Line 91: `execution_alias: arrcade` → `arrcade` |
| `pubspec.yaml` | Line 92: `identity_name: app.arrcade.arrcade` → `app.arrcade.arrcade` |
| `pubspec.yaml` | Line 95: `output_name: arrcade-windows-amd64` → `arrcade-windows-amd64` |
| `windows/runner/Runner.rc` | Window title: `Arrcade` → `Arrcade` |
| `windows/runner/main.cpp` | Window title if present |
| `windows/CMakeLists.txt` | Project name references |

### 3.5 Linux

| File | What to Change |
|------|---------------|
| `linux/CMakeLists.txt` | Line 4: `set(BINARY_NAME "arrcade")` → `"arrcade"` |
| `linux/CMakeLists.txt` | Line 5: `set(APPLICATION_ID "app.arrcade.arrcade")` → `"app.arrcade.arrcade"` |
| `debian/DEBIAN/control` | Line 1: `Package:Arrcade` → `Arrcade` |
| `debian/DEBIAN/control` | Line 4: `Maintainer:Arrcade Support <hello@arrcade.app>` → `{YOUR_NAME} <{YOUR_EMAIL}>` |
| `debian/usr/share/applications/arrcade.desktop` | Rename to `arrcade.desktop`, update Name, Icon, Exec |
| `debian/usr/share/icons/arrcade.png` | Rename to `arrcade.png` |
| `snap/snapcraft.yaml` | Line 1: `name: arrcade` → `arrcade` |
| `snap/snapcraft.yaml` | Line 12+: dbus slot name, app name, parts name |
| `snap/gui/arrcade.desktop` | Rename to `arrcade.desktop`, update Name, Icon, Exec |
| `snap/gui/arrcade.png` | Rename to `arrcade.png` |

### 3.6 Web

| File | What to Change |
|------|---------------|
| `web/manifest.json` | Line 2: `"name": "Arrcade"` → `"Arrcade"` |
| `web/manifest.json` | Line 3: `"short_name": "Arrcade"` → `"Arrcade"` |
| `web/manifest.json` | Line 8: description → your description |
| `web/index.html` | Title tag if present |
| `web/browserconfig.xml` | Any name references |

---

## Phase 4: Domain & URL References

You need to either register your own domain and host these services, or update the URLs to point to your infrastructure.

### 4.1 Notification Service URL

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade/lib/system/webhooks.dart` | `https://notify.arrcade.app/v1/` | `https://notify.getarrcade.app/v1/` |

### 4.2 Website URL

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade/lib/utils/links.dart` | `https://www.arrcade.app` | `https://www.getarrcade.app` |
| `arrcade/README.md` | `www.arrcade.app` | `www.getarrcade.app` |
| `android/app/src/main/res/values/strings.xml` | `https://www.arrcade.app/.well-known/assetlinks.json` | `https://www.getarrcade.app/.well-known/assetlinks.json` |
| `ios/Runner/Runner.entitlements` | `webcredentials:www.arrcade.app` | `webcredentials:www.getarrcade.app` |

### 4.3 Documentation URL

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade/lib/modules.dart` | `https://docs.arrcade.app/...` (5 references) | `https://docs.getarrcade.app/...` |
| `arrcade-notification-service/src/server/server.ts` | `https://docs.arrcade.app/arrcade/notifications` | `https://docs.getarrcade.app/arrcade/notifications` |

### 4.4 Build/Download URLs

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade/lib/system/flavor.dart` | `https://builds.arrcade.app/#latest` | `https://builds.getarrcade.app/#latest` or remove |
| `arrcade/scripts/generate_changelog.dart` | `https://downloads.arrcade.app/latest/` | Your download URL |
| `arrcade/.github/scripts/notify_discord_embed.js` | Build URL references | Your URLs |

### 4.5 Backup Storage URL

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade-cloud-functions/functions/src/services/storage/index.ts` | `backup.arrcade.app` | Your Cloud Storage bucket name |

### 4.6 Email

| File | Old Value | New Value |
|------|-----------|-----------|
| `arrcade/README.md` | `hello@arrcade.app` | `{YOUR_EMAIL}` |
| `arrcade/debian/DEBIAN/control` | `hello@arrcade.app` | `{YOUR_EMAIL}` |

---

## Phase 5: Branding Assets

### 5.1 App Icons

Replace these files with your own designs:

| File | Purpose | Size/Format |
|------|---------|-------------|
| `assets/icon/icon.png` | Primary app icon | 1024x1024 PNG |
| `assets/icon/icon_adaptive.png` | Android adaptive icon foreground | 1024x1024 PNG |
| `assets/icon/icon_windows.png` | Windows icon | 256x256 PNG |
| `assets/icon/icon_web.png` | Web favicon source | 512x512 PNG |

After replacing, run the icon generator (flutter_launcher_icons in pubspec.yaml) to propagate to all platforms:
```bash
flutter pub run flutter_launcher_icons
```

### 5.2 Branding Images

| File | Purpose |
|------|---------|
| `assets/images/branding_full.png` | Full logo with text (used in drawer, about screen) |
| `assets/images/branding_logo.png` | Logo mark only (used in app bar, splash) |

### 5.3 Platform-Specific Icons (auto-generated, but verify)

| Directory | Platform |
|-----------|----------|
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | iOS icons (multiple sizes) |
| `macos/Runner/Assets.xcassets/AppIcon.appiconset/` | macOS icons (multiple sizes) |
| `web/icons/` | Web icons and favicons |
| `web/favicon.png` | Browser tab icon |
| `debian/usr/share/icons/arrcade.png` | Linux icon |
| `snap/gui/arrcade.png` | Snap package icon |

### 5.4 Custom Icon Font

| File | Action |
|------|--------|
| `assets/LunaBrandIcons.ttf` | Replace or rename. If you keep the same module icons, just rename the file. |
| `pubspec.yaml` | Update font family name |
| `lib/widgets/ui/icons/icon.dart` | Update font family reference |

---

## Phase 6: Author & Funding References

### 6.1 GitHub Funding

| File | Change |
|------|--------|
| `arrcade/.github/FUNDING.yml` | Replace `github: jagandeepbrar` and `ko_fi: jagandeepbrar` with your accounts (or delete file) |

### 6.2 Issue Templates

| File | Change |
|------|--------|
| `arrcade/.github/ISSUE_TEMPLATE/config.yml` | Line 7: `https://github.com/JagandeepBrar/arrcade/discussions` → your repo |

### 6.3 Package Metadata

| File | Change |
|------|--------|
| `arrcade/package.json` | `"name": "arrcade"` → `"{app_name}"` |
| `arrcade-notification-service/package.json` | `"name"`, `"repository"`, `"author"` fields |

### 6.4 Copyright Notice

| File | Change |
|------|--------|
| `macos/Runner/Configs/AppInfo.xcconfig` | `Copyright © 2023 Jagandeep Brar` → `Copyright © 2026 {YOUR_NAME}` |

---

## Phase 7: CI/CD & Build Pipeline

### 7.1 GitHub Actions Workflows

All workflow files reference `JagandeepBrar/arrcade` for artifact paths and Docker tags. Update every occurrence:

| File | References to Change |
|------|---------------------|
| `.github/workflows/build.yml` | Repo references, artifact names |
| `.github/workflows/prepare.yml` | Build bucket paths |
| `.github/workflows/build_android.yml` | Artifact upload paths (`JagandeepBrar/arrcade`) |
| `.github/workflows/build_ios.yml` | Artifact upload paths |
| `.github/workflows/build_linux.yml` | Artifact upload paths |
| `.github/workflows/build_macos.yml` | Artifact upload paths |
| `.github/workflows/build_web.yml` | Docker image: `ghcr.io/jagandeepbrar/arrcade:${tag}` → `ghcr.io/<your-github-user>/arrcade:${tag}` |
| `.github/workflows/build_windows.yml` | Artifact upload paths |
| `.github/scripts/notify_discord_embed.js` | Build URLs, Discord webhook references |

### 7.2 Docker

| File | Change |
|------|--------|
| `arrcade/Dockerfile` | Line 20: `LABEL org.opencontainers.image.source` → your repo URL |
| `arrcade-notification-service/Dockerfile` | Line 2: `LABEL org.opencontainers.image.source` → your repo URL |
| `arrcade-notification-service/.github/workflows/build.yaml` | Docker image tags → `ghcr.io/<your-github-user>/arrcade-notification-service` |

### 7.3 Fastlane

| File | Change |
|------|--------|
| `ios/fastlane/Matchfile` | Line 1: `git_url` → your match storage repo |
| `macos/fastlane/Matchfile` | Line 1: `git_url` → your match storage repo |
| All `Fastfile` references | Output filenames, keychain names |

---

## Phase 8: Notification Service

### 8.1 Code Changes

| File | Change |
|------|--------|
| `arrcade-notification-service/package.json` | `name`, `repository`, `author` |
| `arrcade-notification-service/src/server/server.ts` | Redirect URL on line 9 |
| `arrcade-notification-service/Dockerfile` | Image source label |
| `arrcade-notification-service/README.md` | All branding and author references |
| `arrcade-notification-service/LICENSE` | Keep GPL v3, optionally add your copyright line |

### 8.2 Deployment

- [ ] Set up your own server/VPS to host the notification service
- [ ] Configure environment variables with YOUR Firebase credentials, TMDB key, Fanart.tv key, Redis connection
- [ ] Update DNS: point `notify.getarrcade.app` to your server
- [ ] Deploy via Docker: `docker run -d -p 9000:9000 --env-file .env your-image`

---

## Phase 9: Cloud Functions

### 9.1 Code Changes

| File | Change |
|------|--------|
| `arrcade-cloud-functions/.firebaserc` | Firebase project ID |
| `arrcade-cloud-functions/functions/src/services/storage/index.ts` | Bucket name: `backup.arrcade.app` → your bucket |

### 9.2 Deployment

```bash
cd arrcade-cloud-functions
firebase deploy --only functions --project <your-firebase-project>
```

---

## Phase 10: Documentation

### 10.1 Documentation Site

| File/Area | Change |
|-----------|--------|
| `arrcade-docs/README.md` | All "Arrcade" references → `Arrcade` |
| `arrcade-docs/**/*.md` | All documentation content referencing Arrcade |
| `arrcade-docs/releases/*.md` | All download links (build bucket, GitHub releases) |
| `arrcade-docs/getting-started/donations.md` | Remove/replace original author donation links |
| `arrcade-docs/getting-started/frequently-asked-questions.md` | Update Discord, Reddit, email, GitHub links |
| `arrcade-docs/.gitbook/assets/` | Replace any Arrcade-branded screenshots |

### 10.2 READMEs

| File | Change |
|------|--------|
| `README.md` (root) | Complete rewrite |
| `arrcade/README.md` | Complete rewrite — remove all original author links, add yours |
| `arrcade-notification-service/README.md` | Complete rewrite |

---

## Phase 11: Legal Compliance

### 11.1 License Obligations (GPL v3)

- [ ] **Keep GPL v3 license files** in both `arrcade/LICENSE.md` and `arrcade-notification-service/LICENSE`
- [ ] **Add a copyright notice** for your modifications. Add a line at the top of each LICENSE file or in a separate NOTICE file:
  ```
  Original work Copyright © Jagandeep Brar
  Modified work Copyright © 2026 {YOUR_NAME}

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 3.
  ```
- [ ] **State changes clearly** — Add a `NOTICE.md` or `CHANGES.md` documenting that this is a fork:
  ```
  This project is a fork of Arrcade (https://github.com/JagandeepBrar/Arrcade)
  originally created by Jagandeep Brar, licensed under GPL v3.

  This fork has been rebranded and is maintained by {YOUR_NAME}.
  ```
- [ ] **Keep source code public** — Your repo must remain public (or source must be available on request) since GPL v3 requires source distribution
- [ ] **Do NOT remove** the GPL v3 license text itself

### 11.2 What You May Freely Do

- Change the name, branding, and all visual identity
- Remove the original author's funding/donation links
- Add your own monetization (as long as source stays GPL v3)
- Publish to app stores under your own accounts
- Host your own infrastructure
- Add or remove features

---

## Phase 12: Verification

After completing all changes, verify nothing was missed:

### 12.1 Search Verification

Run these searches and confirm zero results (excluding your NOTICE/CHANGES files):

```bash
# Should return 0 results (excluding legal notice files)
grep -ri "arrcade" --include="*.dart" -l | head -20
grep -ri "jagandeepbrar" -l
grep -ri "comettools" -l
grep -ri "arrcade\.app" -l
grep -ri "app\.arrcade\.arrcade" -l
```

### 12.2 Build Verification

- [ ] `flutter pub get` completes without errors
- [ ] `flutter build apk` (Android)
- [ ] `flutter build ios` (iOS)
- [ ] `flutter build macos` (macOS)
- [ ] `flutter build linux` (Linux)
- [ ] `flutter build windows` (Windows)
- [ ] `flutter build web` (Web)
- [ ] Notification service: `npm run build` completes
- [ ] Cloud functions: `npm run build` completes

### 12.3 Runtime Verification

- [ ] App launches on at least one platform
- [ ] Profile creation works
- [ ] At least one service connection works (e.g., Sonarr)
- [ ] Notification service receives a test webhook
- [ ] Cloud account creation works (if Firebase is configured)
- [ ] Backup/restore works

---

## Quick Reference: Find & Replace Summary

| Search | Replace | Scope |
|--------|---------|-------|
| `package:arrcade` | `package:arrcade` | All `.dart` files |
| `app.arrcade.arrcade` | `app.arrcade.arrcade` | All config files |
| `Arrcade` (display name) | `Arrcade` | Manifests, plists, desktop entries |
| `arrcade` (binary/package name) | `arrcade` | pubspec.yaml, CMake, snap, debian |
| `Luna` (class prefix) | `Arc` | All Dart class definitions (optional) |
| `www.arrcade.app` | `www.getarrcade.app` | Dart source, config files |
| `notify.arrcade.app` | `notify.getarrcade.app` | webhooks.dart |
| `docs.arrcade.app` | `docs.getarrcade.app` | modules.dart, server.ts |
| `builds.arrcade.app` | `builds.getarrcade.app` | flavor.dart, CI scripts |
| `backup.arrcade.app` | `backup.getarrcade.app` (or your bucket name) | Cloud functions |
| `hello@arrcade.app` | `hello@getarrcade.app` (or your email) | README, debian control |
| `comettools-arrcade` | Your Firebase project ID | .firebaserc files |
| `jagandeepbrar` / `JagandeepBrar` | Your GitHub username | CI/CD, Docker, funding |
| `Jagandeep Brar` | Your name | Copyright, package.json |
| `ghcr.io/jagandeepbrar/arrcade` | `ghcr.io/<your-github-user>/arrcade` | Docker configs, CI/CD |
| `git@github.com:JagandeepBrar/fastlane-match-storage.git` | Your match repo URL | Matchfiles |
| `LunaBrandIcons` | `ArcBrandIcons` | pubspec.yaml, icon.dart |

---

## Estimated Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Phase 0: Prerequisites | 2-4 hours | Firebase setup, accounts, API keys |
| Phase 1: Infrastructure | 1-2 hours | Firebase config, code signing |
| Phase 2: Core Identity | 1-2 hours | Mostly automated find/replace |
| Phase 3: Platform Configs | 2-3 hours | Manual edits across platforms |
| Phase 4: URLs | 30 min | Straightforward replacements |
| Phase 5: Branding Assets | 2-8 hours | Depends on design effort for new icons/logo |
| Phase 6: Author References | 30 min | Quick replacements |
| Phase 7: CI/CD | 1-2 hours | Workflow updates |
| Phase 8: Notification Service | 2-4 hours | Deploy and configure |
| Phase 9: Cloud Functions | 1 hour | Deploy to your Firebase |
| Phase 10: Documentation | 2-4 hours | Content updates |
| Phase 11: Legal | 30 min | Add notices |
| Phase 12: Verification | 2-4 hours | Build and test all platforms |
