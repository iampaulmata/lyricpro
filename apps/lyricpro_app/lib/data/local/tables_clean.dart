import 'package:drift/drift.dart';

class SetLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get artist => text().nullable()();
  TextColumn get key => text().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}

class SetItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get setId => integer().customConstraint('REFERENCES set_lists(id)')();
  IntColumn get songId => integer().customConstraint('REFERENCES songs(id)')();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get overridesJson => text().nullable()();
}
