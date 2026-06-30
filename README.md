# snippet-mobile

A Flutter remote-control client for the [snippet](https://github.com/wacht-platform/snippet)
coding agent. Run `snippet serve` on a machine and drive it from your phone or
Mac: browse and edit files, view git diffs, run commands, manage checkpoints, and
chat with the agent — over an authenticated tunnel.

Runs on **Android** and **macOS** from one adaptive UI (two-pane when wide, a
collapsed sidebar drawer when narrow).

## Features

- **Sessions** across every connected machine — open, resume, rename, delete.
- **Chat** with the agent: streaming replies, inline tool activity, approvals.
- **Files** — browse, view with syntax highlighting, edit (with conflict
  detection), upload, download, create folders, and select/delete.
- **Git** — status, diffs, stage/commit/branch and more, scoped to a session.
- **Attachments** — send images and files (camera/photos/files, drag-and-drop on
  desktop), up to 10 at a time.
- **Notifications** when a session needs input or finishes (Android + macOS).

## Connecting

On the daemon machine, run `snippet serve` — it prints a QR code and a connection
string (`{url, token}`). In the app, add an instance by scanning the QR or pasting
the string. The app talks to the daemon at `http(s)://host[:port]/?token=<token>`.

## Build & run

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```sh
flutter pub get
flutter run -d macos        # desktop
flutter run                 # a connected Android device/emulator
flutter analyze lib         # static analysis
flutter build apk --release --split-per-abi
```

## License

Copyright (C) 2026 snipextt. Licensed under the **GNU Affero General Public
License v3.0 or later** (AGPL-3.0-or-later); see [LICENSE](LICENSE). Contributions
are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
