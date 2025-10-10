import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyricpro_app/data/local/database.dart';
import 'package:lyricpro_app/data/repositories/library_repository.dart';

final setlistRepositoryProvider = Provider<SetlistRepository>((ref) {
  ref.watch(databaseSeedProvider);
  return SetlistRepository(ref.watch(appDatabaseProvider));
});

final setlistsProvider = StreamProvider<List<SetlistSummary>>((ref) {
  return ref.watch(setlistRepositoryProvider).watchSetlists();
});

final setlistByIdProvider = StreamProvider.family<SetlistDetail?, String>((ref, id) {
  return ref.watch(setlistRepositoryProvider).watchSetlist(id);
});

class SetlistRepository {
  SetlistRepository(this._db);

  final AppDatabase _db;

  Stream<List<SetlistSummary>> watchSetlists() {
    return _db.select(_db.setlists).watch().asyncMap((rows) async {
      final entriesCounts = await (_db.select(_db.setlistEntries)
            ..where((tbl) => tbl.setlistId.isIn(rows.map((e) => e.id))))
          .get();
      return rows.map((setlist) {
        final count = entriesCounts
            .where((entry) => entry.setlistId == setlist.id)
            .length;
        return SetlistSummary(setlist: setlist, songCount: count);
      }).toList(growable: false);
    });
  }

  Stream<SetlistDetail?> watchSetlist(String id) {
    final query = (_db.select(_db.setlists)
          ..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();

    return query.asyncMap((setlist) async {
      if (setlist == null) return null;
      final entriesQuery = _db.select(_db.setlistEntries)
        ..where((tbl) => tbl.setlistId.equals(id))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);
      final entries = await entriesQuery.get();
      final songIds = entries.map((entry) => entry.songId).toSet();
      final songs = await (_db.select(_db.songs)
            ..where((tbl) => tbl.id.isIn(songIds)))
          .get();
      final songMap = {for (final song in songs) song.id: song};
      final items = entries
          .map(
            (entry) => SetlistItem(
              entry: entry,
              song: songMap[entry.songId],
            ),
          )
          .toList();
      return SetlistDetail(setlist: setlist, items: items);
    });
  }
}

class SetlistSummary {
  const SetlistSummary({
    required this.setlist,
    required this.songCount,
  });

  final Setlist setlist;
  final int songCount;
}

class SetlistDetail {
  const SetlistDetail({
    required this.setlist,
    required this.items,
  });

  final Setlist setlist;
  final List<SetlistItem> items;
}

class SetlistItem {
  const SetlistItem({
    required this.entry,
    required this.song,
  });

  final SetlistEntry entry;
  final Song? song;
}
