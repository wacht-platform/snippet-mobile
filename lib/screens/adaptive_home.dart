import 'package:flutter/material.dart';

import '../platform.dart';
import 'desktop_shell.dart';
import 'instances.dart';

/// Picks the layout by available width: the desktop two-pane shell on wide
/// windows (macOS/desktop), the phone layout otherwise. Phones never reach the
/// breakpoint, so their tree is unchanged.
class AdaptiveHome extends StatelessWidget {
  const AdaptiveHome({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= kDesktopBreakpoint ? const DesktopShell() : const InstancesScreen(),
    );
  }
}
