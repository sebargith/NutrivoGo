import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

const _platformChannel = MethodChannel('nutrivogo/platform');

@DataClassName('ProductRow')
class ProductRows extends Table {
  @override
  String get tableName => 'products';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get servingSize => real().nullable()();
  TextColumn get servingUnit => text().nullable()();
  TextColumn get baseUnit => text()();
  RealColumn get caloriesPer100 => real()();
  RealColumn get proteinPer100 => real()();
  RealColumn get carbsPer100 => real()();
  RealColumn get fatPer100 => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LogItemRow')
class LogItemRows extends Table {
  @override
  String get tableName => 'log_items';

  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get mealType => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [ProductRows, LogItemRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.connect(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(productRows, productRows.userId);
        await migrator.addColumn(productRows, productRows.syncStatus);
        await migrator.addColumn(productRows, productRows.lastSyncedAt);
        await migrator.addColumn(logItemRows, logItemRows.userId);
        await migrator.addColumn(logItemRows, logItemRows.syncStatus);
        await migrator.addColumn(logItemRows, logItemRows.lastSyncedAt);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await _databaseDirectory();
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, 'nutrivogo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

Future<Directory> _databaseDirectory() async {
  if (Platform.isAndroid) {
    final directoryPath = await _platformChannel.invokeMethod<String>(
      'applicationSupportDirectory',
    );
    if (directoryPath == null || directoryPath.isEmpty) {
      throw StateError('Android application directory was not available.');
    }
    return Directory(directoryPath);
  }

  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    final localAppData = Platform.environment['LOCALAPPDATA'];
    final basePath = appData ?? localAppData ?? Directory.current.path;
    return Directory(p.join(basePath, 'NutrivoGo'));
  }

  final home = Platform.environment['HOME'];
  if (home != null && home.isNotEmpty) {
    return Directory(p.join(home, '.nutrivogo'));
  }

  return Directory(p.join(Directory.current.path, '.nutrivogo'));
}
