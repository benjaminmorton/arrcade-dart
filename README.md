# <img width="40px" src="./arrcade/assets/images/branding_logo.png" alt="Arrcade"></img>&nbsp;&nbsp;Arrcade

A self-hosted media server companion app that provides a unified interface for managing your media stack — Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli, and Newznab indexers.

Built with Flutter, available on Android, iOS, macOS, Windows, Linux, and Web.

## Project Structure

| Directory | Description |
|---|---|
| `arrcade/` | Flutter app (main client) |
| `arrcade-notification-service/` | Push notification relay service |
| `arrcade-cloud-functions/` | Firebase cloud functions |
| `arrcade-docs/` | Documentation site (GitBook) |

## Features

- Manage and monitor Sonarr, Radarr, and Lidarr from a single app
- Control SABnzbd and NZBGet download clients
- View Tautulli/Plex activity and history
- Search Newznab-compatible indexers
- Push notifications via webhook relay service
- Multi-profile support for managing multiple servers
- AMOLED dark theme with Material Design 3

## Getting Started

```bash
cd arrcade
flutter pub get
flutter run
```

See the `arrcade-docs/` directory for full documentation.
