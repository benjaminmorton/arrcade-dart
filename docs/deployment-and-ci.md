# Deployment & CI/CD Guide

Complete reference for the build pipeline, GitHub Actions workflows, required secrets, code signing, release process, and deployment of all services.

---

## Table of Contents

1. [CI/CD Architecture](#cicd-architecture)
2. [GitHub Actions Workflows](#github-actions-workflows)
3. [Required GitHub Secrets](#required-github-secrets)
4. [Code Signing Setup](#code-signing-setup)
5. [Release Process](#release-process)
6. [Notification Service Deployment](#notification-service-deployment)
7. [Cloud Functions Deployment](#cloud-functions-deployment)
8. [Web App Deployment](#web-app-deployment)

---

## CI/CD Architecture

The build system uses GitHub Actions with a hub-and-spoke model:

```
build.yml (orchestrator)
    │
    ├── prepare.yml (shared prep)
    │   ├── Calculate build number (base 1000000000 + commit count)
    │   ├── Read version from package.json
    │   ├── Generate environment.dart
    │   ├── Generate localization files
    │   ├── Run build_runner (code generation)
    │   └── Upload core artifacts
    │
    ├── build_android.yml
    │   ├── Play Store (.aab via Fastlane)
    │   └── Direct Install (.apk via Fastlane)
    │
    ├── build_ios.yml
    │   └── App Store (.ipa via Fastlane + Match)
    │
    ├── build_macos.yml
    │   ├── App Store (.pkg via Fastlane)
    │   ├── Direct Package (.zip, notarized)
    │   └── Disk Image (.dmg, notarized)
    │
    ├── build_linux.yml
    │   ├── Debian (.deb)
    │   ├── Tarball (.tar.gz)
    │   └── Snap (.snap via Snapcraft)
    │
    ├── build_web.yml
    │   ├── Hosted (raw build/web/)
    │   ├── Archive (.zip)
    │   └── Docker (multi-arch, pushed to ghcr.io)
    │
    └── build_windows.yml
        ├── Archive (.zip)
        └── MSIX Installer (.msix, code signed)
```

### Build Triggers

| Trigger | Flavor | Notes |
|---------|--------|-------|
| Push to `master` | `edge` | Automatic on every merge |
| Manual dispatch | `edge`, `beta`, or `stable` | Selectable via GitHub Actions UI |

### Build Number Calculation

```
build_number = 1000000000 + total_commit_count
```

This ensures monotonically increasing build numbers required by app stores.

---

## GitHub Actions Workflows

### Shared Preparation (`prepare.yml`)

Runs before all platform builds. Outputs:

| Output | Description | Example |
|--------|-------------|---------|
| `build` | Build number | `1000000547` |
| `version` | Semantic version from package.json | `11.0.0` |
| `flavor` | Build channel | `edge`, `beta`, `stable` |
| `title` | Full version string | `11.0.0+1000000547 (edge)` |
| `motd` | Message of the day | Build info string |

Steps:
1. Checkout code
2. Setup Node.js 20
3. Count commits → build number
4. Read version from `package.json` via `jq`
5. Generate `environment.dart` with `environment_config:generate`
6. Generate localization with `dart run scripts/generate_localization.dart`
7. Run `build_runner build` for Hive/JSON/Retrofit code generation
8. Upload generated files as artifact (`core`)

### Reusable Build Action (`prepare_for_build/action.yml`)

Sets up the build environment for each platform:

| Platform | Setup Steps |
|----------|-------------|
| All | Checkout, download core artifacts, create output/keys dirs, Flutter stable, Node 20 |
| Android | Java 17 (Zulu), Ruby, Android platform tools |
| iOS | Ruby, Xcode (latest-stable), SSH agent for Match, keychain |
| macOS | Ruby, Xcode (latest-stable), SSH agent for Match, keychain |
| Linux | Desktop support enabled, clang, cmake, ninja-build, gtk3, lzma |
| Web | Docker buildx |
| Windows | (uses GitHub Windows runner defaults) |

Secret files are decoded from base64 GitHub secrets into:

| Secret | Decoded To |
|--------|-----------|
| `APPLE_STORE_CONNECT_KEY` | `keys/appstore.p8` |
| `CODE_SIGNING_CERTIFICATE` | `keys/codesigning.pfx` |
| Google Play service account | `keys/googleplay.json` |
| `KEY_JKS` | `keys/android/key.jks` |
| `KEY_PROPERTIES` | `keys/android/key.properties` |

### Platform Workflows

#### Android (`build_android.yml`)

| Job | Build Command | Fastlane Lane | Output |
|-----|--------------|---------------|--------|
| Play Store | `flutter build appbundle` | `build_aab` | `arrcade-android.aab` |
| Direct Install | `flutter build apk` | `build_apk` | `arrcade-android.apk` |

Fastlane also has a `deploy_playstore` lane for uploading to Google Play.

#### iOS (`build_ios.yml`)

| Job | Build Command | Fastlane Lane | Output |
|-----|--------------|---------------|--------|
| App Store | `flutter build ios --no-codesign` | `build_appstore` | `arrcade-ios.ipa` |

Signing is handled by Fastlane Match (fetches certificates from a private Git repo).

#### macOS (`build_macos.yml`)

| Job | Fastlane Lane | Notarized | Output |
|-----|---------------|-----------|--------|
| App Store | `build_app_store` | N/A (Apple reviews) | `arrcade-macos.pkg` |
| Direct Package | `build_app_package` | Yes | `arrcade-macos.zip` |
| Disk Image | `build_disk_image` | Yes | `arrcade-macos.dmg` |

DMG build requires additional tools: `graphicsmagick`, `imagemagick`, `create-dmg`.

#### Linux (`build_linux.yml`)

| Job | Method | Output |
|-----|--------|--------|
| Debian | `flutter build linux` + `generate_debian.dart` | `arrcade-linux-amd64.deb` |
| Tarball | `flutter build linux` + `tar` | `arrcade-linux-amd64.tar.gz` |
| Snap | `snapcore/action-build` | `arrcade-linux-amd64.snap` |

No secrets required for Linux builds.

#### Web (`build_web.yml`)

| Job | Method | Output |
|-----|--------|--------|
| Hosted | `npm run build:web` | Raw `build/web/` directory |
| Archive | Zip of `build/web/` | `arrcade-web.zip` |
| Docker | Multi-platform build (amd64 + arm64) | `ghcr.io/{user}/arrcade:{tag}` |

Docker tags are based on flavor:
- `edge` → `:edge`
- `beta` → `:beta`
- `stable` → `:latest` and `:stable`

#### Windows (`build_windows.yml`)

| Job | Method | Output |
|-----|--------|--------|
| Archive | `npm run build:windows` + PowerShell Compress-Archive | `arrcade-windows-amd64.zip` |
| MSIX | `flutter pub run msix:create` with certificate | `arrcade-windows-amd64.msix` |

---

## Required GitHub Secrets

### Android

| Secret | Type | Description |
|--------|------|-------------|
| `KEY_JKS` | Base64 | Android signing keystore (`.jks` file) |
| `KEY_PROPERTIES` | Base64 | Keystore properties file (alias, passwords, store path) |

**Generating Android signing key**:
```bash
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Encode for GitHub secret
base64 -i key.jks | pbcopy
```

**key.properties format**:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../keys/android/key.jks
```

### iOS

| Secret | Type | Description |
|--------|------|-------------|
| `APPLE_ID` | String | Apple Developer account email |
| `APPLE_ITC_TEAM_ID` | String | iTunes Connect Team ID |
| `APPLE_TEAM_ID` | String | Apple Developer Team ID |
| `IOS_CODESIGNING_IDENTITY` | String | Signing certificate identity name |
| `MATCH_KEYCHAIN_NAME` | String | Name for the temporary keychain |
| `MATCH_KEYCHAIN_PASSWORD` | String | Password for the temporary keychain |
| `MATCH_PASSWORD` | String | Encryption password for Match repo |
| `MATCH_SSH_PRIVATE_KEY` | Base64 | SSH key to access the Match certificate repo |

### macOS

All iOS secrets above, plus:

| Secret | Type | Description |
|--------|------|-------------|
| `APPLE_STORE_CONNECT_ISSUER_ID` | String | App Store Connect API Issuer ID |
| `APPLE_STORE_CONNECT_KEY` | Base64 | App Store Connect API key (`.p8` file) |
| `APPLE_STORE_CONNECT_KEY_ID` | String | App Store Connect API Key ID |
| `MACOS_INSTALLER_CERT_APP_STORE` | Base64 | Mac Installer certificate for App Store |
| `MACOS_INSTALLER_CERT_DIRECT` | Base64 | Mac Installer certificate for direct distribution |

### Windows

| Secret | Type | Description |
|--------|------|-------------|
| `CODE_SIGNING_CERTIFICATE` | Base64 | Code signing certificate (`.pfx` file) |
| `CODE_SIGNING_PASSWORD` | String | Certificate password |

### Web / Docker

No additional secrets — uses `GITHUB_TOKEN` (auto-provided) for pushing to `ghcr.io`.

### Notification Service

| Secret | Type | Description |
|--------|------|-------------|
| (Uses GitHub token) | Auto | For pushing Docker image to `ghcr.io` |

---

## Code Signing Setup

### Fastlane Match (iOS/macOS)

Match stores signing certificates and provisioning profiles in a private Git repo.

**Setup for your fork**:
1. Create a private repo for certificate storage (e.g., `your-user/fastlane-match-storage`)
2. Update Matchfiles:

```ruby
# ios/fastlane/Matchfile
git_url("git@github.com:your-user/fastlane-match-storage.git")
type("development")
app_identifier(["com.yourname.yourapp"])

# macos/fastlane/Matchfile
git_url("git@github.com:your-user/fastlane-match-storage.git")
type("development")
app_identifier("com.yourname.yourapp")
```

3. Generate certificates:
```bash
# iOS
cd ios
bundle exec fastlane match development
bundle exec fastlane match appstore

# macOS
cd macos
bundle exec fastlane match development
bundle exec fastlane match appstore
```

### Android Keystore

```bash
# Generate keystore
keytool -genkey -v -keystore key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Create key.properties
cat > android/key.properties << EOF
storePassword=your-password
keyPassword=your-password
keyAlias=upload
storeFile=../keys/android/key.jks
EOF
```

### Windows Code Signing

Requires a code signing certificate from a CA (e.g., DigiCert, Sectigo) or a self-signed certificate for testing:

```powershell
# Self-signed for testing
New-SelfSignedCertificate -Type Custom -Subject "CN=Your Name" `
  -KeyUsage DigitalSignature -FriendlyName "Your App Signing" `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
```

---

## Release Process

### Version Management

The project uses **Commitizen** (`.czrc`) for conventional commits and **standard-version** (`.versionrc`) for release management.

**Commit types**:
- `feat:` — new feature
- `fix:` — bug fix
- `chore:` — maintenance
- `docs:` — documentation
- `refactor:` — code restructuring
- `release:` — version bump

### Creating a Release

```bash
cd arrcade

# 1. Bump version (updates package.json, pubspec.yaml, snapcraft.yaml, CHANGELOG.md)
npm run release -- --release-as 12.0.0

# 2. Review generated CHANGELOG.md

# 3. Commit and tag
git add -A
git commit -m "release: v12.0.0"
git tag v12.0.0

# 4. Push to trigger CI
git push origin master --tags
```

### Build Flavors

| Flavor | Trigger | Use Case |
|--------|---------|----------|
| `edge` | Every push to master | Nightly/cutting-edge builds |
| `beta` | Manual dispatch | Pre-release testing |
| `stable` | Manual dispatch | Production releases |

To trigger a specific flavor, go to GitHub Actions → build.yml → Run workflow → select flavor.

### Changelog Generation

```bash
# Generate changelog JSON (used in-app)
dart run scripts/generate_changelog.dart
```

This script:
1. Compares current version against published releases
2. Parses conventional commit messages
3. Outputs `changelog.json` or `changelog_stable.json`
4. Groups by commit type and feature area

---

## Notification Service Deployment

### Docker (Recommended)

```bash
cd arrcade-notification-service

# Build
docker build -t your-registry/notification-service:latest .

# Push to registry
docker push your-registry/notification-service:latest
```

**Docker image details**:
- Base: `node:18-alpine`
- Init system: `tini`
- Exposed port: `9000`
- Entry: `npm run docker` (runs compiled JS via ts-node)

### Docker Compose (Recommended for Self-Hosting)

Create a `docker-compose.yml`:

```yaml
version: '3.8'
services:
  notification-service:
    image: your-registry/notification-service:latest
    ports:
      - "9000:9000"
    environment:
      - FIREBASE_PROJECT_ID=your-project
      - FIREBASE_CLIENT_EMAIL=your-email
      - FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
      - FIREBASE_PRIVATE_KEY=${FIREBASE_PRIVATE_KEY}
      - THEMOVIEDB_API_KEY=${TMDB_KEY}
      - FANART_TV_API_KEY=${FANART_KEY}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - NODE_ENV=production
    depends_on:
      - redis
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    restart: unless-stopped

volumes:
  redis-data:
```

```bash
# Start
docker compose up -d

# Check health
curl http://localhost:9000/health
```

### CI/CD for Notification Service

The notification service has its own GitHub Actions workflow at `.github/workflows/build.yaml`:
- Triggers on push to main branch
- Builds multi-platform Docker image (linux/amd64)
- Pushes to `ghcr.io`

### Reverse Proxy Setup

Put behind nginx/Caddy/Traefik with HTTPS:

```nginx
# nginx example
server {
    listen 443 ssl;
    server_name notify.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Cloud Functions Deployment

### Setup

```bash
cd arrcade-cloud-functions

# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Set your project
firebase use your-project-id

# Install function dependencies
cd functions && npm install && cd ..
```

### Deploy

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy with pre-deploy lint and build (configured in firebase.json)
# Automatically runs: npm run lint && npm run build
```

### Local Testing

```bash
cd functions

# Start emulator
npm run serve
# This runs: npm run build && firebase emulators:start --only functions

# Or use functions shell for interactive testing
npm run shell
```

### Firebase Configuration

`firebase.json`:
```json
{
  "functions": {
    "predeploy": [
      "npm --prefix \"$RESOURCE_DIR\" run lint",
      "npm --prefix \"$RESOURCE_DIR\" run build"
    ]
  }
}
```

---

## Web App Deployment

### Static Hosting (Nginx)

The Flutter web build produces static files that can be served by any web server:

```bash
# Build
cd arrcade
flutter build web --release

# Copy to web server
cp -r build/web/* /var/www/html/
```

### Docker

The Dockerfile is a multi-stage build:
1. **Build stage**: Debian base, installs Flutter, runs `flutter build web`
2. **Runtime stage**: `nginx:alpine` serves built files from `/usr/share/nginx/html`

```bash
# Build image (supports multi-platform)
docker buildx build --platform linux/amd64,linux/arm64 -t your-app-web .

# Run
docker run -d -p 80:80 your-app-web
```

### Hosted Flavors

The original project hosted three web instances by flavor:
- `stable.arrcade.app` — stable builds
- `beta.arrcade.app` — beta builds
- `edge.arrcade.app` — edge builds

For your fork, configure your DNS and hosting accordingly.
