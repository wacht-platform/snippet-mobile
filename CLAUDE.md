# snippet-mobile — contributor notes

Flutter remote-control client (Android + macOS) for the snippet `serve` daemon
(Dart package `snippet`, app id `com.snippet`). The daemon lives in the
[`snippet`](https://github.com/wacht-platform/snippet) repo — see its README for
the daemon API. See **README.md** here for build/run.

## Conventions
- Keep code comments **lean and sparse**; match the surrounding style.
- **Never expose** the user's API key or the serve token.
- No AI/tool branding in commit messages.

## Build / verify
- `flutter analyze lib` should pass before a PR.
- `flutter run -d macos` for desktop; `flutter build apk --release` for Android.

## Layout
- `lib/api.dart` (DaemonClient), `lib/models.dart`, `lib/widgets.dart`,
  `lib/theme.dart`, `lib/panel.dart`, `lib/command_palette.dart`, `lib/screens/*`.
- One adaptive shell (`screens/desktop_shell.dart`): two-pane when wide, a
  collapsed sidebar drawer when narrow (phones and shrunk desktop windows).
- The app connects to a daemon via `http(s)://host[:port]/?token=<token>`.
