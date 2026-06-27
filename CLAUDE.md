# snippet-mobile — project instructions

Flutter remote-control client for the snippet `serve` daemon (Dart package
`snippet`, Android appId `com.snippet`). The daemon repo is `snippet`
(`~/snippet` on the box) — see its **HANDOFF.md** for the full picture, the
daemon API, and the deploy runbook.

## Conventions (must follow)
- Author commits as **snipextt@gmail.com** (never [redacted]).
- **No branding** in commit messages — no `Co-Authored-By`, no "Generated with Claude Code".
- Keep code comments **lean and sparse**.
- **Never expose** the user's API key or the serve token.

## Build (box)
- Env: `PATH=~/flutter/bin:$PATH`, `JAVA_HOME=~/jdk`, `ANDROID_SDK_ROOT=~/Android`.
- Always `flutter analyze lib` before `flutter build apk --release --split-per-abi`.
- APK download staging: `~/apk-serve/snippet.apk` (served via `python3 -m http.server`
  + a cloudflared quick tunnel).

## Layout
- `lib/api.dart` (DaemonClient), `lib/models.dart`, `lib/widgets.dart`,
  `lib/theme.dart`, `lib/screens/*` (instances, recent, folder, session, model_editor).
- The app connects to a daemon via `http(s)://host[:port]/?token=<token>`.
