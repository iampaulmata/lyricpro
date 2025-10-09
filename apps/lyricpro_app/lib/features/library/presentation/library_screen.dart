import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/shared/sample_data.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const String routeName = 'library';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1000;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Library'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Filters',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, or tags…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Row(
            children: [
              if (isWide)
                SizedBox(
                  width: 280,
                  child: _LibraryFilters(),
                ),
              Expanded(
                child: _LibraryGrid(isWide: isWide),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text('Import'),
          ),
        );
      },
    );
  }
}

class _LibraryFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const _SummaryRow(label: 'Total songs', value: '134'),
                  const _SummaryRow(label: 'Offline ready', value: '87'),
                  const _SummaryRow(label: 'Shared with me', value: '24'),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('Download all'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Favorites',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const FilterChip(
            label: Text('Favorites ★'),
            selected: true,
            onSelected: null,
          ),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in sampleTags.take(4))
                FilterChip(
                  label: Text(tag),
                  onSelected: (_) {},
                ),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Add tag'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Key',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: 'All keys',
            items: const [
              DropdownMenuItem(value: 'All keys', child: Text('All keys')),
              DropdownMenuItem(value: 'Bb', child: Text('Bb')),
              DropdownMenuItem(value: 'G', child: Text('G')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          Text(
            'Tempo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            divisions: 10,
            value: 100,
            min: 60,
            max: 160,
            label: '100 BPM',
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Storage used'),
              subtitle: const Text('2.3 GB of 5 GB'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Manage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            value,
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

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add song'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add to set list'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Download offline'),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'grid',
                    icon: Icon(Icons.grid_view),
                    label: Text('Grid'),
                  ),
                  ButtonSegment(
                    value: 'list',
                    icon: Icon(Icons.view_list),
                    label: Text('List'),
                  ),
                ],
                selected: const {'grid'},
                onSelectionChanged: (_) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    (constraints.maxWidth / (isWide ? 240 : 180)).floor().clamp(1, 4);
                return GridView.builder(
                  itemCount: sampleSongs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWide ? 4 / 3 : 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final song = sampleSongs[index];
                    return _LibraryCard(song: song);
                  },
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Sync now'),
              ),
              const SizedBox(width: 16),
              const Text('Last sync • 5 minutes ago'),
              const Spacer(),
              const Text('0 selected'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.song});

  final SampleSong song;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.pushNamed(EditorScreen.routeName, extra: song);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.music_note_outlined, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(song.artist),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _InfoChip(label: 'Key ${song.key}'),
                  _InfoChip(label: '${song.tempo} BPM'),
                  _InfoChip(label: song.tag),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
