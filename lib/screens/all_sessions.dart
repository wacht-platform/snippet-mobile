import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'folder_browser.dart';
import 'instances.dart';
import 'session.dart';

/// Mobile landing: the Instances screen only when nothing is connected yet,
/// otherwise the aggregated Sessions screen (with a button to manage machines).
class MobileHome extends StatefulWidget {
  const MobileHome({super.key});
  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  bool? _hasInstances;

  @override
  void initState() {
    super.initState();
    InstanceStore().load().then((i) {
      if (mounted) setState(() => _hasInstances = i.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final has = _hasInstances;
    if (has == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.fg3))),
      );
    }
    return has ? const AllSessionsScreen() : const InstancesScreen();
  }
}

/// Sessions across every connected machine, grouped by machine. A top button
/// jumps to the Instances screen to add/manage/switch machines.
class AllSessionsScreen extends StatefulWidget {
  const AllSessionsScreen({super.key});
  @override
  State<AllSessionsScreen> createState() => _AllSessionsScreenState();
}

class _AllSessionsScreenState extends State<AllSessionsScreen> {
  final _store = InstanceStore();
  List<Instance> _instances = const [];
  final Map<String, DaemonClient> _clients = {};
  final Map<String, List<SessionInfo>> _byUrl = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final insts = await _store.load();
    _clients
      ..clear()
      ..addEntries(insts.map((i) => MapEntry(i.url, DaemonClient(i.url, i.token))));
    await Future.wait(insts.map((i) async {
      try {
        final s = await _clients[i.url]!.sessions(limit: 60);
        s.sort((a, b) => b.lastActive.compareTo(a.lastActive));
        _byUrl[i.url] = s;
      } catch (_) {
        _byUrl[i.url] = const [];
      }
    }));
    if (mounted) {
      setState(() {
        _instances = insts;
        _loading = false;
      });
    }
  }

  Future<void> _openInstances() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const InstancesScreen()));
    if (mounted) _load();
  }

  void _open(Instance inst, SessionInfo s) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SessionScreen(client: _clients[inst.url]!, sessionId: s.id, title: s.title, profile: s.profile),
    )).then((_) => _load());
  }

  Future<void> _newSession(Instance inst) async {
    final id = await Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) => FolderBrowser(client: _clients[inst.url]!, newConversation: true),
    ));
    if (id == null || !mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SessionScreen(client: _clients[inst.url]!, sessionId: id, title: 'New session'),
    )).then((_) => _load());
  }

  String _ago(int unixSec) {
    if (unixSec == 0) return '';
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unixSec * 1000));
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 30) return '${d.inDays}d';
    return '${(d.inDays / 30).floor()}mo';
  }

  String _pill(String s) => switch (s) {
        'running' || 'waiting_for_input' => 'running',
        'failed' || 'error' => 'error',
        _ => 'idle',
      };

  String _folderName(String folder) => folder.split('/').where((p) => p.isNotEmpty).lastOrNull ?? (folder.isEmpty ? '—' : folder);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SnAppBar(title: 'Sessions', actions: [
            IconBtn('cpu', tooltip: 'Machines', onTap: _openInstances),
            IconBtn('refresh', onTap: _loading ? null : _load),
          ]),
          Expanded(
            child: _loading
                ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.fg3)))
                : RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.surface2,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      children: [
                        for (final inst in _instances) ..._machineGroup(inst),
                        if (_instances.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: EmptyState(
                              icon: 'cpu',
                              title: 'No machines',
                              body: 'Connect a machine running snippet serve.',
                              action: Btn('Add machine', icon: 'plus', onTap: _openInstances),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _machineGroup(Instance inst) {
    final sessions = _byUrl[inst.url] ?? const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 0, 6),
        child: Row(children: [
          const AppIcon('cpu', size: 13, color: AppColors.fg3),
          const SizedBox(width: 8),
          Expanded(child: Text(inst.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12, color: AppColors.fg2))),
          IconBtn('plus', size: 28, iconSize: 16, tooltip: 'New session', onTap: () => _newSession(inst)),
        ]),
      ),
      if (sessions.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
          child: Text('No sessions yet', style: sans(12, color: AppColors.fg4)),
        )
      else
        ...sessions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _row(inst, s),
            )),
    ];
  }

  Widget _row(Instance inst, SessionInfo s) {
    return AppCard(
      onTap: () => _open(inst, s),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.title.isEmpty ? '(untitled)' : s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(12.5, height: 1.25, color: AppColors.fg1)),
            const SizedBox(height: 3),
            Row(children: [
              const AppIcon('folder', size: 10, color: AppColors.fg4),
              const SizedBox(width: 5),
              Flexible(child: Text(_folderName(s.folder), maxLines: 1, overflow: TextOverflow.ellipsis, style: mono(10, color: AppColors.fg3))),
              if (_ago(s.lastActive).isNotEmpty) Text('  ·  ${_ago(s.lastActive)}', style: mono(10, color: AppColors.fg4)),
            ]),
          ]),
        ),
        const SizedBox(width: 6),
        StatusPill(status: _pill(s.status)),
      ]),
    );
  }
}
