import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/data/repositories/setlist_repository.dart';
import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';

class SetlistScreen extends ConsumerStatefulWidget {
  const SetlistScreen({super.key, required this.setListId});

  static const String routeName = 'setlist';

  final String setListId;

  @override
  ConsumerState<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends ConsumerState<SetlistScreen> {
  String? _selectedEntryId;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(setlistByIdProvider(widget.setListId));

    return detailAsync.when(
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Set list')),
            body: const Center(child: Text('Set list not found')),
          );
        }

        final items = detail.items;
        if (items.isNotEmpty) {
          final ids = items.map((e) => e.entry.id).toSet();
          if (_selectedEntryId == null || !ids.contains(_selectedEntryId)) {
            _selectedEntryId = items.first.entry.id;
          }
        } else {
          _selectedEntryId = null;
        }

        final selectedItem = items.firstWhereOrNull(
          (item) => item.entry.id == _selectedEntryId,
        );
        final selectedSongId = selectedItem?.song?.id;

        final theme = Theme.of(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 1080;

            return Scaffold(
              appBar: AppBar(
                title: Text('Set list • ${detail.setlist.title}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '${items.length} songs • Updated ${_timeAgo(detail.setlist.updatedAt)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              body: SafeArea(
                child: Row(
                  children: [
                    if (isWide)
                      SizedBox(
                        width: 360,
                        child: _SongOrderList(
                          items: items,
                          selectedEntryId: _selectedEntryId,
                          onSelectionChanged: (value) {
                            setState(() => _selectedEntryId = value);
                          },
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _SetListDetailPane(
                          detail: detail,
                          selectedItem: selectedItem,
                          isWide: isWide,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: isWide
                  ? null
                  : _BottomActions(
                      onAddSong: () {},
                      onOpenPerformance: () {
                        context.pushNamed(PerformanceScreen.routeName);
                      },
                      onOpenEditor: selectedSongId == null
                          ? null
                          : () {
                              context.pushNamed(
                                EditorScreen.routeName,
                                extra: selectedSongId,
                              );
                            },
                      songCount: items.length,
                    ),
            );
          },
        );
      },
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Set list')),
        body: Center(child: Text('Failed to load set list: $error')),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Set list')),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}

class _SongOrderList extends StatelessWidget {
  const _SongOrderList({
    required this.items,
    required this.selectedEntryId,
    required this.onSelectionChanged,
  });

  final List<SetlistItem> items;
  final String? selectedEntryId;
  final ValueChanged<String> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Song order',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.entry.id == selectedEntryId;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: colorScheme.primary.withValues(alpha: 0.16),
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.song?.title ?? 'Unknown song'),
                    subtitle: Text(item.song?.artist ?? 'Unknown artist'),
                    trailing: const Icon(Icons.drag_handle),
                    onTap: () => onSelectionChanged(item.entry.id),
                    onLongPress: () {
                      final songId = item.song?.id;
                      if (songId != null) {
                        context.pushNamed(EditorScreen.routeName, extra: songId);
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add song'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetListDetailPane extends StatelessWidget {
  const _SetListDetailPane({
    required this.detail,
    required this.selectedItem,
    required this.isWide,
  });

  final SetlistDetail detail;
  final SetlistItem? selectedItem;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final song = selectedItem?.song;
    final customKey = selectedItem?.entry.customKey;
    final customTempo = selectedItem?.entry.customTempo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? 'No song selected',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(song?.artist ?? 'Add a song to this slot'),
                        ],
                      ),
                    ),
                    if (song != null)
                      FilledButton.tonalIcon(
                        onPressed: () {
                          context.pushNamed(EditorScreen.routeName, extra: song.id);
                        },
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Open editor'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (customKey != null)
                      _InfoChip(
                        icon: Icons.music_note_outlined,
                        label: 'Key $customKey',
                      ),
                    if (customTempo != null)
                      _InfoChip(
                        icon: Icons.timer_outlined,
                        label: '$customTempo BPM',
                      ),
                    _InfoChip(
                      icon: Icons.sell_outlined,
                      label: '${detail.items.length} total songs',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Song preview',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: SingleChildScrollView(
                              child: Text(
                                song?.content ?? 'No lyrics yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isWide) const SizedBox(width: 24),
              if (isWide)
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overrides',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                _OverrideField(
                                  label: 'Key',
                                  value: selectedItem?.entry.customKey ?? song?.songKey ?? '-',
                                  onPressed: () {},
                                ),
                                _OverrideField(
                                  label: 'Tempo',
                                  value: (selectedItem?.entry.customTempo ??
                                              song?.tempo) !=
                                          null
                                      ? '${selectedItem?.entry.customTempo ?? song?.tempo} BPM'
                                      : '-',
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Section notes',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: colorScheme.surfaceContainerHigh,
                                    ),
                                    child: Text(
                                      selectedItem?.entry.notes ?? 'Add song-specific notes',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {},
                                  child: const Text('Apply to entire set'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _PerformanceStrip(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _OverrideField extends StatelessWidget {
  const _OverrideField({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(),
            Text(value),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _PerformanceStrip extends StatelessWidget {
  const _PerformanceStrip();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primary.withValues(alpha: 0.12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
        title: const Text('Start performance mode'),
        subtitle: const Text('Sync with connected devices'),
        trailing: FilledButton(
          onPressed: () {},
          child: const Text('Open'),
        ),
        onTap: () {},
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onAddSong,
    required this.onOpenPerformance,
    required this.onOpenEditor,
    required this.songCount,
  });

  final VoidCallback onAddSong;
  final VoidCallback onOpenPerformance;
  final VoidCallback? onOpenEditor;
  final int songCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onAddSong,
            child: const Text('Add song'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onOpenPerformance,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Performance'),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: onOpenEditor,
            icon: const Icon(Icons.edit_note),
            label: const Text('Editor'),
          ),
          const Spacer(),
          Text('$songCount songs'),
        ],
      ),
    );
  }
}
