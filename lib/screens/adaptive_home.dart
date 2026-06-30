import 'package:flutter/material.dart';

import '../platform.dart';
import 'desktop_shell.dart';
import 'instances.dart';

/// Picks the layout. Desktop platforms (macOS/Linux/Windows) ALWAYS get the
/// native desktop shell — even when the window is shrunk — so it never drops to
/// the phone UI; the shell itself adapts (collapsing the sidebar when narrow).
/// Mobile picks by width (phones never reach the breakpoint → unchanged).
class AdaptiveHome extends StatelessWidget {
  const AdaptiveHome({super.key});
  @override
  Widget build(BuildContext context) {
    if (!kMobile) return const DesktopShell();
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= kDesktopBreakpoint ? const DesktopShell() : const InstancesScreen(),
    );
  }
}
