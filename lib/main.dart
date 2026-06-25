import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'api.dart';
import 'notifications.dart';
import 'screens/instances.dart';
import 'screens/session.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  onNotifTap = (m) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.push(MaterialPageRoute(
      builder: (_) => SessionScreen(
        client: DaemonClient('${m['url']}', '${m['token']}'),
        sessionId: '${m['session'] ?? ''}',
        title: '${m['title'] ?? 'session'}',
      ),
    ));
  };
  await resumeWatchingIfEnabled();
  runApp(const SnippetApp());
}

class SnippetApp extends StatefulWidget {
  const SnippetApp({super.key});
  @override
  State<SnippetApp> createState() => _SnippetAppState();
}

class _SnippetAppState extends State<SnippetApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    reportForeground(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final fg = state == AppLifecycleState.resumed;
    reportForeground(fg);
    if (!fg) reportOpenSession('');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'snippet',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WithForegroundTask(child: InstancesScreen()),
    );
  }
}
