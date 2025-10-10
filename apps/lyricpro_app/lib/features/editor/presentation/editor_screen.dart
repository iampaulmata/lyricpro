import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/data/local/database.dart';
import 'package:lyricpro_app/data/repositories/library_repository.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key, required this.songId});

  static const String routeName = 'editor';

  final String songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songAsync = ref.watch(songByIdProvider(songId));

    return songAsync.when(
      data: (song) {
        if (song == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editor')),
            body: const Center(child: Text('Song not found')),
          );
        }
        return _EditorView(song: song);
      },
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Editor')),
        body: Center(child: Text('Failed to load song: $error')),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Editor')),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EditorView extends StatelessWidget {
  const _EditorView({required this.song});

  final SongWithTags song;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1100;

        return Scaffold(
          appBar: AppBar(
            title: Text('Editing • ${song.song.title}'),
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
                  child: _EditorWorkspace(song: song.song, isWide: isWide),
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

  final SongWithTags song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(song.song.title, style: theme.textTheme.titleLarge),
            subtitle: Text(song.song.artist ?? 'Unknown artist'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
              tooltip: 'Edit metadata',
            ),
          ),
          const SizedBox(height: 12),
          _SidebarField(
            label: 'Tempo',
            value: song.song.tempo != null ? '${song.song.tempo} BPM' : 'Not set',
            icon: Icons.timer_outlined,
          ),
          _SidebarField(
            label: 'Key',
            value: song.song.songKey ?? 'Not set',
            icon: Icons.music_note_outlined,
          ),
          _SidebarField(
            label: 'Time signature',
            value: '4/4',
            icon: Icons.piano_outlined,
          ),
          const Divider(height: 32),
          Text(
            'Tags',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in song.tags)
                Chip(
                  label: Text(tag),
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                ),
              if (song.tags.isEmpty)
                Text(
                  'No tags yet',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 24),
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
            onPressed: () {
              context.pushNamed(
                PerformanceScreen.routeName,
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Teleprompter preview'),
          ),
        ],
      ),
    );
  }
}

class _EditorWorkspace extends StatelessWidget {
  const _EditorWorkspace({required this.song, required this.isWide});

  final Song song;
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
                                child: Text(song.content.isEmpty
                                    ? 'Start typing your lyrics here...'
                                    : song.content),
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
                                      child: Text(
                                        song.content,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
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
                  child: _PreviewDrawer(content: song.content),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewDrawer extends StatelessWidget {
  const _PreviewDrawer({required this.content});

  final String content;

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
              children: [
                Text(
                  content,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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
