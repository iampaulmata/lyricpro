import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/data/repositories/setlist_repository.dart';
import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';

// Clean, minimal Setlist screen. Key goals:
// - avoid Flexible/Expanded inside unbounded scrollables
// - choose a stacked scrollable detail pane when height is narrow
// - provide a simple ReorderableListView and "Add song" wiring to repository

class SetlistScreen extends ConsumerStatefulWidget {
  const SetlistScreen({super.key, required this.setListId});

  static const String routeName = 'setlist';
  final String setListId;

  @override
  ConsumerState<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends ConsumerState<SetlistScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(setlistByIdProvider(widget.setListId));

    return Scaffold(
      appBar: AppBar(title: const Text('Setlist')),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isNarrow = constraints.maxHeight < 600;

        return detailAsync.when(
          data: (detail) {
            final selected = detail?.items.firstOrNull;
            if (isWide) {
              return Row(children: [
                Flexible(flex: 3, child: _SetListItemsColumn(detail: detail, onAdd: _onAdd, onReorder: _onReorder)),
                const VerticalDivider(width: 1),
                SizedBox(width: 420, child: _SetListDetailPane(detail: detail, selectedItem: selected, isWide: isWide, isNarrow: isNarrow)),
              ]);
            }

            return Column(children: [
              Expanded(child: _SetListItemsColumn(detail: detail, onAdd: _onAdd, onReorder: _onReorder)),
              Container(height: 360, child: _SetListDetailPane(detail: detail, selectedItem: selected, isWide: isWide, isNarrow: isNarrow)),
            ]);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        );
      }),
      bottomNavigationBar: _BottomActions(
        onAddSong: _onAdd,
        onOpenPerformance: _onOpenPerformance,
        onOpenEditor: null,
        songCount: _detailCount(ref, widget.setListId),
      ),
    );
  }

  int _detailCount(WidgetRef ref, String id) {
    final det = ref.read(setlistByIdProvider(id));
    return det.when(data: (d) => d?.items.length ?? 0, loading: () => 0, error: (_, __) => 0);
  }

  void _onAdd() async {
    await ref.read(setlistRepositoryProvider).addSampleSongToSet(widget.setListId);
  }

  void _onOpenPerformance() {
    if (!mounted) return;
    context.pushNamed(PerformanceScreen.routeName);
  }

  void _onReorder(int oldIndex, int newIndex) async {
    final det = ref.read(setlistByIdProvider(widget.setListId));
    final detail = det.when(data: (d) => d, loading: () => null, error: (_, __) => null);
    if (detail == null) return;
    final items = detail.items;
    if (oldIndex < 0 || oldIndex >= items.length) return;
    final item = items[oldIndex];
    final target = newIndex.clamp(0, items.length - 1) as int;
    await ref.read(setlistRepositoryProvider).moveSetlistEntry(item.entry.id, target);
  }
}

class _SetListItemsColumn extends StatelessWidget {
  const _SetListItemsColumn({required this.detail, required this.onAdd, required this.onReorder});

  final SetlistDetail? detail;
  final VoidCallback onAdd;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    final items = detail?.items ?? const <SetlistItem>[];
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(title: const Text('Songs'), trailing: OutlinedButton(onPressed: onAdd, child: const Text('Add'))),
          Expanded(
            child: ReorderableListView.builder(
              onReorder: onReorder,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final it = items[index];
                return ListTile(key: ValueKey(it.entry.id), title: Text(it.song?.title ?? 'Untitled'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SetListDetailPane extends StatelessWidget {
  const _SetListDetailPane({required this.detail, required this.selectedItem, required this.isWide, required this.isNarrow});

  final SetlistDetail? detail;
  final SetlistItem? selectedItem;
  final bool isWide;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final song = selectedItem?.song;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = isNarrow || constraints.maxHeight < 520;
        if (compact) {
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(song?.title ?? 'No song selected'))),
              const SizedBox(height: 12),
              Card(child: Container(height: 240, padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Text(song?.content ?? 'No lyrics')))),
            ]),
          );
        }

        // Non-compact: two-column layout with flexible preview and an optional
        // right-side overrides column when wide.
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(song?.title ?? 'No song selected'))),
          const SizedBox(height: 12),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Text(song?.content ?? 'No lyrics'))))),
              if (isWide) const SizedBox(width: 12),
              if (isWide)
                SizedBox(width: 300, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Overrides'), const SizedBox(height: 8), Text(selectedItem?.entry.notes ?? '')])))),
            ]),
          ),
        ]);
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 18), label: Text(label));
}

class _OverrideField extends StatelessWidget {
  const _OverrideField({required this.label, required this.value, required this.onPressed});
  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(onPressed: onPressed, child: Row(children: [Text(label), const Spacer(), Text(value)])),
    );
  }
}

class _PerformanceStrip extends StatelessWidget {
  const _PerformanceStrip();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(color: colorScheme.primary.withAlpha(20), child: ListTile(title: const Text('Start performance mode'), trailing: FilledButton(onPressed: () {}, child: const Text('Open'))));
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onAddSong, required this.onOpenPerformance, required this.onOpenEditor, required this.songCount});

  final VoidCallback onAddSong;
  final VoidCallback onOpenPerformance;
  final VoidCallback? onOpenEditor;
  final int songCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [OutlinedButton(onPressed: onAddSong, child: const Text('Add song')), const SizedBox(width: 12), FilledButton.icon(onPressed: onOpenPerformance, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Performance')), const Spacer(), Text('$songCount songs')]),
    );
  }
}