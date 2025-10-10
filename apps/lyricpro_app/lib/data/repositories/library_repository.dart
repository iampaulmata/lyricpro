import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/data/local/database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final databaseSeedProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await db.seedDemoContent();
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  ref.watch(databaseSeedProvider);
  return LibraryRepository(ref.watch(appDatabaseProvider));
});

final librarySongsProvider = StreamProvider<List<SongWithTags>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchSongs();
});

final songByIdProvider = StreamProvider.family<SongWithTags?, String>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchSong(id);
});

class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  Stream<List<SongWithTags>> watchSongs() {
    final query = _db.select(_db.songs).join([
      leftOuterJoin(
        _db.songTags,
        _db.songTags.songId.equalsExp(_db.songs.id),
      ),
      leftOuterJoin(
        _db.tags,
        _db.tags.id.equalsExp(_db.songTags.tagId),
      ),
    ]);

    return query.watch().map((rows) {
      final grouped = <String, List<_SongRow>>{};
      for (final row in rows) {
        final song = row.readTable(_db.songs);
        final tag = row.readTableOrNull(_db.tags);
        grouped.putIfAbsent(song.id, () => []).add(
              _SongRow(
                song: song,
                tag: tag,
              ),
            );
      }

      return grouped.values.map((group) {
        final song = group.first.song;
        final tags = group
            .map((row) => row.tag?.name)
            .nonNulls
            .toList(growable: false);
        return SongWithTags(song: song, tags: tags);
      }).toList(growable: false);
    });
  }

  Stream<SongWithTags?> watchSong(String id) {
    return watchSongs().map(
      (songs) => songs.firstWhereOrNull((song) => song.song.id == id),
    );
  }
}

class SongWithTags {
  const SongWithTags({
    required this.song,
    required this.tags,
  });

  final Song song;
  final List<String> tags;
}

class _SongRow {
  const _SongRow({
    required this.song,
    required this.tag,
  });

  final Song song;
  final Tag? tag;
}
