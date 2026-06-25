import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../theme.dart';
import 'model_editor.dart';

/// Manage the daemon's model profiles (shared with the TUI's config.toml).
/// Tap a profile to make it the default for new sessions; edit/add via the form.
class ModelsScreen extends StatefulWidget {
  final DaemonClient client;
  const ModelsScreen({super.key, required this.client});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  late Future<ServerConfig> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.client.getConfig();
  }

  void _refresh() => setState(() => _future = widget.client.getConfig());

  Future<void> _edit(ModelProfile? p) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => ModelEditorScreen(client: widget.client, existing: p)),
    );
    if (saved == true) _refresh();
  }

  Future<void> _run(Future<void> Function() op, String onError) async {
    try {
      await op();
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$onError: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      floatingActionButton: GradientButton(
        icon: Icons.add,
        label: 'Add model',
        onTap: () => _edit(null),
      ),
      body: FutureBuilder<ServerConfig>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted)),
              ),
            );
          }
          final profiles = snap.data?.profiles ?? const [];
          if (profiles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No models configured',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Add an API-key provider to get started.',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: profiles.length,
            itemBuilder: (_, i) {
              final p = profiles[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(p.name),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: AppColors.offline.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.offline),
                  ),
                  onDismissed: (_) =>
                      _run(() => widget.client.deleteProfile(p.name), 'delete'),
                  child: GlassCard(
                    onTap: () => _run(
                        () => widget.client.setActiveProfile(p.name), 'activate'),
                    child: Row(
                      children: [
                        Icon(
                          p.active
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: p.active ? AppColors.accent : AppColors.muted,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  if (!p.hasKey) ...[
                                    const SizedBox(width: 8),
                                    const Pill(text: 'no key', color: AppColors.running),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${p.provider} · ${p.model}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12.5)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.muted),
                          onPressed: () => _edit(p),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
