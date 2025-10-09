class SampleSetList {
  const SampleSetList({
    required this.id,
    required this.title,
    required this.songCount,
    required this.duration,
    required this.eventDate,
    required this.notes,
    required this.songs,
  });

  final String id;
  final String title;
  final int songCount;
  final String duration;
  final String eventDate;
  final String notes;
  final List<SampleSong> songs;
}

class SampleSong {
  const SampleSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.key,
    required this.tempo,
    required this.tag,
    required this.duration,
  });

  final String id;
  final String title;
  final String artist;
  final String key;
  final int tempo;
  final String tag;
  final String duration;
}

class SampleActivity {
  const SampleActivity({
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

const List<String> sampleTags = [
  'Rock',
  'Worship',
  'Acoustic',
  'Encore',
];

const List<SampleSong> sampleSongs = [
  SampleSong(
    id: 'song-1',
    title: 'Higher Ground',
    artist: 'Traditional',
    key: 'Bb',
    tempo: 98,
    tag: 'Gospel',
    duration: '04:10',
  ),
  SampleSong(
    id: 'song-2',
    title: 'Firelight',
    artist: 'Young & Radiant',
    key: 'G',
    tempo: 104,
    tag: 'Indie',
    duration: '03:45',
  ),
  SampleSong(
    id: 'song-3',
    title: 'Silent Night',
    artist: 'Traditional',
    key: 'Dm',
    tempo: 72,
    tag: 'Seasonal',
    duration: '05:05',
  ),
  SampleSong(
    id: 'song-4',
    title: 'Breakthrough',
    artist: 'Jamie Cross',
    key: 'A',
    tempo: 110,
    tag: 'Pop',
    duration: '04:00',
  ),
  SampleSong(
    id: 'song-5',
    title: 'River Flow',
    artist: 'Alex Rivera',
    key: 'E',
    tempo: 120,
    tag: 'Rock',
    duration: '03:58',
  ),
  SampleSong(
    id: 'song-6',
    title: 'Still Waters',
    artist: 'Morgan Blake',
    key: 'C',
    tempo: 82,
    tag: 'Acoustic',
    duration: '04:25',
  ),
  SampleSong(
    id: 'song-7',
    title: 'Midnight Drive',
    artist: 'Jamie Cross',
    key: 'F#',
    tempo: 112,
    tag: 'Synthwave',
    duration: '03:40',
  ),
  SampleSong(
    id: 'song-8',
    title: 'Golden Hour',
    artist: 'Young & Radiant',
    key: 'D',
    tempo: 95,
    tag: 'Pop',
    duration: '04:12',
  ),
];

const List<SampleSetList> sampleSetLists = [
  SampleSetList(
    id: 'setlist-1',
    title: 'Tonight @ The Blue Note',
    songCount: 12,
    duration: '52m',
    eventDate: 'Fri • 9:30 PM',
    notes: 'Intro vamp over Bb • Bridge hold for choir entrance',
    songs: sampleSongs,
  ),
  SampleSetList(
    id: 'setlist-2',
    title: 'Sunday Morning Acoustic',
    songCount: 8,
    duration: '38m',
    eventDate: 'Sun • 11:00 AM',
    notes: 'Keep dynamics soft; transition to spoken word after song 4',
    songs: sampleSongs,
  ),
];

const List<SampleActivity> sampleActivity = [
  SampleActivity(
    initials: 'AR',
    title: 'Alex updated “Higher Ground”',
    subtitle: 'Adjusted bridge chords + capo',
    timestamp: '5m ago',
  ),
  SampleActivity(
    initials: 'JC',
    title: 'Jamie shared “Firelight”',
    subtitle: 'Added to shared collection',
    timestamp: '42m ago',
  ),
  SampleActivity(
    initials: 'MB',
    title: 'Morgan synced Sunday Morning Acoustic',
    subtitle: '2 devices pending update',
    timestamp: '1h ago',
  ),
];
