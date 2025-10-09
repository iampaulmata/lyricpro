import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/core/theme_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<_SettingsSection> sections = [
      _SettingsSection(
        title: 'General',
        builder: (context, ref) => const _GeneralSettings(),
      ),
      _SettingsSection(
        title: 'Themes & Display',
        builder: (context, ref) => const _ThemeSettings(),
      ),
      _SettingsSection(
        title: 'Sync & Storage',
        builder: (context, ref) => const _SyncSettings(),
      ),
      _SettingsSection(
        title: 'Hardware & Pedals',
        builder: (context, ref) => const _HardwareSettings(),
      ),
      _SettingsSection(
        title: 'Accessibility',
        builder: (context, ref) => const _AccessibilitySettings(),
      ),
      _SettingsSection(
        title: 'About & Support',
        builder: (context, ref) => const _AboutSettings(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useRail = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (useRail)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final entry in sections)
                        NavigationRailDestination(
                          icon: const Icon(Icons.circle_outlined),
                          selectedIcon: const Icon(Icons.check_circle_outline),
                          label: Text(entry.title),
                        ),
                    ],
                  )
                else
                  Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        final bool selected = index == _selectedIndex;
                        return ListTile(
                          title: Text(sections[index].title),
                          selected: selected,
                          onTap: () {
                            setState(() => _selectedIndex = index);
                          },
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Padding(
                      key: ValueKey(_selectedIndex),
                      padding: const EdgeInsets.all(32),
                      child: sections[_selectedIndex].builder(context, ref),
                    ),
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

class _SettingsSection {
  const _SettingsSection({required this.title, required this.builder});

  final String title;
  final Widget Function(BuildContext context, WidgetRef ref) builder;
}

class _GeneralSettings extends ConsumerWidget {
  const _GeneralSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _SettingsCard(
          title: 'Account',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Text('AR')),
                title: const Text('Alex Rivera'),
                subtitle: const Text('alex.rivera@example.com'),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Manage account'),
                ),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: true,
                onChanged: (_) {},
                title: const Text('Remember my last login'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: false,
                onChanged: (_) {},
                title: const Text('Offline mode (view only)'),
              ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Language',
          child: DropdownButtonFormField<String>(
            initialValue: 'English',
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Spanish', child: Text('Spanish (coming soon)')),
            ],
            onChanged: (_) {},
            decoration: const InputDecoration(
              labelText: 'Preferred language',
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeSettings extends ConsumerWidget {
  const _ThemeSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    return ListView(
      children: [
        _SettingsCard(
          title: 'Theme mode',
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              themeController.themeMode = selection.first;
            },
          ),
        ),
        _SettingsCard(
          title: 'Accent color',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in _accentPalette)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white,
                        width: color == _accentPalette.first ? 3 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Performance layout',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _PresetChip(label: 'Lyrics focus', icon: Icons.text_fields, isActive: true),
              _PresetChip(label: 'Chords focus', icon: Icons.piano),
              _PresetChip(label: 'Mixed', icon: Icons.dashboard_customize_outlined),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyncSettings extends StatefulWidget {
  const _SyncSettings();

  @override
  State<_SyncSettings> createState() => _SyncSettingsState();
}

class _SyncSettingsState extends State<_SyncSettings> {
  String _syncMode = 'automatic';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SettingsCard(
          title: 'Sync mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'automatic',
                    label: Text('Automatic'),
                    icon: Icon(Icons.auto_mode),
                  ),
                  ButtonSegment(
                    value: 'manual',
                    label: Text('Manual'),
                    icon: Icon(Icons.schedule),
                  ),
                ],
                selected: {_syncMode},
                onSelectionChanged: (selection) {
                  setState(() => _syncMode = selection.first);
                },
              ),
              const SizedBox(height: 12),
              Text(
                _syncMode == 'automatic'
                    ? 'Sync when connected to Wi-Fi or cellular data.'
                    : 'Trigger sync manually after shows.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Sync now'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('View queue'),
                  ),
                  const Spacer(),
                  const Text('Last sync • 5 minutes ago'),
                ],
              ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Storage',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_outlined),
                title: Text('Google Drive linked'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.storage_outlined),
                title: Text('Offline library'),
                subtitle: Text('2.3 GB • 134 songs downloaded'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HardwareSettings extends StatelessWidget {
  const _HardwareSettings();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SettingsCard(
          title: 'Connected devices',
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.settings_remote_outlined),
                title: Text('AirTurn Duo'),
                subtitle: Text('Pedal • Connected'),
                trailing: Text('Battery 85%'),
              ),
              ListTile(
                leading: Icon(Icons.piano),
                title: Text('MIDI Footswitch'),
                subtitle: Text('3 bindings active'),
              ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Pedal bindings',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _PedalBindingCard(number: 1, label: 'Next section'),
                  _PedalBindingCard(number: 2, label: 'Toggle scroll'),
                  _PedalBindingCard(number: 3, label: 'Metronome'),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Customize bindings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessibilitySettings extends StatelessWidget {
  const _AccessibilitySettings();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SettingsCard(
          title: 'Text scaling',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: 1.0,
                min: 0.8,
                max: 1.4,
                divisions: 6,
                onChanged: (_) {},
              ),
              const Text('Stage font size preview'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: const Text(
                  'Amazing grace, how sweet the sound',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Accessibility options',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: true,
                onChanged: (_) {},
                title: const Text('Dyslexic-friendly font'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: true,
                onChanged: (_) {},
                title: const Text('Screen reader hints'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: false,
                onChanged: (_) {},
                title: const Text('Pedal-only navigation'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutSettings extends StatelessWidget {
  const _AboutSettings();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SettingsCard(
          title: 'LyricPro',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version 0.1.0',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'An open-source lyric and chord management tool for live performers.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Release notes'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Documentation'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Report an issue'),
                  ),
                ],
              ),
            ],
          ),
        ),
        _SettingsCard(
          title: 'Community',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.forum_outlined),
                title: Text('Discussions'),
                subtitle: Text('Connect with other performers and contributors'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.volunteer_activism_outlined),
                title: Text('Contribute'),
                subtitle: Text('Help build new features and integrations'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: isActive,
      onSelected: (_) {},
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
    );
  }
}

class _PedalBindingCard extends StatelessWidget {
  const _PedalBindingCard({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            child: Text(number.toString()),
          ),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

const List<Color> _accentPalette = [
  Color(0xFFFF8A3D),
  Color(0xFF1EB980),
  Color(0xFF136F63),
  Color(0xFF8E30FF),
  Color(0xFF14B8A6),
  Color(0xFF3B82F6),
];
