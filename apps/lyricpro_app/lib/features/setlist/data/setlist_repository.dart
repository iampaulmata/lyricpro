import 'package:drift/drift.dart';
import 'package:lyricpro_app/data/local/database.dart';

class SetListRepository {
  final AppDatabase db;
  SetListRepository(this.db);

  Future<int> createSet(String name) => db.createSetList(name);
  Stream<List<SetList>> watchSetLists() => db.watchAllSetLists();
  Future<List<SetList>> getSetLists() => db.getAllSetLists();
}
