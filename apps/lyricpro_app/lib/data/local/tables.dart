import 'package:drift/drift.dart';

class Songs extends Table {
  @override
  String get tableName => 'songs';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get songKey => text().nullable()();
  IntColumn get tempo => integer().nullable()();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isOfflineAvailable =>
      boolean().withDefault(const Constant(false))();
  TextColumn get source => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  @override
  String get tableName => 'tags';

  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class SongTags extends Table {
  @override
  String get tableName => 'song_tags';

  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {songId, tagId};
}

class Setlists extends Table {
  @override
  String get tableName => 'setlists';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get eventDate => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SetlistEntries extends Table {
  @override
  String get tableName => 'setlist_entries';

  TextColumn get id => text()();
  TextColumn get setlistId =>
      text().references(Setlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get customKey => text().nullable()();
  IntColumn get customTempo => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum SyncOperation { create, update, delete }

class SyncQueueEntries extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // See SyncOperation
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isProcessing =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
