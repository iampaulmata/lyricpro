import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/shared/sample_data.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key, required this.song});

  static const String routeName = 'editor';

  final SampleSong song;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1100;

        return Scaffold(
          appBar: AppBar(
            title: Text('Editing • ${song.title}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Version history',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Last saved 2 minutes ago • Auto-save on',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: isWide ? 320 : 280,
                  child: _MetadataSidebar(song: song),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _EditorWorkspace(song: song, isWide: isWide),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetadataSidebar extends StatelessWidget {
  const _MetadataSidebar({required this.song});

  final SampleSong song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(song.title, style: theme.textTheme.titleLarge),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
              tooltip: 'Edit metadata',
            ),
          ),
          const SizedBox(height: 12),
          _SidebarField(
            label: 'Tempo',
            value: '${song.tempo} BPM',
            icon: Icons.timer_outlined,
          ),
          _SidebarField(
            label: 'Key',
            value: song.key,
            icon: Icons.music_note_outlined,
          ),
          _SidebarField(
            label: 'Time signature',
            value: '4/4',
            icon: Icons.piano_outlined,
          ),
          const Divider(height: 32),
          Text(
            'Sections',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SectionChip(label: 'Intro'),
              _SectionChip(label: 'Verse 1', isActive: true),
              _SectionChip(label: 'Chorus'),
              _SectionChip(label: 'Verse 2'),
              _SectionChip(label: 'Bridge'),
              _SectionChip(label: 'Tag'),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add section'),
          ),
          const Divider(height: 32),
          Text('Version history', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          ..._historyEntries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    colorScheme.primary.withValues(alpha: 0.12),
                child: Text(entry.initials),
              ),
              title: Text(entry.title),
              subtitle: Text(entry.subtitle),
              trailing: Text(entry.timestamp),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.restore),
            label: const Text('View full history'),
          ),
        ],
      ),
    );
  }
}

class _EditorWorkspace extends StatelessWidget {
  const _EditorWorkspace({required this.song, required this.isWide});

  final SampleSong song;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_double_arrow_down),
                label: const Text('Transpose -1'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_double_arrow_up),
                label: const Text('Transpose +1'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.solar_power),
                label: const Text('Capo'),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'lyrics',
                    label: Text('Lyrics'),
                  ),
                  ButtonSegment(
                    value: 'lyrics-chords',
                    label: Text('Chords + Lyrics'),
                  ),
                  ButtonSegment(
                    value: 'preview',
                    label: Text('Preview'),
                  ),
                ],
                selected: const {'lyrics-chords'},
                onSelectionChanged: (_) {},
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Teleprompter preview'),
                onPressed: () {
                  context.pushNamed(PerformanceScreen.routeName);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: colorScheme.surface,
                            padding: const EdgeInsets.all(24),
                            child: SingleChildScrollView(
                              child: DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontFamily: 'monospace'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    _EditorLine(
                                      number: 1,
                                      content: '{title: Higher Ground}',
                                      isDirective: true,
                                    ),
                                    _EditorLine(
                                      number: 2,
                                      content: '{key: Bb}',
                                      isDirective: true,
                                    ),
                                    _EditorLine(
                                      number: 3,
                                      content: '',
                                    ),
                                    _EditorLine(
                                      number: 4,
                                      content:
                                          '[Bb]Amazing [F]grace how [Gm]sweet the [Eb]sound',
                                    ),
                                    _EditorLine(
                                      number: 5,
                                      content:
                                          'That [Bb]saved a [F]wretch like [Bb]me',
                                    ),
                                    _EditorLine(
                                      number: 6,
                                      content: '{comment: Hold last bar}',
                                      isDirective: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        if (isWide)
                          SizedBox(
                            width: 320,
                            child: Container(
                              color: colorScheme.surfaceContainerHigh,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          _ChordDisplayLine(
                                            chords: ['Bb', 'F', 'Gm', 'Eb'],
                                            lyrics:
                                                'Amazing grace how sweet the sound',
                                          ),
                                          SizedBox(height: 16),
                                          _ChordDisplayLine(
                                            chords: ['Bb', 'F', 'Bb'],
                                            lyrics: 'That saved a wretch like me',
                                          ),
                                          SizedBox(height: 24),
                                          const _EditorSectionHeader(label: 'Chorus'),
                                          _ChordDisplayLine(
                                            chords: ['Gm', 'Bb', 'F'],
                                            lyrics: 'I once was lost but now I am found',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isWide)
                SizedBox(
                  width: 280,
                  child: _PreviewDrawer(song: song),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarField extends StatelessWidget {
  const _SidebarField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      selected: isActive,
      label: Text(label),
      onSelected: (_) {},
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
    );
  }
}

class _EditorLine extends StatelessWidget {
  const _EditorLine({
    required this.number,
    required this.content,
    this.isDirective = false,
  });

  final int number;
  final String content;
  final bool isDirective;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              number.toString().padLeft(2, '0'),
              style: style.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: isDirective
                  ? style.copyWith(color: Theme.of(context).colorScheme.secondary)
                  : style,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorSectionHeader extends StatelessWidget {
  const _EditorSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: color),
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

class _ChordDisplayLine extends StatelessWidget {
  const _ChordDisplayLine({required this.chords, required this.lyrics});

  final List<String> chords;
  final String lyrics;

  @override
  Widget build(BuildContext context) {
    final chordStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          children: chords
              .map(
                (chord) => Chip(
                  label: Text(chord, style: chordStyle),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(
          lyrics,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _PreviewDrawer extends StatelessWidget {
  const _PreviewDrawer({required this.song});

  final SampleSong song;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ChordDisplayLine(
                  chords: ['Bb', 'F', 'Gm', 'Eb'],
                  lyrics: 'Amazing grace how sweet the sound',
                ),
                SizedBox(height: 16),
                _ChordDisplayLine(
                  chords: ['Bb', 'F', 'Bb'],
                  lyrics: 'That saved a wretch like me',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String initials;
  final String title;
  final String subtitle;
  final String timestamp;
}

const List<_HistoryEntry> _historyEntries = [
  _HistoryEntry(
    initials: 'AR',
    title: 'Lyric tweak',
    subtitle: 'Updated Chorus line 2',
    timestamp: '5m',
  ),
  _HistoryEntry(
    initials: 'JC',
    title: 'Key change',
    subtitle: 'Moved from A to Bb',
    timestamp: '1h',
  ),
  _HistoryEntry(
    initials: 'MB',
    title: 'Added bridge notes',
    subtitle: 'Prep for extended vamp',
    timestamp: 'Yesterday',
  ),
];
