import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Songs,
    Tags,
    SongTags,
    Setlists,
    SetlistEntries,
    SyncQueueEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> seedDemoContent() async {
    final existingCount = await (select(songs).get()).then((rows) => rows.length);
    if (existingCount > 0) return;

    await transaction(() async {
      await into(songs).insert(
        SongsCompanion.insert(
          id: 'song-1',
          title: 'Higher Ground',
          artist: const Value('Traditional'),
          content: const Value('[Bb]Amazing [F]grace how [Gm]sweet the [Eb]sound'),
          songKey: const Value('Bb'),
          tempo: const Value(98),
          isOfflineAvailable: const Value(true),
        ),
      );

      await into(songs).insert(
        SongsCompanion.insert(
          id: 'song-2',
          title: 'Firelight',
          artist: const Value('Young & Radiant'),
          content: const Value('[G]Light up the [D]night we [Em]rise'),
          songKey: const Value('G'),
          tempo: const Value(104),
        ),
      );

      await into(tags).insert(TagsCompanion.insert(id: 'tag-1', name: 'Gospel'));
      await into(tags).insert(TagsCompanion.insert(id: 'tag-2', name: 'Indie'));

      await into(songTags)
          .insert(SongTagsCompanion.insert(songId: 'song-1', tagId: 'tag-1'));
      await into(songTags)
          .insert(SongTagsCompanion.insert(songId: 'song-2', tagId: 'tag-2'));

      await into(setlists).insert(
        SetlistsCompanion.insert(
          id: 'setlist-1',
          title: 'Tonight @ The Blue Note',
          notes: const Value('Intro vamp over Bb • Bridge hold'),
          eventDate: Value(DateTime.now().add(const Duration(days: 3))),
        ),
      );

      await into(setlistEntries).insert(
        SetlistEntriesCompanion.insert(
          id: 'entry-1',
          setlistId: 'setlist-1',
          songId: 'song-1',
          position: 0,
          notes: const Value('Open with swell'),
        ),
      );

      await into(setlistEntries).insert(
        SetlistEntriesCompanion.insert(
          id: 'entry-2',
          setlistId: 'setlist-1',
          songId: 'song-2',
          position: 1,
        ),
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lyricpro.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
