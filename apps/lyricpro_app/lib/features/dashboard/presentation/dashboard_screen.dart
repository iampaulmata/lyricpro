import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lyricpro_app/features/editor/presentation/editor_screen.dart';
import 'package:lyricpro_app/features/library/presentation/library_screen.dart';
import 'package:lyricpro_app/features/performance/presentation/performance_screen.dart';
import 'package:lyricpro_app/features/setlists/presentation/setlist_screen.dart';
import 'package:lyricpro_app/features/settings/presentation/settings_screen.dart';
import 'package:lyricpro_app/features/shared/sample_data.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          drawer: isLarge ? null : const _DashboardDrawer(),
          body: SafeArea(
            child: Row(
              children: [
                if (isLarge) const _Sidebar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _DashboardContent(isWide: isLarge),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

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
                for (final tag in sampleTags)
                  Chip(
                    label: Text(tag),
                    avatar: const Icon(Icons.tag, size: 16),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
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
  const _DashboardDrawer();

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
                Navigator.of(context).maybePop();
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
  const _DashboardContent({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double columnGap = isWide ? 32 : 16;

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
                spacing: columnGap,
                runSpacing: columnGap,
                children: [
                  SizedBox(
                    width: isWide ? constraints.maxWidth * 0.6 : double.infinity,
                    child: _SetListCarousel(),
                  ),
                  SizedBox(
                    width: isWide ? constraints.maxWidth * 0.32 : double.infinity,
                    child: const _ActivityCard(),
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
                          final crossAxisCount = subConstraints.maxWidth ~/ 200;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount.clamp(1, 4),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 4 / 3,
                            ),
                            itemCount: sampleSongs.length,
                            itemBuilder: (context, index) {
                              final song = sampleSongs[index];
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
            SliverToBoxAdapter(
              child: _PerformanceCallout(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
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
    final statusColor = switch (syncStatus) {
      SyncStatus.synced => colorScheme.secondary,
      SyncStatus.pending => colorScheme.primary,
      SyncStatus.offline => colorScheme.error,
    };

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  radius: 28,
                  child: Text(
                    name.isNotEmpty ? name.characters.first : '?',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(role),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(switch (syncStatus) {
                  SyncStatus.synced => 'Synced',
                  SyncStatus.pending => 'Pending changes',
                  SyncStatus.offline => 'Offline mode',
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: sampleSetLists.length,
        itemBuilder: (context, index) {
          final setList = sampleSetLists[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    SetlistScreen.routeName,
                    extra: setList,
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
                            setList.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {},
                            child: const Text('Open set list'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${setList.songCount} songs • ${setList.eventDate}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _SetListStatChip(
                            icon: Icons.timer_outlined,
                            label: '${setList.duration} total runtime',
                          ),
                          _SetListStatChip(
                            icon: Icons.devices_other_outlined,
                            label: '3 devices linked',
                          ),
                          _SetListStatChip(
                            icon: Icons.note_alt_outlined,
                            label: 'Intro with vamp • Bridge hold',
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
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final activity = sampleActivity[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(activity.initials),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.subtitle),
                  trailing: Text(activity.timestamp),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: sampleActivity.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song});

  final SampleSong song;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
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
                  Icon(Icons.music_note_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary),
                ],
              ),
              const Spacer(),
              Text(song.artist),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MiniChip(label: 'Key ${song.key}'),
                  _MiniChip(label: '${song.tempo} BPM'),
                  _MiniChip(label: song.tag),
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
