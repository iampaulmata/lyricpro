import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/shared/sample_data.dart';

class SetlistScreen extends StatefulWidget {
  const SetlistScreen({super.key, required this.setList});

  static const String routeName = 'setlist';

  final SampleSetList setList;

  @override
  State<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends State<SetlistScreen> {
  late SampleSong _selectedSong;

  @override
  void initState() {
    super.initState();
    _selectedSong = widget.setList.songs.first;
  }

  void _onSongSelected(SampleSong song) {
    setState(() {
      _selectedSong = song;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final setList = widget.setList;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1080;

        return Scaffold(
          appBar: AppBar(
            title: Text('Set list • ${setList.title}'),
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
                  '${setList.songCount} songs • ${setList.eventDate} • ${setList.duration}',
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
                      setList: setList,
                      selectedSong: _selectedSong,
                      onSongSelected: _onSongSelected,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _SetListDetailPane(
                      setList: setList,
                      song: _selectedSong,
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
                  onOpenEditor: () {
                    context.pushNamed(EditorScreen.routeName, extra: _selectedSong);
                  },
                ),
        );
      },
    );
  }
}

class _SongOrderList extends StatelessWidget {
  const _SongOrderList({
    required this.setList,
    required this.selectedSong,
    required this.onSongSelected,
  });

  final SampleSetList setList;
  final SampleSong selectedSong;
  final ValueChanged<SampleSong> onSongSelected;

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
                itemCount: setList.songs.length,
                itemBuilder: (context, index) {
                  final song = setList.songs[index];
                  final bool isSelected = song.id == selectedSong.id;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor:
                        colorScheme.primary.withValues(alpha: 0.16),
                    leading: CircleAvatar(
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(song.title),
                    subtitle: Text('${song.key} • ${song.duration}'),
                    trailing: const Icon(Icons.drag_handle),
                    onTap: () => onSongSelected(song),
                    onLongPress: () {
                      context.pushNamed(EditorScreen.routeName, extra: song);
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
    required this.setList,
    required this.song,
    required this.isWide,
  });

  final SampleSetList setList;
  final SampleSong song;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                            song.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('${song.artist} • Key ${song.key}'),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        context.pushNamed(EditorScreen.routeName, extra: song);
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
                    _InfoChip(icon: Icons.music_note_outlined, label: 'Key ${song.key}'),
                    _InfoChip(icon: Icons.timer_outlined, label: song.duration),
                    _InfoChip(icon: Icons.graphic_eq_outlined, label: '${song.tempo} BPM'),
                    _InfoChip(icon: Icons.sell_outlined, label: song.tag),
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
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ChordLine(
                                    chords: ['Bb', 'F', 'Gm', 'Eb'],
                                    lyrics: 'Amazing grace how sweet the sound',
                                  ),
                                  _ChordLine(
                                    chords: ['Bb', 'F', 'Bb'],
                                    lyrics: 'That saved a wretch like me',
                                  ),
                                  SizedBox(height: 20),
                                  _SectionHeader(label: 'Chorus'),
                                  _ChordLine(
                                    chords: ['Gm', 'Bb', 'F'],
                                    lyrics: 'I once was lost but now I am found',
                                  ),
                                ],
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
                                _OverrideField(label: 'Key', value: song.key),
                                _OverrideField(label: 'Capo', value: '2'),
                                _OverrideField(label: 'Tempo', value: '${song.tempo} BPM'),
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
                                    child: const Text(
                                      'Hold the bridge at bar 4 • Tag chorus twice if crowd is responsive.',
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
                      _PerformanceStrip(setList: setList),
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

class _ChordLine extends StatelessWidget {
  const _ChordLine({required this.chords, required this.lyrics});

  final List<String> chords;
  final String lyrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            children: chords
                .map(
                  (chord) => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                    ),
                    child: Text(
                      chord,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          Text(
            lyrics,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _OverrideField extends StatelessWidget {
  const _OverrideField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        child: Row(
          children: [
            Text(label),
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
  const _PerformanceStrip({required this.setList});

  final SampleSetList setList;

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
        subtitle: Text('${setList.songCount} songs • ${setList.duration} runtime'),
        trailing: FilledButton(
          onPressed: () {
            context.pushNamed(PerformanceScreen.routeName);
          },
          child: const Text('Open'),
        ),
        onTap: () {
          context.pushNamed(PerformanceScreen.routeName);
        },
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onAddSong,
    required this.onOpenPerformance,
    required this.onOpenEditor,
  });

  final VoidCallback onAddSong;
  final VoidCallback onOpenPerformance;
  final VoidCallback onOpenEditor;

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
          const Text('12 songs • 52 minutes'),
        ],
      ),
    );
  }
}
