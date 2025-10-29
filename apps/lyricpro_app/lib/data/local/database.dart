import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbFolder = Directory(p.join(documentsDirectory.path, 'lyricpro'));
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'lyricpro.sqlite'));
    return NativeDatabase.open(file);
  });
}

@DriftDatabase(tables: [SetLists, Songs, SetItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // SetList CRUD
  Future<int> createSetList(String name) => into(setLists).insert(SetListsCompanion(
        name: Value(name),
      ));

  Future<List<SetList>> getAllSetLists() => select(setLists).get();
  Stream<List<SetList>> watchAllSetLists() => select(setLists).watch();

  // Songs
  Future<int> createSong(Insertable<Song> song) => into(songs).insert(song);

  // Set items
  Future<int> addSongToSet(int setId, int songId) async {
    final maxPos = await (select(setItems)..where((t) => t.setId.equals(setId))).get();
    final nextPos = maxPos.isEmpty ? 0 : (maxPos.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1);
    return into(setItems).insert(SetItemsCompanion(
      setId: Value(setId),
      songId: Value(songId),
      position: Value(nextPos),
    ));
  }

  Future<List<SetItem>> getItemsForSet(int setId) => (select(setItems)..where((t) => t.setId.equals(setId))..orderBy([(t) => OrderingTerm(expression: t.position)])).get();

  Future<void> reorderItem(int itemId, int newPosition) async {
    // naive reorder: update the item position
    await (update(setItems)..where((t) => t.id.equals(itemId))).write(SetItemsCompanion(position: Value(newPosition)));
  }
}