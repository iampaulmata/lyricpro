import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFolder = Directory(p.join(dir.path, 'lyricpro'));
    if (!await dbFolder.exists()) await dbFolder.create(recursive: true);
    final file = File(p.join(dbFolder.path, 'lyricpro.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [
  Songs,
  Tags,
  SongTags,
  Setlists,
  SetlistEntries,
  SyncQueueEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> seedDemoContent() async {
    final existingSongs = await select(songs).get();
    if (existingSongs.isNotEmpty) return;

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

      await into(songTags).insert(SongTagsCompanion.insert(songId: 'song-1', tagId: 'tag-1'));
      await into(songTags).insert(SongTagsCompanion.insert(songId: 'song-2', tagId: 'tag-2'));

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

  // Create a new setlist with a generated id
  Future<String> createSetlist(String title, {String? id}) async {
    final sid = id ?? 'setlist-${DateTime.now().microsecondsSinceEpoch}';
    await into(setlists).insert(SetlistsCompanion.insert(id: sid, title: title));
    return sid;
  }

  // Add a song to a setlist (creates a SetlistEntry)
  Future<String> addSongToSetlist(String setlistId, String songId,
      {String? entryId, int? position, String? customKey, int? customTempo, String? notes}) async {
    final id = entryId ?? 'entry-${DateTime.now().microsecondsSinceEpoch}';
    // determine next position if not provided
    final existing = await (select(setlistEntries)..where((t) => t.setlistId.equals(setlistId))).get();
    final nextPos = position ?? (existing.isEmpty ? 0 : (existing.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1));
    await into(setlistEntries).insert(SetlistEntriesCompanion.insert(
      id: id,
      setlistId: setlistId,
      songId: songId,
      position: nextPos,
      customKey: Value(customKey),
      customTempo: Value(customTempo),
      notes: Value(notes),
    ));
    return id;
  }

  // Remove an entry and shift positions
  Future<void> removeSetlistEntry(String entryId) async {
    await transaction(() async {
      final entry = await (select(setlistEntries)..where((t) => t.id.equals(entryId))).getSingle();
      final sid = entry.setlistId;
      final pos = entry.position;
      await (delete(setlistEntries)..where((t) => t.id.equals(entryId))).go();
      // decrement positions greater than pos
      await customStatement('UPDATE setlist_entries SET position = position - 1 WHERE setlist_id = ? AND position > ?', [sid, pos]);
    });
  }

  // Move an entry within a setlist, shifting other entries accordingly
  Future<void> moveSetlistEntry(String entryId, int newPosition) async {
    await transaction(() async {
      final entry = await (select(setlistEntries)..where((t) => t.id.equals(entryId))).getSingle();
      final sid = entry.setlistId;
      final oldPos = entry.position;
      if (oldPos == newPosition) return;

      if (newPosition < oldPos) {
        // shift items in [newPosition, oldPos-1] up by 1
        await customStatement('UPDATE setlist_entries SET position = position + 1 WHERE setlist_id = ? AND position >= ? AND position < ?', [sid, newPosition, oldPos]);
      } else {
        // shift items in [oldPos+1, newPosition] down by 1
        await customStatement('UPDATE setlist_entries SET position = position - 1 WHERE setlist_id = ? AND position > ? AND position <= ?', [sid, oldPos, newPosition]);
      }

      // set entry to new position
      await (update(setlistEntries)..where((t) => t.id.equals(entryId))).write(SetlistEntriesCompanion(position: Value(newPosition)));
    });
  }
}