import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/data/repositories/library_repository.dart';
import 'package:lyricpro_app/data/repositories/setlist_repository.dart';
import 'package:lyricpro_app/features/library/presentation/library_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/setlists/presentation/setlist_screen.dart';
import 'package:lyricpro_app/features/settings/presentation/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(librarySongsProvider);
    final setlistsAsync = ref.watch(setlistsProvider);

    return songsAsync.when(
      data: (songs) {
        final tagSet = <String>{};
        for (final song in songs) {
          tagSet.addAll(song.tags);
        }
        return setlistsAsync.when(
          data: (setlists) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isLarge = constraints.maxWidth >= 1200;

                return Scaffold(
                  appBar: isLarge
                      ? null
                      : AppBar(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/icons/LyricPro_icon.png',
                                height: 28,
                                semanticLabel: 'LyricPro logo',
                              ),
                              const SizedBox(width: 12),
                              const Text('LyricPro'),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.dashboard_customize_outlined),
                              onPressed: () {},
                              tooltip: 'Customize',
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () {
                                context.pushNamed(SettingsScreen.routeName);
                              },
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(64),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: _SearchField(
                                hint: 'Search songs, artists, tags…',
                              ),
                            ),
                          ),
                        ),
                  drawer: isLarge
                      ? null
                      : _DashboardDrawer(tags: tagSet.toList()),
                  body: SafeArea(
                    child: Row(
                      children: [
                        if (isLarge)
                          _Sidebar(tags: tagSet.toList()),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _DashboardContent(
                              isWide: isLarge,
                              songs: songs,
                              setlists: setlists,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: Center(child: Text('Failed to load set lists: $error')),
          ),
          loading: () => const Scaffold(
            appBar: AppBar(title: Text('Dashboard')),
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(child: Text('Failed to load songs: $error')),
      ),
      loading: () => const Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/LyricPro_icon.png',
                  height: 36,
                  semanticLabel: 'LyricPro logo',
                ),
                const SizedBox(width: 12),
                Text(
                  'LyricPro',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileCard(
              name: 'Alex Rivera',
              role: 'Lead Vocal • Master device',
              syncStatus: SyncStatus.synced,
            ),
            const SizedBox(height: 24),
            const _SidebarSectionTitle('Navigation'),
            _SidebarNavItem(
              icon: Icons.library_music_outlined,
              label: 'Library',
              onTap: () {
                context.pushNamed(LibraryScreen.routeName);
              },
            ),
            const _SidebarNavItem(
              icon: Icons.set_meal_outlined,
              label: 'Set Lists',
              isActive: true,
            ),
            const _SidebarNavItem(
              icon: Icons.people_alt_outlined,
              label: 'Shared with me',
            ),
            const _SidebarNavItem(
              icon: Icons.offline_pin_outlined,
              label: 'Offline queue',
            ),
            const _SidebarNavItem(
              icon: Icons.pedal_bike_outlined,
              label: 'Hardware bindings',
            ),
            const SizedBox(height: 24),
            const _SidebarSectionTitle('Tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tags.take(10))
                  Chip(
                    label: Text(tag),
                    avatar: const Icon(Icons.tag, size: 16),
                  ),
                if (tags.isEmpty)
                  const Text('No tags yet'),
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text('Add tag'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/LyricPro_icon.png',
                    height: 32,
                    semanticLabel: 'LyricPro logo',
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LyricPro',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _ProfileCard(
              name: 'Alex Rivera',
              role: 'Lead Vocal • Master device',
              syncStatus: SyncStatus.pending,
            ),
            const Divider(),
            _SidebarNavItem(
              icon: Icons.library_music_outlined,
              label: 'Library',
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(LibraryScreen.routeName);
              },
            ),
            const _SidebarNavItem(
              icon: Icons.set_meal_outlined,
              label: 'Set Lists',
              isActive: true,
            ),
            const _SidebarNavItem(
              icon: Icons.people_alt_outlined,
              label: 'Shared with me',
            ),
            const _SidebarNavItem(
              icon: Icons.offline_pin_outlined,
              label: 'Offline queue',
            ),
            const _SidebarNavItem(
              icon: Icons.pedal_bike_outlined,
              label: 'Hardware bindings',
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags.take(10)) Chip(label: Text(tag)),
                  if (tags.isEmpty)
                    const Text('No tags yet'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(SettingsScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.isWide,
    required this.songs,
    required this.setlists,
  });

  final bool isWide;
  final List<SongWithTags> songs;
  final List<SetlistSummary> setlists;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (isWide) ...[
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _SearchField(
                    hint: 'Search songs, artists, tags…',
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Quick add'),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.tune),
                  tooltip: 'Filters',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    context.pushNamed(SettingsScreen.routeName);
                  },
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        SliverToBoxAdapter(
          child: Wrap(
            spacing: isWide ? 32 : 16,
            runSpacing: isWide ? 32 : 16,
            children: [
              SizedBox(
                width: isWide ? 680 : double.infinity,
                child: _SetListCarousel(setlists: setlists),
              ),
              SizedBox(
                width: isWide ? 320 : double.infinity,
                child: _ActivityCard(songs: songs),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Library snapshot',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(label: Text('All songs'), value: 'all'),
                          ButtonSegment(label: Text('Favorites'), value: 'favorites'),
                          ButtonSegment(label: Text('Shared'), value: 'shared'),
                        ],
                        selected: const {'all'},
                        onSelectionChanged: (_) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, subConstraints) {
                      final crossAxisCount =
                          subConstraints.maxWidth ~/ 200;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount.clamp(1, 4),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 4 / 3,
                        ),
                        itemCount: songs.take(8).length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return _SongCard(song: song);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(
          child: _PerformanceCallout(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.role,
    required this.syncStatus,
  });

  final String name;
  final String role;
  final SyncStatus syncStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
*** End Patch


enum SyncStatus { synced, pending, offline }

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? background =
        isActive ? scheme.primary.withValues(alpha: 0.12) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: background,
        leading: Icon(icon, color: isActive ? scheme.primary : null),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _SetListCarousel extends StatelessWidget {
  const _SetListCarousel({required this.setlists});

  final List<SetlistSummary> setlists;

  @override
  Widget build(BuildContext context) {
    if (setlists.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: const Text('No set lists yet. Create your first one!'),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: setlists.length,
        itemBuilder: (context, index) {
          final setList = setlists[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    SetlistScreen.routeName,
                    extra: setList.setlist.id,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.85),
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            setList.setlist.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              context.pushNamed(
                                SetlistScreen.routeName,
                                extra: setList.setlist.id,
                              );
                            },
                            child: const Text('Open set list'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${setList.songCount} songs',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: const [
                          _SetListStatChip(
                            icon: Icons.timer_outlined,
                            label: 'Runtime auto-calculated',
                          ),
                          _SetListStatChip(
                            icon: Icons.devices_other_outlined,
                            label: 'Devices synced soon',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetListStatChip extends StatelessWidget {
  const _SetListStatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
      side: const BorderSide(color: Colors.white30),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.songs});

  final List<SongWithTags> songs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = songs
        .sorted((a, b) => b.song.updatedAt.compareTo(a.song.updatedAt))
        .take(5)
        .toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent activity',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh feed',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (latest.isEmpty)
              const Text('No recent edits yet. Start updating your library!')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: latest.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final song = latest[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(song.song.title.characters.first),
                    ),
                    title: Text('Updated ${song.song.title}'),
                    subtitle: Text(
                      'Last edited ${_timeAgo(song.song.updatedAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.pushNamed(
                        EditorScreen.routeName,
                        extra: song.song.id,
                      );
                    },
                  );
                },
              ),
          ],
        ),
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

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song});

  final SongWithTags song;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          context.pushNamed(EditorScreen.routeName, extra: song.song.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.music_note_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      song.song.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const Spacer(),
              Text(song.song.artist ?? 'Unknown artist'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (song.song.songKey != null)
                    _MiniChip(label: 'Key ${song.song.songKey}'),
                  if (song.song.tempo != null)
                    _MiniChip(label: '${song.song.tempo} BPM'),
                  for (final tag in song.tags) _MiniChip(label: tag),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

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

class _PerformanceCallout extends StatelessWidget {
  const _PerformanceCallout();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.mic_none, size: 48, color: colorScheme.secondary),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready for showtime?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Launch performance mode to sync connected devices, activate pedal controls, and roll through your set list hands-free.',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {
                context.pushNamed(PerformanceScreen.routeName);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open performance mode'),
            ),
          ],
        ),
      ),
    );
  }
}
