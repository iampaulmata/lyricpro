import 'package:flutter/material.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  static const String routeName = 'performance';

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _autoScroll = true;
  double _scrollSpeed = 0.4;
  bool _showChords = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _TeleprompterView(showChords: _showChords),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _BottomDock(
                    autoScroll: _autoScroll,
                    scrollSpeed: _scrollSpeed,
                    onAutoScrollChanged: (value) {
                      setState(() => _autoScroll = value);
                    },
                    onSpeedChanged: (value) {
                      setState(() => _scrollSpeed = value);
                    },
                    onToggleChords: () {
                      setState(() => _showChords = !_showChords);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _TopOverlay(
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Higher Ground',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Set: Blue Note Evening • Song 01/12',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            _StatusChip(label: 'Key Bb', icon: Icons.music_note),
            const SizedBox(width: 12),
            _StatusChip(label: 'Capo 2', icon: Icons.solar_power),
            const SizedBox(width: 12),
            _StatusChip(label: '98 BPM', icon: Icons.timer),
            const SizedBox(width: 12),
            _StatusDot(status: _PerformanceStatus.master),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              icon: const Icon(Icons.note_outlined),
              label: const Text('Notes'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              icon: const Icon(Icons.queue_music_outlined),
              label: const Text('Sections'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PerformanceStatus { master, follower, offline }

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final _PerformanceStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      _PerformanceStatus.master => Colors.greenAccent,
      _PerformanceStatus.follower => Colors.blueAccent,
      _PerformanceStatus.offline => Colors.orangeAccent,
    };

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          switch (status) {
            _PerformanceStatus.master => 'Master',
            _PerformanceStatus.follower => 'Following',
            _PerformanceStatus.offline => 'Offline',
          },
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white70, size: 16),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _TeleprompterView extends StatelessWidget {
  const _TeleprompterView({required this.showChords});

  final bool showChords;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[Verse 1]',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          _TeleprompterLine(
            lyrics: 'Amazing grace, how sweet the sound',
            chords: showChords ? const ['Bb', 'F', 'Gm', 'Eb'] : null,
          ),
          const SizedBox(height: 12),
          _TeleprompterLine(
            lyrics: 'That saved a wretch like me',
            chords: showChords ? const ['Bb', 'F', 'Bb'] : null,
          ),
          const SizedBox(height: 32),
          Text(
            '[Chorus]',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          _TeleprompterLine(
            lyrics: 'I once was lost but now I’m found',
            chords: showChords ? const ['Gm', 'Bb', 'F'] : null,
          ),
          const SizedBox(height: 12),
          _TeleprompterLine(
            lyrics: 'Was blind but now I see',
            chords: showChords ? const ['Eb', 'Bb'] : null,
          ),
        ],
      ),
    );
  }
}

class _TeleprompterLine extends StatelessWidget {
  const _TeleprompterLine({required this.lyrics, this.chords});

  final String lyrics;
  final List<String>? chords;

  @override
  Widget build(BuildContext context) {
    final chordStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chords != null)
          Wrap(
            spacing: 16,
            children: chords!
                .map(
                  (chord) => Text(
                    chord,
                    style: chordStyle,
                  ),
                )
                .toList(),
          ),
        if (chords != null) const SizedBox(height: 6),
        Text(
          lyrics,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.autoScroll,
    required this.scrollSpeed,
    required this.onAutoScrollChanged,
    required this.onSpeedChanged,
    required this.onToggleChords,
  });

  final bool autoScroll;
  final double scrollSpeed;
  final ValueChanged<bool> onAutoScrollChanged;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleChords;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: autoScroll,
                  onChanged: onAutoScrollChanged,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Auto-scroll',
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                _FollowerStatus(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Speed', style: TextStyle(color: Colors.white70)),
                Expanded(
                  child: Slider(
                    value: scrollSpeed,
                    onChanged: onSpeedChanged,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onToggleChords,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                  ),
                  icon: const Icon(Icons.piano),
                  label: const Text('Toggle chords'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: const [
                _PedalBindingChip(number: 1, label: 'Next section'),
                _PedalBindingChip(number: 2, label: 'Toggle scroll'),
                _PedalBindingChip(number: 3, label: 'Metronome'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowerStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.devices_other, color: Colors.white70),
        SizedBox(width: 6),
        Text(
          '3 devices • 2 synced, 1 reconnecting',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _PedalBindingChip extends StatelessWidget {
  const _PedalBindingChip({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        child: Text(number.toString()),
      ),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.white12,
    );
  }
}
