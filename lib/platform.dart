import 'package:flutter/foundation.dart';

/// True on phones/tablets (Android/iOS). Desktop (macOS/Linux/Windows) and web
/// are false. Used to guard mobile-only plugins (foreground task, camera
/// permissions) that have no desktop support, and to pick the layout.
bool get kMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// The desktop layout (sidebar + panes) kicks in at/above this logical width.
const double kDesktopBreakpoint = 900;

/// Below this shell width the persistent sidebar collapses into a drawer (the
/// desktop shell stays native — it never falls back to the phone UI).
const double kShellCompact = 720;
