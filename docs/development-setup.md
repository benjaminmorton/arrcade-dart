# Development Setup Guide

How to set up a local development environment, build the app for each platform, and run the supporting services.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Flutter App Setup](#flutter-app-setup)
3. [Code Generation](#code-generation)
4. [Building for Each Platform](#building-for-each-platform)
5. [Notification Service Setup](#notification-service-setup)
6. [Cloud Functions Setup](#cloud-functions-setup)
7. [Documentation Site Setup](#documentation-site-setup)

---

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | Stable channel (3.x) | App framework |
| Dart SDK | >=3.0.0 <4.0.0 | Included with Flutter |
| Node.js | 20 LTS | Notification service, build scripts, cloud functions |
| npm | Bundled with Node | Package management |
| Ruby | 2.7.6 (see `.ruby-version`) | Fastlane for iOS/macOS/Android signing |
| Java JDK | 17 (Zulu recommended) | Android builds |
| Xcode | Latest stable | iOS/macOS builds |
| Android Studio | Latest | Android SDK, emulators |
| Docker | Latest | Notification service, web deployment |
| Firebase CLI | Latest | Cloud functions deployment |
| CocoaPods | Via Gemfile | iOS/macOS native dependencies |

### Optional Software

| Tool | Purpose |
|------|---------|
| VS Code / Android Studio | IDE with Flutter plugin |
| Redis | Local notification service testing |
| Firebase Emulator Suite | Local cloud functions testing |
| create-dmg | macOS .dmg builds |
| Snapcraft | Linux snap builds |

### Install Flutter

```bash
# Clone Flutter SDK (stable channel)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify installation
flutter doctor
```

No `.flutter-version` or `.fvmrc` file exists in the repo — the CI uses the stable channel.

---

## Flutter App Setup

### 1. Install Dependencies

```bash
cd arrcade

# Install Flutter packages
flutter pub get

# Install Ruby dependencies (for Fastlane)
bundle install

# Install Node dependencies (for build scripts)
npm install
```

### 2. Environment Configuration

The app uses `environment_config` to generate build-time constants. Create the environment file:

```bash
# Generate environment.dart with default values
# (BUILD=9999999999, COMMIT=master, FLAVOR=edge)
npm run generate
```

This runs several generation steps:
1. **Environment config** → generates `lib/system/environment.dart` with BUILD, COMMIT, FLAVOR constants
2. **Asset references** → generates `lib/widgets/ui/assets.dart` (LunaAssets class via spider)
3. **build_runner** → generates Hive adapters, JSON serialization, Retrofit clients
4. **Localization** → merges `localization/{module}/{lang}.json` into `assets/localization/{lang}.json`

### 3. Individual Generation Commands

If you need to run generation steps separately:

```bash
# Code generation (Hive adapters, JSON serializable, Retrofit)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
npm run build_runner:watch

# Localization only
dart run scripts/generate_localization.dart

# Asset references only (spider.yaml config)
# Generates LunaAssets class from assets/images/
dart run spider build
```

### 4. Run in Development

```bash
# Run on connected device or emulator
flutter run

# Run with specific flavor
flutter run --dart-define=FLAVOR=edge

# Run on specific device
flutter run -d chrome        # Web
flutter run -d macos          # macOS
flutter run -d windows        # Windows
flutter run -d linux           # Linux
flutter run -d <device-id>    # Specific mobile device
```

### 5. Firebase Configuration (Optional)

For cloud account features, notifications, and backups, you need Firebase config files:

| File | Location | Source |
|------|----------|--------|
| `google-services.json` | `android/app/` | Firebase Console → Project Settings → Android |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase Console → Project Settings → iOS |
| `GoogleService-Info.plist` | `macos/Runner/` | Firebase Console → Project Settings → macOS |

Without these files, the app still builds and runs but cloud features won't work.

---

## Code Generation

### What Gets Generated

| Generator | Config | Input | Output |
|-----------|--------|-------|--------|
| environment_config | `environment_config.yaml` | ENV vars (BUILD, COMMIT, FLAVOR) | `lib/system/environment.dart` |
| hive_generator | `build.yaml` | `@HiveType` annotations | `*.g.dart` adapter files |
| json_serializable | `build.yaml` | `@JsonSerializable` annotations | `*.g.dart` fromJson/toJson |
| retrofit_generator | `build.yaml` | `@RestApi` annotations | `*.g.dart` API clients |
| spider | `spider.yaml` | `assets/images/*.{png,jpg,...}` | `lib/widgets/ui/assets.dart` |
| generate_localization.dart | Script | `localization/{module}/{lang}.json` | `assets/localization/{lang}.json` |

### build.yaml Configuration

```yaml
# JSON serializable settings
json_serializable:
  explicit_to_json: true
  include_if_null: false
```

### Regenerating After Model Changes

```bash
# Full regeneration (recommended after pulling changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (during active development)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Building for Each Platform

### Android

**Requirements**: Java 17, Android SDK (compile SDK 35, min SDK 24, target SDK 35)

**Signing**: Requires `android/key.properties` and `android/key.jks`:

```properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=<alias>
storeFile=../key.jks
```

```bash
# APK (direct install)
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# Via npm scripts
npm run build:android
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk` or `build/app/outputs/bundle/release/app-release.aab`

### iOS

**Requirements**: Xcode (latest stable), CocoaPods, Apple Developer account

```bash
# Install CocoaPods dependencies
cd ios && pod install && cd ..

# Build (no code signing for local testing)
flutter build ios --no-codesign

# Build with signing (via Fastlane)
cd ios && bundle exec fastlane build_appstore && cd ..
```

**Signing**: Uses Fastlane Match for certificate management. Match repo URL configured in `ios/fastlane/Matchfile`.

**Nuke CocoaPods** (if dependency issues):
```bash
npm run cocoapods:nuke
```

### macOS

**Requirements**: Xcode (latest stable), CocoaPods, Apple Developer account

```bash
# Install CocoaPods dependencies
cd macos && pod install && cd ..

# Build
flutter build macos --release

# Build with signing (via Fastlane)
cd macos && bundle exec fastlane build_app_package && cd ..
```

**Notarization**: macOS builds require notarization via `notarytool`. Requires App Store Connect API key.

### Linux

**Requirements**: clang, cmake, ninja-build, libgtk-3-dev, liblzma-dev

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get install clang cmake ninja-build libgtk-3-dev liblzma-dev

# Build
flutter build linux --release

# Output: build/linux/x64/release/bundle/
```

**Packaging**:
```bash
# Debian package
dart run scripts/generate_debian.dart

# Snap package (requires snapcraft)
snapcraft
```

### Windows

**Requirements**: Visual Studio 2022 with C++ desktop workload

```bash
# Build
flutter build windows --release

# MSIX package
flutter pub run msix:create

# Via npm scripts
npm run build:windows
```

**Code signing**: Requires `.pfx` certificate file. Configured in `pubspec.yaml` under `msix_config`.

### Web

```bash
# Build
flutter build web --release

# Via npm scripts
npm run build:web

# Output: build/web/
```

**Docker deployment**:
```bash
# Build Docker image (nginx serves the built web app)
docker build -t arrcade-web .

# Run
docker run -d -p 80:80 arrcade-web
```

---

## Notification Service Setup

### Local Development

```bash
cd arrcade-notification-service

# Install dependencies
npm install

# Copy environment template
cp .env.sample .env

# Edit .env with your credentials
# (See Environment Variables section below)
```

### Environment Variables

Create a `.env` file from `.env.sample`:

```env
# Firebase (required)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@project.iam.gserviceaccount.com
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# External APIs (required)
THEMOVIEDB_API_KEY=your-tmdb-api-key
FANART_TV_API_KEY=your-fanart-tv-api-key

# Redis (required)
REDIS_HOST=localhost
REDIS_PORT=6379

# Redis (optional)
REDIS_USER=
REDIS_PASS=
REDIS_USE_TLS=false

# Server (optional)
PORT=9000
NODE_ENV=development
```

### Running Locally

```bash
# Development mode (with hot reload and pretty logging)
npm run start:dev

# Development mode (JSON logging)
npm start

# Build and run production
npm run build
npm run serve
```

### Running with Docker

```bash
# Build image
docker build -t arrcade-notification-service .

# Run (with env file)
docker run -d \
  --env-file .env \
  -p 9000:9000 \
  arrcade-notification-service

# Or pass env vars directly
docker run -d \
  -e FIREBASE_PROJECT_ID=... \
  -e FIREBASE_CLIENT_EMAIL=... \
  -e FIREBASE_PRIVATE_KEY=... \
  -e FIREBASE_DATABASE_URL=... \
  -e THEMOVIEDB_API_KEY=... \
  -e FANART_TV_API_KEY=... \
  -e REDIS_HOST=... \
  -e REDIS_PORT=6379 \
  -p 9000:9000 \
  arrcade-notification-service
```

### Redis Setup (for local dev)

```bash
# Via Docker
docker run -d --name redis -p 6379:6379 redis:7-alpine

# Or via Homebrew (macOS)
brew install redis
brew services start redis
```

### Testing the Service

```bash
# Health check
curl http://localhost:9000/health

# Test custom notification (replace :id with a Firebase UID or FCM token)
curl -X POST http://localhost:9000/v1/custom/device/:id \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "body": "Hello from dev"}'
```

---

## Cloud Functions Setup

```bash
cd arrcade-cloud-functions/functions

# Install dependencies
npm install

# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Set project
firebase use your-project-id
```

### Local Testing

```bash
# Start emulator
npm run serve

# Or use Firebase shell
npm run shell
```

### Deployment

```bash
# Deploy to Firebase
npm run deploy

# Or manually
firebase deploy --only functions
```

---

## Documentation Site Setup

The docs use GitBook. To run locally:

```bash
cd arrcade-docs

# Install GitBook CLI (if using local preview)
npm install -g gitbook-cli
gitbook install
gitbook serve

# Or simply edit markdown files — GitBook syncs from the repo
```

The documentation is organized via `SUMMARY.md` (table of contents) and individual `.md` files.

---

## Useful Commands Reference

| Command | Location | Purpose |
|---------|----------|---------|
| `flutter pub get` | `arrcade/` | Install Dart dependencies |
| `npm run generate` | `arrcade/` | Run all code generation |
| `dart run build_runner build` | `arrcade/` | Generate Hive/JSON/Retrofit code |
| `npm run build_runner:watch` | `arrcade/` | Watch mode for code generation |
| `npm run cocoapods:nuke` | `arrcade/` | Reset CocoaPods completely |
| `npm run fastlane:update` | `arrcade/` | Update Fastlane dependencies |
| `flutter run` | `arrcade/` | Run app in debug mode |
| `flutter analyze` | `arrcade/` | Run static analysis |
| `npm start` | `notification-service/` | Start dev server |
| `npm run serve` | `cloud-functions/functions/` | Start emulator |
