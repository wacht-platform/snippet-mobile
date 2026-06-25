import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import 'add_instance.dart';
import 'sessions.dart';

/// Home screen: connected daemon instances as reorderable cards, plus an always-
/// present "Add instance" card (which doubles as the empty state).
class InstancesScreen extends StatefulWidget {
  const InstancesScreen({super.key});

  @override
  State<InstancesScreen> createState() => _InstancesScreenState();
}

class _InstancesScreenState extends State<InstancesScreen> {
  final _store = InstanceStore();
  List<Instance>? _instances;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _store.load();
    if (mounted) setState(() => _instances = items);
  }

  Future<void> _add() async {
    final inst = await Navigator.push<Instance>(
      context,
      MaterialPageRoute(builder: (_) => const AddInstanceScreen()),
    );
    if (inst == null) return;
    final items = [...?_instances]..removeWhere((e) => e.url == inst.url);
    items.add(inst);
    await _store.save(items);
    if (mounted) setState(() => _instances = items);
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final items = [...?_instances];
    final it = items.removeAt(oldIndex);
    items.insert(newIndex, it);
    await _store.save(items);
    if (mounted) setState(() => _instances = items);
  }

  Future<void> _confirmDelete(Instance inst) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('Remove instance?'),
        content: Text(inst.label),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    final items = [...?_instances]
      ..removeWhere((e) => e.url == inst.url && e.token == inst.token);
    await _store.save(items);
    if (mounted) setState(() => _instances = items);
  }

  void _open(Instance inst) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionsScreen(
          client: DaemonClient(inst.url, inst.token),
          instanceName: inst.label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instances = _instances;
    return Scaffold(
      appBar: AppBar(title: const Text('Instances')),
      body: instances == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: instances.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
                          children: [
                            const Text('No instances yet',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            const Text(
                              'Run `snippet serve` and add it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 24),
                            _AddCard(onTap: _add),
                          ],
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          buildDefaultDragHandles: false,
                          itemCount: instances.length,
                          onReorderItem: _reorder,
                          itemBuilder: (_, i) {
                            final inst = instances[i];
                            return Padding(
                              key: ValueKey('${inst.url}|${inst.token}'),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _InstanceCard(
                                instance: inst,
                                index: i,
                                onOpen: () => _open(inst),
                                onDelete: () => _confirmDelete(inst),
                              ),
                            );
                          },
                        ),
                ),
                if (instances.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _AddCard(onTap: _add),
                  ),
              ],
            ),
    );
  }
}

class _AddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.55), width: 1.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Add instance',
                style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _InstanceCard extends StatelessWidget {
  final Instance instance;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const _InstanceCard({
    required this.instance,
    required this.index,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      child: Row(
        children: [
          _StatusDot(client: DaemonClient(instance.url, instance.token)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instance.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(hostOf(instance.url),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.muted),
            onPressed: onDelete,
            tooltip: 'Remove',
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(left: 2, right: 8),
              child: Icon(Icons.drag_handle, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Health dot: muted while checking, green online, red offline.
class _StatusDot extends StatefulWidget {
  final DaemonClient client;
  const _StatusDot({required this.client});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> {
  bool? _online;

  @override
  void initState() {
    super.initState();
    widget.client.health().then((v) {
      if (mounted) setState(() => _online = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _online == null
        ? AppColors.muted
        : (_online! ? AppColors.online : AppColors.offline);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: GlowDot(color: color),
    );
  }
}
